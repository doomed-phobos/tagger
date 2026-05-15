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
}
