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
}
