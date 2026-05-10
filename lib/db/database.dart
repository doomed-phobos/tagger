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

@DriftDatabase(tables: [Artist, Tag, ArtistTag])
class Database extends _$Database {
  Database([QueryExecutor? executor]) : super(executor ?? _openConnection());

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
}
