import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// PageManager espía para observar goHome y setFromRouteChain.
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

/// AppConfig real alineado al arquetipo, cableando nuestro PageManager espía.
AppConfig _makeConfigWith(_SpyPageManager spy) {
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

void main() {
  group('AppManager · restore-after-login (pending route chain)', () {
    test('con chain pendiente no vacía → setFromRouteChain y NO goHome', () {
      final _SpyPageManager spy = _SpyPageManager();
      final AppManager manager = AppManager(_makeConfigWith(spy));

      // Inyectamos la intención pendiente
      manager.debugSetPendingRouteChain('/profile/settings?tab=privacy');

      manager.onAuthenticatedRestorePendingStack();

      expect(
        spy.lastSetFromRouteChain,
        '/profile/settings?tab=privacy',
        reason: 'Debe restaurar el stack a partir del route chain pendiente',
      );
      expect(
        spy.goHomeCalled,
        isFalse,
        reason: 'No debe ir a home cuando hay chain válido',
      );

      manager.dispose();
    });

    test('sin chain (null o vacía) → goHome', () {
      final _SpyPageManager spy = _SpyPageManager();
      final AppManager manager = AppManager(_makeConfigWith(spy));

      // Caso null
      manager.debugSetPendingRouteChain(null);
      manager.onAuthenticatedRestorePendingStack();
      expect(spy.goHomeCalled, isTrue);
      expect(spy.lastSetFromRouteChain, isNull);

      // Reset de espía para el caso vacío
      final _SpyPageManager spy2 = _SpyPageManager();
      final AppManager manager2 = AppManager(_makeConfigWith(spy2));

      manager2.debugSetPendingRouteChain('');
      manager2.onAuthenticatedRestorePendingStack();
      expect(spy2.goHomeCalled, isTrue);
      expect(spy2.lastSetFromRouteChain, isNull);

      manager.dispose();
      manager2.dispose();
    });

    test('clearPendingIntent() borra chain y restore va a home', () {
      final _SpyPageManager spy = _SpyPageManager();
      final AppManager manager = AppManager(_makeConfigWith(spy));

      manager.debugSetPendingRouteChain('/orders/123');
      manager.clearPendingIntent(); // <- borra la intención

      manager.onAuthenticatedRestorePendingStack();

      expect(
        spy.goHomeCalled,
        isTrue,
        reason: 'Al borrar la intención, el restore debe ir a home',
      );
      expect(spy.lastSetFromRouteChain, isNull);

      manager.dispose();
    });

    test('responsive getter expone la instancia inyectada', () {
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

      expect(identical(manager.responsive, responsive), isTrue);

      manager.dispose();
    });
  });
  group('AppManager · restore-after-login (completo)', () {
    test('1) restore con chain válida → setFromRouteChain y nulifica chain',
        () {
      final _SpyPageManager spy = _SpyPageManager();
      final AppManager manager = AppManager(_makeConfigWith(spy));

      manager.debugSetPendingRouteChain('/profile/settings?tab=privacy');
      manager.onAuthenticatedRestorePendingStack();

      expect(spy.lastSetFromRouteChain, '/profile/settings?tab=privacy');
      expect(
        spy.goHomeCalled,
        isFalse,
        reason: 'Con chain válida no debe ir a home',
      );

      // Segunda llamada: ya NO hay chain (se nulificó) → va a home
      spy.goHomeCalled = false;
      spy.lastSetFromRouteChain = null;

      manager.onAuthenticatedRestorePendingStack();
      expect(
        spy.goHomeCalled,
        isTrue,
        reason:
            'Después de restaurar una vez, el chain se borra y el siguiente restore manda a home',
      );
      expect(spy.lastSetFromRouteChain, isNull);

      manager.dispose();
    });

    test('2) clearPendingIntent() seguido de restore → va a home', () {
      final _SpyPageManager spy = _SpyPageManager();
      final AppManager manager = AppManager(_makeConfigWith(spy));

      manager.debugSetPendingRouteChain('/orders/123');
      manager.clearPendingIntent();
      manager.onAuthenticatedRestorePendingStack();

      expect(spy.goHomeCalled, isTrue);
      expect(spy.lastSetFromRouteChain, isNull);

      manager.dispose();
    });

    test('3) responsive getter expone la misma instancia inyectada', () {
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

      expect(identical(manager.responsive, responsive), isTrue);

      manager.dispose();
    });
  });
}
