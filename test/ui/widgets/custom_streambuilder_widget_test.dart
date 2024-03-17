import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/ui/widgets/custom_streambuilder_widget.dart';

void main() {
  late StreamController<String> streamController;
  const ValueKey<String> veryfyMeKey = ValueKey<String>('veryfyMeKey');

  const String text = 'Hello';
  const Text childWidget = Text(
    text,
    key: veryfyMeKey,
  );

  setUp(() {
    streamController = StreamController<String>()..sink.add(text);
  });

  tearDown(() {
    streamController.close();
  });
  testWidgets('CustomStreamBuilder should display the child widget',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomStreamBuilderWidget<String>(
          stream: streamController.stream,
          child: childWidget,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byWidget(childWidget), findsOneWidget);
  });
}
