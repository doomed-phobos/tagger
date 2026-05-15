import "package:flutter/material.dart";
import "package:tagger/bootstrap.dart";
import "package:tagger/db/database.dart";
import "package:tagger/pages/add.dart";

class HomePage extends StatefulWidget {
  final Database _database;

  const HomePage(this._database, {super.key});

  @override
  createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Expanded(
          flex: 0,
          child: TextField(
            decoration: InputDecoration(
              hintText: "artist name tag:tag 1",
              labelText: "Search...",
              suffixIcon: IconButton(
                onPressed: () => _go_to_add_page(widget._database, context),
                icon: Icon(Icons.add),
              ),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
      ],
    );
  }
}

// TODO: Add default artist name from TextField
Future<void> _go_to_add_page(Database database, BuildContext context) async {
  if (context.mounted) {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => bootstrap(AddPage(database))),
    );
  }
}
