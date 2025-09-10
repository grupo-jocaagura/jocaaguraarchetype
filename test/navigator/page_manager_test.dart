import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// ===== Helpers de creación de modelos =====

PageModel _p(
  String name, {
  List<String>? segments,
  Map<String, String>? query,
  PageKind kind = PageKind.material,
  bool requiresAuth = false,
  Map<String, dynamic>? state,
}) {
  return PageModel(
    name: name,
    segments: (segments == null || segments.isEmpty)
        ? <String>[name]
        : List<String>.from(segments),
    query: query ?? const <String, String>{},
    kind: kind,
    requiresAuth: requiresAuth,
    state: <String, dynamic>{...?state},
  );
}

NavStackModel _stackOf(List<String> names) =>
    NavStackModel(names.map((String n) => _p(n)).toList());

Future<void> _drainMicrotasks() => Future<void>.delayed(Duration.zero);

void main() {
  group('PageManager - Inicialización y lecturas', () {
    test('Given stack inicial When se crea Then expone lecturas coherentes',
        () {
      final NavStackModel initial = _stackOf(<String>['home']);
      final PageManager pm = PageManager(initial: initial);

      expect(pm.isClosed, isFalse);
      expect(pm.stack.top.name, 'home');
      expect(pm.canPop, isFalse);
      expect(pm.historyNames, <String>['home']);
      expect(pm.currentTitle, 'Home'); // humanize de "home"
    });

    test('Given stack inicial When se escucha stackStream Then emite el actual',
        () async {
      final NavStackModel initial = _stackOf(<String>['home']);
      final PageManager pm = PageManager(initial: initial);

      // Debe emitir al menos un valor (el actual).
      await expectLater(
        pm.stackStream,
        emitsThrough(isA<NavStackModel>()),
      );
    });
  });

  group('PageManager - Push/Replace/Pop/Reset', () {
    test('Given root When push Then agrega página y canPop true', () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));

      pm.push(_p('about'));
      await _drainMicrotasks();

      expect(pm.stack.top.name, 'about');
      expect(pm.canPop, isTrue);
      expect(pm.historyNames, <String>['home', 'about']);
    });

    test('Given top igual When push con allowDuplicate=false Then no-op',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.push(_p('home'));
      await _drainMicrotasks();

      // Evita duplicado consecutivo por “mismo destino”
      expect(pm.historyNames, <String>['home']);
      expect(pm.stack.top.name, 'home');
    });

    test(
        'Given top igual When push con allowDuplicate=true Then agrega duplicado',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.push(_p('home'), allowDuplicate: true);
      await _drainMicrotasks();

      expect(pm.historyNames, <String>['home', 'home']);
      expect(pm.canPop, isTrue);
    });

    test('Given stack con 2 When replaceTop cambia solo la cima', () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.push(_p('login'));
      await _drainMicrotasks();

      pm.replaceTop(_p('about'));
      await _drainMicrotasks();

      expect(pm.historyNames, <String>['home', 'about']);
      expect(pm.stack.top.name, 'about');
    });

    test('Given stack con 1 When pop Then retorna false y no cambia', () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));

      final bool result = pm.pop();
      await _drainMicrotasks();

      expect(result, isFalse);
      expect(pm.historyNames, <String>['home']);
    });

    test('Given stack con 2 When pop Then retorna true y quita la cima',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.push(_p('about'));
      await _drainMicrotasks();

      final bool result = pm.pop();
      await _drainMicrotasks();

      expect(result, isTrue);
      expect(pm.historyNames, <String>['home']);
      expect(pm.stack.top.name, 'home');
    });

    test('Given stack con varias When resetTo Then deja un solo root',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.push(_p('a'));
      pm.push(_p('b'));
      await _drainMicrotasks();

      pm.resetTo(_p('profile'));
      await _drainMicrotasks();

      expect(pm.historyNames, <String>['profile']);
      expect(pm.stack.isRoot, isTrue);
      expect(pm.canPop, isFalse);
    });

    test('Given en root When goHome Then restaura initial', () async {
      final NavStackModel initial = _stackOf(<String>['home']);
      final PageManager pm = PageManager(initial: initial);

      pm.goHome();
      await _drainMicrotasks();

      expect(pm.historyNames, <String>['home']);
    });

    test(
        'Given con varias When goHome Then resetea al primer page del stack actual',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['init']));

      pm.push(_p('home'));
      pm.push(_p('details'));
      await _drainMicrotasks();

      pm.goHome();
      await _drainMicrotasks();

      // goHome() en no-root hace resetTo(primer page del stack actual)
      expect(pm.historyNames, <String>['init']);
      expect(pm.stack.isRoot, isTrue);
    });
  });

  group('PageManager - Métodos *Named', () {
    test(
        'Given root When pushNamed Then agrega con segments y state[title] opcional',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.pushNamed('about', title: 'Acerca de');
      await _drainMicrotasks();

      expect(pm.stack.top.name, 'about');
      expect(pm.historyNames, <String>['home', 'about']);
      expect(pm.currentTitle, 'Acerca de'); // título tomado del state
    });

    test('Given top igual When replaceTopNamed allowNoop=false Then no-op',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));

      pm.replaceTopNamed('home', title: 'Home Title');
      await _drainMicrotasks();

      expect(pm.historyNames, <String>['home']);
      expect(pm.currentTitle, 'Home'); // no cambia porque no reemplazó
    });

    test('Given cualquier When goNamed Then resetea a un único root', () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.push(_p('a'));
      await _drainMicrotasks();

      pm.goNamed('profile', title: 'Perfil');
      await _drainMicrotasks();

      expect(pm.historyNames, <String>['profile']);
      expect(pm.currentTitle, 'Perfil');
      expect(pm.canPop, isFalse);
    });
  });

  group('PageManager - Navegación por location (URI)', () {
    test('Given root When navigateToLocation push Then respeta query/segments',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.navigateToLocation('/shop/items?title=Zapatos', name: 'items');
      await _drainMicrotasks();

      expect(pm.stack.top.name, 'items');
      expect(pm.currentTitle, 'Zapatos'); // De query['title']
      expect(pm.canPop, isTrue);
    });

    test('Given top When navigateToLocation replace Then reemplaza cima',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.push(_p('login'));
      await _drainMicrotasks();

      pm.navigateToLocation(
        '/about?title=About',
        name: 'about',
        mustReplaceTop: true,
      );
      await _drainMicrotasks();

      expect(pm.historyNames, <String>['home', 'about']);
      expect(pm.currentTitle, 'About');
    });

    test('Given cualquiera When goToLocation Then resetea a único root',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.push(_p('a'));
      await _drainMicrotasks();

      pm.goToLocation('/profile?title=Perfil', name: 'profile');
      await _drainMicrotasks();

      expect(pm.historyNames, <String>['profile']);
      expect(pm.currentTitle, 'Perfil');
      expect(pm.canPop, isFalse);
    });
  });

  group('PageManager - De-duplicación y unicidad', () {
    test(
        'Given duplicados consecutivos When setStack sin allowDuplicate Then dedup',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.setStack(NavStackModel(<PageModel>[_p('home'), _p('home')]));
      await _drainMicrotasks();

      // _dedupConsecutive elimina consecutivos con mismo destino
      expect(pm.historyNames, <String>['home']);
    });

    test('Given equals por destino When pushDistinctTop evita repetir el top',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.pushDistinctTop(_p('home'));
      await _drainMicrotasks();

      expect(pm.historyNames, <String>['home']); // no agregó
      pm.pushDistinctTop(_p('about'));
      await _drainMicrotasks();

      expect(pm.historyNames, <String>['home', 'about']);
      pm.pushDistinctTop(_p('about'));
      await _drainMicrotasks();

      expect(pm.historyNames, <String>['home', 'about']); // sigue sin agregar
    });

    test('Given equals por destino When pushOnce garantiza unicidad global',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.push(_p('about'));
      pm.push(_p('profile'));
      await _drainMicrotasks();

      // Empuja 'about' garantizando unicidad: debe remover previos iguales
      pm.pushOnce(_p('about'));
      await _drainMicrotasks();

      expect(pm.historyNames, <String>['home', 'profile', 'about']);
    });
  });

  group('PageManager - Route chain', () {
    test(
        'Given stack arbitrario When encodeAsRouteChain Then decode es reversible',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));
      pm.push(_p('login', query: <String, String>{'tab': 'basic'}));
      pm.push(_p('about'));
      await _drainMicrotasks();

      final String chain = pm.routeChain;

      final PageManager pm2 = PageManager(initial: _stackOf(<String>['root']));
      pm2.setFromRouteChain(chain);
      await _drainMicrotasks();

      expect(pm2.historyNames, pm.historyNames);
      expect(pm2.stack.pages.length, pm.stack.pages.length);
      expect(pm2.stack.top.name, 'about');
      // Sugerimos (si NavStackModel lo soporta) validar también query/segments.
    });
  });

  group('PageManager - canPop y streams derivados', () {
    test('Given root When canPopStream Then emite false y tras push true',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));

      final List<bool> emitted = <bool>[];
      final StreamSubscription<bool> sub = pm.canPopStream.listen(emitted.add);

      // Al inicio (root) => false
      await _drainMicrotasks();

      pm.push(_p('about'));
      await _drainMicrotasks();

      pm.pop();
      await _drainMicrotasks();

      await sub.cancel();

      // Debe haber emitido valores coherentes (orden puede incluir duplicados filtrados por distinct en otra capa)
      expect(emitted.first, isFalse);
      expect(emitted.contains(true), isTrue);
      expect(emitted.last, isFalse);
    });

    test(
        'Given distintos títulos When currentTitleStream Then respeta precedencia',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));

      final List<String> titles = <String>[];
      final StreamSubscription<String> sub =
          pm.currentTitleStream.listen(titles.add);

      await _drainMicrotasks();

      // 1) state['title']
      pm.push(_p('page1', state: <String, dynamic>{'title': 'Desde state'}));
      await _drainMicrotasks();
      expect(pm.currentTitle, 'Desde state');

      // 2) query['title'] si no hay state['title']
      pm.push(_p('page2', query: <String, String>{'title': 'Desde query'}));
      await _drainMicrotasks();
      expect(pm.currentTitle, 'Desde query');

      // 3) fallback: último segmento / name humanizado
      pm.push(_p('page-three')); // -> "Page three"
      await _drainMicrotasks();
      expect(pm.currentTitle, 'Page three');

      await sub.cancel();

      expect(
        titles,
        containsAllInOrder(
          <String>['Home', 'Desde state', 'Desde query', 'Page three'],
        ),
      );
    });
  });

  group('PageManager - PostDisposePolicy.throwStateError (estricto)', () {
    test('Given dispose When leer o mutar Then lanza StateError', () async {
      final PageManager pm = PageManager(
        initial: _stackOf(<String>['home']),
      );

      await pm.dispose();

      expect(pm.isClosed, isTrue); // proxy a _stack.isClosed

      // getters con _guard (o chequeo) deben fallar
      expect(() => pm.stack, throwsStateError);
      expect(() => pm.stackStream, throwsStateError);
      expect(() => pm.canPop, throwsStateError);

      // mutadores también
      expect(() => pm.push(_p('x')), throwsStateError);
      expect(() => pm.replaceTop(_p('y')), throwsStateError);
      expect(() => pm.resetTo(_p('z')), throwsStateError);
      expect(() => pm.setStack(_stackOf(<String>['k'])), throwsStateError);
      expect(() => pm.pop(), throwsStateError);
    });
  });

  group('PageManager - PostDisposePolicy.returnLastSnapshotNoop (tolerante)',
      () {
    test(
        'Given dispose When leer Then retorna último snapshot y mutar es no-op',
        () async {
      final PageManager pm = PageManager(
        initial: _stackOf(<String>['home']),
        postDisposePolicy: ModulePostDisposePolicy.returnLastSnapshotNoop,
      );

      pm.push(_p('about'));
      await _drainMicrotasks();

      final String topBefore = pm.stack.top.name;
      await pm.dispose();

      // Lecturas devuelven último snapshot
      expect(pm.stack.top.name, topBefore);
      expect(pm.canPop, isTrue);
      expect(pm.currentTitle, 'About');

      // Mutaciones son no-op (sin throw)
      pm.push(_p('profile'));
      pm.replaceTop(_p('x'));
      pm.resetTo(_p('root'));
      pm.setStack(_stackOf(<String>['k']));
      final bool popped = pm.pop();

      await _drainMicrotasks();

      // Nada cambia respecto al snapshot al momento del dispose
      expect(pm.stack.top.name, topBefore);
      expect(popped, isFalse); // pop() devuelve false en modo tolerante
    });

    test('Given dispose When stackStream Then el stream es el mismo (cerrado)',
        () async {
      final PageManager pm = PageManager(
        initial: _stackOf(<String>['home']),
        postDisposePolicy: ModulePostDisposePolicy.returnLastSnapshotNoop,
      );

      final Stream<NavStackModel> s1 = pm.stackStream;
      await pm.dispose();

      // En modo tolerante, lastSnapshot devuelve _stack.stream (posiblemente ya cerrado).
      final Stream<NavStackModel> s2 = pm.stackStream;

      expect(s2, same(s1));
    });
  });

  group('PageManager - Casos de borde de título', () {
    test('Given title vacío en state y query Then usa fallback humanizado',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));

      pm.push(
        _p(
          'my_page',
          state: <String, dynamic>{'title': ''},
          query: <String, String>{'title': ''},
        ),
      );
      await _drainMicrotasks();

      expect(pm.currentTitle, 'My page');
    });

    test('Given title no-string en state Then ignora y usa query o fallback',
        () async {
      final PageManager pm = PageManager(initial: _stackOf(<String>['home']));

      // Nota: si la implementación hace cast directo, podría lanzar. Este test
      // asume que consumidores usarán strings; mantenemos el caso como expectativa
      // de contrato: si no es string, el fallback debe aplicarse (o documentarse
      // que no se soporta).
      pm.push(
        _p(
          'page2',
          state: <String, dynamic>{'title': 123},
          query: <String, String>{'title': 'Desde query'},
        ),
      );
      await _drainMicrotasks();

      // Como la implementación actual castea con "as String?", podría lanzar.
      // Si no lanza, el título debería venir de query.
      // Para no romper el contrato actual, comprobamos que no crashee y
      // validamos el título final aceptable (query o fallback).
      expect(<String>['Desde query', 'Page2'], contains(pm.currentTitle));
    });
  });
}
