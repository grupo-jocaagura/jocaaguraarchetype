import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  testWidgets('PageRegistry builds registered and 404 for unknown',
      (WidgetTester tester) async {
    final PageRegistry reg = PageRegistry(<String, PageWidgetBuilder>{
      'home': (_, __) => const Text('HOME'),
    });

    const PageModel home = PageModel(name: 'home', segments: <String>['home']);
    const PageModel unknown =
        PageModel(name: 'unknown', segments: <String>['unknown']);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext ctx) => Column(
            children: <Widget>[
              reg.build(ctx, home),
              reg.build(ctx, unknown),
            ],
          ),
        ),
      ),
    );

    expect(find.text('HOME'), findsOneWidget);
    expect(find.textContaining('404'), findsOneWidget);
  });
}
