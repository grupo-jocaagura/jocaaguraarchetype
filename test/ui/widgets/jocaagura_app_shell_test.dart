import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// -----------------------------------------------------------------------------
// Fakes mínimos (sin paquetes externos)
// -----------------------------------------------------------------------------

class _FakeBlocResponsive implements BlocResponsive {
  int setSizeCalls = 0;

  @override
  void setSizeFromContext(BuildContext context) {
    setSizeCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBlocTheme implements BlocTheme {
  _FakeBlocTheme({
    required this.stateOrDefaultValue,
    required this.streamValue,
  });

  final ThemeState stateOrDefaultValue;
  final Stream<ThemeState> streamValue;

  @override
  ThemeState get stateOrDefault => stateOrDefaultValue;

  @override
  Stream<ThemeState> get stream => streamValue;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBlocOnboarding implements BlocOnboarding {
  _FakeBlocOnboarding({
    required this.stateValue,
    required this.stateStreamValue,
  });

  final OnboardingState stateValue;
  final Stream<OnboardingState> stateStreamValue;

  @override
  OnboardingState get state => stateValue;

  @override
  Stream<OnboardingState> get stateStream => stateStreamValue;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// AppManager fake: solo implementa lo que el AppShell/Controller usan.
/// El resto se resuelve con noSuchMethod para no crecer el fake.
class _FakeAppManager implements AppManager, AbstractAppManager {
  _FakeAppManager({
    required this.theme,
    required this.onboarding,
    required this.pageManager,
    required this.responsive,
  });

  @override
  final BlocTheme theme;

  @override
  final BlocOnboarding onboarding;

  @override
  final PageManager pageManager;

  @override
  final BlocResponsive responsive;

  final List<AppLifecycleState> lifecycleCalls = <AppLifecycleState>[];

  bool _disposed = false;
  int disposeCalls = 0;

  @override
  bool get isDisposed => _disposed;

  @override
  void handleLifecycle(AppLifecycleState state) {
    lifecycleCalls.add(state);
  }

  @override
  FutureOr<void> dispose() {
    disposeCalls++;
    _disposed = true;
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

PageManager _pageManagerWithTopName(String name) {
  final PageModel top = PageModel(name: name, segments: <String>[name]);
  return PageManager(initial: NavStackModel.single(top));
}

/// Ajusta esto a tu API real de PageRegistry.
/// La idea es registrar al menos las páginas que aparecerán en el stack.
PageRegistry _minimalRegistry() {
  //
  // Ejemplos típicos:
  // return PageRegistry(pages: <String, WidgetBuilder>{ ... });
  // return PageRegistry(<String, WidgetBuilder>{ ... });
  // return PageRegistry.fromMap(<String, WidgetBuilder>{ ... });
  //
  // Debes garantizar que 'home' y 'dashboard' existan (según tests).
  return PageRegistry(
    <String, PageWidgetBuilder>{
      'home': (_, __) => const SizedBox(key: Key('page_home')),
      'dashboard': (_, __) => const SizedBox(key: Key('page_dashboard')),
      'start': (_, __) => const SizedBox(key: Key('page_start')),
    },
  );
}

ThemeMode _themeModeFromMaterialApp(WidgetTester tester) {
  final MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
  return app.themeMode ?? ThemeMode.system;
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------

void main() {
  group('JocaaguraAppShell', () {
    testWidgets(
      'Given splashOverlayBuilder != null When build Then renders JocaaguraSplashOverlay',
      (WidgetTester tester) async {
        // Arrange
        final StreamController<ThemeState> themeCtrl =
            StreamController<ThemeState>.broadcast(sync: true);
        final StreamController<OnboardingState> onboardingCtrl =
            StreamController<OnboardingState>.broadcast(sync: true);

        addTearDown(() async {
          await themeCtrl.close();
          await onboardingCtrl.close();
        });

        final _FakeBlocResponsive responsive = _FakeBlocResponsive();
        final _FakeAppManager manager = _FakeAppManager(
          theme: _FakeBlocTheme(
            stateOrDefaultValue:
                ThemeState.defaults.copyWith(mode: ThemeMode.light),
            streamValue: themeCtrl.stream,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: onboardingCtrl.stream,
          ),
          pageManager: _pageManagerWithTopName('home'),
          responsive: responsive,
        );

        final JocaaguraAppShellController controller =
            JocaaguraAppShellController(
          appManager: manager,
          themeStream: themeCtrl.stream,
          onboardingStream: onboardingCtrl.stream,
          scheduler: (void Function() f) => f(),
        );

        // Act
        await tester.pumpWidget(
          JocaaguraAppShell(
            appManager: manager,
            registry: _minimalRegistry(),
            initialLocation: '/start',
            ownsManager: false,
            seedInitialFromPageManager: false,
            controller: controller,
            splashOverlayBuilder: (BuildContext _, OnboardingState os) {
              return Text(
                'splash-${os.status.name}',
                textDirection: TextDirection.ltr,
              );
            },
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(JocaaguraSplashOverlay), findsOneWidget);
        expect(find.text('splash-idle'), findsOneWidget);
        // Router app no debería estar presente en esta rama
        expect(find.byType(JocaaguraThemedRouterApp), findsNothing);
      },
    );

    testWidgets(
      'Given splashOverlayBuilder == null When build Then renders themed router and seeds initial route from pageManager when enabled',
      (WidgetTester tester) async {
        // Arrange
        final StreamController<ThemeState> themeCtrl =
            StreamController<ThemeState>.broadcast(sync: true);
        final StreamController<OnboardingState> onboardingCtrl =
            StreamController<OnboardingState>.broadcast(sync: true);

        addTearDown(() async {
          await themeCtrl.close();
          await onboardingCtrl.close();
        });

        final _FakeBlocResponsive responsive = _FakeBlocResponsive();
        final _FakeAppManager manager = _FakeAppManager(
          theme: _FakeBlocTheme(
            stateOrDefaultValue:
                ThemeState.defaults.copyWith(mode: ThemeMode.dark),
            streamValue: themeCtrl.stream,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: onboardingCtrl.stream,
          ),
          pageManager: _pageManagerWithTopName('dashboard'),
          responsive: responsive,
        );

        // Act
        await tester.pumpWidget(
          JocaaguraAppShell(
            appManager: manager,
            registry: _minimalRegistry(),
            initialLocation: '/start',
            ownsManager: false,
            seedInitialFromPageManager: true, // 👈 usa top.name
            splashOverlayBuilder: null,
          ),
        );
        await tester.pump();

        // Assert: renderiza router app
        expect(find.byType(JocaaguraThemedRouterApp), findsOneWidget);

        // Assert: themeMode proviene del initialTheme (stateOrDefault del manager)
        expect(_themeModeFromMaterialApp(tester), ThemeMode.dark);

        // Assert: seedPath = '/dashboard'
        expect(find.byKey(const Key('page_dashboard')), findsOneWidget);
      },
    );

    testWidgets(
      'Given controller injected When controller changes on didUpdateWidget Then new controller is used',
      (WidgetTester tester) async {
        // Arrange
        final StreamController<ThemeState> theme1 =
            StreamController<ThemeState>.broadcast(sync: true);
        final StreamController<ThemeState> theme2 =
            StreamController<ThemeState>.broadcast(sync: true);

        final StreamController<OnboardingState> onboarding =
            StreamController<OnboardingState>.broadcast(sync: true);

        addTearDown(() async {
          await theme1.close();
          await theme2.close();
          await onboarding.close();
        });

        final _FakeBlocResponsive responsive = _FakeBlocResponsive();

        // Manager común (para no mover PageManager en este test)
        final _FakeAppManager manager = _FakeAppManager(
          theme: _FakeBlocTheme(
            stateOrDefaultValue:
                ThemeState.defaults.copyWith(mode: ThemeMode.light),
            streamValue: theme1.stream,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: onboarding.stream,
          ),
          pageManager: _pageManagerWithTopName('home'),
          responsive: responsive,
        );

        final JocaaguraAppShellController c1 = JocaaguraAppShellController(
          appManager: manager,
          themeStream: theme1.stream,
          onboardingStream: onboarding.stream,
          scheduler: (void Function() f) => f(),
        );

        final JocaaguraAppShellController c2 = JocaaguraAppShellController(
          appManager: manager,
          themeStream: theme2.stream,
          onboardingStream: onboarding.stream,
          scheduler: (void Function() f) => f(),
        );

        // Act 1: build con c1 (light)
        await tester.pumpWidget(
          JocaaguraAppShell(
            appManager: manager,
            registry: _minimalRegistry(),
            initialLocation: '/start',
            ownsManager: false,
            seedInitialFromPageManager: false,
            controller: c1,
            splashOverlayBuilder: null,
          ),
        );
        await tester.pump();
        expect(_themeModeFromMaterialApp(tester), ThemeMode.light);

        // Act 2: update widget con c2 y emitimos dark por el stream nuevo
        await tester.pumpWidget(
          JocaaguraAppShell(
            appManager: manager,
            registry: _minimalRegistry(),
            initialLocation: '/start',
            ownsManager: false,
            seedInitialFromPageManager: false,
            controller: c2,
            splashOverlayBuilder: null,
          ),
        );

        theme2.add(ThemeState.defaults.copyWith(mode: ThemeMode.dark));
        await tester.pump();
        await tester.pump();

        // Assert: ahora usa c2
        expect(_themeModeFromMaterialApp(tester), ThemeMode.dark);
      },
    );

    testWidgets(
      'Given no controller injected When appManager changes Then internal controller replaces manager and themeMode updates',
      (WidgetTester tester) async {
        // Arrange
        final StreamController<ThemeState> themeA =
            StreamController<ThemeState>.broadcast(sync: true);
        final StreamController<ThemeState> themeB =
            StreamController<ThemeState>.broadcast(sync: true);
        final StreamController<OnboardingState> onboarding =
            StreamController<OnboardingState>.broadcast(sync: true);

        addTearDown(() async {
          await themeA.close();
          await themeB.close();
          await onboarding.close();
        });

        final _FakeBlocResponsive responsiveA = _FakeBlocResponsive();
        final _FakeBlocResponsive responsiveB = _FakeBlocResponsive();

        final _FakeAppManager managerA = _FakeAppManager(
          theme: _FakeBlocTheme(
            stateOrDefaultValue:
                ThemeState.defaults.copyWith(mode: ThemeMode.light),
            streamValue: themeA.stream,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: onboarding.stream,
          ),
          pageManager: _pageManagerWithTopName('home'),
          responsive: responsiveA,
        );

        final _FakeAppManager managerB = _FakeAppManager(
          theme: _FakeBlocTheme(
            stateOrDefaultValue:
                ThemeState.defaults.copyWith(mode: ThemeMode.dark),
            streamValue: themeB.stream,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: onboarding.stream,
          ),
          pageManager: _pageManagerWithTopName('home'),
          responsive: responsiveB,
        );

        // Act 1: build con managerA
        await tester.pumpWidget(
          JocaaguraAppShell(
            appManager: managerA,
            registry: _minimalRegistry(),
            initialLocation: '/start',
            ownsManager: false,
            seedInitialFromPageManager: false,
            splashOverlayBuilder: null,
          ),
        );
        await tester.pump();
        expect(_themeModeFromMaterialApp(tester), ThemeMode.light);

        // Act 2: update con managerB (controller null => replaceManager branch)
        await tester.pumpWidget(
          JocaaguraAppShell(
            appManager: managerB,
            registry: _minimalRegistry(),
            initialLocation: '/start',
            ownsManager: false,
            seedInitialFromPageManager: false,
            splashOverlayBuilder: null,
          ),
        );
        await tester.pump();
        await tester.pump();

        await tester.pump();

// Act: forzar valor en el stream nuevo para que StreamBuilder actualice snapshot
        themeB.add(ThemeState.defaults.copyWith(mode: ThemeMode.dark));
        await tester.pump();
        await tester.pump();

// Assert
        expect(_themeModeFromMaterialApp(tester), ThemeMode.dark);
      },
    );

    testWidgets(
      'Given ownsManager=true When lifecycle becomes detached Then controller disposes manager (via scheduler)',
      (WidgetTester tester) async {
        // Arrange
        final StreamController<ThemeState> themeCtrl =
            StreamController<ThemeState>.broadcast(sync: true);
        final StreamController<OnboardingState> onboardingCtrl =
            StreamController<OnboardingState>.broadcast(sync: true);

        addTearDown(() async {
          await themeCtrl.close();
          await onboardingCtrl.close();
        });

        final _FakeBlocResponsive responsive = _FakeBlocResponsive();
        final _FakeAppManager manager = _FakeAppManager(
          theme: _FakeBlocTheme(
            stateOrDefaultValue:
                ThemeState.defaults.copyWith(mode: ThemeMode.light),
            streamValue: themeCtrl.stream,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: onboardingCtrl.stream,
          ),
          pageManager: _pageManagerWithTopName('home'),
          responsive: responsive,
        );

        // Controller con scheduler sync para determinismo
        final JocaaguraAppShellController controller =
            JocaaguraAppShellController(
          appManager: manager,
          themeStream: themeCtrl.stream,
          onboardingStream: onboardingCtrl.stream,
          scheduler: (void Function() f) => f(),
        );

        await tester.pumpWidget(
          JocaaguraAppShell(
            appManager: manager,
            registry: _minimalRegistry(),
            initialLocation: '/start',
            ownsManager: true,
            seedInitialFromPageManager: false,
            controller: controller,
            splashOverlayBuilder: null,
          ),
        );
        await tester.pump();

        // Act: trigger lifecycle change
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.detached);
        await tester.pump();

        // Assert
        expect(manager.lifecycleCalls, contains(AppLifecycleState.detached));
        expect(manager.disposeCalls, 1);
        expect(manager.isDisposed, isTrue);

        // Cleanup path: ensure dispose() of widget tree doesn't throw
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      },
    );
  });
}
