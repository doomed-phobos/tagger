import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:tagger/db/database.dart";
import "package:tagger/dialog.dart";
import "package:tagger/extractor/artist.dart";
import "package:tagger/filter.dart";
import "package:tagger/pages/add.dart";
import "package:tagger/theme.dart";
import "package:fpdart/fpdart.dart" as fp;
import "package:tagger/toast.dart";

class HomePage extends StatefulWidget {
  final Database _database;
  final Map<String, Color> _memo_update = {};

  HomePage(this._database, {super.key});

  @override
  createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  Filter filter = Filter.empty();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Expanded(
          flex: 0,
          child: TextField(
            onSubmitted: (value) => set_filter(Filter.make(value)),
            decoration: InputDecoration(
              hintText: "artist name tag:tag 1 tag: tag 2",
              labelText: "Search...",
              suffixIcon: IconButton(
                onPressed: () =>
                    _go_to_add_page(AddPage(widget._database, null)),
                icon: Icon(Icons.add),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: StreamBuilder<List<ArtistStreamItem>>(
            stream: widget._database.get_artist_stream(filter),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text("Error: ${snapshot.error}");

              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              final data = snapshot.data!;

              if (data.isEmpty) {
                final filters = [
                  if (filter.artist_name != null)
                    'artist="${filter.artist_name}"',

                  ...filter.tags.map((t) => 'tag:$t'),
                ].join(', ');

                return Center(
                  child: Text(
                    filters.isEmpty
                        ? "No hay elementos"
                        : "No hay elementos para los filtros: $filters",
                        textAlign: .center,
                  ),
                );
              }

              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) => _ArtistItem(
                  data[index],
                  edit_artist_item,
                  delete_artist_item,
                  widget._memo_update,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void set_filter(Filter filter) {
    setState(() {
      this.filter = filter;
    });
  }

  Future<void> delete_artist_item(int artist_id) async {
    if (await widget._database.delete_artist(artist_id)) {
      show_success_toast("Success to delete artist!");
    } else {
      show_error_toast("Failed to delete artist!");
    }
  }

  Future<void> edit_artist_item(ArtistStreamItem item) async {
    final add_page = AddPage(widget._database, item.main_url);

    for (final tag in item.tags) {
      add_page.add_tag(
        tag.$1,
        await fp.Option.fromNullable(tag.$2)
            .toTaskOption()
            .flatMap(
              (image_path) =>
                  fp.TaskOption.tryCatch(
                    () async => await File(image_path).readAsBytes(),
                  ).orElse(() {
                    show_warning_toast("Failed to load image of ${tag.$1}");
                    return fp.TaskOption.none();
                  }),
            )
            .run(),
      );
    }

    for (final url in item.urls) {
      add_page.add_link(url);
    }

    await _go_to_add_page(add_page);
  }

  Future<void> _go_to_add_page(AddPage page) async {
    if (context.mounted) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => page));
    }
  }
}

class _ArtistItem extends StatefulWidget {
  final ArtistStreamItem data;
  final void Function(ArtistStreamItem) fn_go_to_add_page;
  final void Function(int) fn_delete_artist_item;
  final Map<String, Color> memo_update;

  const _ArtistItem(
    this.data,
    this.fn_go_to_add_page,
    this.fn_delete_artist_item,
    this.memo_update,
  );

  @override
  createState() => _ArtistItemState();
}

class _ArtistItemState extends State<_ArtistItem> {
  Color circle_color = Colors.grey[800]!;
  fp.Option<(String, File)> selected_tag = fp.none();
  final image_key = GlobalKey();

  @override
  void initState() {
    super.initState();

    check_update();
  }

  Future<void> check_update() async {
    if (!widget.memo_update.containsKey(widget.data.name)) {
      widget.memo_update[widget.data.name] =
          await get_artist_data_from_url(widget.data.main_url)
              .map((r) => r.$2)
              .map(
                (last_gallery_id) =>
                    last_gallery_id == widget.data.last_gallery_id
                    ? Colors.green
                    : Colors.orange,
              )
              .getOrElse((_) => Colors.red)
              .run();
    }

    if (mounted) {
      setState(() {
        circle_color = widget.memo_update[widget.data.name]!;
      });
    }
  }

  void scroll_to_image(BuildContext context) {
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = selected_tag.match(
      () => [build_inner_content()],
      (tag) => [
        build_inner_content(),
        SizedBox(height: 10),
        Flexible(
          child: SizedBox(
            child: FutureBuilder<fp.Option<Uint8List>>(
              future: fp.TaskOption.tryCatch(
                () async => tag.$2.readAsBytes(),
              ).run(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                return snapshot.data!.match(
                  () => Icon(Icons.broken_image),
                  (bytes) => Image.memory(
                    bytes,
                    width: .infinity,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          if (frame != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              scroll_to_image(context);
                            });
                          }

                          return child;
                        },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );

    return Card(
      child: Padding(
        padding: .all(5),
        child: Column(
          mainAxisSize: .min,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Row(
                  mainAxisSize: .min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: circle_color,
                        shape: .circle,
                      ),
                    ),
                    SizedBox(width: 5),
                    Flexible(
                      child: GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: widget.data.main_url),
                          );

                          show_success_toast("Artist URL copied!");
                        },
                        child: Text(
                          widget.data.name,
                          style: get_artist_name_style(),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => widget.fn_go_to_add_page(widget.data),
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (await show_yes_no_dialog(
                          context,
                          "Delete",
                          "Delete '${widget.data.name}?'",
                        )) {
                          widget.fn_delete_artist_item(widget.data.id);
                        }
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              ],
            ),

            ...children,
          ],
        ),
      ),
    );
  }

  Widget build_inner_content() {
    return Table(
      columnWidths: {0: FlexColumnWidth(1), 1: FlexColumnWidth(5)},
      children: [
        TableRow(
          children: [
            const TableCell(
              verticalAlignment: .middle,
              child: Center(child: Text("Tags")),
            ),
            Padding(
              padding: EdgeInsetsGeometry.all(8),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: widget.data.tags.map((tag) {
                  return OutlinedButton(
                    onPressed: tag.$2 != null
                        ? () {
                            setState(() {
                              final new_tag = (tag.$1, File(tag.$2!));
                              selected_tag.match(
                                () => selected_tag = fp.some(new_tag),
                                (prev) {
                                  if (tag.$1 == prev.$1) {
                                    selected_tag = fp.none();
                                  } else {
                                    selected_tag = fp.some(new_tag);
                                  }
                                },
                              );
                            });
                          }
                        : null,
                    style: get_tag_style(
                      selected_tag.map((v) => v.$1).getOrElse(() => "") ==
                              tag.$1
                          ? Colors.blue
                          : null,
                    ),
                    child: Text(tag.$1),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const TableCell(
              verticalAlignment: .middle,
              child: Center(child: Text("Links")),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: widget.data.urls
                  .map(
                    (url) => GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: url));

                        show_success_toast("URL copied!");
                      },
                      child: Text(url, style: get_link_style()),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }
}
