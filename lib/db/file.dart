import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File> compress_image_and_save(Uint8List bytes, String out_path) async {
  final compressed_bytes = await FlutterImageCompress.compressWithList(
    bytes, 
    minWidth: 512,
    minHeight: 512,
    quality: 50,
  );

  return File(out_path).writeAsBytes(compressed_bytes);
}