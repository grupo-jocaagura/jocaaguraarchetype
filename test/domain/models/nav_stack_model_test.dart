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
      expect(emptyParsed.top.name, NavStackModel.defaultName);
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
      expect(r.top.name, NavStackModel.defaultName);
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
  group('NavStackModel - invariantes', () {
    test('Given ctor with empty list When created Then normaliza a root', () {
      final NavStackModel s = NavStackModel(const <PageModel>[]);
      expect(s.pages, isNotEmpty);
      expect(s.top.name, NavStackModel.defaultName);
      expect(s.isRoot, isTrue);
    });

    test('Given copyWith([]) When applied Then normaliza a root', () {
      final NavStackModel base =
          NavStackModel.single(const PageModel(name: 'home'));
      final NavStackModel s = base.copyWith(pages: <PageModel>[]);
      expect(s.pages, isNotEmpty);
      expect(s.top.name, NavStackModel.defaultName);
    });
  });

  group('push/pop/replaceTop/resetTo', () {
    test('Given root When push Then top cambia y tamaño +1', () {
      NavStackModel s = NavStackModel.single(const PageModel(name: 'home'));
      s = s.push(const PageModel(name: 'details'));
      expect(s.top.name, 'details');
      expect(s.pages.length, 2);
    });

    test('Given stack When replaceTop Then sustituye sin cambiar tamaño', () {
      NavStackModel s = NavStackModel(const <PageModel>[
        PageModel(name: 'home'),
        PageModel(name: 'a'),
      ]);
      s = s.replaceTop(const PageModel(name: 'b'));
      expect(s.pages.length, 2);
      expect(s.top.name, 'b');
    });

    test('Given root When pop Then retorna misma instancia', () {
      final NavStackModel root =
          NavStackModel.single(const PageModel(name: 'home'));
      final NavStackModel popped = root.pop();
      expect(identical(root, popped), isTrue);
    });

    test('Given stack(2) When pop Then top regresa al anterior', () {
      NavStackModel s = NavStackModel.single(const PageModel(name: 'home'));
      s = s.push(const PageModel(name: 'details'));
      s = s.pop();
      expect(s.top.name, 'home');
      expect(s.pages.length, 1);
    });

    test('Given stack When resetTo Then queda single con root dado', () {
      NavStackModel s = NavStackModel(const <PageModel>[
        PageModel(name: 'home'),
        PageModel(name: 'x'),
      ]);
      s = s.resetTo(const PageModel(name: 'rooted'));
      expect(s.isRoot, isTrue);
      expect(s.top.name, 'rooted');
    });
  });

  group('estrategias de deduplicación', () {
    test('pushDistinctTop evita duplicado consecutivo por routeEquals', () {
      NavStackModel s = NavStackModel.single(
        const PageModel(name: 'home', segments: <String>['home']),
      );
      const PageModel p = PageModel(name: 'home', segments: <String>['home']);
      s = s.pushDistinctTop(p);
      expect(s.pages.length, 1); // no duplicó
    });

    test('pushOnce deja solo una instancia "igual" y la mueve al top', () {
      NavStackModel s = NavStackModel(const <PageModel>[
        PageModel(name: 'home', segments: <String>['home']),
        PageModel(name: 'profile', segments: <String>['u', '1']),
      ]);
      s = s.pushOnce(const PageModel(name: 'home', segments: <String>['home']));
      expect(s.pages.where((PageModel p) => p.name == 'home').length, 1);
      expect(s.top.name, 'home');
    });

    test('dedupAll conserva primera ocurrencia', () {
      final NavStackModel s = NavStackModel(const <PageModel>[
        PageModel(name: 'home'),
        PageModel(name: 'home'), // duplicado
        PageModel(name: 'a'),
        PageModel(name: 'home'), // duplicado
      ]).dedupAll();
      expect(
        s.pages.map((PageModel e) => e.name).toList(),
        <String>['home', 'a'],
      );
    });

    test('moveToTopOrPush quita las previas y sube la nueva', () {
      final NavStackModel s = NavStackModel(const <PageModel>[
        PageModel(name: 'x'),
        PageModel(name: 'home'),
      ]).moveToTopOrPush(const PageModel(name: 'home'));
      expect(s.top.name, 'home');
      expect(s.pages.where((PageModel p) => p.name == 'home').length, 1);
    });
  });

  group('round-trips JSON/URI', () {
    test('toJson/fromJson conservan pila (no vacía)', () {
      final NavStackModel s = NavStackModel(const <PageModel>[
        PageModel(name: 'home', segments: <String>['home']),
        PageModel(name: 'details', segments: <String>['products', '42']),
      ]);
      final Map<String, dynamic> json = s.toJson();
      final NavStackModel r = NavStackModel.fromJson(json);
      expect(r, equals(s));
    });

    test('encodeAsRouteChain/decodeRouteChain conserva orden', () {
      final NavStackModel s = NavStackModel(const <PageModel>[
        PageModel(name: 'home', segments: <String>['home']),
        PageModel(
          name: 'details',
          segments: <String>['products', '42'],
          query: <String, String>{'ref': 'home'},
        ),
      ]);
      final String chain = s.encodeAsRouteChain();
      final NavStackModel r = NavStackModel.decodeRouteChain(chain);
      expect(r.pages.length, 2);
      expect(r.top.name, 'details');
      expect(r.pages.first.name, 'home');
    });

    test('decodeRouteChain con cadena vacía produce root', () {
      final NavStackModel s = NavStackModel.decodeRouteChain('   ');
      expect(s.isRoot, isTrue);
      expect(s.top.name, NavStackModel.defaultName);
    });
  });

  group('igualdad y hashCode', () {
    test('== y hashCode coherentes para pilas iguales', () {
      final NavStackModel a = NavStackModel(const <PageModel>[
        PageModel(name: 'home'),
        PageModel(name: 'a'),
      ]);
      final NavStackModel b = NavStackModel(const <PageModel>[
        PageModel(name: 'home'),
        PageModel(name: 'a'),
      ]);
      expect(a == b, isTrue);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('== detecta diferencias de orden', () {
      final NavStackModel a = NavStackModel(const <PageModel>[
        PageModel(name: 'home'),
        PageModel(name: 'a'),
      ]);
      final NavStackModel b = NavStackModel(const <PageModel>[
        PageModel(name: 'a'),
        PageModel(name: 'home'),
      ]);
      expect(a == b, isFalse);
    });
  });
  group('Route chain encode/decode', () {
    test('Round-trip simple (sin query)', () {
      final NavStackModel original = NavStackModel(const <PageModel>[
        PageModel(name: 'home', segments: <String>['home']),
        PageModel(name: 'details', segments: <String>['products', '42']),
      ]);

      final String chain = original.encodeAsRouteChain();
      final NavStackModel back = NavStackModel.decodeRouteChain(chain);

      expect(
        Iterable<int>.generate(original.pages.length)
            .every((int i) => routeEquals(original.pages[i], back.pages[i])),
        isTrue,
      );
    });

    test('Round-trip con query y espacios', () {
      final NavStackModel original = NavStackModel(const <PageModel>[
        PageModel(
          name: 'search',
          segments: <String>['q'],
          query: <String, String>{'text': 'hello world', 'tags': 'a;b;c'},
        ),
      ]);

      final String chain = original.encodeAsRouteChain();
      // Verifica que los ';' internos fueron escapados y no rompen el split
      expect(chain.contains(';a;b;c'), isFalse);

      final NavStackModel back = NavStackModel.decodeRouteChain(chain);
      expect(listEquals(original.pages, back.pages), isTrue);
    });

    test('decode("") normaliza a default', () {
      final NavStackModel back = NavStackModel.decodeRouteChain('');
      expect(back.pages.isNotEmpty, isTrue);
      expect(back.top.name, defaultNavStackModel.top.name);
    });

    test('fromJson([]) normaliza a default', () {
      final NavStackModel back = NavStackModel.fromJson(const <String, dynamic>{
        'pages': <Map<String, dynamic>>[],
      });
      expect(back.pages.isNotEmpty, isTrue);
      expect(back.top.name, defaultNavStackModel.top.name);
    });

    test('Round-trip encode(decode(x)) estable', () {
      // Cadenas con caracteres complicados; ; debe quedar escapado
      const String chain =
          '/home;/products/42?ref=home;/q?text=a%3Bb%3Bc&space=x+y';
      final NavStackModel back = NavStackModel.decodeRouteChain(chain);
      final String again = back.encodeAsRouteChain();
      expect(
        again,
        chain,
        reason:
            'encode(decode(chain)) debe ser estable si PageModel.toUriString() es determinista',
      );
    });
  });

  group('NavStackModel.copyWith', () {
    test(
        'Given stack inicial When copyWith(null) Then retorna la misma instancia (identical)',
        () {
      // Arrange
      final NavStackModel base =
          NavStackModel.single(const PageModel(name: 'home'));

      // Act
      final NavStackModel out = base.copyWith();

      // Assert
      expect(identical(out, base), isTrue,
          reason: 'Debe devolver this cuando pages == null');
    });

    test(
        'Given stack inicial When copyWith([]) Then retorna defaultNavStackModel y preserva invariante no-vacío',
        () {
      // Arrange
      final NavStackModel base =
          NavStackModel.single(const PageModel(name: 'home'));

      // Act
      final NavStackModel out = base.copyWith(pages: <PageModel>[]);

      // Assert
      expect(identical(out, base), isFalse,
          reason: 'No debe ser la misma instancia');
      expect(out, equals(defaultNavStackModel),
          reason: 'Debe delegar al factory y regresar el default');
      expect(out.pages.isNotEmpty, isTrue,
          reason: 'Invariante no-vacío debe mantenerse');
      expect(out.isRoot, isTrue, reason: 'Default es una sola página');
      expect(out.top.name, equals(NavStackModel.defaultName),
          reason: 'Default usa el nombre "notFound"');
    });

    test(
        'Given stack inicial When copyWith(lista no vacía) Then crea nueva pila inmutable con top correcto',
        () {
      // Arrange
      final NavStackModel base =
          NavStackModel.single(const PageModel(name: 'home'));
      final List<PageModel> nueva = <PageModel>[
        const PageModel(name: 'home'),
        const PageModel(name: 'details', segments: <String>['products', '42']),
      ];

      // Act
      final NavStackModel out = base.copyWith(pages: nueva);

      // Assert
      expect(identical(out, base), isFalse,
          reason: 'Debe ser una nueva instancia');
      expect(out.pages.length, equals(2));
      expect(out.top.name, equals('details'));

      // La lista interna debe ser inmodificable
      expect(
        () => out.pages.add(const PageModel(name: 'x')),
        throwsA(isA<UnsupportedError>()),
        reason: 'pages debe ser List.unmodifiable',
      );
    });

    test(
        'Given pila resultado inmodificable When re-aplico copyWith(pages: out.pages) Then sigue siendo igual y estable',
        () {
      // Arrange
      final NavStackModel base =
          NavStackModel.single(const PageModel(name: 'home'));
      final NavStackModel a = base.copyWith(
        pages: <PageModel>[
          const PageModel(name: 'a'),
          const PageModel(name: 'b'),
        ],
      );

      // Act
      final NavStackModel b = a.copyWith(pages: a.pages);

      // Assert
      expect(b == a, isTrue,
          reason: 'Contenido igual según == de NavStackModel');
      // No garantizamos identidad; lo importante es la igualdad estructural y la inmutabilidad.
      expect(
        () => b.pages.removeLast(),
        throwsA(isA<UnsupportedError>()),
        reason: 'Debe permanecer inmutable al re-aplicar copyWith',
      );
    });

    test(
        'Given stack inicial When copyWith(lista con mismo contenido) Then es igual pero no necesariamente identical',
        () {
      // Arrange
      final NavStackModel base =
          NavStackModel.single(const PageModel(name: 'home'));
      final List<PageModel> misma = <PageModel>[const PageModel(name: 'home')];

      // Act
      final NavStackModel out = base.copyWith(pages: misma);

      // Assert
      expect(out == base, isTrue, reason: 'Igualdad estructural por contenido');
      expect(identical(out, base), isFalse,
          reason: 'Puede crear una nueva instancia aun con mismo contenido');
    });
  });
}
