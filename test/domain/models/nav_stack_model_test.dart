import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  // Helpers
  PageModel p({
    required String name,
    List<String>? segments,
    Map<String, String>? query,
    PageKind kind = PageKind.material,
    bool requiresAuth = false,
    Map<String, dynamic>? state,
  }) {
    return PageModel(
      name: name,
      segments: segments ?? <String>[name],
      query: query ?? const <String, String>{},
      kind: kind,
      requiresAuth: requiresAuth,
      state: state ?? const <String, dynamic>{},
    );
  }

  group('NavStackModel · constructor & basics', () {
    test('single() crea stack con un único root; top e isRoot coherentes', () {
      final NavStackModel s = NavStackModel.single(p(name: 'home'));
      expect(s.pages.length, 1);
      expect(s.top.name, 'home');
      expect(s.isRoot, isTrue);
    });

    test('pop() en root retorna la MISMA instancia (no-op)', () {
      final NavStackModel s = NavStackModel.single(p(name: 'home'));
      final NavStackModel s2 = s.pop();
      expect(
        identical(s, s2),
        isTrue,
        reason: 'Debe devolver la misma referencia',
      );
      expect(s2.top.name, 'home');
    });

    test('push()/replaceTop()/pop() cambian el top de forma esperada', () {
      NavStackModel s = NavStackModel.single(p(name: 'home'));
      s = s.push(p(name: 'details', segments: <String>['products', '42']));
      expect(s.top.name, 'details');
      expect(s.isRoot, isFalse);

      s = s
          .replaceTop(p(name: 'details', segments: <String>['products', '99']));
      expect(s.top.segments, <String>['products', '99']);

      s = s.pop();
      expect(s.top.name, 'home');
      expect(s.isRoot, isTrue);
    });

    test('resetTo() borra toda la pila y deja un único root', () {
      NavStackModel s = NavStackModel.single(p(name: 'home'));
      s = s.push(p(name: 'a'));
      s = s.push(p(name: 'b'));
      expect(s.pages.length, 3);

      s = s.resetTo(p(name: 'root2'));
      expect(s.pages.length, 1);
      expect(s.top.name, 'root2');
      expect(s.isRoot, isTrue);
    });
  });

  group('NavStackModel · JSON round-trip', () {
    test('toJson/fromJson conserva páginas; fromJson vacío crea root default',
        () {
      final NavStackModel s = NavStackModel(<PageModel>[
        p(name: 'home'),
        p(
          name: 'product',
          segments: <String>['products', '1'],
          query: <String, String>{'ref': 'home'},
        ),
      ]);

      final Map<String, dynamic> j = s.toJson();
      final NavStackModel parsed = NavStackModel.fromJson(j);

      expect(parsed.pages.length, 2);
      expect(parsed.top.name, 'product');
      expect(
        listEquals(parsed.top.segments, <String>['products', '1']),
        isTrue,
      );
      expect(
        mapEquals(parsed.top.query, <String, String>{'ref': 'home'}),
        isTrue,
      );

      // fromJson con lista vacía → root default
      final NavStackModel emptyParsed =
          NavStackModel.fromJson(const <String, dynamic>{'pages': <dynamic>[]});
      expect(emptyParsed.pages.length, 1);
      expect(emptyParsed.top.name, 'root');
      expect(emptyParsed.top.segments, isEmpty);
    });
  });

  group('NavStackModel · route chain encode/decode', () {
    test('encodeAsRouteChain / decodeRouteChain son inversos básicos', () {
      final NavStackModel s = NavStackModel(<PageModel>[
        p(name: 'home', segments: <String>['home']),
        p(
          name: 'product',
          segments: <String>['products', '42'],
          query: <String, String>{'ref': 'home'},
        ),
        p(
          name: 'about',
          segments: <String>['about'],
        ),
      ]);

      final String chain = s.encodeAsRouteChain();
      final NavStackModel r = NavStackModel.decodeRouteChain(chain);

      expect(r.pages.length, 3);
      expect(r.top.name, 'about');
      expect(r.pages.first.name, 'home');
      expect(
        mapEquals(r.pages[1].query, <String, String>{'ref': 'home'}),
        isTrue,
      );
    });

    test('decodeRouteChain con string vacío → root default', () {
      final NavStackModel r = NavStackModel.decodeRouteChain('   ');
      expect(r.pages.length, 1);
      expect(r.top.name, 'root');
      expect(r.top.segments, isEmpty);
    });
  });

  group('NavStackModel · igualdad y hashCode', () {
    test(
        '== compara elemento a elemento (orden y contenido) y hashCode estable',
        () {
      final NavStackModel a = NavStackModel(<PageModel>[
        p(name: 'home'),
        p(name: 'a'),
      ]);
      final NavStackModel b = NavStackModel(<PageModel>[
        p(name: 'home'),
        p(name: 'a'),
      ]);
      final NavStackModel c = NavStackModel(<PageModel>[
        p(name: 'home'),
        p(name: 'b'),
      ]);

      expect(a == b, isTrue);
      expect(a.hashCode, equals(b.hashCode));

      expect(a == c, isFalse);
    });

    test('copyWith reemplaza la lista de pages cuando se provee', () {
      final NavStackModel s = NavStackModel(<PageModel>[p(name: 'home')]);
      final NavStackModel s2 = s.copyWith(pages: <PageModel>[p(name: 'x')]);
      expect(s2.pages.length, 1);
      expect(s2.top.name, 'x');
      expect(s.top.name, 'home', reason: 'original inmutable');
    });
  });

  group('NavStackModel · pushDistinctTop()', () {
    test('evita duplicado consecutivo según _routeEquals (default)', () {
      NavStackModel s = NavStackModel.single(
        p(name: 'home', segments: <String>['home']),
      );
      final PageModel home2 =
          p(name: 'home', segments: <String>['home']); // igual ruta
      s = s.pushDistinctTop(home2);
      expect(s.pages.length, 1, reason: 'igual al top → no agrega');

      final PageModel homeQuery = p(
        name: 'home',
        segments: <String>['home'],
        query: <String, String>{'ref': 'x'},
      );
      s = s.pushDistinctTop(homeQuery);
      expect(s.pages.length, 2, reason: 'query distinto → distinta ruta');
      expect(s.top.query['ref'], 'x');
    });

    test('con comparador custom (por nombre) evita duplicados de mismo nombre',
        () {
      bool nameEquals(PageModel a, PageModel b) => a.name == b.name;

      NavStackModel s = NavStackModel.single(p(name: 'home'));
      s = s.pushDistinctTop(p(name: 'home'), equals: nameEquals);
      expect(
        s.pages.length,
        1,
        reason: 'mismo nombre (custom) → evita duplicado',
      );

      s = s.pushDistinctTop(p(name: 'home2'), equals: nameEquals);
      expect(s.pages.length, 2);
      expect(s.top.name, 'home2');
    });
  });

  group('NavStackModel · pushOnce()', () {
    test('garantiza una sola instancia “igual” (default por ruta)', () {
      NavStackModel s = NavStackModel(<PageModel>[
        p(name: 'home', segments: <String>['home']),
        p(name: 'a', segments: <String>['a']),
        p(name: 'home', segments: <String>['home']), // duplicado
      ]);

      s = s.pushOnce(p(name: 'home', segments: <String>['home']));
      // Debe dejar solo uno de 'home' y ponerlo al top
      expect(s.top.name, 'home');
      final int countHome = s.pages
          .where(
            (PageModel x) =>
                x.name == 'home' && listEquals(x.segments, <String>['home']),
          )
          .length;
      expect(countHome, 1);
    });

    test('comparador custom por nombre elimina previos con ese nombre', () {
      bool nameEquals(PageModel a, PageModel b) => a.name == b.name;
      NavStackModel s = NavStackModel(<PageModel>[
        p(name: 'home'),
        p(name: 'details'),
        p(name: 'home'),
      ]);
      s = s.pushOnce(p(name: 'home'), equals: nameEquals);

      expect(s.top.name, 'home');
      expect(s.pages.where((PageModel x) => x.name == 'home').length, 1);
      expect(s.pages.length, 2, reason: 'se removió un repetido');
    });
  });

  group('NavStackModel · dedupAll()', () {
    test('conserva el primer encontrado y elimina subsecuentes “iguales”', () {
      NavStackModel s = NavStackModel(<PageModel>[
        p(name: 'home', segments: <String>['home']),
        p(name: 'a', segments: <String>['a']),
        p(name: 'home', segments: <String>['home']),
        p(name: 'b', segments: <String>['b']),
        p(name: 'a', segments: <String>['a']),
      ]);

      s = s.dedupAll(); // por ruta
      expect(s.pages.length, 3);
      expect(s.pages[0].name, 'home');
      expect(s.pages[1].name, 'a');
      expect(s.pages[2].name, 'b');
    });

    test('comparador por nombre conserva primer nombre y elimina repetidos',
        () {
      bool nameEquals(PageModel a, PageModel b) => a.name == b.name;
      NavStackModel s = NavStackModel(<PageModel>[
        p(name: 'x', segments: <String>['x1']),
        p(name: 'x', segments: <String>['x2']),
        p(name: 'y'),
        p(name: 'x', segments: <String>['x3']),
      ]);

      s = s.dedupAll(equals: nameEquals);
      expect(s.pages.length, 2);
      expect(
        s.pages[0].segments,
        <String>['x1'],
        reason: 'conserva el primero',
      );
      expect(s.pages[1].name, 'y');
    });
  });

  group('NavStackModel · moveToTopOrPush()', () {
    test('si existe “igual”, lo mueve al top (removiendo previos); si no, push',
        () {
      NavStackModel s = NavStackModel(<PageModel>[
        p(name: 'home', segments: <String>['home']),
        p(name: 'a', segments: <String>['a']),
        p(name: 'b', segments: <String>['b']),
      ]);

      // Mover 'a' al top
      s = s.moveToTopOrPush(p(name: 'a', segments: <String>['a']));
      expect(s.top.name, 'a');
      expect(s.pages.where((PageModel x) => x.name == 'a').length, 1);

      // No existe 'c' → push
      s = s.moveToTopOrPush(p(name: 'c', segments: <String>['c']));
      expect(s.top.name, 'c');
      expect(s.pages.length, 4);
    });

    test('comparador custom por nombre: mueve por nombre y respeta único', () {
      bool nameEquals(PageModel a, PageModel b) => a.name == b.name;
      NavStackModel s = NavStackModel(<PageModel>[
        p(name: 'home'),
        p(name: 'profile'),
        p(name: 'settings'),
      ]);

      s = s.moveToTopOrPush(p(name: 'profile'), equals: nameEquals);
      expect(s.top.name, 'profile');
      expect(s.pages.where((PageModel x) => x.name == 'profile').length, 1);
    });
  });

  group('NavStackModel · toString()', () {
    test('representación contiene el listado de names', () {
      final NavStackModel s = NavStackModel(<PageModel>[
        p(name: 'home'),
        p(name: 'a'),
        p(name: 'b'),
      ]);

      final String str = s.toString();
      expect(str.contains('home'), isTrue);
      expect(str.contains('a'), isTrue);
      expect(str.contains('b'), isTrue);
    });
  });
}
