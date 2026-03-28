import 'package:fpdart/fpdart.dart';
import 'package:messagepack/messagepack.dart';

extension SerializerExtension on Unpacker {
  Option<bool> toOptionBool() => Option.tryCatch(() => unpackBool()).flatMapNullable((e) => e);
  Option<String> toOptionString() => Option.tryCatch(() => unpackString()).flatMapNullable((e) => e);
  Option<int> toOptionInt() => Option.tryCatch(() => unpackInt()).flatMapNullable((e) => e);
}