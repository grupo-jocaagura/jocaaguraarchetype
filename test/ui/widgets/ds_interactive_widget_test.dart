import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('DsInteractiveBuilder', () {
    testWidgets(
      'Given enabled state When rendered Then uses enabled builder',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(),
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('enabled');
              },
            ),
          ),
        );

        expect(find.text('enabled'), findsOneWidget);
      },
    );

    testWidgets(
      'Given hidden state without hiddenBuilder When rendered Then renders shrink',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(isVisible: false),
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('enabled');
              },
            ),
          ),
        );

        expect(find.text('enabled'), findsNothing);
        expect(find.byType(SizedBox), findsOneWidget);
      },
    );

    testWidgets(
      'Given hidden state with hiddenBuilder When rendered Then uses hidden builder',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(isVisible: false),
              hiddenBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('hidden');
              },
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('enabled');
              },
            ),
          ),
        );

        expect(find.text('hidden'), findsOneWidget);
        expect(find.text('enabled'), findsNothing);
      },
    );

    testWidgets(
      'Given loading state When rendered Then uses loading builder',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(
                isLoading: true,
                isEnabled: false,
              ),
              loadingBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('loading');
              },
              disabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('disabled');
              },
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('enabled');
              },
            ),
          ),
        );

        expect(find.text('loading'), findsOneWidget);
        expect(find.text('disabled'), findsNothing);
        expect(find.text('enabled'), findsNothing);
      },
    );

    testWidgets(
      'Given loading state without loadingBuilder When rendered Then falls back to disabled builder',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(
                isLoading: true,
                isEnabled: false,
              ),
              disabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('disabled');
              },
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('enabled');
              },
            ),
          ),
        );

        expect(find.text('disabled'), findsOneWidget);
        expect(find.text('enabled'), findsNothing);
      },
    );

    testWidgets(
      'Given loading state without loading or disabled builder When rendered Then falls back to enabled builder',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(
                isLoading: true,
                isEnabled: false,
              ),
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return Text('enabled ${state.isLoading}');
              },
            ),
          ),
        );

        expect(find.text('enabled true'), findsOneWidget);
      },
    );

    testWidgets(
      'Given error state When rendered Then uses error builder',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(
                errorText: 'Something failed',
              ),
              errorBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return Text('error ${state.errorText}');
              },
              disabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('disabled');
              },
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('enabled');
              },
            ),
          ),
        );

        expect(find.text('error Something failed'), findsOneWidget);
        expect(find.text('disabled'), findsNothing);
        expect(find.text('enabled'), findsNothing);
      },
    );

    testWidgets(
      'Given error state without errorBuilder When rendered Then falls back to disabled builder',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(
                errorText: 'Something failed',
              ),
              disabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('disabled');
              },
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('enabled');
              },
            ),
          ),
        );

        expect(find.text('disabled'), findsOneWidget);
        expect(find.text('enabled'), findsNothing);
      },
    );

    testWidgets(
      'Given selected state When rendered Then uses selected builder',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(isSelected: true),
              selectedBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('selected');
              },
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('enabled');
              },
            ),
          ),
        );

        expect(find.text('selected'), findsOneWidget);
        expect(find.text('enabled'), findsNothing);
      },
    );

    testWidgets(
      'Given selected state without selectedBuilder When rendered Then falls back to enabled builder',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(isSelected: true),
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return Text('enabled selected ${state.isSelected}');
              },
            ),
          ),
        );

        expect(find.text('enabled selected true'), findsOneWidget);
      },
    );

    testWidgets(
      'Given disabled state When rendered Then uses disabled builder',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(
                isEnabled: false,
                reasonText: 'Not allowed',
              ),
              disabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return Text('disabled ${state.reasonText}');
              },
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('enabled');
              },
            ),
          ),
        );

        expect(find.text('disabled Not allowed'), findsOneWidget);
        expect(find.text('enabled'), findsNothing);
      },
    );

    testWidgets(
      'Given disabled state without disabledBuilder When rendered Then falls back to enabled builder',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(
                isEnabled: false,
                reasonText: 'Not allowed',
              ),
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return Text('enabled fallback ${state.canInteract}');
              },
            ),
          ),
        );

        expect(find.text('enabled fallback false'), findsOneWidget);
      },
    );

    testWidgets(
      'Given hidden loading error selected disabled state When rendered Then hidden has priority',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(
                isVisible: false,
                isLoading: true,
                isEnabled: false,
                isSelected: true,
                errorText: 'Error',
              ),
              hiddenBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('hidden');
              },
              loadingBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('loading');
              },
              errorBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('error');
              },
              selectedBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('selected');
              },
              disabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('disabled');
              },
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('enabled');
              },
            ),
          ),
        );

        expect(find.text('hidden'), findsOneWidget);
        expect(find.text('loading'), findsNothing);
        expect(find.text('error'), findsNothing);
        expect(find.text('selected'), findsNothing);
        expect(find.text('disabled'), findsNothing);
        expect(find.text('enabled'), findsNothing);
      },
    );

    testWidgets(
      'Given loading error selected disabled state When rendered Then loading has priority after visible',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(
                isLoading: true,
                isEnabled: false,
                isSelected: true,
                errorText: 'Error',
              ),
              loadingBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('loading');
              },
              errorBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('error');
              },
              selectedBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('selected');
              },
              disabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('disabled');
              },
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('enabled');
              },
            ),
          ),
        );

        expect(find.text('loading'), findsOneWidget);
        expect(find.text('error'), findsNothing);
        expect(find.text('selected'), findsNothing);
        expect(find.text('disabled'), findsNothing);
        expect(find.text('enabled'), findsNothing);
      },
    );

    testWidgets(
      'Given error selected disabled state When rendered Then error has priority after loading',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: DsInteractiveBuilder(
              state: const ModelInteractiveState(
                isEnabled: false,
                isSelected: true,
                errorText: 'Error',
              ),
              errorBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('error');
              },
              selectedBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('selected');
              },
              disabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('disabled');
              },
              enabledBuilder: (
                BuildContext context,
                ModelInteractiveState state,
              ) {
                return const Text('enabled');
              },
            ),
          ),
        );

        expect(find.text('error'), findsOneWidget);
        expect(find.text('selected'), findsNothing);
        expect(find.text('disabled'), findsNothing);
        expect(find.text('enabled'), findsNothing);
      },
    );
  });
}
