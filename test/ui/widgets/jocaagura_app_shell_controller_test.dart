import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class FakeBlocTheme implements BlocTheme {
  FakeBlocTheme({
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

class _FakeAbstractAppManager implements AbstractAppManager {
  _FakeAbstractAppManager({
    required BlocTheme theme,
    required BlocOnboarding onboarding,
    required PageManager pageManager,
  })  : _theme = theme,
        _onboarding = onboarding,
        _pageManager = pageManager;

  final BlocTheme _theme;
  final BlocOnboarding _onboarding;
  final PageManager _pageManager;

  final List<AppLifecycleState> handledLifecycle = <AppLifecycleState>[];

  bool _isDisposed = false;
  int disposeCalls = 0;

  @override
  BlocTheme get theme => _theme;

  @override
  BlocOnboarding get onboarding => _onboarding;

  @override
  PageManager get pageManager => _pageManager;

  @override
  bool get isDisposed => _isDisposed;

  @override
  void handleLifecycle(AppLifecycleState state) {
    handledLifecycle.add(state);
  }

  @override
  FutureOr<void> dispose() {
    disposeCalls++;
    _isDisposed = true;
    return null;
  }

  /// Helper for tests
  void markDisposed() => _isDisposed = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Same behavior, but typed as AppManager for replaceManager(AppManager newManager).
class _FakeAppManager extends _FakeAbstractAppManager implements AppManager {
  _FakeAppManager({
    required super.theme,
    required super.onboarding,
    required super.pageManager,
  });
}

PageManager _pageManagerWithTopName(String name) {
  final PageModel top = PageModel(
    name: name,
    segments: <String>[name],
  );
  return PageManager(initial: NavStackModel.single(top));
}

void main() {
  group('JocaaguraAppShellController', () {
    test(
      'Given manager When fromManager Then wires appManager/themeStream/onboardingStream',
      () async {
        // Arrange
        final StreamController<ThemeState> themeCtrl =
            StreamController<ThemeState>.broadcast();
        final StreamController<OnboardingState> onboardingCtrl =
            StreamController<OnboardingState>.broadcast();

        addTearDown(() async {
          await themeCtrl.close();
          await onboardingCtrl.close();
        });

        const ThemeState themeState = ThemeState.defaults;
        final BlocTheme blocTheme = FakeBlocTheme(
          streamValue: themeCtrl.stream,
          stateOrDefaultValue: themeState,
        );

        final OnboardingState onboardingState = OnboardingState.idle();
        final BlocOnboarding blocOnboarding = _FakeBlocOnboarding(
          stateValue: onboardingState,
          stateStreamValue: onboardingCtrl.stream,
        );

        final AbstractAppManager am = _FakeAbstractAppManager(
          theme: blocTheme,
          onboarding: blocOnboarding,
          pageManager: _pageManagerWithTopName('home'),
        );

        // Act
        final JocaaguraAppShellController controller =
            JocaaguraAppShellController.fromManager(am);

        // Assert (identity OK for manager)
        expect(identical(controller.appManager, am), isTrue);

        // Assert streams by behavior (reliable)
        final ThemeState emittedTheme =
            ThemeState.defaults.copyWith(mode: ThemeMode.dark);
        final OnboardingState emittedOnboarding =
            OnboardingState.idle().copyWith(status: OnboardingStatus.running);

        expectLater(controller.themeStream, emits(emittedTheme));
        expectLater(controller.onboardingStream, emits(emittedOnboarding));

        themeCtrl.add(emittedTheme);
        onboardingCtrl.add(emittedOnboarding);
      },
    );

    test(
        'Given manager When reading initial getters Then returns state from manager blocs',
        () {
      // Arrange
      const ThemeState themeState = ThemeState.defaults;
      final BlocTheme blocTheme = FakeBlocTheme(
        streamValue: const Stream<ThemeState>.empty(),
        stateOrDefaultValue: themeState,
      );

      final OnboardingState onboardingState = OnboardingState.idle();
      final BlocOnboarding blocOnboarding = _FakeBlocOnboarding(
        stateValue: onboardingState,
        stateStreamValue: const Stream<OnboardingState>.empty(),
      );

      final AbstractAppManager am = _FakeAbstractAppManager(
        theme: blocTheme,
        onboarding: blocOnboarding,
        pageManager: _pageManagerWithTopName('home'),
      );

      final JocaaguraAppShellController controller =
          JocaaguraAppShellController(
        appManager: am,
        themeStream: blocTheme.stream,
        onboardingStream: blocOnboarding.stateStream,
      );

      // Act + Assert
      expect(identical(controller.initialTheme, themeState), isTrue);
      expect(controller.initialOnboarding, onboardingState);
    });

    group('computeSeedPath', () {
      test(
          'Given seedInitialFromPageManager=false When computeSeedPath Then returns initialLocation',
          () {
        // Arrange
        final AbstractAppManager am = _FakeAbstractAppManager(
          theme: FakeBlocTheme(
            streamValue: const Stream<ThemeState>.empty(),
            stateOrDefaultValue: ThemeState.defaults,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: const Stream<OnboardingState>.empty(),
          ),
          pageManager: _pageManagerWithTopName('home'),
        );

        final JocaaguraAppShellController controller =
            JocaaguraAppShellController(
          appManager: am,
          themeStream: am.theme.stream,
          onboardingStream: am.onboarding.stateStream,
        );

        // Act
        final String result = controller.computeSeedPath(
          seedInitialFromPageManager: false,
          initialLocation: '/start',
        );

        // Assert
        expect(result, '/start');
      });

      test(
          'Given seedInitialFromPageManager=true and top.name not empty When computeSeedPath Then returns /<top.name>',
          () {
        // Arrange
        final AbstractAppManager am = _FakeAbstractAppManager(
          theme: FakeBlocTheme(
            streamValue: const Stream<ThemeState>.empty(),
            stateOrDefaultValue: ThemeState.defaults,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: const Stream<OnboardingState>.empty(),
          ),
          pageManager: _pageManagerWithTopName('dashboard'),
        );

        final JocaaguraAppShellController controller =
            JocaaguraAppShellController(
          appManager: am,
          themeStream: am.theme.stream,
          onboardingStream: am.onboarding.stateStream,
        );

        // Act
        final String result = controller.computeSeedPath(
          seedInitialFromPageManager: true,
          initialLocation: '/start',
        );

        // Assert
        expect(result, '/dashboard');
      });

      test(
          'Given seedInitialFromPageManager=true and top.name empty When computeSeedPath Then returns initialLocation',
          () {
        // Arrange
        final AbstractAppManager am = _FakeAbstractAppManager(
          theme: FakeBlocTheme(
            streamValue: const Stream<ThemeState>.empty(),
            stateOrDefaultValue: ThemeState.defaults,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: const Stream<OnboardingState>.empty(),
          ),
          pageManager: _pageManagerWithTopName(''),
        );

        final JocaaguraAppShellController controller =
            JocaaguraAppShellController(
          appManager: am,
          themeStream: am.theme.stream,
          onboardingStream: am.onboarding.stateStream,
        );

        // Act
        final String result = controller.computeSeedPath(
          seedInitialFromPageManager: true,
          initialLocation: '/start',
        );

        // Assert
        expect(result, '/start');
      });
    });

    group('shouldShowSplash', () {
      test(
          'Given status idle/running When shouldShowSplash Then returns true; otherwise false',
          () {
        // Arrange
        final AbstractAppManager am = _FakeAbstractAppManager(
          theme: FakeBlocTheme(
            streamValue: const Stream<ThemeState>.empty(),
            stateOrDefaultValue: ThemeState.defaults,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: const Stream<OnboardingState>.empty(),
          ),
          pageManager: _pageManagerWithTopName('home'),
        );

        final JocaaguraAppShellController controller =
            JocaaguraAppShellController(
          appManager: am,
          themeStream: am.theme.stream,
          onboardingStream: am.onboarding.stateStream,
        );

        final OnboardingState idle = OnboardingState.idle();
        final OnboardingState running =
            idle.copyWith(status: OnboardingStatus.running);
        final OnboardingState completed =
            idle.copyWith(status: OnboardingStatus.completed);
        final OnboardingState skipped =
            idle.copyWith(status: OnboardingStatus.skipped);

        // Act + Assert
        expect(controller.shouldShowSplash(idle), isTrue);
        expect(controller.shouldShowSplash(running), isTrue);
        expect(controller.shouldShowSplash(completed), isFalse);
        expect(controller.shouldShowSplash(skipped), isFalse);
      });
    });

    group('handleLifecycle', () {
      test(
          'Given any state When handleLifecycle Then delegates to appManager.handleLifecycle',
          () {
        // Arrange
        final _FakeAbstractAppManager am = _FakeAbstractAppManager(
          theme: FakeBlocTheme(
            streamValue: const Stream<ThemeState>.empty(),
            stateOrDefaultValue: ThemeState.defaults,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: const Stream<OnboardingState>.empty(),
          ),
          pageManager: _pageManagerWithTopName('home'),
        );

        int scheduledCalls = 0;
        void scheduler(void Function() f) {
          scheduledCalls++;
          f();
        }

        final JocaaguraAppShellController controller =
            JocaaguraAppShellController(
          appManager: am,
          themeStream: am.theme.stream,
          onboardingStream: am.onboarding.stateStream,
          scheduler: scheduler,
        );

        // Act
        controller.handleLifecycle(
          state: AppLifecycleState.resumed,
          ownsManager: false,
        );

        // Assert
        expect(
          am.handledLifecycle,
          <AppLifecycleState>[AppLifecycleState.resumed],
        );
        expect(scheduledCalls, 0);
        expect(am.disposeCalls, 0);
      });

      test(
          'Given detached and ownsManager=false When handleLifecycle Then does not schedule dispose',
          () {
        // Arrange
        final _FakeAbstractAppManager am = _FakeAbstractAppManager(
          theme: FakeBlocTheme(
            streamValue: const Stream<ThemeState>.empty(),
            stateOrDefaultValue: ThemeState.defaults,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: const Stream<OnboardingState>.empty(),
          ),
          pageManager: _pageManagerWithTopName('home'),
        );

        int scheduledCalls = 0;
        void scheduler(void Function() f) {
          scheduledCalls++;
          f();
        }

        final JocaaguraAppShellController controller =
            JocaaguraAppShellController(
          appManager: am,
          themeStream: am.theme.stream,
          onboardingStream: am.onboarding.stateStream,
          scheduler: scheduler,
        );

        // Act
        controller.handleLifecycle(
          state: AppLifecycleState.detached,
          ownsManager: false,
        );

        // Assert
        expect(
          am.handledLifecycle,
          <AppLifecycleState>[AppLifecycleState.detached],
        );
        expect(scheduledCalls, 0);
        expect(am.disposeCalls, 0);
        expect(am.isDisposed, isFalse);
      });

      test(
          'Given detached and ownsManager=true and not disposed When handleLifecycle Then schedules and disposes',
          () {
        // Arrange
        final _FakeAbstractAppManager am = _FakeAbstractAppManager(
          theme: FakeBlocTheme(
            streamValue: const Stream<ThemeState>.empty(),
            stateOrDefaultValue: ThemeState.defaults,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: const Stream<OnboardingState>.empty(),
          ),
          pageManager: _pageManagerWithTopName('home'),
        );

        int scheduledCalls = 0;
        void scheduler(void Function() f) {
          scheduledCalls++;
          f(); // run sync for deterministic test
        }

        final JocaaguraAppShellController controller =
            JocaaguraAppShellController(
          appManager: am,
          themeStream: am.theme.stream,
          onboardingStream: am.onboarding.stateStream,
          scheduler: scheduler,
        );

        // Act
        controller.handleLifecycle(
          state: AppLifecycleState.detached,
          ownsManager: true,
        );

        // Assert
        expect(
          am.handledLifecycle,
          <AppLifecycleState>[AppLifecycleState.detached],
        );
        expect(scheduledCalls, 1);
        expect(am.disposeCalls, 1);
        expect(am.isDisposed, isTrue);
      });

      test(
          'Given detached and ownsManager=true but already disposed When handleLifecycle Then schedules but does not dispose again',
          () {
        // Arrange
        final _FakeAbstractAppManager am = _FakeAbstractAppManager(
          theme: FakeBlocTheme(
            streamValue: const Stream<ThemeState>.empty(),
            stateOrDefaultValue: ThemeState.defaults,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: const Stream<OnboardingState>.empty(),
          ),
          pageManager: _pageManagerWithTopName('home'),
        )..markDisposed();

        int scheduledCalls = 0;
        void scheduler(void Function() f) {
          scheduledCalls++;
          f();
        }

        final JocaaguraAppShellController controller =
            JocaaguraAppShellController(
          appManager: am,
          themeStream: am.theme.stream,
          onboardingStream: am.onboarding.stateStream,
          scheduler: scheduler,
        );

        // Act
        controller.handleLifecycle(
          state: AppLifecycleState.detached,
          ownsManager: true,
        );

        // Assert
        expect(
          am.handledLifecycle,
          <AppLifecycleState>[AppLifecycleState.detached],
        );
        expect(scheduledCalls, 1);
        expect(am.disposeCalls, 0); // guarded by isDisposed
      });
    });

    test(
      'Given controller When replaceManager Then swaps manager and updates streams',
      () async {
        // Arrange: initial manager
        final _FakeAbstractAppManager am1 = _FakeAbstractAppManager(
          theme: FakeBlocTheme(
            streamValue: const Stream<ThemeState>.empty(),
            stateOrDefaultValue: ThemeState.defaults,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle(),
            stateStreamValue: const Stream<OnboardingState>.empty(),
          ),
          pageManager: _pageManagerWithTopName('home'),
        );

        final JocaaguraAppShellController controller =
            JocaaguraAppShellController(
          appManager: am1,
          themeStream: am1.theme.stream,
          onboardingStream: am1.onboarding.stateStream,
        );

        // Arrange: new manager
        final StreamController<ThemeState> themeCtrl =
            StreamController<ThemeState>.broadcast();
        final StreamController<OnboardingState> onboardingCtrl =
            StreamController<OnboardingState>.broadcast();

        addTearDown(() async {
          await themeCtrl.close();
          await onboardingCtrl.close();
        });

        final _FakeAppManager am2 = _FakeAppManager(
          theme: FakeBlocTheme(
            streamValue: themeCtrl.stream,
            stateOrDefaultValue: ThemeState.defaults,
          ),
          onboarding: _FakeBlocOnboarding(
            stateValue: OnboardingState.idle()
                .copyWith(status: OnboardingStatus.running),
            stateStreamValue: onboardingCtrl.stream,
          ),
          pageManager: _pageManagerWithTopName('settings'),
        );

        // Act
        controller.replaceManager(am2);

        // Assert manager identity
        expect(identical(controller.appManager, am2), isTrue);

        // Assert streams by behavior
        final ThemeState emittedTheme =
            ThemeState.defaults.copyWith(mode: ThemeMode.light);
        final OnboardingState emittedOnboarding =
            OnboardingState.idle().copyWith(status: OnboardingStatus.completed);

        expectLater(controller.themeStream, emits(emittedTheme));
        expectLater(controller.onboardingStream, emits(emittedOnboarding));

        themeCtrl.add(emittedTheme);
        onboardingCtrl.add(emittedOnboarding);
      },
    );
  });
}
