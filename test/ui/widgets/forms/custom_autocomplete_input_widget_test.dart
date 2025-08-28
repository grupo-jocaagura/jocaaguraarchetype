import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

Future<void> _pump(
  WidgetTester tester, {
  required Widget child,
  Size surface = const Size(800, 600),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: MediaQuery(
        data: MediaQueryData(size: surface),
        child:
            Scaffold(body: Center(child: SizedBox(width: 320, child: child))),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _tf() => find.byType(TextField);

void main() {
  group('CustomAutoCompleteInputWidget', () {
    testWidgets(
        'render básico + label/placeholder/icon + valor inicial y validación inicial OK',
        (WidgetTester tester) async {
      final List<String> changed = <String>[];
      final List<String> submitted = <String>[];

      String? validator(String? v) => null; // siempre válido

      final CustomAutoCompleteInputWidget w = CustomAutoCompleteInputWidget(
        label: 'Usuario',
        placeholder: 'Tu usuario',
        icondata: Icons.person_outline,
        initialData: 'init',
        onEditingValidateFunction: validator,
        onChanged: changed.add,
        onFieldSubmitted: submitted.add,
      );

      await _pump(tester, child: w);

      // Vistas básicas
      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('Tu usuario'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);

      // El TextField refleja el valor inicial
      final TextField tf = tester.widget(_tf());
      expect(tf.controller!.text, 'init');

      // Como el inicial es válido, onChanged se dispara en initState vía _onValidate
      expect(changed, contains('init'));
    });

    testWidgets(
        'validación inicial inválida muestra error y NO dispara onChanged',
        (WidgetTester tester) async {
      final List<String> changed = <String>[];

      String? validator(String? v) => (v == 'ok') ? null : 'err';

      final CustomAutoCompleteInputWidget w = CustomAutoCompleteInputWidget(
        onEditingValidateFunction: validator,
        onChanged: changed.add,
      );

      await _pump(tester, child: w);

      // Error visible (por initState -> _onValidate(''))
      expect(find.text('err'), findsOneWidget);
      expect(changed, isEmpty);
    });

    testWidgets(
        'filtrado de sugerencias (case-insensitive) y selección actualiza valor + onChanged',
        (WidgetTester tester) async {
      final List<String> changed = <String>[];

      final CustomAutoCompleteInputWidget w = CustomAutoCompleteInputWidget(
        suggestList: const <String>['Apple', 'Banana', 'Grape', 'Pineapple'],
        onEditingValidateFunction: (String? v) => null, // siempre válido
        onChanged: changed.add,
      );

      await _pump(tester, child: w);

      await tester.tap(_tf());
      await tester.pump();

      await tester.enterText(_tf(), 'ap'); // Apple, Grape, Pineapple
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Grape'), findsOneWidget);
      expect(find.text('Pineapple'), findsOneWidget);
      expect(find.text('Banana'), findsNothing);

      // Tocar Pineapple
      await tester.tap(find.text('Pineapple'));
      await tester.pumpAndSettle();

      // TextField quedó con Pineapple y onChanged fue llamado
      final TextField tf = tester.widget(_tf());
      expect(tf.controller!.text, 'Pineapple');
      expect(changed.contains('Pineapple'), isTrue);
    });

    testWidgets(
        'submit (IME done) llama onFieldSubmitted solo si pasa validación',
        (WidgetTester tester) async {
      final List<String> submitted = <String>[];

      String? validator(String? v) => (v == 'ok') ? null : 'err';

      final CustomAutoCompleteInputWidget w = CustomAutoCompleteInputWidget(
        onEditingValidateFunction: validator,
        onChanged: (_) {},
        onFieldSubmitted: submitted.add,
      );

      await _pump(tester, child: w);

      // Caso inválido: no debe llamar onFieldSubmitted
      await tester.tap(_tf());
      await tester.enterText(_tf(), 'bad');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(submitted, isEmpty);
      expect(find.text('err'), findsOneWidget);

      // Caso válido
      await tester.enterText(_tf(), 'ok');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(submitted.last, 'ok');
      expect(find.text('err'), findsNothing);
    });

    testWidgets('debounce: onChanged se dispara tras el delay configurado',
        (WidgetTester tester) async {
      final List<String> changed = <String>[];

      // validator siempre OK para que onChanged se llame cuando dispare _onValidate
      final CustomAutoCompleteInputWidget w = CustomAutoCompleteInputWidget(
        onEditingValidateFunction: (String? v) => null,
        onChangedDebounce: const Duration(milliseconds: 200),
        onChanged: changed.add,
      );

      await _pump(tester, child: w);

      await tester.tap(_tf());
      await tester.enterText(_tf(), 'hello');
      await tester.pump(const Duration(milliseconds: 100));
      // Aún no (debounce 200ms)
      expect(changed.where((String e) => e == 'hello'), isEmpty);

      await tester.pump(const Duration(milliseconds: 120));
      // Ya pasó el umbral
      expect(changed.where((String e) => e == 'hello'), isNotEmpty);

      // Nuevo cambio reinicia debounce
      await tester.enterText(_tf(), 'world');
      await tester.pump(const Duration(milliseconds: 150));
      expect(changed.where((String e) => e == 'world'), isEmpty);
      await tester.pump(const Duration(milliseconds: 60));
      expect(changed.where((String e) => e == 'world'), isNotEmpty);
    });

    testWidgets('overlay: respeta minWidth=280 y maxHeight=240 (por defecto)',
        (WidgetTester tester) async {
      final CustomAutoCompleteInputWidget w = CustomAutoCompleteInputWidget(
        suggestList: List<String>.generate(40, (int i) => 'item $i'),
        onEditingValidateFunction: (String? v) => null,
        onChanged: (_) {},
      );

      // superficie angosta para forzar el minWidth del overlay
      await _pump(
        tester,
        child: w,
        surface: const Size(260, 600),
      );

      await tester.tap(_tf());
      await tester.enterText(_tf(), 'item');
      await tester.pumpAndSettle();

      final Size lv = tester.getSize(find.byType(ListView).first);
      expect(lv.width >= 280, isTrue);
      expect(lv.height <= 240, isTrue);
    });

    testWidgets('errorText aparece/disminuye según validación al escribir',
        (WidgetTester tester) async {
      final List<String> changed = <String>[];

      String? validator(String? v) =>
          (v != null && v.length >= 3) ? null : 'min 3';

      final CustomAutoCompleteInputWidget w = CustomAutoCompleteInputWidget(
        onEditingValidateFunction: validator,
        onChanged: changed.add,
      );

      await _pump(tester, child: w);

      await tester.tap(_tf());
      await tester.enterText(_tf(), 'hi');
      await tester.pumpAndSettle();
      expect(find.text('min 3'), findsOneWidget);
      expect(changed, isEmpty); // aún inválido

      await tester.enterText(_tf(), 'hey');
      await tester.pumpAndSettle();
      expect(find.text('min 3'), findsNothing);
      expect(changed.contains('hey'), isTrue);
    });

    testWidgets('propaga keyboardType', (WidgetTester tester) async {
      final CustomAutoCompleteInputWidget w = CustomAutoCompleteInputWidget(
        textInputType: TextInputType.emailAddress,
        onEditingValidateFunction: (String? v) => null,
        onChanged: (_) {},
      );

      await _pump(tester, child: w);
      final TextField tf = tester.widget(_tf());
      expect(tf.keyboardType, TextInputType.emailAddress);
    });
  });
}
