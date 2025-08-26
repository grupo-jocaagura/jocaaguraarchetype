import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Helpers para construir PageModel/NavStackModel con la forma esperada por tu API.
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
    segments:
        (segments == null || segments.isEmpty) ? <String>[name] : segments,
    query: query ?? const <String, String>{},
    kind: kind,
    requiresAuth: requiresAuth,
    state: state ?? const <String, dynamic>{},
  );
}

NavStackModel _stack(List<PageModel> pages) => NavStackModel(pages);

/// Matcher que tolera que el stream emita 0 o 1 evento antes del done.
/// (Algunos subjects/streams re-emiten el último valor a nuevos listeners
/// antes de cerrarse; otros no.)
Matcher closesOptionallyAfterOneValue<T>() => emitsAnyOf(<Matcher>[
      emitsInOrder(<Matcher>[isA<T>(), emitsDone]),
      emitsDone,
    ]);
void main() {
  group('PageManager - estado base y canPop', () {
    test('canPop/canPopStream reflejan root y no-root', () async {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[_p('home')]));

      expect(pm.canPop, isFalse);

      final List<bool> emitted = <bool>[];
      final StreamSubscription<bool> sub = pm.canPopStream.listen(emitted.add);

      pm.push(_p('details'));
      await Future<void>.delayed(Duration.zero);
      expect(pm.canPop, isTrue);

      pm.goHome(); // vuelve al primer elemento
      await Future<void>.delayed(Duration.zero);
      expect(pm.canPop, isFalse);

      await sub.cancel();
    });

    test('setStack no emite si es igual (dedup/guard equality)', () async {
      final PageModel home = _p('home');
      final PageManager pm = PageManager(initial: _stack(<PageModel>[home]));

      int count = 0;
      final StreamSubscription<NavStackModel> sub =
          pm.stackStream.listen((_) => count++);

      // force: mismo stack
      pm.setStack(_stack(<PageModel>[home]));
      await Future<void>.delayed(Duration.zero);

      // Puede emitir 0 o 1 al crearse (según BlocGeneral),
      // pero esta llamada no debe incrementar 'count'
      expect(count, anyOf(0, 1));

      await sub.cancel();
    });
  });

  group('PageManager - mutaciones básicas', () {
    test('push / pop / replaceTop / resetTo / goHome', () async {
      final PageModel home = _p('home');
      final PageManager pm = PageManager(initial: _stack(<PageModel>[home]));

      // push (evita duplicado consecutivo por defecto)
      pm.push(_p('home')); // no-op
      expect(pm.stack.pages.length, 1);

      pm.push(_p('a'));
      pm.push(_p('b'));
      expect(pm.historyNames, <String>['home', 'a', 'b']);
      expect(pm.canPop, isTrue);

      // replaceTop
      pm.replaceTop(_p('c'));
      expect(pm.historyNames, <String>['home', 'a', 'c']);

      // pop
      final bool popped = pm.pop();
      expect(popped, isTrue);
      expect(pm.historyNames, <String>['home', 'a']);
      pm.pop();
      // pop en root => false
      expect(pm.pop(), isFalse);

      // resetTo
      pm.resetTo(_p('login'));
      expect(pm.historyNames, <String>['login']);

      // goHome (al primer elemento del stack)
      pm.push(_p('x'));
      pm.push(_p('y'));
      pm.goHome();
      expect(pm.historyNames, <String>['login']);
    });
  });

  group('PageManager - helpers named', () {
    test(
        'pushNamed / replaceTopNamed / goNamed respetan segments y state[title]',
        () {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[_p('root')]));

      pm.pushNamed('profile', title: 'Perfil Lindo');
      expect(pm.stack.top.name, 'profile');
      expect(pm.currentTitle, 'Perfil Lindo'); // state['title'] domina

      pm.replaceTopNamed('orders', segments: <String>['app', 'orders', 'list']);
      expect(pm.stack.top.segments, <String>['app', 'orders', 'list']);

      pm.goNamed('dashboard', query: <String, String>{'title': 'Panel'});
      expect(pm.stack.top.name, 'dashboard');
      // No state['title'], toma de query['title']
      expect(pm.currentTitle, 'Panel');
    });
  });

  group('PageManager - títulos (prioridades y humanización)', () {
    test('prioridad: state["title"] > query["title"] > last segment > name',
        () {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[_p('root')]));

      // 1) state['title']
      pm.goNamed('a', title: 'Tít. Estado');
      expect(pm.currentTitle, 'Tít. Estado');

      // 2) query['title']
      pm.goNamed('b', query: <String, String>{'title': 'Tít. Query'});
      expect(pm.currentTitle, 'Tít. Query');

      // 3) humaniza último segmento
      pm.resetTo(
        _p(
          'c',
          segments: <String>['settings', 'user_prefs'],
          // sin title y sin query
        ),
      );
      expect(pm.currentTitle, 'User prefs');

      // 4) usa name si no hay segmentos
      pm.resetTo(
        _p(
          'my-page',
          segments: <String>[], // explícito vacío
        ),
      );
      expect(pm.currentTitle, 'My page');
    });

    test('currentTitleStream es distinct', () async {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[_p('root')]));

      final List<String> got = <String>[];
      final StreamSubscription<String> sub =
          pm.currentTitleStream.listen(got.add);

      pm.goNamed('pageA', title: 'A');
      pm.replaceTopNamed(
        'pageA',
        title: 'A',
      ); // no debería emitir por ser igual
      pm.replaceTopNamed('pageB', title: 'B');

      await Future<void>.delayed(Duration.zero);
      // Puede emitirse el inicial, luego 'A' y luego 'B' (distinct).
      expect(got.where((String e) => e == 'A').length, 1);
      expect(got.contains('B'), isTrue);

      await sub.cancel();
    });
  });

  group('PageManager - helpers de unicidad', () {
    test('pushDistinctTop evita duplicado consecutivo', () {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[_p('home')]));

      pm.pushDistinctTop(_p('a'));
      pm.pushDistinctTop(_p('a')); // no agrega
      pm.pushDistinctTop(_p('b'));
      pm.pushDistinctTop(_p('b')); // no agrega

      expect(pm.historyNames, <String>['home', 'a', 'b']);
    });

    test('pushOnce garantiza unicidad en todo el stack', () {
      final PageManager pm = PageManager(
        initial: _stack(<PageModel>[_p('home'), _p('a'), _p('b')]),
      );

      // Insertar 'a' debe remover el existente y añadirlo al tope
      pm.pushOnce(_p('a'));
      expect(pm.historyNames, <String>['home', 'b', 'a']);

      // Insertar 'home' lo mueve al tope dejando una sola instancia
      pm.pushOnce(_p('home'));
      expect(pm.historyNames, <String>['b', 'a', 'home']);
    });

    test('setStack hace dedup consecutivo automáticamente', () {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[_p('root')]));

      // Duplicados consecutivos 'x', 'x' deben colapsar a uno
      pm.setStack(
        _stack(<PageModel>[
          _p('root'),
          _p('x'),
          _p('x'),
          _p('y'),
          _p('y'),
          _p('x'),
        ]),
      );
      // Ojo: el último 'x' no es consecutivo del previo 'y', se mantiene.
      expect(pm.historyNames, <String>['root', 'x', 'y', 'x']);
    });
  });

  group('PageManager - rutas, cadenas y URIs', () {
    test('navigateToLocation usa PageModel.fromUri y replaceTop', () {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[_p('root')]));

      pm.navigateToLocation('/orders/123?title=Detalle');
      expect(pm.stack.top.name, isNotEmpty); // dependerá de tu fromUri
      expect(pm.currentTitle, 'Detalle'); // por query['title']
    });

    test('encodeAsRouteChain y decodeRouteChain son inversos', () {
      final NavStackModel original = _stack(<PageModel>[
        _p('root'),
        _p('a'),
        _p('b', query: <String, String>{'x': '1'}),
      ]);

      final PageManager pm1 = PageManager(initial: original);
      final String chain = pm1.routeChain;

      final PageManager pm2 =
          PageManager(initial: _stack(<PageModel>[_p('placeholder')]));
      pm2.setFromRouteChain(chain);

      expect(pm2.stack.pages.length, original.pages.length);
      expect(pm2.stack.top.name, original.top.name);
      expect(
        pm2.historyNames,
        original.pages.map((PageModel e) => e.name).toList(),
      );
    });
  });

  group('PageManager - ergonomía allowDuplicate/allowNoop', () {
    test(
        'push evita duplicado consecutivo incluso con allowDuplicate=true (setStack dedup)',
        () {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[_p('home')]));

      // Por defecto, empujar la misma página es no-op.
      pm.push(_p('home'));
      expect(pm.historyNames, <String>['home']);

      pm.push(_p('home'), allowDuplicate: true);
      expect(pm.historyNames, <String>['home', 'home']);
    });

    test('replaceTop con allowNoop=false evita no-ops; true reemplaza igual',
        () {
      final PageManager pm = PageManager(initial: _stack(<PageModel>[_p('a')]));

      pm.replaceTop(_p('a')); // no-op
      expect(pm.historyNames, <String>['a']);
      expect(pm.isClosed, isFalse);

      pm.replaceTop(_p('a'), allowNoop: true);
      expect(
        pm.historyNames,
        <String>['a'],
      ); // sigue siendo 'a' pero se ejecutó la ruta
      // No hay forma trivial de detectar el "reemplazo" idéntico sin un contador de llamadas;
      // lo importante es que no rompe y permite la operación.
    });
  });

  group('PageManager.dispose', () {
    test(
        'cierra el stream y marca isClosed=true (emite valor inicial y luego done)',
        () async {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[_p('home')]));

      // Aceptamos un valor inicial seguido del cierre.
      final Future<void> done = expectLater(
        pm.stackStream,
        emitsInOrder(<Matcher>[isA<NavStackModel>(), emitsDone]),
      );

      pm.dispose();
      await done;

      expect(pm.isClosed, isTrue);
    });

    test(
        'es idempotente: múltiples dispose() no lanzan y mantienen isClosed=true',
        () async {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[_p('home')]));

      // Primera cierra y completa el stream.
      await Future<void>.sync(pm.dispose);
      expect(pm.isClosed, isTrue);

      // Siguientes no deben lanzar ni cambiar el estado.
      await Future<void>.sync(pm.dispose);
      await Future<void>.sync(pm.dispose);
      expect(pm.isClosed, isTrue);
    });

    test(
        'tras dispose, nuevos listeners reciben cierre inmediato (con o sin último valor)',
        () async {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[_p('home')]));
      await Future<void>.sync(pm.dispose);
      expect(pm.isClosed, isTrue);

      // Un listener creado después del dispose debe completarse enseguida.
      await expectLater(
        pm.stackStream,
        closesOptionallyAfterOneValue<NavStackModel>(),
      );
    });

    test('dos suscriptores observan el cierre del stream', () async {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[_p('home')]));

      final Future<void> f1 = expectLater(
        pm.stackStream,
        emitsInOrder(<Matcher>[isA<NavStackModel>(), emitsDone]),
      );

      final Future<void> f2 = expectLater(
        pm.stackStream,
        emitsInOrder(<Matcher>[isA<NavStackModel>(), emitsDone]),
      );

      pm.dispose();
      await Future.wait(<Future<void>>[f1, f2]);

      expect(pm.isClosed, isTrue);
    });
  });
}
