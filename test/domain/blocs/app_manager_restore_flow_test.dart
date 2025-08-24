import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Espía mínimo de PageManager para observar llamadas relevantes del flujo.
class _SpyPageManager extends PageManager {
  _SpyPageManager()
      : super(
          initial: NavStackModel.single(
            const PageModel(name: 'home', segments: <String>['home']),
          ),
        );

  bool goHomeCalled = false;
  String? lastSetFromRouteChain;

  @override
  void goHome() {
    goHomeCalled = true;
    super.goHome();
  }

  @override
  void setFromRouteChain(String chain) {
    lastSetFromRouteChain = chain;
    super.setFromRouteChain(chain);
  }
}

void main() {
  /// Construye una AppConfig real con componentes del arquetipo,
  /// cableando nuestro PageManager espía.
  AppConfig makeConfigWith(_SpyPageManager spy) {
    final BlocTheme themeBloc = BlocTheme(
      themeUsecases: ThemeUsecases.fromRepo(
        RepositoryThemeImpl(gateway: GatewayThemeImpl()),
      ),
    );
    return AppConfig(
      blocTheme: themeBloc,
      blocUserNotifications: BlocUserNotifications(),
      blocLoading: BlocLoading(),
      blocMainMenuDrawer: BlocMainMenuDrawer(),
      blocSecondaryMenuDrawer: BlocSecondaryMenuDrawer(),
      blocResponsive: BlocResponsive(),
      blocOnboarding: BlocOnboarding(),
      pageManager: spy,
    );
  }

  group('AppManager · Restore-after-login & helpers', () {
    test(
        'onAuthenticatedRestorePendingStack() sin intención pendiente → goHome',
        () {
      final _SpyPageManager spy = _SpyPageManager();
      final AppManager manager = AppManager(makeConfigWith(spy));

      // No tenemos forma pública de setear la intención pendiente,
      // por lo que esta ruta debe mandar a home.
      manager.onAuthenticatedRestorePendingStack();

      expect(
        spy.goHomeCalled,
        isTrue,
        reason: 'Sin intención pendiente se debe limpiar el stack hacia home',
      );
      expect(
        spy.lastSetFromRouteChain,
        isNull,
        reason: 'No debe intentar restaurar un route chain inexistente',
      );

      manager.dispose();
    });

    test('clearPendingIntent() seguido de restore → también va a home', () {
      final _SpyPageManager spy = _SpyPageManager();
      final AppManager manager = AppManager(makeConfigWith(spy));

      // Borramos explícitamente cualquier intención pendiente (aunque sea null),
      // y verificamos que el restore siga enviando a home.
      manager.clearPendingIntent();
      manager.onAuthenticatedRestorePendingStack();

      expect(spy.goHomeCalled, isTrue);
      expect(spy.lastSetFromRouteChain, isNull);

      manager.dispose();
    });

    test('responsive getter devuelve la misma instancia inyectada', () {
      final _SpyPageManager spy = _SpyPageManager();
      final BlocResponsive responsive = BlocResponsive();
      final AppConfig cfg = AppConfig(
        blocTheme: BlocTheme(
          themeUsecases: ThemeUsecases.fromRepo(
            RepositoryThemeImpl(gateway: GatewayThemeImpl()),
          ),
        ),
        blocUserNotifications: BlocUserNotifications(),
        blocLoading: BlocLoading(),
        blocMainMenuDrawer: BlocMainMenuDrawer(),
        blocSecondaryMenuDrawer: BlocSecondaryMenuDrawer(),
        blocResponsive: responsive,
        blocOnboarding: BlocOnboarding(),
        pageManager: spy,
      );

      final AppManager manager = AppManager(cfg);

      expect(
        identical(manager.responsive, responsive),
        isTrue,
        reason: 'Debe exponer exactamente el BlocResponsive del AppConfig',
      );

      manager.dispose();
    });
  });
}
