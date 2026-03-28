import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:messagepack/messagepack.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tagger/serializer.dart';

typedef ArtistEntry = (
  NonEmptyString, // Artist Name
  HashMap<NonEmptyString, Option<Uint8List>>, // Tags
  HashSet<NonEmptyString>); // Urls

class _ArtistList with ChangeNotifier {
  final HashMap<NonEmptyString, Artist> container;

  _ArtistList(this.container);

  int get length => container.length;

  void operator[]=(NonEmptyString key, Artist value) {
    container[key] = value;
    notifyListeners();
  }

  Option<Artist> get(NonEmptyString name) => container.lookup(name);

  bool contains(NonEmptyString name) => container.containsKey(name);

  void removeAt(NonEmptyString name) {
    container.remove(name);
    notifyListeners();
  }
}

class Database {
  final String _directory_path;
  final _ArtistList _artists;
  final HashMap<int, Tag> _tags; // TODO: Instead of List, is slow???
  final HashMap<int /* tag_id */, int /* rfc_count */> _map_reference_tags;

  Iterable<Tag> get tags => List.unmodifiable(_tags.values);
  
  Database._(this._directory_path, this._artists, this._tags, this._map_reference_tags);

  Option<Tag> get_tag_by_id(int id) => _tags.lookup(id);

  ChangeNotifier get_artists_notifier() => _artists;

  Iterable<Artist> all_artists() => _artists.container.values;

  bool doesExistArtist(NonEmptyString artist_name) => _artists.contains(artist_name);

  TaskOption<ArtistEntry> convert_artist_to_entry(Artist artist) {
    return TaskOption.tryCatch(() async {
      final opt_list = artist.tags.traverseOption((art_tag) => get_tag_by_id(art_tag.tag_id).map((tag) => (tag, art_tag.opt_image_url.map((url) => File(url.value).readAsBytesSync()))));
      return opt_list.map((list) =>
        HashMap<NonEmptyString, Option<Uint8List>>
          .fromIterable(
            list,
            key: (e) => e.$1.name,
            value: (e) => e.$2));
    })
    .flatMap((tags) => tags.toTaskOption())
    .map((tags) => (artist.name, tags, HashSet<NonEmptyString>.from(artist.urls)));
  }
  
  TaskEither<String, void> removeArtist(NonEmptyString artist_name) => TaskEither.tryCatch(
    () async {
      _artists.get(artist_name).match(
        () {},
        (artist) async {
          final futures = <Future<void>>[];

          for (final artist_tag in artist.tags) {
            _unref_tag(artist_tag.tag_id);
            artist_tag.opt_image_url.match(
              () {},
              (image_path) => futures.add(File(image_path.value).delete())
            );
          }

          await Future.wait(futures);

          _artists.removeAt(artist_name);

          _removeDanglingTags();

          {
            final packer = Packer();
            packer.packListLength(_tags.length);
            for (final tag in tags) {
              tag.writeIntoPacker(packer);
            }

            await File("$_directory_path/tags").writeAsBytes(packer.takeBytes());
          }

          {
            final packer = Packer();
            packer.packListLength(_artists.length);
            for (final artist in all_artists()) {
              artist.writeIntoPacker(packer);
            }
            
            await File("$_directory_path/artists").writeAsBytes(packer.takeBytes());
          }
        }
      );
    },
    (e, _) => "Failed to remove artist $e"
  );

  void _ref_tag(int tag_id) {
    assert(_map_reference_tags[tag_id] != null);
    _map_reference_tags[tag_id] = _map_reference_tags[tag_id]! + 1;
  }

  void _unref_tag(int tag_id) {
    assert(_map_reference_tags[tag_id] != null);
    _map_reference_tags[tag_id] = _map_reference_tags[tag_id]! - 1;
  }

  void _add_tag(Tag tag) {
    if (!_tags.containsKey(tag.id)) {
      _tags[tag.id] = tag;
      _map_reference_tags[tag.id] = 1;
    } else {
      _ref_tag(tag.id);
    }
  }
  
  TaskEither<String, void> addArtist(ArtistEntry artist_entry) =>
    TaskEither.tryCatch(
      () async {
        final dir = Directory("$_directory_path/images");
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      },
      (e, _) => "Failed to create images directory: $e"
    )
    .andThen(() => TaskEither.tryCatch(
      () async {
      HashSet<ArtistTag> new_artist_tags = HashSet();

      final newImageFutures = <Future<void>>[];
      // Tags
      for (final tag_entry in artist_entry.$2.entries) {
        final tag = Tag(
          id: tag_entry.key.generateHash(),
          name: tag_entry.key
        );

        final image_path = NonEmptyString.unsafeMake("$_directory_path/images/${artist_entry.$1.value}-${tag.name.value}");
        final artist_tag = ArtistTag(
          tag_id: tag.id,
          opt_image_url: tag_entry.value.isSome() ? some(image_path) : none());
        
        _add_tag(tag);
        new_artist_tags.add(artist_tag);

        tag_entry.value.match(
          () {},
          (bytes) => newImageFutures.add(File(image_path.value).writeAsBytes(bytes))
        );
      }

      await Future.wait(newImageFutures);

      final deleteImageFutures = <Future<void>>[];
      _artists.get(artist_entry.$1)
      .match(() {},
        (artist) {
          for (final artist_tag in artist.tags) {
            if (!new_artist_tags.contains(artist_tag)) {
              artist_tag.opt_image_url.match(
                () {},
                (image_url) {
                  _unref_tag(artist_tag.tag_id);
                  deleteImageFutures.add(File(image_url.value).delete());
                }
              );
            }
          }
        });

      Future.wait(deleteImageFutures);

      _removeDanglingTags();

      {
        final packer = Packer();
        packer.packListLength(_tags.length);
        for (final tag in tags) {
          tag.writeIntoPacker(packer);
        }

        await File("$_directory_path/tags").writeAsBytes(packer.takeBytes());
      }

      final new_artist = Artist(name: artist_entry.$1, tags: new_artist_tags.toList(), urls: artist_entry.$3.toList());
      _artists[artist_entry.$1] = new_artist;

      {
        final packer = Packer();
        packer.packListLength(_artists.length);
        for (final artist in all_artists()) {
          artist.writeIntoPacker(packer);
        }
        
        await File("$_directory_path/artists").writeAsBytes(packer.takeBytes());
      }
      },
      (e, _) => "Failed to save data: $e"
    ));

  void _removeDanglingTags() async {
    final idsToRemove = _map_reference_tags
      .entries
      .where((e) => e.value <= 0)
      .map((e) => e.key)
      .toList();

    // FIXME: La eliminación de tags provoca que los índices se muevan
    // por lo que los mapas ya no apuntan a donde debería
    for (final id in idsToRemove) {
      _tags.remove(id);
      _map_reference_tags.remove(id);
    }
  }

  static TaskOption<Database> make_from_data() => TaskOption(() async {
    final directory = await getApplicationDocumentsDirectory();

    final artists = await TaskOption.tryCatch(() => File("${directory.path}/artists").readAsBytes())
      .flatMap((bytes) {
        final unpacker = Unpacker(bytes);
        return List.generate(
          unpacker.unpackListLength(),
          (_) => Artist.makeFromUnpacker(unpacker))
          .sequenceOption()
          .toTaskOption();
      })
      .getOrElse(() => [])
      .run();

    final tags = await TaskOption.tryCatch(() => File("${directory.path}/tags").readAsBytes())
      .flatMap((bytes) {
        final unpacker = Unpacker(bytes);
        return List.generate(
          unpacker.unpackListLength(),
          (_) => Tag.makeFromUnpacker(unpacker))
          .sequenceOption()
          .toTaskOption();
      })
      .getOrElse(() => [])
      .run();

    HashMap<int, int> map_reference_tags = HashMap();
    for (final artist in artists) {
      for (final tag in artist.tags) {
        map_reference_tags.update(
          tag.tag_id,
          (ref_cnt) => ref_cnt+1,
          ifAbsent: () => 1);
      }
    }

    return some(
      Database._(
        directory.path,
        _ArtistList(HashMap.fromIterable(artists, key: (artist) => artist.name, value: (artist) => artist)),
        HashMap.fromIterable(tags, key: (tag) => tag.id, value: (tag) => tag),
        map_reference_tags));
  });
}
