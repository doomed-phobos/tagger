import 'package:flutter/material.dart';

ThemeData get_app_theme_data() {
  return ThemeData(
    brightness: .dark,
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.grey[600]),
      border: .none,
      contentPadding: EdgeInsets.symmetric(horizontal: 5),
      focusedBorder: OutlineInputBorder(
        borderRadius: .zero,
        borderSide: BorderSide(color: Colors.blue)
      ),
      filled: true,
      fillColor: Colors.grey[900],
    ),
  );
}
