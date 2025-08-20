import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 author: @albertjjimenezp
class MockPageManager extends PageManager {
  MockPageManager({required super.initial});

  bool backCalled = false;
  int historyPagesCount = 0;

  void back() {
    backCalled = true;
  }

  void setCurrentUrl(RouteInformation routeInformation) {}
}

void main() {
  testWidgets('Page404Widget - Back button is shown when historyPagesCount > 1',
      (WidgetTester tester) async {
    final MockPageManager mockPageManager =
        MockPageManager(initial: NavStackModel(const <PageModel>[]));
    mockPageManager.historyPagesCount =
        2; // Set historyPagesCount to a value > 1

    await tester.pumpWidget(
      MaterialApp(
        home: Page404Widget(pageManager: mockPageManager),
      ),
    );

    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets(
      'Page404Widget - Back button is not shown when historyPagesCount <= 1',
      (WidgetTester tester) async {
    final MockPageManager mockPageManager =
        MockPageManager(initial: NavStackModel(const <PageModel>[]));
    mockPageManager.historyPagesCount =
        1; // Set historyPagesCount to a value <= 1

    await tester.pumpWidget(
      MaterialApp(
        home: Page404Widget(pageManager: mockPageManager),
      ),
    );

    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('Page404Widget - Back button calls pageManager.back()',
      (WidgetTester tester) async {
    final MockPageManager mockPageManager =
        MockPageManager(initial: NavStackModel(const <PageModel>[]));
    mockPageManager.historyPagesCount =
        2; // Set historyPagesCount to a value > 1

    await tester.pumpWidget(
      MaterialApp(
        home: Page404Widget(pageManager: mockPageManager),
      ),
    );

    await tester.tap(find.byType(BackButton));
    expect(mockPageManager.backCalled, isTrue);
  });
}
