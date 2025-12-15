import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('JocaaguraSplashOverlay', () {
    late StreamController<OnboardingState> controller;

    setUp(() {
      controller = StreamController<OnboardingState>.broadcast();
    });

    tearDown(() async {
      await controller.close();
    });

    testWidgets(
      'Given initial onboarding When built Then renders using initial state',
      (WidgetTester tester) async {
        final OnboardingState initial = OnboardingState.idle();

        await tester.pumpWidget(
          MaterialApp(
            home: JocaaguraSplashOverlay(
              onboardingStream: controller.stream,
              initialOnboarding: initial,
              overlayBuilder: (BuildContext context, OnboardingState os) {
                return Text(
                  'status:${os.status.name}',
                  key: const Key('status'),
                );
              },
            ),
          ),
        );

        expect(find.byKey(const Key('status')), findsOneWidget);
        expect(find.text('status:idle'), findsOneWidget);
      },
    );

    testWidgets(
      'Given stream emits running When new state arrives Then rebuilds with emitted state',
      (WidgetTester tester) async {
        final OnboardingState initial = OnboardingState.idle();
        final OnboardingState running = initial.copyWith(
          status: OnboardingStatus.running,
          totalSteps: 2,
          stepIndex: 0,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: JocaaguraSplashOverlay(
              onboardingStream: controller.stream,
              initialOnboarding: initial,
              overlayBuilder: (BuildContext context, OnboardingState os) {
                return Text(
                  'status:${os.status.name}',
                  key: const Key('status'),
                );
              },
            ),
          ),
        );

        expect(find.text('status:idle'), findsOneWidget);

        controller.add(running);
        await tester.pump();

        expect(find.text('status:idle'), findsNothing);
        expect(find.text('status:running'), findsOneWidget);
      },
    );

    testWidgets(
      'Given stream emits completed When new state arrives Then overlayBuilder receives completed',
      (WidgetTester tester) async {
        final OnboardingState initial = OnboardingState.idle();
        final OnboardingState completed = initial.copyWith(
          status: OnboardingStatus.completed,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: JocaaguraSplashOverlay(
              onboardingStream: controller.stream,
              initialOnboarding: initial,
              overlayBuilder: (BuildContext context, OnboardingState os) {
                return Text(
                  'status:${os.status.name}',
                  key: const Key('status'),
                );
              },
            ),
          ),
        );

        controller.add(completed);
        await tester.pump();

        expect(find.text('status:completed'), findsOneWidget);
      },
    );
  });
}
