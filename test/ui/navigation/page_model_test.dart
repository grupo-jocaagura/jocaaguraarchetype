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
}
