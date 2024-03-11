import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/navigator/page_manager.dart';
import 'package:jocaaguraarchetype/ui/pages/page_404_widget.dart';

// revisado 10/03/2024 author: @albertjjimenezp
class MockPageManager extends PageManager {
  bool backCalled = false;
  int _historyPagesCount = 0;

  @override
  void back() {
    backCalled = true;
  }

  @override
  int get historyPagesCount => _historyPagesCount;

  set historyPagesCount(int value) {
    _historyPagesCount = value;
  }

  void setCurrentUrl(RouteInformation routeInformation) {}
}

void main() {
  testWidgets('Page404Widget - Back button is shown when historyPagesCount > 1',
      (WidgetTester tester) async {
    final MockPageManager mockPageManager = MockPageManager();
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
    final MockPageManager mockPageManager = MockPageManager();
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
    final MockPageManager mockPageManager = MockPageManager();
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
