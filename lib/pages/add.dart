import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";
import "package:tagger/db/database.dart";
import "package:tagger/dialog.dart";
import "package:fpdart/fpdart.dart" as fp;
import "package:tagger/extractor/artist.dart";
import "package:tagger/extractor/image.dart";
import "package:tagger/theme.dart";
import "package:tagger/toast.dart";

class AddPage extends StatefulWidget {
  final Database _database;
  final String? _default_artist_url;
  final Map<String, fp.Option<Uint8List>> _tag_map = {};
  final List<String> _link_set = [];

  AddPage(this._database, this._default_artist_url, {super.key});

  void add_tag(String name, fp.Option<Uint8List> buffer) {
    _tag_map[name] = buffer;
  }

  void add_link(String url) {
    _link_set.add(url);
  }

  @override
  createState() => _AddPage();
}

class _AddPage extends State<AddPage> {
final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  var isLoading = false;

  @override
  void initState() {
    super.initState();

    if(widget._default_artist_url != null) {
      controller.text = widget._default_artist_url!;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
                IconButton(
                  onPressed: save_artist,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        )
                      : Icon(Icons.save),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: "Artist URL",
                        hintText: "https://hitomi.la/artist/XXXXXXXX-all.html",
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "URL artist is empty"
                          : null,
                    ),
                    SizedBox(height: 20),

                    _TagForm(widget._database, widget._tag_map),

                    SizedBox(height: 10),

                    _LinkForm(widget._link_set),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> save_artist() async {
    if (context.mounted) {
      setState(() => isLoading = true);
    }

    if (formKey.currentState!.validate()) {
      await get_artist_data_from_url(controller.text)
          .map(
            (data) {
            debugPrint("Fetched: ${data.$2}");
            return ArtistCompanion.insert(
              url: controller.text,
              name: data.$1,
              last_gallery_id: data.$2,
            );
            }
          )
          .flatMap(
            (data) => widget._database.insert_artist(
              data,
              widget._tag_map,
              widget._link_set,
            ),
          )
          .match(
            (e) => show_error_toast(e),
            (unit) => show_success_toast("Artist added!"),
          )
          .run();
    }

    if (context.mounted) {
      setState(() => isLoading = false);
    }
  }
}

class _TagForm extends StatefulWidget {
  final Database database;
  final Map<String, fp.Option<Uint8List>> tag_map;

  const _TagForm(this.database, this.tag_map);

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
              return tags.where((x) => !widget.tag_map.containsKey(x)).toList();
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
                onFieldSubmitted: (value) => add_tag(value),
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: "Tag?",
                  hintText: "tag 1",
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
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
                          },
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

  void add_tag(String name) {
    final v = name.trim();
    if (v.isEmpty) return;

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
    }

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
                                  (e) => show_error_toast(e),
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

class _LinkForm extends StatefulWidget {
  final List<String> link_list;
  const _LinkForm(this.link_list);

  @override
  createState() => _LinkFormState();
}

class _LinkFormState extends State<_LinkForm> {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  final focusNode = FocusNode();

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
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            onFieldSubmitted: (value) => add_link(value),
            decoration: InputDecoration(
              labelText: "Link?",
              hintText: "https://www.pixiv.net/",
              suffixIcon: IconButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    add_link(controller.text);
                  }
                },
                icon: Icon(Icons.add),
              ),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? "Link is empty" : null,
          ),
          SizedBox(height: 10),
          Wrap(
            runSpacing: 8,
            spacing: 8,
            children: widget.link_list
                .map(
                  (url) => TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: .zero),
                      foregroundColor: Colors.blue,
                    ),
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        Flexible(child: Text(url)),
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () async {
                            final confirm = await show_yes_no_dialog(
                              context,
                              "Delete Link",
                              'Delete "$url"?',
                            );
                            if (confirm) {
                              setState(() => widget.link_list.remove(url));
                            }
                          },
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

  void add_link(String text) {
    final v = text.trim();
    if (v.isEmpty) return;

    setState(() => widget.link_list.add(v));

    controller.clear();
    focusNode.unfocus();
  }
}
