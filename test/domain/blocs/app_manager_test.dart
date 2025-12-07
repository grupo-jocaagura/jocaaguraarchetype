import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

bool _routeEquals(PageModel a, PageModel b) {
  return a.name == b.name &&
      listEquals(a.segments, b.segments) &&
      mapEquals(a.query, b.query) &&
      a.kind == b.kind &&
      a.requiresAuth == b.requiresAuth;
}

/// -----------------------------
/// Spies / Fakes
/// -----------------------------
class _DummyModuleA extends BlocModule {
  @override
  void dispose() {}
}

class _DummyModuleB extends BlocModule {
  @override
  void dispose() {}
}

class _SpyPageManager extends PageManager {
  _SpyPageManager()
      : super(
          initial: NavStackModel.single(
            const PageModel(name: 'home', segments: <String>['home']),
          ),
        );

  PageModel? lastResetTo;
  PageModel? lastPush;
  bool? lastPushAllowDuplicate;
  PageModel? lastReplaceTop;
  bool? lastReplaceTopAllowNoop;
  PageModel? lastPushOnce;
  bool popCalled = false;
  bool goHomeCalled = false;
  String? lastRouteChain;

  @override
  void resetTo(PageModel root) {
    lastResetTo = root;
    super.resetTo(root);
  }

  @override
  void push(PageModel page, {bool allowDuplicate = true}) {
    lastPush = page;
    lastPushAllowDuplicate = allowDuplicate;
    super.push(page, allowDuplicate: allowDuplicate);
  }

  @override
  void pushOnce(PageModel page, {PageEquals equals = _routeEquals}) {
    lastPushOnce = page;
    super.pushOnce(page);
  }

  @override
  void replaceTop(PageModel page, {bool allowNoop = false}) {
    lastReplaceTop = page;
    lastReplaceTopAllowNoop = allowNoop;
    super.replaceTop(page, allowNoop: allowNoop);
  }

  @override
  bool pop() {
    popCalled = true;
    return super.pop();
  }

  @override
  void goHome() {
    goHomeCalled = true;
    super.goHome();
  }

  @override
  void setFromRouteChain(String chain) {
    lastRouteChain = chain;
    super.setFromRouteChain(chain);
  }
}

class _SpyUserNotifications extends BlocUserNotifications {
  String? lastToast;
  @override
  void showToast(String message, {Duration? duration}) {
    lastToast = message;
    super.showToast(message, duration: duration);
  }
}

class _SpyLoading extends BlocLoading {
  String? lastLabel;
  Duration? lastMinShow;
  int loadingWhileCalls = 0;
  int queueLoadingWhileCalls = 0;

  @override
  Future<T> loadingWhile<T>(
    String msg,
    FutureOr<T> Function() action, {
    Duration minShow = Duration.zero,
  }) async {
    loadingWhileCalls++;
    lastLabel = msg;
    lastMinShow = minShow;
    return action();
  }

  @override
  Future<T> queueLoadingWhile<T>(
    String label,
    Future<T> Function() op, {
    Duration minShow = Duration.zero,
  }) async {
    queueLoadingWhileCalls++;
    lastLabel = label;
    lastMinShow = minShow;
    return op();
  }
}

class _SpyMainMenuDrawer extends BlocMainMenuDrawer {}

class _SpySecondaryMenuDrawer extends BlocSecondaryMenuDrawer {}

class _SpyThemeBloc extends BlocTheme {
  _SpyThemeBloc()
      : super(
          themeUsecases: ThemeUsecases(
            load: LoadTheme(_RepoOk()),
            setMode: SetThemeMode(_RepoOk()),
            setSeed: SetThemeSeed(_RepoOk()),
            toggleM3: ToggleMaterial3(_RepoOk()),
            applyPreset: ApplyThemePreset(_RepoOk()),
            setTextScale: SetThemeTextScale(_RepoOk()),
            reset: ResetTheme(_RepoOk()),
            randomize: RandomizeTheme(
              _RepoOk(),
              const FakeServiceJocaaguraArchetypeTheme(),
            ),
            applyPatch: ApplyThemePatch(_RepoOk()),
            setFromState: SetThemeState(_RepoOk()),
            buildThemeData: const BuildThemeData(),
          ),
        );
}

class _RepoOk implements RepositoryTheme {
  ThemeState _s = ThemeState.defaults;
  @override
  Future<Either<ErrorItem, ThemeState>> read() async =>
      Right<ErrorItem, ThemeState>(_s);
  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState s) async =>
      Right<ErrorItem, ThemeState>(_s = s);
}

/// AppConfig armado con spies para inyectar en AppManager.
AppConfig _makeConfigWithSpies(_SpyPageManager pm,
    {BlocModelVersion? blocModelVersion}) {
  return AppConfig(
    blocTheme: _SpyThemeBloc(),
    blocUserNotifications: _SpyUserNotifications(),
    blocLoading: _SpyLoading(),
    blocMainMenuDrawer: _SpyMainMenuDrawer(),
    blocSecondaryMenuDrawer: _SpySecondaryMenuDrawer(),
    blocResponsive: BlocResponsive(),
    blocOnboarding: BlocOnboarding(),
    pageManager: pm,
    blocModelVersion: blocModelVersion,
  );
}

/// AppConfig alternativo para probar applyConfig().
AppConfig _makeAnotherConfig(_SpyPageManager pm) {
  return AppConfig(
    blocTheme: _SpyThemeBloc(),
    blocUserNotifications: _SpyUserNotifications(),
    blocLoading: _SpyLoading(),
    blocMainMenuDrawer: _SpyMainMenuDrawer(),
    blocSecondaryMenuDrawer: _SpySecondaryMenuDrawer(),
    blocResponsive: BlocResponsive(),
    blocOnboarding: BlocOnboarding(),
    pageManager: pm,
  );
}

void main() {
  group('AppManager · construcción y accessors', () {
    test('expone los blocs del AppConfig inyectado', () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppConfig cfg = _makeConfigWithSpies(pm);
      final AppManager m = AppManager(cfg);

      expect(identical(m.pageManager, pm), isTrue);
      expect(m.notifications, isA<_SpyUserNotifications>());
      expect(m.loading, isA<_SpyLoading>());
      expect(m.theme, isA<BlocTheme>());
      expect(m.mainMenu, isA<BlocMainMenuDrawer>());
      expect(m.secondaryMenu, isA<BlocSecondaryMenuDrawer>());
      expect(m.onboarding, isA<BlocOnboarding>());

      m.dispose();
    });
  });

  group('AppManager · applyConfig()', () {
    test('sin resetStack NO llama goHome y actualiza referencias', () {
      final _SpyPageManager pm1 = _SpyPageManager();
      final _SpyPageManager pm2 = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm1));

      final AppConfig next = _makeAnotherConfig(pm2);
      m.applyConfig(next); // resetStack = false

      expect(m.pageManager, same(pm2));
      expect(pm1.goHomeCalled, isFalse);
      expect(pm2.goHomeCalled, isFalse);

      m.dispose();
      next.dispose();
    });

    test('con resetStack llama goHome en el PageManager actual', () {
      final _SpyPageManager pm1 = _SpyPageManager();
      final _SpyPageManager pm2 = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm1));

      final AppConfig next = _makeAnotherConfig(pm2);
      m.applyConfig(next, resetStack: true);

      // Se usa el PageManager actual que quedó en el config nuevo,
      // pero clearAndGoHome debe invocar goHome() en el pageManager expuesto.
      expect(m.pageManager, same(pm2));
      expect(pm2.goHomeCalled, isTrue);

      m.dispose();
      next.dispose();
    });
  });

  group('AppManager · navegación (delegación a PageManager)', () {
    test('goTo(location) usa resetTo() con PageModel.fromUri', () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      m.goTo('/profile?tab=info');
      expect(pm.lastResetTo, isNotNull);
      expect(pm.lastResetTo!.segments, <String>['profile']);
      expect(pm.lastResetTo!.query['tab'], 'info');

      m.dispose();
    });

    test('push(location) delega a push con allowDuplicate (por defecto true)',
        () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      m.push('/orders/123');
      expect(pm.lastPush, isNotNull);
      expect(pm.lastPush!.segments, <String>['orders', '123']);
      expect(pm.lastPushAllowDuplicate, isTrue);

      m.push('/orders/123', allowDuplicate: false);
      expect(pm.lastPushAllowDuplicate, isFalse);

      m.dispose();
    });

    test('pushOnce(location) delega a pushOnce', () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      m.pushOnce('/cart');
      expect(pm.lastPushOnce, isNotNull);
      expect(pm.lastPushOnce!.segments, <String>['cart']);

      m.dispose();
    });

    test('replaceTop(location) delega a replaceTop con allowNoop', () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      m.replaceTop('/search?q=shoes', allowNoop: true);
      expect(pm.lastReplaceTop, isNotNull);
      expect(pm.lastReplaceTop!.segments, <String>['search']);
      expect(pm.lastReplaceTop!.query['q'], 'shoes');
      expect(pm.lastReplaceTopAllowNoop, isTrue);

      m.dispose();
    });

    test('replaceTopNamed construye PageModel y delega a replaceTop', () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      m.replaceTopNamed(
        'product',
        segments: <String>['catalog', 'product'],
        query: <String, String>{'id': '42'},
        requiresAuth: true,
        state: <String, dynamic>{'foo': 'bar'},
        allowNoop: true,
      );

      final PageModel? p = pm.lastReplaceTop;
      expect(p, isNotNull);
      expect(p!.name, 'product');
      expect(p.segments, <String>['catalog', 'product']);
      expect(p.query['id'], '42');
      expect(p.kind, PageKind.material);
      expect(p.requiresAuth, isTrue);
      expect(p.state['foo'], 'bar');
      expect(pm.lastReplaceTopAllowNoop, isTrue);

      m.dispose();
    });

    test('pop() delega a PageManager.pop()', () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      final bool _ = m.pop();
      expect(pm.popCalled, isTrue);

      m.dispose();
    });

    test('clearAndGoHome() delega a PageManager.goHome()', () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      m.clearAndGoHome();
      expect(pm.goHomeCalled, isTrue);

      m.dispose();
    });

    test('selectFromMainMenu/SecondaryMenu usan pushOnce', () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      m.selectFromMainMenu('/inbox');
      expect(pm.lastPushOnce, isNotNull);
      expect(pm.lastPushOnce!.segments, <String>['inbox']);

      m.selectFromSecondaryMenu('/settings');
      expect(pm.lastPushOnce!.segments, <String>['settings']);

      m.dispose();
    });

    test('onRequiresAuthAtTop → goTo("/login")', () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      m.onRequiresAuthAtTop();
      expect(pm.lastResetTo, isNotNull);
      expect(pm.lastResetTo!.segments, <String>['login']);

      m.dispose();
    });
  });

  group('AppManager · helpers de UI (loading / notifications)', () {
    test('notify delega a BlocUserNotifications.showToast', () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppConfig cfg = _makeConfigWithSpies(pm);
      final AppManager m = AppManager(cfg);

      final _SpyUserNotifications notif =
          cfg.blocUserNotifications as _SpyUserNotifications;

      m.notify('hola!');
      expect(notif.lastToast, 'hola!');

      m.dispose();
    });

    test('runWithLoading usa BlocLoading.loadingWhile con label y minShow',
        () async {
      final _SpyPageManager pm = _SpyPageManager();
      final AppConfig cfg = _makeConfigWithSpies(pm);
      final AppManager m = AppManager(cfg);

      final _SpyLoading loading = cfg.blocLoading as _SpyLoading;

      final String result = await m.runWithLoading(
        Future<String>.value('ok'),
        label: 'Cargando…',
        minShow: const Duration(milliseconds: 50),
      );

      expect(result, 'ok');
      expect(loading.loadingWhileCalls, 1);
      expect(loading.lastLabel, 'Cargando…');
      expect(loading.lastMinShow, const Duration(milliseconds: 50));

      m.dispose();
    });

    test('queueRunWithLoading usa queueLoadingWhile con label y minShow',
        () async {
      final _SpyPageManager pm = _SpyPageManager();
      final AppConfig cfg = _makeConfigWithSpies(pm);
      final AppManager m = AppManager(cfg);

      final _SpyLoading loading = cfg.blocLoading as _SpyLoading;

      final int result = await m.queueRunWithLoading<int>(
        () async => 7,
        label: 'Trabajando…',
        minShow: const Duration(milliseconds: 30),
      );

      expect(result, 7);
      expect(loading.queueLoadingWhileCalls, 1);
      expect(loading.lastLabel, 'Trabajando…');
      expect(loading.lastMinShow, const Duration(milliseconds: 30));

      m.dispose();
    });
  });

  group('AppManager · ciclo de vida', () {
    test('dispose marca isDisposed y encadena a AppConfig.dispose()', () async {
      final _SpyPageManager pm = _SpyPageManager();
      final AppConfig cfg = _makeConfigWithSpies(pm);
      final AppManager m = AppManager(cfg);

      expect(m.isDisposed, isFalse);
      await m.dispose();
      expect(m.isDisposed, isTrue);
    });
  });
  group('AppManager · desarrollo: requireModule* expuestos', () {
    test('requireModuleOfType<T>() expone el primero del tipo', () {
      final _SpyPageManager pm = _SpyPageManager();

      final AppConfig cfg = AppConfig(
        blocTheme: _SpyThemeBloc(),
        blocUserNotifications: _SpyUserNotifications(),
        blocLoading: _SpyLoading(),
        blocMainMenuDrawer: _SpyMainMenuDrawer(),
        blocSecondaryMenuDrawer: _SpySecondaryMenuDrawer(),
        blocResponsive: BlocResponsive(),
        blocOnboarding: BlocOnboarding(),
        pageManager: pm,
        blocModuleList: <String, BlocModule>{
          'a': _DummyModuleA(),
          'b': _DummyModuleB(),
          'a2': _DummyModuleA(), // si hubiera más de uno, retorna el primero
        },
      );

      final AppManager m = AppManager(cfg);

      final _DummyModuleA a = m.requireModuleOfType<_DummyModuleA>();
      expect(a, isA<_DummyModuleA>());

      final _DummyModuleB b = m.requireModuleOfType<_DummyModuleB>();
      expect(b, isA<_DummyModuleB>());

      m.dispose();
    });

    test('requireModuleOfType<T>() lanza si no existe un módulo de ese tipo',
        () async {
      final _SpyPageManager pm = _SpyPageManager();

      final AppConfig cfg = AppConfig(
        blocTheme: _SpyThemeBloc(),
        blocUserNotifications: _SpyUserNotifications(),
        blocLoading: _SpyLoading(),
        blocMainMenuDrawer: _SpyMainMenuDrawer(),
        blocSecondaryMenuDrawer: _SpySecondaryMenuDrawer(),
        blocResponsive: BlocResponsive(),
        blocOnboarding: BlocOnboarding(),
        pageManager: pm,
        blocModuleList: <String, BlocModule>{
          'onlyA': _DummyModuleA(),
        },
      );

      final AppManager m = AppManager(cfg);

      expect(
        () => m.requireModuleOfType<_DummyModuleB>(),
        throwsA(isA<UnimplementedError>()),
      );

      await m.dispose();
    });

    test('requireModuleByKey<T>() resuelve case-insensitive y valida tipo',
        () async {
      final _SpyPageManager pm = _SpyPageManager();

      final AppConfig cfg = AppConfig(
        blocTheme: _SpyThemeBloc(),
        blocUserNotifications: _SpyUserNotifications(),
        blocLoading: _SpyLoading(),
        blocMainMenuDrawer: _SpyMainMenuDrawer(),
        blocSecondaryMenuDrawer: _SpySecondaryMenuDrawer(),
        blocResponsive: BlocResponsive(),
        blocOnboarding: BlocOnboarding(),
        pageManager: pm,
        blocModuleList: <String, BlocModule>{
          'Canvas': _DummyModuleA(),
        },
      );

      final AppManager m = AppManager(cfg);

      final _DummyModuleA m1 = m.requireModuleByKey<_DummyModuleA>('canvas');
      final _DummyModuleA m2 = m.requireModuleByKey<_DummyModuleA>('CANVAS');

      expect(m1, isA<_DummyModuleA>());
      expect(identical(m1, m2), isTrue);

      await m.dispose();
    });

    test('requireModuleByKey<T>() lanza si la key no existe', () async {
      final _SpyPageManager pm = _SpyPageManager();

      final AppConfig cfg = AppConfig(
        blocTheme: _SpyThemeBloc(),
        blocUserNotifications: _SpyUserNotifications(),
        blocLoading: _SpyLoading(),
        blocMainMenuDrawer: _SpyMainMenuDrawer(),
        blocSecondaryMenuDrawer: _SpySecondaryMenuDrawer(),
        blocResponsive: BlocResponsive(),
        blocOnboarding: BlocOnboarding(),
        pageManager: pm,
      );

      final AppManager m = AppManager(cfg);

      expect(
        () => m.requireModuleByKey<_DummyModuleA>('missing'),
        throwsA(isA<UnimplementedError>()),
      );

      await m.dispose();
    });

    test(
        'requireModuleByKey<T>() lanza si el tipo no coincide con el registrado',
        () async {
      final _SpyPageManager pm = _SpyPageManager();

      final AppConfig cfg = AppConfig(
        blocTheme: _SpyThemeBloc(),
        blocUserNotifications: _SpyUserNotifications(),
        blocLoading: _SpyLoading(),
        blocMainMenuDrawer: _SpyMainMenuDrawer(),
        blocSecondaryMenuDrawer: _SpySecondaryMenuDrawer(),
        blocResponsive: BlocResponsive(),
        blocOnboarding: BlocOnboarding(),
        pageManager: pm,
        blocModuleList: <String, BlocModule>{
          'canvas': _DummyModuleA(),
        },
      );

      final AppManager m = AppManager(cfg);

      expect(
        () => m.requireModuleByKey<_DummyModuleB>('canvas'),
        throwsA(isA<UnimplementedError>()),
      );

      await m.dispose();
    });
  });
  group('AppManager · navegación con PageModel', () {
    test('goToModel delega a PageManager.resetTo(model)', () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      const PageModel model = PageModel(
        name: 'profile',
        segments: <String>['profile'],
        query: <String, String>{'tab': 'info'},
      );

      m.goToModel(model);

      expect(pm.lastResetTo, isNotNull);
      expect(pm.lastResetTo!.name, 'profile');
      expect(pm.lastResetTo!.segments, <String>['profile']);
      expect(pm.lastResetTo!.query['tab'], 'info');

      m.dispose();
    });

    test('pushModel delega a PageManager.push(model) respetando allowDuplicate',
        () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      const PageModel first = PageModel(
        name: 'orders',
        segments: <String>['orders', '123'],
      );

      m.pushModel(first); // por defecto allowDuplicate = true
      expect(pm.lastPush, isNotNull);
      expect(pm.lastPush!.segments, <String>['orders', '123']);
      expect(pm.lastPushAllowDuplicate, isTrue);

      const PageModel second = PageModel(
        name: 'orders',
        segments: <String>['orders', '456'],
      );

      m.pushModel(second, allowDuplicate: false);
      expect(pm.lastPush, isNotNull);
      expect(pm.lastPush!.segments, <String>['orders', '456']);
      expect(pm.lastPushAllowDuplicate, isFalse);

      m.dispose();
    });

    test('pushOnceModel delega a PageManager.pushOnce(model)', () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      const PageModel model = PageModel(
        name: 'cart',
        segments: <String>['cart'],
      );

      m.pushOnceModel(model);

      expect(pm.lastPushOnce, isNotNull);
      expect(pm.lastPushOnce!.name, 'cart');
      expect(pm.lastPushOnce!.segments, <String>['cart']);

      m.dispose();
    });

    test(
        'replaceTopModel delega a PageManager.replaceTop(model) respetando allowNoop',
        () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      const PageModel model = PageModel(
        name: 'search',
        segments: <String>['search'],
        query: <String, String>{'q': 'shoes'},
      );

      m.replaceTopModel(model, allowNoop: true);

      expect(pm.lastReplaceTop, isNotNull);
      expect(pm.lastReplaceTop!.name, 'search');
      expect(pm.lastReplaceTop!.segments, <String>['search']);
      expect(pm.lastReplaceTop!.query['q'], 'shoes');
      expect(pm.lastReplaceTopAllowNoop, isTrue);

      m.dispose();
    });
  });

  group('AppManager · versión de la app', () {
    test('expone BlocModelVersion y refleja su snapshot actual', () {
      final _SpyPageManager pm = _SpyPageManager();
      final BlocModelVersion versionBloc = BlocModelVersion();
      final AppConfig cfg =
          _makeConfigWithSpies(pm, blocModelVersion: versionBloc);
      final AppManager m = AppManager(cfg);

      expect(m.appVersionBloc, same(versionBloc));
      expect(m.currentAppVersion, same(versionBloc.value));

      m.dispose();
    });

    test('currentAppVersion usa default cuando no hay BlocModelVersion', () {
      final _SpyPageManager pm = _SpyPageManager();
      final AppManager m = AppManager(_makeConfigWithSpies(pm));

      expect(m.appVersionBloc, isNull);
      expect(m.currentAppVersion, ModelAppVersion.defaultModelAppVersion);

      m.dispose();
    });
  });
}
