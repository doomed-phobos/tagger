import "package:flutter/material.dart";
import "package:fpdart/fpdart.dart";
import 'package:tagger/bootstrap.dart';
import "package:tagger/db/database.dart";
import 'package:tagger/pages/home.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final either = Either.tryCatch(
    () => Database(),
    (s, _) => "Failed to initialize Database: $s",
  );

  runApp(
    either.match(
      (error) => MaterialApp(home: Text(error)),
      (database) => ToastificationWrapper(child: bootstrap(HomePage(database))),
    ),
  );
}
