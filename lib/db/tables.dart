import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:xxh3/xxh3.dart';
import '../packer_extension.dart';
import 'package:messagepack/messagepack.dart';

class NonEmptyString extends Equatable {
  final String value;

  NonEmptyString._(this.value) : assert(value.isNotEmpty);

  @override
  List<Object?> get props => [value];

  static NonEmptyString unsafeMake(String value) {
    assert(!const bool.fromEnvironment("dart.vm.product"));
    return NonEmptyString._(value);
  }

  int generateHash() => xxh3(utf8.encode(value));

  static Option<NonEmptyString> makeFromString(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? none(): some(NonEmptyString._(trimmed));
  }

  static Option<NonEmptyString> makeFromUnpacker(Unpacker unpacker) => unpacker
    .toOptionString()
    .flatMap((name) => makeFromString(name));
}

class ArtistTag{
  final int tag_id;
  final Option<NonEmptyString> opt_image_path;

  ArtistTag._({required this.tag_id, required this.opt_image_path});

  ArtistTag cloneWith(Option<NonEmptyString> new_opt_image_path) =>
    ArtistTag._(tag_id: tag_id, opt_image_path: new_opt_image_path);

  void pack(Packer packer) {
    packer.packInt(tag_id);
    opt_image_path.match(
      () {
        packer.packBool(false);
      },
      (url) {
        packer.packBool(true);
        packer.packString(url.value);
      }
    );
  }

  static Option<ArtistTag> makeFromUnpacker(Unpacker unpacker, TagTable tag_table) => unpacker
    .toOptionInt()
    .flatMap((tag_id) => unpacker
      .toOptionBool()
      .map((b) => b ? unpacker.toOptionString().flatMap((image_path) => NonEmptyString.makeFromString(image_path)) : none<NonEmptyString>())
      .flatMap((opt_image_path) {
        return tag_table.try_get_tag(tag_id)
          .map((tag) => tag_table._attach(tag_id, tag.name, opt_image_path));
      }));
}

class Artist {
  final NonEmptyString name;
  final List<ArtistTag> tags;
  final List<NonEmptyString> urls;

  Artist({required this.name, this.tags = const [], this.urls = const []});

  void writeIntoPacker(Packer packer) {
    packer.packString(name.value);
    packer.packInt(tags.length);
    for (var tag in tags) {
      tag.pack(packer);
    }
    packer.packListLength(urls.length);
    for (var url in urls) {
      packer.packString(url.value);
    }
  }

  Uint8List toBytes() {
    final packer = Packer();
    writeIntoPacker(packer);
    return packer.takeBytes();
  }

  static Option<Artist> makeFromUnpacker(Unpacker unpacker, TagTable tag_table) => NonEmptyString
    .makeFromUnpacker(unpacker)
    .flatMap((name) => unpacker.toOptionInt()
      .flatMap((n) => List<Option<ArtistTag>>.generate(n, (_) => ArtistTag.makeFromUnpacker(unpacker, tag_table))
        .sequenceOption()
      )
      .flatMap((tags) => Option.tryCatch(() => unpacker.unpackList())
        .flatMap((list) => Option.tryCatch(() => list.map((o) => o as String)
          .map((s) => NonEmptyString.makeFromString(s))
          .toList()
          .sequenceOption()))
          .flatMap((e) => e)
          .flatMap((urls) => some(Artist(name: name, tags: tags, urls: urls)))
      )
    );
}

class Tag {
  final int id;
  final NonEmptyString name;

  Tag({required this.id, required this.name});

  void writeIntoPacker(Packer packer) {
    packer.packInt(id);
    packer.packString(name.value);
  }

  static Option<Tag> makeFromUnpacker(Unpacker unpacker) => unpacker
    .toOptionInt()
    .flatMap((id) => NonEmptyString.makeFromUnpacker(unpacker)
      .flatMap((name) => some(Tag(id: id, name: name))));
}

class TagTable {
  final HashMap<int, Tag> _container = HashMap();
  final HashMap<int, int> _ref_cnt_map = HashMap();

  Tag add_tag(int id, NonEmptyString name) {
    assert(!_container.containsKey(id));
    assert(!_ref_cnt_map.containsKey(id));

    _ref_cnt_map[id] = 0;
    return _container[id] = Tag(id: id, name: name);
  }

  Tag get_tag(int tag_id) {
    assert(_container.containsKey(tag_id));
    return _container[tag_id]!;
  }

  Option<Tag> try_get_tag(int tag_id) {
    return _container.lookup(tag_id);
  }

  Iterable<Tag> get tags => _container.values;

  void remove_tag(Tag tag) {
    _container.remove(tag.id);
  }

  ArtistTag _attach(int id, NonEmptyString tag_name, Option<NonEmptyString> opt_image_url) {
    final tag = _container.lookup(id).getOrElse(() => add_tag(id, tag_name));

    _ref_cnt_map[tag.id] = _ref_cnt_map[tag.id]! + 1;
    return ArtistTag._(tag_id: tag.id, opt_image_path: opt_image_url);
  }

  ArtistTag attach(NonEmptyString tag_name, Option<NonEmptyString> opt_image_url) {
    final id = tag_name.generateHash();
    return _attach(id, tag_name, opt_image_url);
  }

  
  void detach(ArtistTag artist_tag) {
    final tag = _container[artist_tag.tag_id];
    assert(tag != null);
    assert(_ref_cnt_map[artist_tag.tag_id] != null);
    
    final cnt = (_ref_cnt_map[artist_tag.tag_id] = _ref_cnt_map[artist_tag.tag_id]! - 1);
    assert(cnt >= 0);
    
    if(cnt == 0) {
      _container.remove(artist_tag.tag_id);
      _ref_cnt_map.remove(artist_tag.tag_id);
    }
  }
}