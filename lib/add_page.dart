import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tagger/database.dart';
import 'package:tagger/image_extractor.dart';
import 'package:tagger/serializer.dart';
import 'package:tagger/theme.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:toastification/toastification.dart';

class AddPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final Database _database;
  final HashMap<NonEmptyString, fp.Option<Uint8List>> _tag_map = HashMap();
  
  AddPage(this._database, {super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Add Artist",
                  textAlign: .center,
                  style: TextStyle(fontWeight: .bold, fontSize: 24),
                ),
              ),
              ElevatedButton(onPressed: () {
                if(_formKey.currentState!.validate()) {

                }
              }, child: const Text("Save")),
            ],
          ),

          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Artist Name",
              hintText: "artist 1"
            ),
            validator: (value) => (value == null || value.isEmpty) ? "Artist is empty" : null,
          ),
          SizedBox(height: 10),

          _TagForm(_tag_map, _database.tags),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _TagForm extends StatefulWidget {
  final HashMap<NonEmptyString, fp.Option<Uint8List>> _tag_map;
  final List<Tag> _tags;

  const _TagForm(this._tag_map, this._tags, {super.key});

  @override
  createState() => _TagFormState();
}

class _TagFormState extends State<_TagForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Autocomplete<String>(
            optionsBuilder: (input) {
              return widget._tags
                  .filter(
                    (tag) =>
                        tag.name.value.toLowerCase().startsWith(input.text),
                  )
                  .filter((tag) => !widget._tag_map.containsKey(tag.name))
                  .map((tag) => tag.name.value);
            },
            fieldViewBuilder:
                (context, controller, focusNode, onEditingComplete) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: "Tag?",
                      hintText: "Write something",
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            NonEmptyString.makeFromString(
                              controller.text,
                            ).match(() {}, (v) {
                              if (!widget._tag_map.containsKey(v)) {
                                setState(() {
                                  widget._tag_map[v] = fp.None();
                                });
                              }
                            });
                            controller.clear();
                            focusNode.unfocus();
                          }
                        },
                        icon: Icon(Icons.add),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? "Tag is empty" : null,
                  );
                },
          ),
          SizedBox(height: 10),
          Wrap(
            runSpacing: 8,
            spacing: 8,
            children: widget._tag_map.entries
                .map(
                  (e) => OutlinedButton(
                    onPressed: () => showImageModal(e.key),
                    style: get_tag_style(
                      e.value.isSome() ? Colors.green : Colors.red,
                    ),
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        Text(e.key.value),
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () => setState(() => widget._tag_map.remove(e.key)),
                          style: get_button_icon_style(),
                          icon: Icon(Icons.delete),
                        ),
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

  void showImageModal(NonEmptyString key) {
    final controller = TextEditingController();
    var loading = false;

    final updateImage = (bytes) => setState(() => widget._tag_map[key] = fp.some(bytes));

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            var image = widget._tag_map
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
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: "Image URL",
                      suffixIcon: IconButton(
                        onPressed: () async {
                          setState(() => loading = true);

                          FocusManager.instance.primaryFocus?.unfocus();
                          await Future.delayed(
                            const Duration(milliseconds: 50),
                          );

                          final res = await get_image_bytes_from_hitomi_url(
                            controller.text,
                          ).run();
                          res.match(
                            (e) => setState(
                              () => toastification.show(
                                title: Text(e),
                                type: .error,
                                autoCloseDuration: const Duration(seconds: 2),
                              ),
                            ),
                            (bytes) => updateImage(bytes),
                          );

                          setState(() => loading = false);
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
