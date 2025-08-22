// example/lib/support/example_env.dart
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'example_services.dart';

/// Modos de ejecución para el example.
enum AppMode { dev, qa }

/// Entorno estático simple para el example (solo demo).
class ExampleEnv {
  static late BlocAppConfig appConfigBloc;
  static late AppConfig cfgDev;
  static late AppConfig cfgQa;

  /// Construye un AppConfig para el modo dado.
  static AppConfig buildConfig({
    required AppMode mode,
    required PageRegistry registry,
  }) {
    // Onboarding steps: conectividad + sesión (Either<ErrorItem, Unit>).
    final List<OnboardingStep> steps = <OnboardingStep>[
      OnboardingStep(
        title: 'net-check',
        onEnter: () async {
          final bool online = await ExampleConnectivity.instance.checkNow();
          if (!online) {
            return Left<ErrorItem, Unit>(
              const ErrorItem(
                title: 'offline',
                code: 'offline',
                description: 'No connection available',
                errorLevel: ErrorLevelEnum.severe,
              ),
            );
          }
          return Right<ErrorItem, Unit>(Unit.value);
        },
      ),
      OnboardingStep(
        title: 'session-check',
        onEnter: () async {
          // La navegación final se decide tras completar el onboarding.
          await ExampleAuth.instance.ensureInitializedAndCheck();
          return Right<ErrorItem, Unit>(Unit.value);
        },
      ),
      // (Opcional) Auto-advance explícito por UX:
      // OnboardingStep(title: 'finish', autoAdvanceAfter: const Duration(milliseconds: 1)),
    ];

    // Preconfigurar fakes por modo
    if (mode == AppMode.dev) {
      ExampleConnectivity.instance.setOnline(true);
      ExampleAuth.instance.setLoggedIn(false);
    } else {
      ExampleConnectivity.instance.setOnline(true);
      ExampleAuth.instance.setLoggedIn(true);
    }

    return AppConfig.dev(
      registry: registry,
      onboardingSteps: steps,
    );
  }
}
