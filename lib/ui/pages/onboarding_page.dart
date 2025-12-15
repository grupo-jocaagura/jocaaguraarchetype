part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Simple onboarding flow for first-run setup.
///
/// Supply the steps (widgets or descriptors) and handle completion by
/// notifying the AbstractAppManager / Router to proceed to the home route.
///
/// ### Example
/// ```dart
/// OnboardingPage(
///   steps: <Widget>[
///     const _StepWelcome(),
///     const _StepPermissions(),
///   ],
///   onFinish: () => context.read<AppManager>().goToHome(),
/// );
/// ```
class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({required this.blocOnboarding, super.key});
  final BlocOnboarding blocOnboarding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: StreamBuilder<OnboardingState>(
              stream: blocOnboarding.stateStream,
              builder: (
                BuildContext context,
                AsyncSnapshot<OnboardingState> snapshot,
              ) {
                return Text(
                  blocOnboarding.currentStep?.title ?? 'Loading...',
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
