import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'example_services.dart';

enum AppMode { dev, qa }

class ExampleEnv {
  static late BlocAppConfig appConfigBloc;
  static late AppConfig cfgDev;
  static late AppConfig cfgQa;

  static AppConfig buildConfig({
    required AppMode mode,
    required PageRegistry registry,
  }) {
    final List<OnboardingStep> steps = <OnboardingStep>[
      OnboardingStep(
        title: 'net-check',
        onEnter: () async {
          try {
            final ConnectionTypeEnum t =
                await ExampleServices.connectivity.checkConnectivity();
            final bool online = t != ConnectionTypeEnum.none;
            if (!online) {
              return Left<ErrorItem, Unit>(
                const ErrorItem(
                  title: 'Offline',
                  code: 'NET_OFFLINE',
                  description:
                      'No network connection detected. Please check your connectivity.',
                  errorLevel: ErrorLevelEnum.severe,
                ),
              );
            }
            return Right<ErrorItem, Unit>(Unit.value);
          } catch (e) {
            return Left<ErrorItem, Unit>(
              ErrorItem(
                title: 'Connectivity Error',
                code: 'NET_CHECK_FAIL',
                description: e.toString(),
                errorLevel: ErrorLevelEnum.severe,
              ),
            );
          }
        },
        autoAdvanceAfter: const Duration(seconds: 1),
      ),
      OnboardingStep(
        title: 'session-check',
        onEnter: () async {
          await ExampleServices.auth.ensureInitializedAndCheck();
          return Right<ErrorItem, Unit>(Unit.value);
        },
        autoAdvanceAfter: const Duration(seconds: 1),
      ),
    ];

    if (mode == AppMode.dev) {
      ExampleServices.connectivity.simulateConnection(ConnectionTypeEnum.wifi);
      ExampleServices.auth.setLoggedIn(false);
    } else {
      ExampleServices.connectivity.simulateConnection(ConnectionTypeEnum.wifi);
      ExampleServices.auth.setLoggedIn(true);
    }

    return AppConfig.dev(
      registry: registry,
      onboardingSteps: steps,
    );
  }
}
