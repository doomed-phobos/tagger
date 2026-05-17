import "dart:typed_data";

import "package:fpdart/fpdart.dart";
import "package:http/http.dart" as http;

typedef ArtistData = (String /*name*/, int /*last gallery id*/);

TaskEither<String, ArtistData> get_artist_data_from_url(String url) => TaskEither(() async {
  final regex = RegExp(
    r"^https://hitomi\.la/(group|artist)/(.*)-all\.html$",
  ).firstMatch(url);
  if (regex == null) {
    return left("Invalid URL artist");
  }
  final type = regex.group(1)!;
  final name = regex.group(2)!;

  final response = await http.get(
    Uri.parse(
      'https://ltn.gold-usergeneratedcontent.net/$type/$name-all.nozomi',
    ),
    headers: {'Range': 'bytes=0-4'},
  );

  if (!(response.statusCode == 200 || response.statusCode == 206)) {
    return left("Failed to get artist info");
  }

  final bytes = response.bodyBytes;
  final data = ByteData.sublistView(bytes);

  return right(
  (
  Uri.decodeComponent(name),
  data.getInt32(0, Endian.big)));
});
