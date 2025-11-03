part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Helper to build an onboarding step that safely loads a deferred module.
///
/// Example
/// ```dart
/// // In your app package:
/// import 'package:firebase_core/firebase_core.dart' deferred as fb_core;
///
/// final steps = <OnboardingStep>[
///   deferredStep(
///     title: 'Core',
///     description: 'Loading core services…',
///     load: () async {
///       await fb_core.loadLibrary();
///       // await fb_core.Firebase.initializeApp(options: ...);
///     },
///     timeout: const Duration(seconds: 8),
///   ),
/// ];
/// ```
OnboardingStep deferredStep({
  required String title,
  required String description,
  required Future<void> Function() load,
  Duration timeout = const Duration(seconds: 10),
}) {
  return OnboardingStep(
    title: title,
    description: description,
    onEnter: () async {
      try {
        await load().timeout(timeout);
        return Right<ErrorItem, Unit>(Unit.value);
      } on TimeoutException {
        return Left<ErrorItem, Unit>(
          ErrorItem(
            title: 'Timeout while loading $title',
            code: 'ONBOARDNGSTEP_TIMEOUT',
            description: '',
          ),
        );
      } catch (e, s) {
        return Left<ErrorItem, Unit>(
          ErrorItem(
            title: 'Failed to load $title: $e',
            description: s.toString(),
            code: 'ONBOARDINGSTEP_FAILED_TO_LOAD',
          ),
        );
      }
    },
    autoAdvanceAfter: const Duration(milliseconds: 200),
  );
}
