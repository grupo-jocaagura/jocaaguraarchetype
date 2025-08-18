import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

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
