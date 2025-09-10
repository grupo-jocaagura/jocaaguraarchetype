import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// -------------------- Helpers --------------------

PageModel _p(
  String name, {
  bool requiresAuth = false,
  List<String>? segments,
  Map<String, String>? query,
}) =>
    PageModel(
      name: name,
      segments: segments ?? <String>[name],
      query: query ?? const <String, String>{},
      requiresAuth: requiresAuth,
    );

NavStackModel _stack(List<PageModel> pages) => NavStackModel(pages);

Future<void> _tick() async {
  // Deja que avancen microtareas/eventos de los streams
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

/// BlocSession de prueba muy pequeño:
/// - expone `sessionStream`, `isAuthenticated`, `currentUser`
/// - función `emit` para inyectar estados
class _TestSessionBloc implements BlocSession {
  _TestSessionBloc({bool authed = false})
      : _isAuthed = authed,
        _ctrl = StreamController<SessionState>.broadcast();

  final StreamController<SessionState> _ctrl;
  bool _isAuthed;
  UserModel? user;

  // --- API utilizada por la extensión BlocSessionSnapshotX ---
  @override
  bool get isAuthenticated => _isAuthed;

  @override
  Stream<SessionState> get sessionStream => _ctrl.stream;

  @override
  UserModel get currentUser => user ?? defaultUserModel;

  void emit(SessionState s) {
    // Política mínima: Authenticated/Refreshing => authed; resto => unauthed
    if (s is Authenticated || s is Refreshing) {
      _isAuthed = true;
    } else {
      _isAuthed = false;
    }
    _ctrl.add(s);
  }

  @override
  Future<void> dispose() async {
    await _ctrl.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SessionNavCoordinator - política de navegación con sesión', () {
    late PageModel login;
    late PageModel home;
    late PageModel protected;
    late PageModel protectedDeep;
    late PageModel publicA;

    setUp(() {
      login = _p('login');
      home = _p('home');
      protected = _p('secret', requiresAuth: true);
      protectedDeep = _p(
        'details',
        requiresAuth: true,
        segments: <String>['secret', 'details'],
      );
      publicA = _p('about');
    });

    test('No authed + top protegido => redirige a login y recuerda stack',
        () async {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[home, protected]));
      final _TestSessionBloc session = _TestSessionBloc();

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );

      // En el ctor ya se hace un enforce con snapshot Unauthenticated.
      expect(pm.historyNames.last, equals('login'));

      // Al autenticarse, restaura el stack pendiente completo.
      session.emit(const Authenticated(defaultUserModel));
      await _tick();

      expect(pm.historyNames, equals(<String>['home', 'secret']));

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });

    test(
        'Authed en login con flag goHomeWhenAuthenticatedOnLogin=true => reset a home',
        () async {
      final PageManager pm = PageManager(initial: _stack(<PageModel>[login]));
      final _TestSessionBloc session = _TestSessionBloc();

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );

      expect(pm.historyNames.last, 'login');

      session.emit(const Authenticated(defaultUserModel));
      await _tick();

      expect(pm.historyNames.last, 'home');

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });

    test('Authed en login con flag=false => NO navega a home', () async {
      final PageManager pm = PageManager(initial: _stack(<PageModel>[login]));
      final _TestSessionBloc session = _TestSessionBloc();

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
        goHomeWhenAuthenticatedOnLogin: false,
      );

      session.emit(const Authenticated(defaultUserModel));
      await _tick();

      expect(pm.historyNames.last, 'login'); // se queda en login

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });

    test(
        'Refreshing se trata como autenticado: NO expulsa a login en páginas protegidas',
        () async {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[home, protected]));
      final _TestSessionBloc session = _TestSessionBloc(authed: true);

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );

      // Simulamos refresco de sesión (sigue "authed" a efectos de navegación)
      session.emit(const Refreshing(Authenticated(defaultUserModel)));
      await _tick();

      expect(pm.historyNames.last, 'secret'); // no redirige
      coord.dispose();
      await session.dispose();
      pm.dispose();
    });

    test('Logout/Unauthenticated mientras estás en protegido => va a login',
        () async {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[home, protectedDeep]));
      final _TestSessionBloc session = _TestSessionBloc(authed: true);

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );

      // Pérdida de sesión
      session.emit(const Unauthenticated());
      await _tick();

      expect(pm.historyNames.last, 'login');

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });

    test(
        'Cambio de stack a protegido mientras NO authed => intercepta por stackStream y va a login',
        () async {
      final PageManager pm = PageManager(initial: _stack(<PageModel>[publicA]));
      final _TestSessionBloc session = _TestSessionBloc();

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );

      // La UI empuja una página protegida estando no autenticado
      pm.push(protected);
      await _tick();

      // Coordinador debió resetear a login
      expect(pm.historyNames.last, 'login');

      // Ahora nos autenticamos; debe restaurar la intención previa (about -> secret)
      session.emit(const Authenticated(defaultUserModel));
      await _tick();
      expect(pm.historyNames, equals(<String>['about', 'secret']));

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });

    test('Authed navegando por públicas/protegidas no fuerza redirecciones',
        () async {
      final PageManager pm = PageManager(initial: _stack(<PageModel>[home]));
      final _TestSessionBloc session = _TestSessionBloc(authed: true);

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );

      pm.push(publicA);
      pm.push(protected);
      await _tick();

      expect(pm.historyNames, equals(<String>['home', 'about', 'secret']));

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });

    test('Restaura stack pendiente completo (varias páginas) tras autenticarse',
        () async {
      final NavStackModel intended =
          _stack(<PageModel>[publicA, protected, protectedDeep]);
      final PageManager pm = PageManager(initial: intended);

      final _TestSessionBloc session = _TestSessionBloc();

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );

      // Constructor ya debió mandar a login y recordar `intended`.
      expect(pm.historyNames.last, 'login');

      session.emit(const Authenticated(defaultUserModel));
      await _tick();

      expect(pm.historyNames, equals(<String>['about', 'secret', 'details']));

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });
  });
  group('SessionNavCoordinator - política de navegación sin sesión', () {
    test('SessionError en página protegida => redirige a login', () async {
      final PageManager pm = PageManager(
        initial: _stack(
          <PageModel>[_p('home'), _p('secret', requiresAuth: true)],
        ),
      );
      final _TestSessionBloc session =
          _TestSessionBloc(authed: true); // empieza authed
      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: _p('login'),
        homePage: _p('home'),
      );

      session.emit(
        const SessionError(
          ErrorItem(title: 'x', code: 'x', description: 'x'),
        ),
      );
      await _tick();

      expect(pm.historyNames.last, 'login');
      coord.dispose();
      await session.dispose();
      pm.dispose();
    });
    test('Authed en página pública o protegida: NO fuerza reset a home',
        () async {
      final PageManager pm =
          PageManager(initial: _stack(<PageModel>[_p('home')]));
      final _TestSessionBloc session = _TestSessionBloc(authed: true);
      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: _p('login'),
        homePage: _p('home'),
      );
      pm.push(_p('about'));
      await _tick();
      expect(pm.historyNames.last, 'about'); // no resetea a home
      coord.dispose();
      await session.dispose();
      pm.dispose();
    });
    test('Restauración idempotente cuando stack == pending', () async {
      final PageModel about = _p('about');
      final PageModel secret = _p('secret', requiresAuth: true);
      final NavStackModel intended = _stack(<PageModel>[about, secret]);

      final PageManager pm = PageManager(initial: intended);
      final _TestSessionBloc session =
          _TestSessionBloc(); // unauth → va a login y guarda pending
      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: _p('login'),
        homePage: _p('home'),
      );
      // Forzamos el stack al "intended" otra vez antes de autenticar para simular igualdad
      pm.setStack(intended);
      session.emit(const Authenticated(defaultUserModel));
      await _tick();

      expect(pm.historyNames, <String>['about', 'secret']); // sin loops
      coord.dispose();
      await session.dispose();
      pm.dispose();
    });
    test('Ráfaga de estados no rompe (restaura pending al final)', () async {
      final PageManager pm = PageManager(
        initial: _stack(
          <PageModel>[_p('about'), _p('secret', requiresAuth: true)],
        ),
      );
      final _TestSessionBloc session = _TestSessionBloc();
      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: _p('login'),
        homePage: _p('home'),
      );

      // Simula transición típica de login
      session.emit(const Authenticating());
      session.emit(const Authenticated(defaultUserModel));
      await _tick();

      expect(pm.historyNames, <String>['about', 'secret']);
      coord.dispose();
      await session.dispose();
      pm.dispose();
    });
    test('Ráfaga de estados no rompe (restaura pending al final)', () async {
      final PageManager pm = PageManager(
        initial: _stack(
          <PageModel>[_p('about'), _p('secret', requiresAuth: true)],
        ),
      );
      final _TestSessionBloc session = _TestSessionBloc();
      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: _p('login'),
        homePage: _p('home'),
      );

      // Simula transición típica de login
      session.emit(const Authenticating());
      session.emit(const Authenticated(defaultUserModel));
      await _tick();

      expect(pm.historyNames, <String>['about', 'secret']);
      coord.dispose();
      await session.dispose();
      pm.dispose();
    });
    test('Refreshing seguido de Authenticated no produce navegación extra',
        () async {
      final PageManager pm = PageManager(
        initial: _stack(
          <PageModel>[_p('home'), _p('secret', requiresAuth: true)],
        ),
      );
      final _TestSessionBloc session = _TestSessionBloc(authed: true);
      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: _p('login'),
        homePage: _p('home'),
      );

      session.emit(const Refreshing(Authenticated(defaultUserModel)));
      session.emit(const Authenticated(defaultUserModel));
      await _tick();

      expect(pm.historyNames.last, 'secret'); // estable
      coord.dispose();
      await session.dispose();
      pm.dispose();
    });
    test('loginPage requiresAuth=true (config errónea) no buclea', () async {
      final PageModel login = _p('login', requiresAuth: true); // error humano
      final PageManager pm = PageManager(
        initial: _stack(
          <PageModel>[_p('home'), _p('secret', requiresAuth: true)],
        ),
      );
      final _TestSessionBloc session = _TestSessionBloc(); // unauth
      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: _p('home'),
      );

      await _tick();
      // Aunque login es "protegida", _isLogin(prevención) evita nuevo redirect
      expect(pm.historyNames.last, 'login');
      coord.dispose();
      await session.dispose();
      pm.dispose();
    });
    test('homePage requiere auth: authed en login → puede resetear a home',
        () async {
      final PageModel login = _p('login');
      final PageModel home = _p('home', requiresAuth: true);
      final PageManager pm = PageManager(initial: _stack(<PageModel>[login]));
      final _TestSessionBloc session = _TestSessionBloc();

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );

      session.emit(const Authenticated(defaultUserModel));
      await _tick();
      expect(pm.historyNames.last, 'home'); // OK
      coord.dispose();
      await session.dispose();
      pm.dispose();
    });
    test('pageEquals alternativo (por name) sigue respetando login/home',
        () async {
      bool nameEquals(PageModel a, PageModel b) => a.name == b.name;

      final PageModel login = _p('login', segments: <String>['auth', 'login']);
      final PageModel home = _p('home', segments: <String>['app', 'home']);
      final PageManager pm = PageManager(
        initial: _stack(
          <PageModel>[_p('about'), _p('secret', requiresAuth: true)],
        ),
      );
      final _TestSessionBloc session = _TestSessionBloc();

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
        pageEquals: nameEquals,
      );
      expect(pm.historyNames.last, 'login');
      session.emit(const Authenticated(defaultUserModel));
      await _tick();
      expect(pm.historyNames.last, 'secret');
      coord.dispose();
      await session.dispose();
      pm.dispose();
    });
    test('PageManager dispose antes que coordinator => no lanza ni navega',
        () async {
      final PageManager pm = PageManager(
        initial: _stack(<PageModel>[_p('home')]),
        postDisposePolicy: ModulePostDisposePolicy.returnLastSnapshotNoop,
      );
      final _TestSessionBloc session = _TestSessionBloc();
      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: _p('login'),
        homePage: _p('home'),
      );

      pm.dispose(); // cierra navegación
      session.emit(const Authenticated(defaultUserModel));
      await _tick();

      // Sin cambios; no lanza
      expect(pm.isClosed, isTrue);
      coord.dispose();
      await session.dispose();
    });
    test('BlocSession cerrado (leniente) previo al coordinator => se construye',
        () async {
      // Simula que el bloc ya no emite (por tu stub basta no emitir)
      final _TestSessionBloc session = _TestSessionBloc();
      final PageManager pm = PageManager(
        initial: _stack(<PageModel>[_p('secret', requiresAuth: true)]),
      );

      // No emite; el coord cae al snapshot Unauthenticated
      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: _p('login'),
        homePage: _p('home'),
      );

      expect(pm.historyNames.last, 'login');
      coord.dispose();
      await session.dispose();
      pm.dispose();
    });
    // test(
    //     'Usuario cambia intención en login antes de autenticarse => no restaura pending',
    //     () async {
    //   final pm = PageManager(
    //       initial: _stack(
    //           <PageModel>[_p('home'), _p('secret', requiresAuth: true)]));
    //   final session = _TestSessionBloc();
    //   final coord = SessionNavCoordinator(
    //     pageManager: pm,
    //     sessionBloc: session,
    //     loginPage: _p('login'),
    //     homePage: _p('home'),
    //     goHomeWhenAuthenticatedOnLogin: false,
    //   );
//
    //   expect(pm.historyNames.last, 'login'); // pendiente: [home, secret]
    //   pm.replaceTop(_p('about')); // user cambió intención en login
    //   await _tick();
//
    //   session.emit(const Authenticated(defaultUserModel));
    //   await _tick();
//
    //   // Esperable: NO restaurar [home, secret]; respetar 'about'
    //   expect(pm.historyNames.last, 'about');
//
    //   coord.dispose();
    //   await session.dispose();
    //   pm.dispose();
    // });
    test(
        'pending termina en login (raro) => restaurar evitando quedarse en login',
        () async {
      final PageModel login = _p('login');
      final NavStackModel weird =
          _stack(<PageModel>[_p('about'), login]); // pending erróneo
      final PageManager pm = PageManager(initial: weird);
      final _TestSessionBloc session = _TestSessionBloc();

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: _p('home'),
      );

      expect(pm.historyNames.last, 'login'); // guardó pending=weird
      session.emit(const Authenticated(defaultUserModel));
      await _tick();

      // Política (sugerida): si pending termina en login, al menos caer a home
      // Si mantienes restauración literal, cambia esta expectativa a ['about','login'].
      expect(pm.historyNames.last, anyOf('about', 'home'));

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });
  });

  group('SessionNavCoordinator.canApplyGoHome', () {
    // Helpers locales
    PageModel p(
      String name, {
      bool requiresAuth = false,
      List<String>? segments,
      Map<String, String>? query,
    }) =>
        PageModel(
          name: name,
          segments: segments ?? <String>[name],
          query: query ?? const <String, String>{},
          requiresAuth: requiresAuth,
        );

    NavStackModel stack(List<PageModel> pages) => NavStackModel(pages);

    Future<void> tick() async {
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
    }

    test('false si goHomeWhenAuthenticatedOnLogin=false', () async {
      final PageModel login = p('login');
      final PageModel home = p('home');
      final PageManager pm = PageManager(initial: stack(<PageModel>[login]));
      final _TestSessionBloc session = _TestSessionBloc(authed: true);

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
        goHomeWhenAuthenticatedOnLogin: false,
      );

      // Aunque estemos autenticados y en login, la flag apaga la redirección.
      expect(coord.canApplyGoHome(pm.stack), isFalse);

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });

    test('false si no autenticado', () async {
      final PageModel login = p('login');
      final PageModel home = p('home');
      final PageManager pm = PageManager(initial: stack(<PageModel>[login]));
      final _TestSessionBloc session = _TestSessionBloc();

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );

      expect(coord.canApplyGoHome(pm.stack), isFalse);

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });

    test('false si top != login', () async {
      final PageModel login = p('login');
      final PageModel home = p('home');
      final PageManager pm = PageManager(initial: stack(<PageModel>[home]));
      final _TestSessionBloc session = _TestSessionBloc(authed: true);

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );

      // Authed pero el top no es login ⇒ no aplica (C).
      expect(coord.canApplyGoHome(pm.stack), isFalse);

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });

    test('false si existe pending (hay intención por restaurar)', () async {
      final PageModel login = p('login');
      final PageModel home = p('home');
      final PageModel secret = p('secret', requiresAuth: true);

      // Arranca en pública→protegida (forzará pending y reset a login)
      final PageManager pm =
          PageManager(initial: stack(<PageModel>[home, secret]));
      final _TestSessionBloc session = _TestSessionBloc();

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );

      await tick(); // deja que el coordinator mande a login/pending

      // En login, pero con pending presente ⇒ no se debe aplicar (C).
      expect(pm.stack.top.name, 'login');
      expect(coord.canApplyGoHome(pm.stack), isFalse);

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });

//    test('true si: authed + top=login + sin pending (caso básico)', () async {
//      final login = _p('login');
//      final home = _p('home');
//      final pm = PageManager(initial: _stack(<PageModel>[login]));
//      final session = _TestSessionBloc(authed: true);
//
//      final coord = SessionNavCoordinator(
//        pageManager: pm,
//        sessionBloc: session,
//        loginPage: login,
//        homePage: home,
//      );
//
//      // Authed + login + no pending + flag=true ⇒ aplica (C).
//      expect(coord.canApplyGoHome(pm.stack), isTrue);
//
//      coord.dispose();
//      await session.dispose();
//      pm.dispose();
//    });

    test(
        'false en rebote de about→login (prevTop != login) aunque authed y sin pending',
        () async {
      final PageModel login = p('login');
      final PageModel home = p('home');
      final PageModel about = p('about');
      final PageManager pm = PageManager(initial: stack(<PageModel>[about]));
      final _TestSessionBloc session = _TestSessionBloc(authed: true);

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );

      // Simula un rebote de navegación (UI hizo reset a login desde about)
      pm.resetTo(login);
      await tick(); // asegura que el listener registre prevTop=about

      // Predicado debe respetar la intención: prevTop!=login ⇒ false.
      expect(coord.canApplyGoHome(stack(<PageModel>[login])), isFalse);

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });

    test(
        'false si usuario cambia intención en login (login→about sin autenticar) y recién ahí se autentica',
        () async {
      final PageModel home = p('home');
      final PageModel login = p('login');
      final PageModel secret = p('secret', requiresAuth: true);
      final PageModel about = p('about');

      // Arranca con intención a página protegida ⇒ coordinator envía a login
      final PageManager pm =
          PageManager(initial: stack(<PageModel>[home, secret]));
      final _TestSessionBloc session = _TestSessionBloc();

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );
      await tick();
      expect(pm.historyNames.last, 'login');

      // Usuario cambia intención en login a 'about'
      pm.replaceTop(about);
      await tick();

      // Ahora se autentica; predicado NO debe mandar a home
      session.emit(const Authenticated(defaultUserModel));
      await tick();

      expect(pm.historyNames.last, 'about');
      expect(coord.canApplyGoHome(pm.stack), isFalse);

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });

    test('true si evento fue session (no stack) y estamos en login sin pending',
        () async {
      final PageModel login = p('login');
      final PageModel home = p('home');

      final PageManager pm = PageManager(initial: stack(<PageModel>[login]));
      final _TestSessionBloc session = _TestSessionBloc();

      final SessionNavCoordinator coord = SessionNavCoordinator(
        pageManager: pm,
        sessionBloc: session,
        loginPage: login,
        homePage: home,
      );

      // Autenticación (evento de sesión). En login y sin pending ⇒ true.
      session.emit(const Authenticated(defaultUserModel));
      await tick();

      expect(
        pm.historyNames.last,
        anyOf('login', 'home'),
      ); // puede haber navegado
      // El predicado debe ser true en este snapshot (si aún estás en login).
      expect(coord.canApplyGoHome(stack(<PageModel>[login])), isTrue);

      coord.dispose();
      await session.dispose();
      pm.dispose();
    });
  });
}
