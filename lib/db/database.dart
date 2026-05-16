import "dart:io";

import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";
import "package:fpdart/fpdart.dart";
import "package:path_provider/path_provider.dart";

part "database.g.dart";

@TableIndex(name: "artist_name_idx", columns: {#name})
class Artist extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get last_gallery_id => integer()();
  TextColumn get name => text().unique()();
  TextColumn get url => text().unique()();
}

@TableIndex(name: "tag_name_idx", columns: {#name})
class Tag extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

@TableIndex(name: "artist_tag_artist_tag_idx", columns: {#artist, #tag})
@TableIndex(name: "artist_tag_tag_idx", columns: {#tag})
@TableIndex(name: "artist_tag_artist_idx", columns: {#artist})
class ArtistTag extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get image_path => text().nullable()();
  IntColumn get artist => integer().references(Artist, #id)();
  IntColumn get tag => integer().references(Tag, #id)();
}

@TableIndex(name: "artist_url_artist_idx", columns: {#artist})
class ArtistUrl extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get artist => integer().references(Artist, #id)();
  TextColumn get url => text()();
}

class ArtistStreamItem {
  final int id;
  final int last_gallery_id;
  final String name;
  final String main_url;

  final Set<(String, String?)> tags = {};
  final Set<String> urls = {};

  ArtistStreamItem(this.id, this.last_gallery_id, this.name, this.main_url);
}

@DriftDatabase(tables: [Artist, Tag, ArtistTag, ArtistUrl])
class Database extends _$Database {
  Database() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: "database",
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }

  Stream<List<ArtistStreamItem>> get_artist_stream() {
    final query = customSelect(
      '''
    SELECT 
      a.id,
      a.url,
      a.last_gallery_id,
      a.name,
      t.name AS tag_name,
      at.image_path AS tag_image_path,
      au.url AS work_url
    FROM artist a
    LEFT JOIN artist_tag at ON a.id = at.artist
    LEFT JOIN tag t ON at.tag = t.id
    LEFT JOIN artist_url au ON a.id = au.artist
    ORDER BY a.id
    ''',
      // Indica a drift qué tablas se leen para que el stream se actualice
      // cuando cualquiera de ellas cambie
      readsFrom: {artist, artistTag, tag, artistUrl},
    ).watch();

    return query.map((rows) {
      final Map<int, ArtistStreamItem> items = {};

      for (final row in rows) {
        final id = row.read<int>('id');
        final main_url = row.read<String>('url');
        final lastGalleryId = row.read<int>('last_gallery_id');
        final name = row.read<String>('name');
        final tagName = row.read<String?>('tag_name');
        final tagImagePath = row.read<String?>('tag_image_path');
        final work_url = row.read<String?>('work_url');

        // Obtiene o crea el acumulador para este artista
        final acc = items.putIfAbsent(
          id,
          () => ArtistStreamItem(id, lastGalleryId, name, main_url),
        );

        // Agrega el tag si existe
        if (tagName != null) {
          acc.tags.add((tagName, tagImagePath));
        }
        // Agrega la URL si existe
        if (work_url != null) {
          acc.urls.add(work_url);
        }
      }

      return items.values.toList();
    });
  }

  Future<List<String>> find_tags(String query) {
    final select = customSelect(
      '''
    SELECT name
    FROM tag
    WHERE name LIKE ?
    ''',
      variables: [Variable.withString("%$query%")],
      readsFrom: {tag},
    );

    return select.map((x) => x.read<String>("name")).get();
  }

  Future<bool> does_exist_artist(String name) async {
    final existing = await (select(
      artist,
    )..where((a) => a.name.equals(name))).getSingleOrNull();
    return existing != null;
  }

  TaskEither<String, Unit> insert_artist(
    ArtistCompanion artist,
    Map<String, Option<Uint8List>> tags,
    List<String> urls,
  ) {
    return TaskEither.Do(($) async {
      // Get documents directory
      final documents = await $(
        TaskEither.tryCatch(
          getApplicationDocumentsDirectory,
          (e, _) => "Failed to get documents directory: $e",
        ),
      );

      // Get images directory
      final images_dir = Directory("${documents.path}/images");
      await $(
        TaskEither.tryCatch(() async {
          if (!await images_dir.exists()) {
            await images_dir.create(recursive: true);
          }

          return images_dir.path;
        }, (e, _) => "Failed to create images directory: $e"),
      );

      // Creating artist
      final artist_id = await upsert_artist(artist);
      final image_futures = <Future<void>>[];

      // Assuming that File creation and deletion won't throw any exception
      for (final entry in tags.entries) {
        final tag_id = await find_or_create_tag(entry.key);

        final filename = "${artist.name.value}_${entry.key}";
        final file = File("${images_dir.path}/$filename");

        final buffer = entry.value.toNullable();
        if (buffer != null) {
          image_futures.add(file.writeAsBytes(buffer));
        }

        if (await upsert_artist_tag(
          artist_id,
          tag_id,
          buffer != null ? file.path : null,
        )) {
          image_futures.add(file.delete());
        }
      }

      // Elimina si el ArtistTag ya no debería existir
      final existing_tags = await get_existing_artist_tags(artist_id);
      for (final existing in existing_tags) {
        if (!tags.containsKey(existing.$1)) {
          final image_path = existing.$2.image_path;
          if (image_path != null) {
            image_futures.add(File(image_path).delete());
          }
          await delete_artist_tag_and_posibly_tag(
            existing.$2.id,
            existing.$2.tag,
          );
        }
      }

      await Future.wait(image_futures);

      return unit;
    });
  }

  Future<int> upsert_artist(ArtistCompanion companion) async {
    final existing = await (select(
      artist,
    )..where((a) => a.name.equals(companion.name.value))).getSingleOrNull();
    if (existing != null) {
      await update(artist).replace(
        existing.copyWith(last_gallery_id: companion.last_gallery_id.value),
      );
      return existing.id;
    }

    return await into(artist).insert(companion);
  }

  Future<int> find_or_create_tag(String name) async {
    final existing = await (select(
      tag,
    )..where((t) => t.name.equals(name))).getSingleOrNull();

    if (existing != null) {
      return existing.id;
    }

    return await into(tag).insert(TagCompanion(name: Value(name)));
  }

  Future<bool /*should delete image?*/> upsert_artist_tag(
    int artist_id,
    int tag_id,
    String? image_path,
  ) async {
    final existing =
        await (select(artistTag)..where(
              (at) => at.artist.equals(artist_id) & at.tag.equals(tag_id),
            ))
            .getSingleOrNull();
    if (existing != null) {
      await update(
        artistTag,
      ).replace(existing.copyWith(image_path: Value(image_path)));
    } else {
      await into(artistTag).insert(
        ArtistTagCompanion(
          artist: Value(artist_id),
          tag: Value(tag_id),
          image_path: Value(image_path),
        ),
      );
    }

    return existing?.image_path != null && image_path == null;
  }

  Future<List<(String, ArtistTagData)>> get_existing_artist_tags(
    int artist_id,
  ) async {
    final rows =
        await (select(artistTag)..where((at) => at.artist.equals(artist_id)))
            .join([innerJoin(tag, tag.id.equalsExp(artistTag.tag))])
            .get();

    final result = <(String, ArtistTagData)>[];
    for (final row in rows) {
      final _artist_tag = row.readTable(artistTag);
      final _tag = row.readTable(tag);
      result.add((_tag.name, _artist_tag));
    }

    return result;
  }

  Future<void> delete_artist_tag_and_posibly_tag(
    int artist_tag_id,
    int tag_id,
  ) async {
    await transaction(() async {
      await (delete(artistTag)..where((t) => t.id.equals(artist_tag_id))).go();

      final remaining = await (select(
        artistTag,
      )..where((t) => t.tag.equals(tag_id))).get();

      if (remaining.isEmpty) {
        await (delete(tag)..where((t) => t.id.equals(tag_id))).go();
      }
    });
  }

  Future<bool> delete_artist(int artist_id) async {
    // 1. Obtener todos los ArtistTag de este artista (para tener las rutas de las imágenes)
    final artistTags = await (select(
      artistTag,
    )..where((at) => at.artist.equals(artist_id))).get();

    // 2. Eliminar los archivos de imagen asociados a cada ArtistTag (si existen)
    for (final at in artistTags) {
      final imagePath = at.image_path;
      if (imagePath != null) {
        try {
          await File(imagePath).delete();
        } catch (_) {
          // Si falla la eliminación del archivo, no interrumpimos la operación
        }
      }
    }

    // 3. Transacción: eliminar registros de la base de datos
    await transaction(() async {
      // 3.1 Eliminar cada ArtistTag y, si procede, el Tag huérfano
      for (final at in artistTags) {
        await delete_artist_tag_and_posibly_tag(at.id, at.tag);
      }

      // 3.2 Eliminar todas las URLs del artista
      await (delete(
        artistUrl,
      )..where((au) => au.artist.equals(artist_id))).go();

      // 3.3 Eliminar el artista
      await (delete(artist)..where((a) => a.id.equals(artist_id))).go();
    });

    return true;
  }
}
