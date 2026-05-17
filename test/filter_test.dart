import "package:flutter_test/flutter_test.dart";
import "package:tagger/filter.dart";

void main() {
  group("Artist name", () {
    test("empty", () {
      final result = Filter.make("");

      expect(result.artist_name, null);
    });

    test("basic", () {
      final result = Filter.make("artistname");

      expect(result.artist_name, "artistname");
    });

    test("trim start", () {
      final result = Filter.make("  artistname");

      expect(result.artist_name, "artistname");
    });
    
    test("trim end", () {
      final result = Filter.make("artistname   ");

      expect(result.artist_name, "artistname");
    });

    test("trim around", () {
      final result = Filter.make("     artistname   ");

      expect(result.artist_name, "artistname");
    });
    
    test("trim between", () {
      final result = Filter.make("artist        name");

      expect(result.artist_name, "artist        name");
    });

    test("trim everywhere", () {
      final result = Filter.make("   a  rt is t        na m     e");

      expect(result.artist_name, "a  rt is t        na m     e");
    });
  });
  
  group("Tag", () {
    test("basic", () {
      final result = Filter.make("tag:tag");

      expect(result.tags, unorderedEquals(["tag"]));
    });

    test("empty", () {
      final result = Filter.make("");

      expect(result.tags, unorderedEquals([]));
    });

    test("space at start query", () {
      final result = Filter.make(" tag:1");

      expect(result.tags, unorderedEquals(["1"]));
    });

    test("weird", () {
      final result = Filter.make("tag:tag:");

      expect(result.tags, unorderedEquals([]));
    });

    test("long", () {
      final result = Filter.make("tag:this is a long tag");

      expect(result.tags, unorderedEquals(["this is a long tag"]));
    });

    test("multiples", () {
      final result = Filter.make("tag:this is a long tag tag:short");

      expect(result.tags, unorderedEquals(["this is a long tag", "short"]));
    });

    test("multiples with space everywhere", () {
      final result = Filter.make("tag:this    is  a  long  tag    tag:  short    tag:hi   ");

      expect(result.tags, unorderedEquals(["this    is  a  long  tag", "short", "hi"]));
    });
    
    test("concatenado", () {
      final result = Filter.make("tag:thisisanewtag:hi");

      expect(result.tags, unorderedEquals(["thisisanew", "hi"]));
    });

    test("tag at end", () {
      final result = Filter.make("tag:1 tag:");

      expect(result.tags, unorderedEquals(["1"]));
    });
  });

  group("Artist & Tags", () {
    test("basic", () {
      final result = Filter.make("artist name tag:tag1 tag:2");
  
      expect(result.artist_name, "artist name");
      expect(result.tags, unorderedEquals(["tag1", "2"]));
    });

    test("artistname at end", () {
      final result = Filter.make("tag:tag1 tag:2 artistname");
  
      expect(result.artist_name, null);
      expect(result.tags, unorderedEquals(["tag1", "2 artistname"]));
    });

    test("basic2", () {
      final result = Filter.make("foo tag:anime bar");
  
      expect(result.artist_name, "foo");
      expect(result.tags, unorderedEquals(["anime bar"]));
    });

    test("spaced tags", () {
      final result = Filter.make("artistname tag:tag1 tag:2 tag:     3tag:4 ");
  
      expect(result.artist_name, "artistname");
      expect(result.tags, unorderedEquals(["tag1", "2", "3", "4"]));
    });
  });
}
