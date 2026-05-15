import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";
import "package:tagger/db/database.dart";
import "package:tagger/dialog.dart";
import "package:fpdart/fpdart.dart" as fp;
import "package:tagger/extractor/image.dart";
import "package:tagger/theme.dart";
import "package:toastification/toastification.dart";

class AddPage extends StatefulWidget {
  final Database _database;
  const AddPage(this._database, {super.key});

  @override
  createState() => _AddPage();
}

class _AddPage extends State<AddPage> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    exit_dialog() async {
      final res = await show_yes_no_dialog(context, "Exit", "Are you sure?");

      if (res && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        await exit_dialog();
      },
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: exit_dialog,
                  icon: Icon(Icons.arrow_circle_left_rounded),
                ),
                const Expanded(
                  child: Text(
                    "Add Artist",
                    textAlign: .center,
                    style: TextStyle(fontWeight: .bold, fontSize: 24),
                  ),
                ),
                IconButton(onPressed: null, icon: Icon(Icons.save)),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Artist Name",
                        hintText: "artist 1",
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Artist is empty"
                          : null,
                    ),
                    SizedBox(height: 20),

                    _TagForm(widget._database),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagForm extends StatefulWidget {
  final Database database;
  final Map<String, fp.Option<Uint8List>> tag_map = {};

  _TagForm(this.database);

  @override
  createState() => _TagFormState();
}

class _TagFormState extends State<_TagForm> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          TypeAheadField<String>(
            key: ValueKey(widget.tag_map.length),
            focusNode: focusNode,
            controller: controller,
            suggestionsCallback: (search) async {
              final tags = await widget.database.find_tags(search);
              return
                tags
                  .where((x) => !widget.tag_map.containsKey(x))
                  .toList();
            },
            onSelected: (tag) {
              add_tag(tag);
            },
            itemBuilder: (context, tag) {
              return ListTile(title: Text(tag));
            },
            builder: (context, controller, focusNode) {
              return TextFormField(
                onTapOutside: (_) => focusNode.unfocus(),
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: "Tag?",
                  hintText: "tag 1",
                  suffixIcon: IconButton(
                    onPressed: () {
                      if(formKey.currentState!.validate()) {
                        add_tag(controller.text);
                      }
                    },
                    icon: Icon(Icons.add),
                  ),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? "Tag is empty" : null,
              );
            },
          ),
          SizedBox(height: 10),
          Wrap(
            runSpacing: 8,
            spacing: 8,
            children: widget.tag_map.entries
                .map(
                  (e) => OutlinedButton(
                    onPressed: () => show_image_modal(e.key),
                    style: get_tag_style(e.value.isSome() ? Colors.blue : null),
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        Text(e.key),
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () async {
                            final confirm = await show_yes_no_dialog(
                              context,
                              "Delete Tag",
                              'Delete Tag "${e.key}"?',
                            );
                            if (confirm) {
                              setState(() => widget.tag_map.remove(e.key));
                            }
                          }, icon: Icon(Icons.delete)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  void add_tag(String name) {
    final v = name.trim();

    if (!widget.tag_map.containsKey(v)) {
      setState(() {
        widget.tag_map[v] = fp.None();
      });
    }

    controller.clear();
    focusNode.unfocus();
  }

  void show_image_modal(String key) {
    var loading = false;
    String url = "";

    update_image(bytes) {
      if (mounted) {
        setState(() => widget.tag_map[key] = fp.some(bytes));
      }
    };

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            var image = widget.tag_map
                .lookup(key)
                .flatMap((o) => o)
                .match(
                  () => Icon(Icons.broken_image),
                  (bytes) => Image.memory(bytes, fit: .contain),
                );

            if (loading) {
              image = Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    onChanged: (value) => url = value,
                    decoration: InputDecoration(
                      labelText: "Image URL",
                      suffixIcon: IconButton(
                        onPressed: loading
                            ? null
                            : () async {
                                setState(() => loading = true);

                                FocusManager.instance.primaryFocus?.unfocus();
                                await Future.delayed(
                                  const Duration(milliseconds: 50),
                                );

                                final res =
                                    await get_image_bytes_from_hitomi_url(
                                      url,
                                    ).run();

                                res.match(
                                  (e) => toastification.show(
                                    title: Text(e),
                                    type: .error,
                                    autoCloseDuration: const Duration(
                                      seconds: 3,
                                    ),
                                  ),
                                  (bytes) => update_image(bytes),
                                );

                                if (context.mounted) {
                                  setState(() => loading = false);
                                }
                              },
                        icon: Icon(Icons.search),
                      ),
                      hintText: "https://hitomi.la/reader/xxxxxxx.html#xx-xx",
                    ),
                  ),
                ),
                Expanded(flex: 7, child: image),
              ],
            );
          },
        );
      },
    );
  }
}
