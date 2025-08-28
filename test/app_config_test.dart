import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'mocks/mock_blocs.dart';

/// Fakes mínimos para construir ThemeUsecases en un BlocTheme real.
class _SpyThemeBloc extends BlocTheme {
  _SpyThemeBloc() : super(themeUsecases: _ucsOk());
  bool disposedCalled = false;
  @override
  void dispose() {
    disposedCalled = true;
    super.dispose();
  }
}

class _SpyUserNotifications extends BlocUserNotifications {
  bool disposedCalled = false;
  @override
  Future<void> dispose() async {
    disposedCalled = true;
    return super.dispose();
  }
}

class _SpyLoading extends BlocLoading {
  bool disposedCalled = false;
  @override
  void dispose() {
    disposedCalled = true;
    super.dispose();
  }
}

class _SpyMainMenuDrawer extends BlocMainMenuDrawer {
  bool disposedCalled = false;
  @override
  void dispose() {
    disposedCalled = true;
    super.dispose();
  }
}

class _SpySecondaryMenuDrawer extends BlocSecondaryMenuDrawer {
  bool disposedCalled = false;
  @override
  void dispose() {
    disposedCalled = true;
    super.dispose();
  }
}

class _SpyResponsive extends BlocResponsive {
  bool disposedCalled = false;
  @override
  void dispose() {
    disposedCalled = true;
    super.dispose();
  }
}

class _SpyOnboarding extends BlocOnboarding {
  bool disposedCalled = false;
  @override
  void dispose() {
    disposedCalled = true;
    super.dispose();
  }
}

class _SpyPageManager extends PageManager {
  _SpyPageManager()
      : super(
          initial: NavStackModel.single(
            const PageModel(name: 'home', segments: <String>['home']),
          ),
        );
  bool disposedCalled = false;
  @override
  void dispose() {
    disposedCalled = true;
    super.dispose();
  }
}

/// Extra module (no-core) para validar que AppConfig también lo libera.
class _SpyExtraModule extends BlocModule {
  bool disposedCalled = false;
  @override
  void dispose() {
    disposedCalled = true;
  }
}

/// Fakes mínimos para ThemeUsecases (compartido con _SpyThemeBloc)
class _RepoOk implements RepositoryTheme {
  ThemeState _s = ThemeState.defaults;
  @override
  Future<Either<ErrorItem, ThemeState>> read() async =>
      Right<ErrorItem, ThemeState>(_s);
  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState s) async =>
      Right<ErrorItem, ThemeState>(_s = s);
}

ThemeUsecases _ucsOk() => ThemeUsecases(
      load: LoadTheme(_RepoOk()),
      setMode: SetThemeMode(_RepoOk()),
      setSeed: SetThemeSeed(_RepoOk()),
      toggleM3: ToggleMaterial3(_RepoOk()),
      applyPreset: ApplyThemePreset(_RepoOk()),
      setTextScale: SetThemeTextScale(_RepoOk()),
      reset: ResetTheme(_RepoOk()),
      randomize:
          RandomizeTheme(_RepoOk(), const FakeServiceJocaaguraArchetypeTheme()),
      applyPatch: ApplyThemePatch(_RepoOk()),
      setFromState: SetThemeState(_RepoOk()),
      buildThemeData: const BuildThemeData(),
    );

PageRegistry _dummyRegistry() {
  // Un registry mínimo para satisfacer AppConfig.dev; implementa lo que uses.
  // Aquí asumimos que PageRegistry tiene ctor vacío o de conveniencia.
  return const PageRegistry(<String, PageWidgetBuilder>{});
}

void main() {
  group('AppConfig.dev · construcción y wiring', () {
    test('sin onboardingSteps conserva totalSteps = 0 y crea módulos core',
        () async {
      final AppConfig cfg = AppConfig.dev(
        registry: _dummyRegistry(),
      );

      // Módulos principales no nulos
      expect(cfg.blocTheme, isNotNull);
      expect(cfg.blocUserNotifications, isNotNull);
      expect(cfg.blocLoading, isNotNull);
      expect(cfg.blocMainMenuDrawer, isNotNull);
      expect(cfg.blocSecondaryMenuDrawer, isNotNull);
      expect(cfg.blocResponsive, isNotNull);
      expect(cfg.blocOnboarding, isNotNull);
      expect(cfg.pageManager, isNotNull);

      // Onboarding sin steps explícitos
      expect(cfg.blocOnboarding.state.totalSteps, 0);

      // Sanity: blocCore no debe lanzar
      final BlocCore<dynamic> core = cfg.blocCore();
      expect(core, isNotNull);

      await cfg.dispose();
    });

    test(
        'con onboardingSteps configura el BlocOnboarding con totalSteps correcto',
        () async {
      final List<OnboardingStep> steps = <OnboardingStep>[
        const OnboardingStep(title: 'Welcome'),
        const OnboardingStep(title: 'Permissions'),
      ];

      final AppConfig cfg = AppConfig.dev(
        registry: _dummyRegistry(),
        onboardingSteps: steps,
      );

      expect(cfg.blocOnboarding.state.totalSteps, steps.length);

      await cfg.dispose();
    });

    test('BlocTheme dentro de AppConfig.dev responde a setMode()', () async {
      final AppConfig cfg = AppConfig.dev(
        registry: _dummyRegistry(),
      );

      await cfg.blocTheme.setMode(ThemeMode.dark);
      expect(cfg.blocTheme.stateOrDefault.mode, ThemeMode.dark);

      await cfg.dispose();
    });
  });
  group('AppConfig', () {
    test('should initialize all BLoCs correctly', () {
      final AppConfig appConfig = AppConfig(
        blocTheme: MockBlocTheme(
          themeUsecases: ThemeUsecases.fromRepo(
            RepositoryThemeImpl(
              gateway: GatewayThemeImpl(
                themeService: const ServiceJocaaguraArchetypeTheme(),
              ),
            ),
          ),
        ),
        blocUserNotifications: MockBlocUserNotifications(),
        blocLoading: MockBlocLoading(),
        blocMainMenuDrawer: MockBlocMainMenuDrawer(),
        blocSecondaryMenuDrawer: MockBlocSecondaryMenuDrawer(),
        blocResponsive: MockBlocResponsive(),
        blocOnboarding: MockBlocOnboarding(),
        pageManager: MockBlocNavigator(
          initial: NavStackModel(
            const <PageModel>[
              PageModel(name: '/', segments: <String>['home']),
            ],
          ),
        ),
      );

      final BlocCore<dynamic> blocCore = appConfig.blocCore();

      expect(
        blocCore.getBlocModule<MockBlocTheme>(MockBlocTheme.name),
        isA<MockBlocTheme>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocUserNotifications.name),
        isA<MockBlocUserNotifications>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocLoading.name),
        isA<MockBlocLoading>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocMainMenuDrawer.name),
        isA<MockBlocMainMenuDrawer>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocSecondaryMenuDrawer.name),
        isA<MockBlocSecondaryMenuDrawer>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocResponsive.name),
        isA<MockBlocResponsive>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocOnboarding.name),
        isA<MockBlocOnboarding>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocNavigator.name),
        isA<MockBlocNavigator>(),
      );
    });
  });
  group('AppConfig · dispose() libera core y extras', () {
    test('dispose marca flags en todos los módulos y en extras', () async {
      final _SpyThemeBloc theme = _SpyThemeBloc();
      final _SpyUserNotifications notif = _SpyUserNotifications();
      final _SpyLoading loading = _SpyLoading();
      final _SpyMainMenuDrawer mainDrawer = _SpyMainMenuDrawer();
      final _SpySecondaryMenuDrawer secondaryDrawer = _SpySecondaryMenuDrawer();
      final _SpyResponsive responsive = _SpyResponsive();
      final _SpyOnboarding onboarding = _SpyOnboarding();
      final _SpyPageManager pageManager = _SpyPageManager();
      final _SpyExtraModule extra = _SpyExtraModule();

      final AppConfig cfg = AppConfig(
        blocTheme: theme,
        blocUserNotifications: notif,
        blocLoading: loading,
        blocMainMenuDrawer: mainDrawer,
        blocSecondaryMenuDrawer: secondaryDrawer,
        blocResponsive: responsive,
        blocOnboarding: onboarding,
        pageManager: pageManager,
        blocModuleList: <String, BlocModule>{'extra': extra},
      );

      // Sanity: blocCore no debe lanzar y debería incluir los módulos (no verificamos su interior).
      final BlocCore<dynamic> core = cfg.blocCore();
      expect(core, isNotNull);

      // Llamamos dispose del AppConfig.
      await cfg.dispose();

      // Verificamos que todos los spies fueron liberados.
      expect(theme.disposedCalled, isTrue);
      expect(notif.disposedCalled, isTrue);
      expect(loading.disposedCalled, isTrue);
      expect(mainDrawer.disposedCalled, isTrue);
      expect(secondaryDrawer.disposedCalled, isTrue);
      expect(responsive.disposedCalled, isTrue);
      expect(onboarding.disposedCalled, isTrue);
      expect(pageManager.disposedCalled, isTrue);
      expect(extra.disposedCalled, isTrue);
    });
  });
}
