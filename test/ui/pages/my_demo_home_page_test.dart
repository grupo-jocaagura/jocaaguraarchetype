import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../mocks/make_testeable_app.dart';

void main() {
  group('MyDemoHomePage Widget Tests', () {
    testWidgets('My demo home page line test coverage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTesteablePage(
          child: const MyDemoHomePage(
            title: 'Test Title',
          ),
        ),
      );
      await tester.pump(
        const Duration(seconds: 2),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MaterialButton).first);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    });
  });
}
