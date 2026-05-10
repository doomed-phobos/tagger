// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ArtistTable extends Artist with TableInfo<$ArtistTable, ArtistData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtistTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artist';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtistData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArtistData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtistData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $ArtistTable createAlias(String alias) {
    return $ArtistTable(attachedDatabase, alias);
  }
}

class ArtistData extends DataClass implements Insertable<ArtistData> {
  final int id;
  final String name;
  const ArtistData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ArtistCompanion toCompanion(bool nullToAbsent) {
    return ArtistCompanion(id: Value(id), name: Value(name));
  }

  factory ArtistData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtistData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  ArtistData copyWith({int? id, String? name}) =>
      ArtistData(id: id ?? this.id, name: name ?? this.name);
  ArtistData copyWithCompanion(ArtistCompanion data) {
    return ArtistData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtistData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtistData && other.id == this.id && other.name == this.name);
}

class ArtistCompanion extends UpdateCompanion<ArtistData> {
  final Value<int> id;
  final Value<String> name;
  const ArtistCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  ArtistCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<ArtistData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  ArtistCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return ArtistCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $TagTable extends Tag with TableInfo<$TagTable, TagData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TagTable createAlias(String alias) {
    return $TagTable(attachedDatabase, alias);
  }
}

class TagData extends DataClass implements Insertable<TagData> {
  final int id;
  final String name;
  const TagData({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagCompanion toCompanion(bool nullToAbsent) {
    return TagCompanion(id: Value(id), name: Value(name));
  }

  factory TagData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  TagData copyWith({int? id, String? name}) =>
      TagData(id: id ?? this.id, name: name ?? this.name);
  TagData copyWithCompanion(TagCompanion data) {
    return TagData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagData(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagData && other.id == this.id && other.name == this.name);
}

class TagCompanion extends UpdateCompanion<TagData> {
  final Value<int> id;
  final Value<String> name;
  const TagCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TagCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<TagData> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TagCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return TagCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ArtistTagTable extends ArtistTag
    with TableInfo<$ArtistTagTable, ArtistTagData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtistTagTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _image_pathMeta = const VerificationMeta(
    'image_path',
  );
  @override
  late final GeneratedColumn<String> image_path = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<int> artist = GeneratedColumn<int>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES artist (id)',
    ),
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<int> tag = GeneratedColumn<int>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tag (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, image_path, artist, tag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artist_tag';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtistTagData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _image_pathMeta,
        image_path.isAcceptableOrUnknown(data['image_path']!, _image_pathMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArtistTagData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtistTagData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      image_path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artist'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag'],
      )!,
    );
  }

  @override
  $ArtistTagTable createAlias(String alias) {
    return $ArtistTagTable(attachedDatabase, alias);
  }
}

class ArtistTagData extends DataClass implements Insertable<ArtistTagData> {
  final int id;
  final String? image_path;
  final int artist;
  final int tag;
  const ArtistTagData({
    required this.id,
    this.image_path,
    required this.artist,
    required this.tag,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || image_path != null) {
      map['image_path'] = Variable<String>(image_path);
    }
    map['artist'] = Variable<int>(artist);
    map['tag'] = Variable<int>(tag);
    return map;
  }

  ArtistTagCompanion toCompanion(bool nullToAbsent) {
    return ArtistTagCompanion(
      id: Value(id),
      image_path: image_path == null && nullToAbsent
          ? const Value.absent()
          : Value(image_path),
      artist: Value(artist),
      tag: Value(tag),
    );
  }

  factory ArtistTagData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtistTagData(
      id: serializer.fromJson<int>(json['id']),
      image_path: serializer.fromJson<String?>(json['image_path']),
      artist: serializer.fromJson<int>(json['artist']),
      tag: serializer.fromJson<int>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'image_path': serializer.toJson<String?>(image_path),
      'artist': serializer.toJson<int>(artist),
      'tag': serializer.toJson<int>(tag),
    };
  }

  ArtistTagData copyWith({
    int? id,
    Value<String?> image_path = const Value.absent(),
    int? artist,
    int? tag,
  }) => ArtistTagData(
    id: id ?? this.id,
    image_path: image_path.present ? image_path.value : this.image_path,
    artist: artist ?? this.artist,
    tag: tag ?? this.tag,
  );
  ArtistTagData copyWithCompanion(ArtistTagCompanion data) {
    return ArtistTagData(
      id: data.id.present ? data.id.value : this.id,
      image_path: data.image_path.present
          ? data.image_path.value
          : this.image_path,
      artist: data.artist.present ? data.artist.value : this.artist,
      tag: data.tag.present ? data.tag.value : this.tag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtistTagData(')
          ..write('id: $id, ')
          ..write('image_path: $image_path, ')
          ..write('artist: $artist, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, image_path, artist, tag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtistTagData &&
          other.id == this.id &&
          other.image_path == this.image_path &&
          other.artist == this.artist &&
          other.tag == this.tag);
}

class ArtistTagCompanion extends UpdateCompanion<ArtistTagData> {
  final Value<int> id;
  final Value<String?> image_path;
  final Value<int> artist;
  final Value<int> tag;
  const ArtistTagCompanion({
    this.id = const Value.absent(),
    this.image_path = const Value.absent(),
    this.artist = const Value.absent(),
    this.tag = const Value.absent(),
  });
  ArtistTagCompanion.insert({
    this.id = const Value.absent(),
    this.image_path = const Value.absent(),
    required int artist,
    required int tag,
  }) : artist = Value(artist),
       tag = Value(tag);
  static Insertable<ArtistTagData> custom({
    Expression<int>? id,
    Expression<String>? image_path,
    Expression<int>? artist,
    Expression<int>? tag,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (image_path != null) 'image_path': image_path,
      if (artist != null) 'artist': artist,
      if (tag != null) 'tag': tag,
    });
  }

  ArtistTagCompanion copyWith({
    Value<int>? id,
    Value<String?>? image_path,
    Value<int>? artist,
    Value<int>? tag,
  }) {
    return ArtistTagCompanion(
      id: id ?? this.id,
      image_path: image_path ?? this.image_path,
      artist: artist ?? this.artist,
      tag: tag ?? this.tag,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (image_path.present) {
      map['image_path'] = Variable<String>(image_path.value);
    }
    if (artist.present) {
      map['artist'] = Variable<int>(artist.value);
    }
    if (tag.present) {
      map['tag'] = Variable<int>(tag.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistTagCompanion(')
          ..write('id: $id, ')
          ..write('image_path: $image_path, ')
          ..write('artist: $artist, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $ArtistTable artist = $ArtistTable(this);
  late final $TagTable tag = $TagTable(this);
  late final $ArtistTagTable artistTag = $ArtistTagTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [artist, tag, artistTag];
}

typedef $$ArtistTableCreateCompanionBuilder =
    ArtistCompanion Function({Value<int> id, required String name});
typedef $$ArtistTableUpdateCompanionBuilder =
    ArtistCompanion Function({Value<int> id, Value<String> name});

final class $$ArtistTableReferences
    extends BaseReferences<_$Database, $ArtistTable, ArtistData> {
  $$ArtistTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ArtistTagTable, List<ArtistTagData>>
  _artistTagRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.artistTag,
    aliasName: $_aliasNameGenerator(db.artist.id, db.artistTag.artist),
  );

  $$ArtistTagTableProcessedTableManager get artistTagRefs {
    final manager = $$ArtistTagTableTableManager(
      $_db,
      $_db.artistTag,
    ).filter((f) => f.artist.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_artistTagRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ArtistTableFilterComposer extends Composer<_$Database, $ArtistTable> {
  $$ArtistTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> artistTagRefs(
    Expression<bool> Function($$ArtistTagTableFilterComposer f) f,
  ) {
    final $$ArtistTagTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.artistTag,
      getReferencedColumn: (t) => t.artist,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTagTableFilterComposer(
            $db: $db,
            $table: $db.artistTag,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArtistTableOrderingComposer extends Composer<_$Database, $ArtistTable> {
  $$ArtistTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtistTableAnnotationComposer
    extends Composer<_$Database, $ArtistTable> {
  $$ArtistTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> artistTagRefs<T extends Object>(
    Expression<T> Function($$ArtistTagTableAnnotationComposer a) f,
  ) {
    final $$ArtistTagTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.artistTag,
      getReferencedColumn: (t) => t.artist,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTagTableAnnotationComposer(
            $db: $db,
            $table: $db.artistTag,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArtistTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ArtistTable,
          ArtistData,
          $$ArtistTableFilterComposer,
          $$ArtistTableOrderingComposer,
          $$ArtistTableAnnotationComposer,
          $$ArtistTableCreateCompanionBuilder,
          $$ArtistTableUpdateCompanionBuilder,
          (ArtistData, $$ArtistTableReferences),
          ArtistData,
          PrefetchHooks Function({bool artistTagRefs})
        > {
  $$ArtistTableTableManager(_$Database db, $ArtistTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtistTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtistTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtistTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => ArtistCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  ArtistCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ArtistTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({artistTagRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (artistTagRefs) db.artistTag],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (artistTagRefs)
                    await $_getPrefetchedData<
                      ArtistData,
                      $ArtistTable,
                      ArtistTagData
                    >(
                      currentTable: table,
                      referencedTable: $$ArtistTableReferences
                          ._artistTagRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ArtistTableReferences(db, table, p0).artistTagRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.artist == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ArtistTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ArtistTable,
      ArtistData,
      $$ArtistTableFilterComposer,
      $$ArtistTableOrderingComposer,
      $$ArtistTableAnnotationComposer,
      $$ArtistTableCreateCompanionBuilder,
      $$ArtistTableUpdateCompanionBuilder,
      (ArtistData, $$ArtistTableReferences),
      ArtistData,
      PrefetchHooks Function({bool artistTagRefs})
    >;
typedef $$TagTableCreateCompanionBuilder =
    TagCompanion Function({Value<int> id, required String name});
typedef $$TagTableUpdateCompanionBuilder =
    TagCompanion Function({Value<int> id, Value<String> name});

final class $$TagTableReferences
    extends BaseReferences<_$Database, $TagTable, TagData> {
  $$TagTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ArtistTagTable, List<ArtistTagData>>
  _artistTagRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
    db.artistTag,
    aliasName: $_aliasNameGenerator(db.tag.id, db.artistTag.tag),
  );

  $$ArtistTagTableProcessedTableManager get artistTagRefs {
    final manager = $$ArtistTagTableTableManager(
      $_db,
      $_db.artistTag,
    ).filter((f) => f.tag.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_artistTagRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagTableFilterComposer extends Composer<_$Database, $TagTable> {
  $$TagTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> artistTagRefs(
    Expression<bool> Function($$ArtistTagTableFilterComposer f) f,
  ) {
    final $$ArtistTagTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.artistTag,
      getReferencedColumn: (t) => t.tag,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTagTableFilterComposer(
            $db: $db,
            $table: $db.artistTag,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagTableOrderingComposer extends Composer<_$Database, $TagTable> {
  $$TagTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagTableAnnotationComposer extends Composer<_$Database, $TagTable> {
  $$TagTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> artistTagRefs<T extends Object>(
    Expression<T> Function($$ArtistTagTableAnnotationComposer a) f,
  ) {
    final $$ArtistTagTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.artistTag,
      getReferencedColumn: (t) => t.tag,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTagTableAnnotationComposer(
            $db: $db,
            $table: $db.artistTag,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagTableTableManager
    extends
        RootTableManager<
          _$Database,
          $TagTable,
          TagData,
          $$TagTableFilterComposer,
          $$TagTableOrderingComposer,
          $$TagTableAnnotationComposer,
          $$TagTableCreateCompanionBuilder,
          $$TagTableUpdateCompanionBuilder,
          (TagData, $$TagTableReferences),
          TagData,
          PrefetchHooks Function({bool artistTagRefs})
        > {
  $$TagTableTableManager(_$Database db, $TagTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => TagCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  TagCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable(table), $$TagTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({artistTagRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (artistTagRefs) db.artistTag],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (artistTagRefs)
                    await $_getPrefetchedData<
                      TagData,
                      $TagTable,
                      ArtistTagData
                    >(
                      currentTable: table,
                      referencedTable: $$TagTableReferences._artistTagRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagTableReferences(db, table, p0).artistTagRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tag == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $TagTable,
      TagData,
      $$TagTableFilterComposer,
      $$TagTableOrderingComposer,
      $$TagTableAnnotationComposer,
      $$TagTableCreateCompanionBuilder,
      $$TagTableUpdateCompanionBuilder,
      (TagData, $$TagTableReferences),
      TagData,
      PrefetchHooks Function({bool artistTagRefs})
    >;
typedef $$ArtistTagTableCreateCompanionBuilder =
    ArtistTagCompanion Function({
      Value<int> id,
      Value<String?> image_path,
      required int artist,
      required int tag,
    });
typedef $$ArtistTagTableUpdateCompanionBuilder =
    ArtistTagCompanion Function({
      Value<int> id,
      Value<String?> image_path,
      Value<int> artist,
      Value<int> tag,
    });

final class $$ArtistTagTableReferences
    extends BaseReferences<_$Database, $ArtistTagTable, ArtistTagData> {
  $$ArtistTagTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ArtistTable _artistTable(_$Database db) => db.artist.createAlias(
    $_aliasNameGenerator(db.artistTag.artist, db.artist.id),
  );

  $$ArtistTableProcessedTableManager get artist {
    final $_column = $_itemColumn<int>('artist')!;

    final manager = $$ArtistTableTableManager(
      $_db,
      $_db.artist,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_artistTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagTable _tagTable(_$Database db) =>
      db.tag.createAlias($_aliasNameGenerator(db.artistTag.tag, db.tag.id));

  $$TagTableProcessedTableManager get tag {
    final $_column = $_itemColumn<int>('tag')!;

    final manager = $$TagTableTableManager(
      $_db,
      $_db.tag,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ArtistTagTableFilterComposer
    extends Composer<_$Database, $ArtistTagTable> {
  $$ArtistTagTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image_path => $composableBuilder(
    column: $table.image_path,
    builder: (column) => ColumnFilters(column),
  );

  $$ArtistTableFilterComposer get artist {
    final $$ArtistTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artist,
      referencedTable: $db.artist,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTableFilterComposer(
            $db: $db,
            $table: $db.artist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagTableFilterComposer get tag {
    final $$TagTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tag,
      referencedTable: $db.tag,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagTableFilterComposer(
            $db: $db,
            $table: $db.tag,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArtistTagTableOrderingComposer
    extends Composer<_$Database, $ArtistTagTable> {
  $$ArtistTagTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image_path => $composableBuilder(
    column: $table.image_path,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArtistTableOrderingComposer get artist {
    final $$ArtistTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artist,
      referencedTable: $db.artist,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTableOrderingComposer(
            $db: $db,
            $table: $db.artist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagTableOrderingComposer get tag {
    final $$TagTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tag,
      referencedTable: $db.tag,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagTableOrderingComposer(
            $db: $db,
            $table: $db.tag,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArtistTagTableAnnotationComposer
    extends Composer<_$Database, $ArtistTagTable> {
  $$ArtistTagTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get image_path => $composableBuilder(
    column: $table.image_path,
    builder: (column) => column,
  );

  $$ArtistTableAnnotationComposer get artist {
    final $$ArtistTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artist,
      referencedTable: $db.artist,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistTableAnnotationComposer(
            $db: $db,
            $table: $db.artist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagTableAnnotationComposer get tag {
    final $$TagTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tag,
      referencedTable: $db.tag,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagTableAnnotationComposer(
            $db: $db,
            $table: $db.tag,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArtistTagTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ArtistTagTable,
          ArtistTagData,
          $$ArtistTagTableFilterComposer,
          $$ArtistTagTableOrderingComposer,
          $$ArtistTagTableAnnotationComposer,
          $$ArtistTagTableCreateCompanionBuilder,
          $$ArtistTagTableUpdateCompanionBuilder,
          (ArtistTagData, $$ArtistTagTableReferences),
          ArtistTagData,
          PrefetchHooks Function({bool artist, bool tag})
        > {
  $$ArtistTagTableTableManager(_$Database db, $ArtistTagTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtistTagTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtistTagTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtistTagTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> image_path = const Value.absent(),
                Value<int> artist = const Value.absent(),
                Value<int> tag = const Value.absent(),
              }) => ArtistTagCompanion(
                id: id,
                image_path: image_path,
                artist: artist,
                tag: tag,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> image_path = const Value.absent(),
                required int artist,
                required int tag,
              }) => ArtistTagCompanion.insert(
                id: id,
                image_path: image_path,
                artist: artist,
                tag: tag,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ArtistTagTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({artist = false, tag = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (artist) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.artist,
                                referencedTable: $$ArtistTagTableReferences
                                    ._artistTable(db),
                                referencedColumn: $$ArtistTagTableReferences
                                    ._artistTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tag) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tag,
                                referencedTable: $$ArtistTagTableReferences
                                    ._tagTable(db),
                                referencedColumn: $$ArtistTagTableReferences
                                    ._tagTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ArtistTagTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ArtistTagTable,
      ArtistTagData,
      $$ArtistTagTableFilterComposer,
      $$ArtistTagTableOrderingComposer,
      $$ArtistTagTableAnnotationComposer,
      $$ArtistTagTableCreateCompanionBuilder,
      $$ArtistTagTableUpdateCompanionBuilder,
      (ArtistTagData, $$ArtistTagTableReferences),
      ArtistTagData,
      PrefetchHooks Function({bool artist, bool tag})
    >;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$ArtistTableTableManager get artist =>
      $$ArtistTableTableManager(_db, _db.artist);
  $$TagTableTableManager get tag => $$TagTableTableManager(_db, _db.tag);
  $$ArtistTagTableTableManager get artistTag =>
      $$ArtistTagTableTableManager(_db, _db.artistTag);
}
