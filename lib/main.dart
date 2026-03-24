import 'package:flutter/material.dart';
import 'package:tagger/theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: get_app_theme_data(),
      home: Scaffold(
        body: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Expanded(
                  flex: 0,
                  child: TextField(
                    decoration: InputDecoration(hintText: "Search by..."),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    color: Colors.red,
                    child: Text(
                      "Here goes scroll ",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
