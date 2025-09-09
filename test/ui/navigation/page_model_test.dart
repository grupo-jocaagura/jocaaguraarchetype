import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('PageModel', () {
    test('toUriString / fromUri round-trip', () {
      const PageModel a = PageModel(
        name: 'details',
        segments: <String>['products', '42'],
        query: <String, String>{'ref': 'home', 'q': 'ç'},
        fragment: 'top',
      );
      final String uriStr = a.toUriString();
      final PageModel b = PageModel.fromUri(Uri.parse(uriStr), name: 'details');

      expect(b.name, 'details');
      expect(b.segments, <String>['products', '42']);
      expect(b.query['ref'], 'home');
      expect(b.query['q'], 'ç');
      expect(b.fragment, 'top');
    });

    test('json round-trip preserves fields', () {
      const PageModel a = PageModel(
        name: 'x',
        segments: <String>['a', 'b'],
        query: <String, String>{'k': 'v'},
        fragment: 'f',
        kind: PageKind.dialog,
        requiresAuth: true,
        state: <String, dynamic>{'mode': 'edit', 'count': 1},
      );
      final PageModel b = PageModel.fromJson(a.toJson());
      expect(b, a);
      expect(b.hashCode, a.hashCode);
    });
  });
  group('PageModel.hash helpers', () {
    test(
        'hashUnorderedStringMap: same content different order yields same hash',
        () {
      const int seed = 12345;
      final Map<String, String> map1 = <String, String>{'a': '1', 'b': '2'};
      final Map<String, String> map2 = <String, String>{'b': '2', 'a': '1'};

      final int h1 = PageModel.hashUnorderedStringMap(map1, seed);
      final int h2 = PageModel.hashUnorderedStringMap(map2, seed);

      expect(h1, equals(h2));
    });

    test('hashUnorderedStringMap: different values produce different hash', () {
      const int seed = 999;
      final Map<String, String> map1 = <String, String>{'x': '1'};
      final Map<String, String> map2 = <String, String>{'x': '2'};

      final int h1 = PageModel.hashUnorderedStringMap(map1, seed);
      final int h2 = PageModel.hashUnorderedStringMap(map2, seed);

      expect(h1, isNot(equals(h2)));
    });

    test('hashUnorderedDynamicMap: order does not affect hash', () {
      const int seed = 555;
      final Map<String, dynamic> map1 = <String, dynamic>{'k1': 1, 'k2': true};
      final Map<String, dynamic> map2 = <String, dynamic>{'k2': true, 'k1': 1};

      final int h1 = PageModel.hashUnorderedDynamicMap(map1, seed);
      final int h2 = PageModel.hashUnorderedDynamicMap(map2, seed);

      expect(h1, equals(h2));
    });

    test('hashUnorderedDynamicMap: null vs non-null changes hash', () {
      const int seed = 42;
      final Map<String, dynamic> map1 = <String, dynamic>{'k': null};
      final Map<String, dynamic> map2 = <String, dynamic>{'k': 0};

      final int h1 = PageModel.hashUnorderedDynamicMap(map1, seed);
      final int h2 = PageModel.hashUnorderedDynamicMap(map2, seed);

      expect(h1, isNot(equals(h2)));
    });

    test('hashCode of PageModel is stable regardless of insertion order', () {
      const PageModel a = PageModel(
        name: 'test',
        query: <String, String>{'a': '1', 'b': '2'},
        state: <String, dynamic>{'x': true, 'y': 99},
      );

      const PageModel b = PageModel(
        name: 'test',
        query: <String, String>{'b': '2', 'a': '1'},
        state: <String, dynamic>{'y': 99, 'x': true},
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
  group('PageModel.copyWith immutability', () {
    test('copyWith returns unmodifiable collections when new ones are provided',
        () {
      final List<String> segIn = <String>['a', 'b'];
      final Map<String, String> qIn = <String, String>{'k': 'v'};
      final Map<String, dynamic> stIn = <String, dynamic>{'s': 1};

      const PageModel base = PageModel(name: 'p');
      final PageModel copy = base.copyWith(
        segments: segIn,
        query: qIn,
        state: stIn,
      );

      // Try to mutate exposed collections -> must throw.
      expect(() => copy.segments.add('x'), throwsUnsupportedError);
      expect(() => copy.query['q'] = 'w', throwsUnsupportedError);
      expect(() => copy.state['t'] = 2, throwsUnsupportedError);

      // Mutate the original inputs -> copy must remain unaffected (defensive copy).
      segIn.add('Z');
      qIn['k'] = 'CHANGED';
      stIn['s'] = 999;

      expect(copy.segments, <String>['a', 'b']); // unchanged
      expect(copy.query, <String, String>{'k': 'v'}); // unchanged
      expect(copy.state, <String, dynamic>{'s': 1}); // unchanged
    });

    test('copyWith keeps immutability when reusing existing collections', () {
      const PageModel original = PageModel(
        name: 'p',
        segments: <String>['x'],
        query: <String, String>{'k': 'v'},
        state: <String, dynamic>{'s': true},
      );

      // Do not pass new collections -> must still be unmodifiable on the copy.
      final PageModel copy = original.copyWith(name: 'p2');

      expect(() => copy.segments.add('y'), throwsUnsupportedError);
      expect(() => copy.query['q'] = 'w', throwsUnsupportedError);
      expect(() => copy.state['t'] = 1, throwsUnsupportedError);

      // Identity-wise, only name changed.
      expect(copy.name, 'p2');
      expect(copy.segments, <String>['x']);
      expect(copy.query, <String, String>{'k': 'v'});
      expect(copy.state, <String, dynamic>{'s': true});
    });

    test(
        'copyWith preserves equality semantics (only changed fields affect ==)',
        () {
      const PageModel a = PageModel(
        name: 'p',
        segments: <String>['s1', 's2'],
        query: <String, String>{'a': '1'},
        state: <String, dynamic>{'x': 10},
      );

      // Change nothing -> equal
      final PageModel b = a.copyWith();
      expect(b, equals(a));

      // Change route field -> not equal
      final PageModel c = a.copyWith(segments: <String>['s1', 'DIFF']);
      expect(c == a, isFalse);

      // Restore segments and change only state -> not equal (by current contract)
      final PageModel d = a.copyWith(state: <String, dynamic>{'x': 11});
      expect(d == a, isFalse);
    });
  });
}
