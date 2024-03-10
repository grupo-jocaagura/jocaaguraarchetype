import 'package:flutter/material.dart';

import '../../blocs/bloc_onboarding.dart';

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
            child: StreamBuilder<String>(
              stream: blocOnboarding.msgStream,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return Text(
                  blocOnboarding.msg,
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
