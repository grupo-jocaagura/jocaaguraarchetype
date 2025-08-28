import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('PageModel · fromUri()', () {
    test('parsea segmentos, query y fragment; infiere name del primer segmento',
        () {
      final Uri uri = Uri.parse('/products/42?ref=home#gallery');
      final PageModel p = PageModel.fromUri(uri);

      expect(p.name, 'products');
      expect(p.segments, <String>['products', '42']);
      expect(p.query, <String, String>{'ref': 'home'});
      expect(p.fragment, 'gallery');
      expect(p.kind, PageKind.material, reason: 'default kind');
      expect(p.requiresAuth, isFalse);
      expect(p.state, isEmpty);
    });

    test('si path vacío → name = "root", segments vacíos, fragment null', () {
      final PageModel p = PageModel.fromUri(Uri.parse('/'));

      expect(p.name, 'root');
      expect(p.segments, isEmpty);
      expect(p.query, isEmpty);
      expect(p.fragment, isNull);
    });

    test('respeta name explícito y kind personalizado', () {
      final PageModel p = PageModel.fromUri(
        Uri.parse('/a/b'),
        name: 'custom',
        kind: PageKind.dialog,
      );
      expect(p.name, 'custom');
      expect(p.kind, PageKind.dialog);
      expect(p.segments, <String>['a', 'b']);
    });

    test('decodifica URL components en segmentos y query', () {
      final PageModel p = PageModel.fromUri(
        Uri.parse('/category/My%20Item?q=hello%20world'),
      );
      expect(p.segments, <String>['category', 'My Item']);
      expect(p.query, <String, String>{'q': 'hello world'});
    });
  });

  group('PageModel · toUriString()', () {
    test('encodea correctamente query y fragment', () {
      const PageModel p = PageModel(
        name: 'details',
        segments: <String>['products', 'Mi Producto'],
        query: <String, String>{'ref': 'home & deals'},
        fragment: 'sec-1',
      );

      final String uriStr = p.toUriString();
      final Uri uri = Uri.parse(uriStr);

      // Path codifica espacios como %20
      expect(uri.path, '/products/Mi%20Producto');

      // Query parameters deben preservarse decodificados
      expect(uri.queryParameters, <String, String>{'ref': 'home & deals'});

      // Fragment igual
      expect(uri.fragment, 'sec-1');
    });

    test('sin query ni fragment → sólo la ruta con slash inicial', () {
      const PageModel p = PageModel(
        name: 'home',
        segments: <String>['home'],
      );
      expect(p.toUriString(), '/home');
    });

    test('segmentos vacíos → "/"', () {
      const PageModel p = PageModel(
        name: 'root',
        segments: <String>[],
      );
      expect(p.toUriString(), '/');
    });
  });

  group('PageModel · JSON roundtrip', () {
    test('toJson/fromJson preserva campos básicos y tipos', () {
      const PageModel original = PageModel(
        name: 'details',
        segments: <String>['products', '42'],
        query: <String, String>{'ref': 'home', 'coupon': 'A&B'},
        fragment: 'images',
        kind: PageKind.fullScreenDialog,
        requiresAuth: true,
        state: <String, dynamic>{'scroll': 120.5, 'fav': true},
      );

      final Map<String, dynamic> json = original.toJson();
      final PageModel parsed = PageModel.fromJson(json);

      expect(parsed, original);
      expect(parsed.kind, PageKind.fullScreenDialog);
      expect(parsed.requiresAuth, isTrue);
      expect(parsed.state['scroll'], 120.5);
      expect(parsed.state['fav'], true);
    });

    test('fromJson con kind desconocido → fallback a material', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'name': 'k',
        'segments': <String>['k'],
        'query': <String, String>{},
        'fragment': null,
        'kind': 'unknown-kind',
        'requiresAuth': false,
        'state': <String, dynamic>{},
      };

      final PageModel parsed = PageModel.fromJson(json);
      expect(parsed.kind, PageKind.material);
    });

    test('fromJson con mapas/listas nulos → defaults seguros', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'name': 'safe',
        'segments': <String>['safe'],
        // query/state/fragment omitidos
      };

      final PageModel parsed = PageModel.fromJson(json);
      expect(parsed.query, isEmpty);
      expect(parsed.state, isEmpty);
      expect(parsed.fragment, isNull);
      expect(parsed.requiresAuth, isFalse);
    });
  });

  group('PageModel · copyWith()', () {
    test('reemplaza sólo campos provistos', () {
      const PageModel base = PageModel(
        name: 'home',
        segments: <String>['home'],
        query: <String, String>{'a': '1'},
        fragment: 'top',
        state: <String, dynamic>{'x': 1},
      );

      final PageModel cpy = base.copyWith(
        name: 'dashboard',
        segments: <String>['dash'],
        query: <String, String>{'b': '2'},
        fragment: 'main',
        kind: PageKind.cupertino,
        requiresAuth: true,
        state: <String, dynamic>{'y': 2},
      );

      expect(cpy.name, 'dashboard');
      expect(cpy.segments, <String>['dash']);
      expect(cpy.query, <String, String>{'b': '2'});
      expect(cpy.fragment, 'main');
      expect(cpy.kind, PageKind.cupertino);
      expect(cpy.requiresAuth, isTrue);
      expect(cpy.state, <String, dynamic>{'y': 2});

      // inmutabilidad del original
      expect(base.name, 'home');
      expect(base.fragment, 'top');
      expect(base.kind, PageKind.material);
      expect(base.requiresAuth, isFalse);
    });
  });

  group('PageModel · igualdad y hashCode', () {
    test('dos PageModel idénticos son == y comparten hashCode', () {
      const PageModel a = PageModel(
        name: 'details',
        segments: <String>['p', '1'],
        query: <String, String>{'ref': 'x'},
        fragment: 'f',
        kind: PageKind.dialog,
        requiresAuth: true,
        state: <String, dynamic>{'s': 1},
      );
      const PageModel b = PageModel(
        name: 'details',
        segments: <String>['p', '1'],
        query: <String, String>{'ref': 'x'},
        fragment: 'f',
        kind: PageKind.dialog,
        requiresAuth: true,
        state: <String, dynamic>{'s': 1},
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('cambio en cualquier parte relevante rompe igualdad', () {
      const PageModel base = PageModel(
        name: 'a',
        segments: <String>['x'],
        query: <String, String>{'q': '1'},
        fragment: 'f',
        state: <String, dynamic>{'k': 'v'},
      );

      expect(
        base ==
            base.copyWith(
              name: 'b',
            ),
        isFalse,
      );
      expect(
        base ==
            base.copyWith(
              segments: <String>['x', 'y'],
            ),
        isFalse,
      );
      expect(
        base ==
            base.copyWith(
              query: <String, String>{'q': '2'},
            ),
        isFalse,
      );
      expect(
        base ==
            base.copyWith(
              fragment: 'g',
            ),
        isFalse,
      );
      expect(
        base ==
            base.copyWith(
              kind: PageKind.cupertino,
            ),
        isFalse,
      );
      expect(
        base ==
            base.copyWith(
              requiresAuth: true,
            ),
        isFalse,
      );
      expect(
        base ==
            base.copyWith(
              state: <String, dynamic>{'k': 'different'},
            ),
        isFalse,
      );
    });
  });

  group('PageModel · casos de borde con fragment y query', () {
    test('fragment vacío o null no debe aparecer en toUriString', () {
      const PageModel withNull = PageModel(
        name: 'home',
        segments: <String>['home'],
      );
      const PageModel withEmpty = PageModel(
        name: 'home',
        segments: <String>['home'],
        fragment: '',
      );

      expect(withNull.toUriString(), '/home');
      expect(withEmpty.toUriString(), '/home');
    });

    test('query vacío se omite en toUriString', () {
      const PageModel p = PageModel(
        name: 'home',
        segments: <String>['home'],
      );
      expect(p.toUriString(), '/home');
    });

    test('query con caracteres especiales se encodea/decodifica correctamente',
        () {
      const PageModel p = PageModel(
        name: 'q',
        segments: <String>['q'],
        query: <String, String>{
          'space': 'a b',
          'amp': 'x&y',
          'unicode': 'á/ñ',
        },
      );

      final String uri = p.toUriString();
      final PageModel parsed = PageModel.fromUri(Uri.parse(uri));

      expect(parsed.query['space'], 'a b');
      expect(parsed.query['amp'], 'x&y');
      expect(parsed.query['unicode'], 'á/ñ');
    });
  });
}
