part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class JocaaguraSplashOverlay extends StatelessWidget {
  const JocaaguraSplashOverlay({
    required this.onboardingStream,
    required this.initialOnboarding,
    required this.overlayBuilder,
    super.key,
  });

  final Stream<OnboardingState> onboardingStream;
  final OnboardingState initialOnboarding;
  final Widget Function(BuildContext, OnboardingState) overlayBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OnboardingState>(
      stream: onboardingStream,
      initialData: initialOnboarding,
      builder: (BuildContext ctx, AsyncSnapshot<OnboardingState> snap) {
        final OnboardingState os = snap.data ?? initialOnboarding;
        return overlayBuilder(ctx, os);
      },
    );
  }
}
