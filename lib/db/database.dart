import "package:drift/drift.dart";
import "package:drift_flutter/drift_flutter.dart";
import "package:path_provider/path_provider.dart";

part "database.g.dart";

class Artist extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class Tag extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class ArtistTag extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get image_path => text().nullable()();
  IntColumn get artist => integer().references(Artist, #id)();
  IntColumn get tag => integer().references(Tag, #id)();
}

class ArtistUrl extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get artist => integer().references(Artist, #id)();
  TextColumn get url => text()();
}

@DriftDatabase(tables: [Artist, Tag, ArtistTag, ArtistUrl])
class Database extends _$Database {
  Database() : super(_openConnection());

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();

      await customStatement('''
      CREATE VIRTUAL TABLE artist_fts
      USING fts5(
        name,
        content='artist',
        content_rowid='id'
      );
    ''');

      await customStatement('''
      CREATE TRIGGER artist_ai
      AFTER INSERT ON artist
      BEGIN
        INSERT INTO artist_fts(rowid, name)
        VALUES (new.id, new.name);
      END;
    ''');

      await customStatement('''
      CREATE TRIGGER artist_ad
      AFTER DELETE ON artist
      BEGIN
        INSERT INTO artist_fts(artist_fts, rowid, name)
        VALUES('delete', old.id, old.name);
      END;
    ''');

      await customStatement('''
      CREATE TRIGGER artist_au
      AFTER UPDATE ON artist
      BEGIN
        INSERT INTO artist_fts(artist_fts, rowid, name)
        VALUES('delete', old.id, old.name);

        INSERT INTO artist_fts(rowid, name)
        VALUES(new.id, new.name);
      END;
    ''');

      await customStatement("""
      CREATE VIRTUAL TABLE tag_fts USING fts5(
        name,
        content='tag',
        content_rowid='id'
      );

      """);

      await customStatement('''
      CREATE TRIGGER tag_ai
      AFTER INSERT ON tag
      BEGIN
        INSERT INTO tag_fts(rowid, name)
        VALUES (new.id, new.name);
      END;
    ''');

      await customStatement('''
      CREATE TRIGGER tag_ad
      AFTER DELETE ON tag
      BEGIN
        INSERT INTO tag_fts(tag_fts, rowid, name)
        VALUES('delete', old.id, old.name);
      END;
    ''');

      await customStatement('''
      CREATE TRIGGER tag_au
      AFTER UPDATE ON tag
      BEGIN
        INSERT INTO tag_fts(tag_fts, rowid, name)
        VALUES('delete', old.id, old.name);

        INSERT INTO tag_fts(rowid, name)
        VALUES(new.id, new.name);
      END;
    ''');
    },
  );

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
    if(query.trim().isEmpty) {
      return Future.value([]);
    }

    final select = customSelect(
      '''
    SELECT tag.*
    FROM tag
    JOIN tag_fts
      on tag.id = tag_fts.rowid
    WHERE tag_fts MATCH ?
    ''',
      variables: [Variable.withString(query)],
      readsFrom: {tag},
    );

    return select.map((x) => x.read<String>("name")).get();
  }
}
