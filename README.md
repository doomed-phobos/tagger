# tagger

Apk for organize mangas.
  + Contains a ~custom database using msgpack and hashmap~ sqlite database with indices. [See Database](lib/db/database.dart)
  + Tag autocompletion. [See add](lib/pages/add.dart)
  + Reference count for tags for autodeletion.
  + URL extractor from supported galleries :). [See image extractor](lib/extractor/image.dart)
  + Artist extractor from URL. [See artist extractor](lib/extractor/artist.dart)
