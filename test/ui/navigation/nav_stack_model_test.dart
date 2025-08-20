import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('NavStackModel', () {
    const PageModel home = PageModel(name: 'home', segments: <String>['home']);
    const PageModel details =
        PageModel(name: 'details', segments: <String>['products', '42']);

    test('push / top / pop', () {
      NavStackModel s = NavStackModel.single(home);
      expect(s.top, home);
      expect(s.isRoot, isTrue);

      s = s.push(details);
      expect(s.top, details);
      expect(s.isRoot, isFalse);

      s = s.pop();
      expect(s.top, home);
      expect(s.isRoot, isTrue);
    });

    test('replaceTop', () {
      NavStackModel s = NavStackModel.single(home);
      s = s.replaceTop(details);
      expect(s.top, details);
      expect(s.pages.length, 1);
    });

    test('route chain round-trip', () {
      final NavStackModel s = NavStackModel(const <PageModel>[home, details]);
      final String chain = s.encodeAsRouteChain();
      final NavStackModel t = NavStackModel.decodeRouteChain(chain);
      expect(t, s);
    });

    test('json round-trip', () {
      final NavStackModel s = NavStackModel(const <PageModel>[home, details]);
      final NavStackModel t = NavStackModel.fromJson(s.toJson());
      expect(t, s);
    });
  });
}
