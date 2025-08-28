import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('MyRouteInformationParser.parseRouteInformation', () {
    test('"/" devuelve stack con defaultRouteName y segmentos vacíos',
        () async {
      const MyRouteInformationParser p = MyRouteInformationParser();

      final NavStackModel s = await p.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/')),
      );

      expect(s.pages.length, 1);
      expect(s.top.name, 'home');
      expect(s.top.segments, isEmpty);
    });

    test('mapea slug con slugToName y separa segmentos y query', () async {
      const MyRouteInformationParser p = MyRouteInformationParser(
        slugToName: MyRouteInformationParser.kebabToCamel,
      );

      final NavStackModel s = await p.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/index-app/foo/bar?x=1&y=ok')),
      );

      expect(s.pages.length, 1);
      expect(s.top.name, 'indexApp'); // kebab→camel
      expect(s.top.segments, <String>['foo', 'bar']);
      expect(s.top.query, <String, String>{'x': '1', 'y': 'ok'});
    });
  });

  group('MyRouteInformationParser.restoreRouteInformation', () {
    PageModel p0(String name, {List<String>? seg, Map<String, String>? q}) =>
        PageModel(
          name: name,
          segments: seg ?? const <String>[],
          query: q ?? const <String, String>{},
        );

    test('convierte el top del stack a Uri (toUriString)', () {
      const MyRouteInformationParser p = MyRouteInformationParser();

      final NavStackModel stack = NavStackModel(<PageModel>[
        p0('home'),
        p0('profile', seg: <String>['me'], q: <String, String>{'tab': 'posts'}),
      ]);

      final RouteInformation? ri = p.restoreRouteInformation(stack);
      expect(ri, isNotNull);

      // Según tu implementación de PageModel.toUriString(), el name no va en el path:
      // path esperado: "/me?tab=posts"
      expect(ri!.uri.path, '/me');
      expect(ri.uri.queryParameters['tab'], 'posts');
    });
  });

  group('kebabToCamel util', () {
    test('convierte "index-app-settings" → "indexAppSettings"', () {
      expect(
        MyRouteInformationParser.kebabToCamel('index-app-settings'),
        'indexAppSettings',
      );
    });

    test('deja cadenas vacías o sin "-" como están', () {
      expect(MyRouteInformationParser.kebabToCamel(''), '');
      expect(MyRouteInformationParser.kebabToCamel('home'), 'home');
    });
  });
}
