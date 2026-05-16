import "dart:io";

import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";
import "package:fpdart/fpdart.dart";
import "package:path_provider/path_provider.dart";

import "package:flutter/material.dart" as m; // FIXME: Delete this

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
      final artist_id = await find_or_create_artist(artist);
      final image_futures = <Future<void>>[];

      // Assuming that File creation and deletion won't throw any exception
      for (final entry in tags.entries) {
        final tag_id = await find_or_create_tag(entry.key);

        final filename = "${artist.name.value}_${entry.key}";
        final file = File("${images_dir.path}/$filename");

        final buffer = entry.value.toNullable();
        if (buffer != null) {
          m.debugPrint("Writing buffer in ${file.path}");
          //image_futures.add(file.writeAsBytes(buffer));
        }

        if (await upsert_artist_tag(
          artist_id,
          tag_id,
          buffer != null ? file.path : null,
        )) {
          //image_futures.add(file.delete());
          m.debugPrint("Deleting buffer in ${file.path}");
        }
      }

      // Elimina si el ArtistTag ya no debería existir
      final existing_tags = await get_existing_artist_tags(artist_id);
      for (final existing in existing_tags) {
        if (!tags.containsKey(existing.$1)) {
          m.debugPrint("Deleting artist_tag=${existing.$2.id} and posibly tag=${existing.$2.tag}");
          final image_path = existing.$2.image_path;
          if (image_path != null) {
            m.debugPrint("Deleting image in ${image_path}");
            //image_futures.add(File(image_path).delete());
          }
          await delete_artist_tag_and_posibly_tag(existing.$2.id, existing.$2.tag);
        }
      }

      await Future.wait(image_futures);

      return unit;
    });
  }

  Future<int> find_or_create_artist(ArtistCompanion companion) async {
    final existing = await (select(
      artist,
    )..where((a) => a.name.equals(companion.name.value))).getSingleOrNull();
    if (existing != null) {
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

  Future<void> delete_artist_tag_and_posibly_tag(int artist_tag_id, int tag_id) async {
    await transaction(() async {
      await (delete(artistTag)..where((t) => t.id.equals(artist_tag_id))).go();

      final remaining = await (select(
        artistTag,
      )..where((t) => t.tag.equals(tag_id))).get();

      if (remaining.isEmpty) {
        await (delete(tag)..where((t) => t.id.equals(tag_id))).go();
        m.debugPrint("Deleting tag=$tag_id");
      }
    });
  }
}
