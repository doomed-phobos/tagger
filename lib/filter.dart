class Filter {
  final String? artist_name;
  final List<String> tags;

  Filter(this.artist_name, this.tags);
  
  Filter.empty() : this(null, []);

  static Filter make(String query) {
    consume() {
      if (query.isEmpty) return null;

      final i = query.lastIndexOf("tag:");
      late String token;
      if (i < 0) {
        token = query;
        query = "";
      } else {
        token = query.substring(i);
        query = query.substring(0, i);
      }

      return token.trim();
    }

    String? artistname;
    final tags = <String>[];

    for (String? token = consume(); token != null; token = consume()) {
      if (token.startsWith("tag:")) {
        final tag = token.substring(4).trim();
        if (tag.isNotEmpty) tags.add(tag);
      } else {
        artistname ??= token;
      }
    }

    return Filter(artistname, tags);
  }
}
