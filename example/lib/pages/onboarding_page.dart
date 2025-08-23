import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../support/example_services.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  Object? _lastManagerIdentity;
  bool _startedForThisManager = false;

  void _ensureStarted() {
    final AppManager app = context.appManager;
    final Object identity = app; // identidad por instancia

    if (!identical(_lastManagerIdentity, identity)) {
      _lastManagerIdentity = identity;
      _startedForThisManager = false;
    }

    if (!_startedForThisManager) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        app.onboarding.start();
      });
      _startedForThisManager = true;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureStarted());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureStarted();
  }

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    return StreamBuilder<OnboardingState>(
      stream: app.onboarding.stateStream,
      initialData: app.onboarding.state,
      builder: (BuildContext context, AsyncSnapshot<OnboardingState> snap) {
        final OnboardingState s = snap.data ?? OnboardingState.idle();
        if (s.status == OnboardingStatus.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final bool logged =
                await ExampleServices.auth.ensureInitializedAndCheck();
            app.replaceTopNamed(
              logged ? 'homeSession' : 'home',
              segments: <String>[if (logged) 'home-session' else 'home'],
            );
          });
        }
        final String title = (s.hasStep && app.onboarding.currentStep != null)
            ? (app.onboarding.currentStep!.title)
            : 'Starting…';
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(title),
                if (s.error != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    s.error!.description,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: app.onboarding.retryOnEnter,
                    child: const Text('Retry'),
                  ),
                  TextButton(
                    onPressed: app.onboarding.skip,
                    child: const Text('Skip'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
