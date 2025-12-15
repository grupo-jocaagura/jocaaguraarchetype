part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

typedef MicrotaskScheduler = void Function(void Function());

class JocaaguraAppShellController {
  JocaaguraAppShellController({
    required AbstractAppManager appManager,
    required Stream<ThemeState> themeStream,
    required Stream<OnboardingState> onboardingStream,
    MicrotaskScheduler scheduler = scheduleMicrotask,
  })  : _appManager = appManager,
        _themeStream = themeStream,
        _onboardingStream = onboardingStream,
        _scheduler = scheduler;

  factory JocaaguraAppShellController.fromManager(
    AbstractAppManager appManager, {
    MicrotaskScheduler scheduler = scheduleMicrotask,
  }) {
    return JocaaguraAppShellController(
      appManager: appManager,
      themeStream: appManager.theme.stream,
      onboardingStream: appManager.onboarding.stateStream,
      scheduler: scheduler,
    );
  }

  AbstractAppManager _appManager;
  Stream<ThemeState> _themeStream;
  Stream<OnboardingState> _onboardingStream;
  final MicrotaskScheduler _scheduler;

  AbstractAppManager get appManager => _appManager;
  Stream<ThemeState> get themeStream => _themeStream;
  Stream<OnboardingState> get onboardingStream => _onboardingStream;

  ThemeState get initialTheme => _appManager.theme.stateOrDefault;
  OnboardingState get initialOnboarding => _appManager.onboarding.state;

  /// Lógica pura: resolvemos el path inicial sin tocar Flutter.
  String computeSeedPath({
    required bool seedInitialFromPageManager,
    required String initialLocation,
  }) {
    if (seedInitialFromPageManager) {
      final PageModel top = _appManager.pageManager.stack.top;
      if (top.name.isNotEmpty) {
        return '/${top.name}';
      }
    }
    return initialLocation;
  }

  bool shouldShowSplash(OnboardingState os) {
    return os.status == OnboardingStatus.idle ||
        os.status == OnboardingStatus.running;
  }

  /// Lógica testable: puedes inyectar scheduler sync en tests.
  void handleLifecycle({
    required AppLifecycleState state,
    required bool ownsManager,
  }) {
    _appManager.handleLifecycle(state);

    if (state == AppLifecycleState.detached && ownsManager) {
      _scheduler(() {
        if (!_appManager.isDisposed) {
          _appManager.dispose();
        }
      });
    }
  }

  /// Para didUpdateWidget (cuando cambia el manager)
  void replaceManager(AbstractAppManager newManager) {
    _appManager = newManager;
    _themeStream = newManager.theme.stream;
    _onboardingStream = newManager.onboarding.stateStream;
  }
}
