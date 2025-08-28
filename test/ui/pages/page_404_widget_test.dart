import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('Page404Widget', () {
    testWidgets('muestra título y mensaje base', (WidgetTester tester) async {
      final _FakePageManager pm = _FakePageManager(history: <String>['/home']);

      await _pump404(tester, pageManager: pm);

      expect(find.text('Error 404'), findsOneWidget);
      expect(find.text('Pagina No encontrada'), findsOneWidget);
      expect(
        find.byType(BackButton),
        findsNothing,
      ); // solo 1 entrada → sin back
    });

    testWidgets('muestra BackButton cuando historyNames.length > 1',
        (WidgetTester tester) async {
      final _FakePageManager pm =
          _FakePageManager(history: <String>['/home', '/details']);

      await _pump404(tester, pageManager: pm);

      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('tap en BackButton llama a pageManager.pop',
        (WidgetTester tester) async {
      final _FakePageManager pm =
          _FakePageManager(history: <String>['/home', '/details']);

      await _pump404(tester, pageManager: pm);

      expect(pm.popped, isFalse);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(pm.popped, isTrue);
    });
  });
}

/// --- Helpers & Fakes ---

Future<void> _pump404(
  WidgetTester tester, {
  required PageManager pageManager,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Page404Widget(pageManager: pageManager),
    ),
  );
  await tester.pumpAndSettle();
}

/// Fake mínimo que satisface lo que Page404Widget utiliza.
/// Si tu PageManager real tiene más miembros, añade stubs aquí.
class _FakePageManager implements PageManager {
  _FakePageManager({required List<String> history})
      : _history = List<String>.from(history);

  final List<String> _history;
  bool popped = false;

  @override
  List<String> get historyNames => _history;

  @override
  bool pop() {
    popped = true;
    return popped;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
