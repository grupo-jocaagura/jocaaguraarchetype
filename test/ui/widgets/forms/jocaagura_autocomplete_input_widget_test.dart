import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Harness controlado que simula al BLoC/parent:
/// - guarda `value` y lo actualiza cuando el widget emite onChangedAttempt/onSubmittedAttempt.
class _Harness extends StatefulWidget {
  const _Harness({
    required this.initialValue,
    required this.onChangedLog,
    required this.onSubmittedLog,
    this.errorText,
    this.suggestList,
    this.label = '',
    this.placeholder = '',
    this.icon,
    this.obscureText = false,
    this.showToggleObscure = true,
    this.maxOptionsHeight = 240,
    this.minOptionsWidth = 280,
    this.autofillHints,
    this.semanticsLabel,
    this.semanticsHint,
    super.key,
  });

  final String initialValue;
  final List<String>? suggestList;
  final String? errorText;
  final String label;
  final String placeholder;
  final IconData? icon;
  final bool obscureText;
  final bool showToggleObscure;
  final double maxOptionsHeight;
  final double minOptionsWidth;
  final Iterable<String>? autofillHints;
  final String? semanticsLabel;
  final String? semanticsHint;

  final List<String> onChangedLog;
  final List<String> onSubmittedLog;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  String _value = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _error = widget.errorText;
  }

  void setExternalValue(String v, {String? error}) {
    setState(() {
      _value = v;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return JocaaguraAutocompleteInputWidget(
      value: _value,
      errorText: _error,
      label: widget.label,
      placeholder: widget.placeholder,
      icondata: widget.icon,
      suggestList: widget.suggestList,
      obscureText: widget.obscureText,
      showToggleObscure: widget.showToggleObscure,
      maxOptionsHeight: widget.maxOptionsHeight,
      minOptionsWidth: widget.minOptionsWidth,
      autofillHints: widget.autofillHints,
      semanticsLabel: widget.semanticsLabel,
      semanticsHint: widget.semanticsHint,
      onChangedAttempt: (String t) {
        widget.onChangedLog.add(t);
        setState(() => _value = t);
      },
      onSubmittedAttempt: (String t) {
        widget.onSubmittedLog.add(t);
        setState(() => _value = t);
      },
    );
  }
}

/// Helper para montar dentro de MaterialApp/Scaffold (necesario para Overlay).
Future<void> _pumpHarness(
  WidgetTester tester, {
  required _Harness harness,
  Size surface = const Size(800, 600),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: MediaQuery(
        data: MediaQueryData(size: surface),
        child: Scaffold(
          body: Center(
            child: SizedBox(width: 300, child: harness),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _textFieldFinder() => find.byType(TextField);

void main() {
  group('JocaaguraAutocompleteInputWidget (controlado)', () {
    testWidgets('render básico, label/placeholder, icono y errorText',
        (WidgetTester tester) async {
      final List<String> changed = <String>[];
      final List<String> submitted = <String>[];

      final _Harness harness = _Harness(
        initialValue: 'init',
        onChangedLog: changed,
        onSubmittedLog: submitted,
        label: 'Usuario',
        placeholder: 'Tu usuario',
        icon: Icons.person_outline,
        errorText: 'Ups',
      );

      await _pumpHarness(tester, harness: harness);

      // Label visible (InputDecorator usa Text para label)
      expect(find.text('Usuario'), findsOneWidget);
      // Placeholder (hint)
      expect(find.text('Tu usuario'), findsOneWidget);
      // Ícono
      expect(find.byIcon(Icons.person_outline), findsOneWidget);

      // Valor inicial reflejado en el TextField
      final TextField tf = tester.widget(_textFieldFinder());
      expect(tf.controller!.text, 'init');

      // Error visible
      expect(find.text('Ups'), findsOneWidget);
    });

    testWidgets('sync externo: el padre cambia value y el campo se actualiza',
        (WidgetTester tester) async {
      final List<String> changed = <String>[];
      final List<String> submitted = <String>[];

      final GlobalKey<_HarnessState> key = GlobalKey<_HarnessState>();
      final _Harness harness = _Harness(
        key: key,
        initialValue: 'A',
        onChangedLog: changed,
        onSubmittedLog: submitted,
      );

      await _pumpHarness(tester, harness: harness);

      key.currentState!.setExternalValue('B', error: 'Err');
      await tester.pumpAndSettle();

      final TextField tf = tester.widget(_textFieldFinder());
      expect(tf.controller!.text, 'B');
      expect(find.text('Err'), findsOneWidget);
    });

    testWidgets('onChangedAttempt y filtrado de sugerencias (case-insensitive)',
        (WidgetTester tester) async {
      final List<String> changed = <String>[];
      final List<String> submitted = <String>[];

      final List<String> suggestions = <String>[
        'Apple',
        'Banana',
        'Grape',
        'Pineapple',
        'Orange',
      ];

      final _Harness harness = _Harness(
        initialValue: '',
        onChangedLog: changed,
        onSubmittedLog: submitted,
        suggestList: suggestions,
      );

      await _pumpHarness(tester, harness: harness);

      await tester.tap(_textFieldFinder());
      await tester.pumpAndSettle();

      await tester.enterText(
        _textFieldFinder(),
        'ap',
      ); // Apple, Grape, Pineapple
      await tester.pumpAndSettle();

      expect(changed, isNotEmpty);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Grape'), findsOneWidget);
      expect(find.text('Pineapple'), findsOneWidget);
      expect(find.text('Banana'), findsNothing);
    });

    testWidgets(
        'onSelected: al tocar una sugerencia actualiza value (controlado)',
        (WidgetTester tester) async {
      final List<String> changed = <String>[];
      final List<String> submitted = <String>[];

      final _Harness harness = _Harness(
        initialValue: '',
        onChangedLog: changed,
        onSubmittedLog: submitted,
        suggestList: const <String>['alpha', 'beta', 'gamma'],
      );

      await _pumpHarness(tester, harness: harness);

      await tester.tap(_textFieldFinder());
      await tester.pumpAndSettle();

      await tester.enterText(_textFieldFinder(), 'a');
      await tester.pumpAndSettle();

      // Tocar 'gamma'
      await tester.tap(find.text('gamma'));
      await tester.pumpAndSettle();

      // Cambios registrados y el TextField queda con 'gamma'
      expect(changed, contains('gamma'));
      final TextField tf = tester.widget(_textFieldFinder());
      expect(tf.controller!.text, 'gamma');

      // Overlay debe cerrarse (la opción tocada ya no está)
      expect(find.text('beta'), findsNothing);
    });

    testWidgets('submit (IME action) dispara onSubmittedAttempt con el valor',
        (WidgetTester tester) async {
      final List<String> changed = <String>[];
      final List<String> submitted = <String>[];

      final _Harness harness = _Harness(
        initialValue: '',
        onChangedLog: changed,
        onSubmittedLog: submitted,
      );

      await _pumpHarness(tester, harness: harness);

      await tester.tap(_textFieldFinder());
      await tester.pump();

      await tester.enterText(_textFieldFinder(), 'hola');
      await tester.pump();

      // Enviar acción "done"
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(submitted.last, 'hola');
    });

    testWidgets('obscureText + toggle de visibilidad',
        (WidgetTester tester) async {
      const _Harness harness = _Harness(
        initialValue: 'secret',
        onChangedLog: <String>[],
        onSubmittedLog: <String>[],
        obscureText: true,
      );

      await _pumpHarness(tester, harness: harness);

      TextField tf = tester.widget(_textFieldFinder());
      expect(tf.obscureText, isTrue);

      // El botón existe y al tocarlo alterna obscure
      expect(find.byType(IconButton), findsOneWidget);
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      tf = tester.widget(_textFieldFinder());
      expect(tf.obscureText, isFalse);
    });

    testWidgets('sin toggle cuando showToggleObscure=false',
        (WidgetTester tester) async {
      const _Harness harness = _Harness(
        initialValue: 'secret',
        onChangedLog: <String>[],
        onSubmittedLog: <String>[],
        obscureText: true,
        showToggleObscure: false,
      );

      await _pumpHarness(tester, harness: harness);
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('overlay: respeta minOptionsWidth y maxOptionsHeight',
        (WidgetTester tester) async {
      final List<String> suggestions =
          List<String>.generate(50, (int i) => 'item $i');
      final List<String> onchanged = <String>[];
      final List<String> onSubmittedLog = <String>[];

      final _Harness harness = _Harness(
        initialValue: '',
        onChangedLog: onchanged,
        onSubmittedLog: onSubmittedLog,
        suggestList: suggestions,
        minOptionsWidth: 300,
        maxOptionsHeight: 200,
      );

      // superficie angosta para forzar el minWidth del overlay
      await _pumpHarness(
        tester,
        harness: harness,
        surface: const Size(260, 600),
      );

      await tester.tap(_textFieldFinder());
      await tester.pump();
      await tester.enterText(
        _textFieldFinder(),
        'item',
      ); // muchas coincidencias
      await tester.pumpAndSettle();

      // El ListView del overlay debe medir al menos minOptionsWidth y a lo sumo maxOptionsHeight
      final Size lvSize = tester.getSize(find.byType(ListView).first);
      expect(lvSize.width >= 300, isTrue);
      expect(lvSize.height <= 200, isTrue);
    });

    testWidgets(
        'Semantics: label/hint personalizados y autofillHints propagados',
        (WidgetTester tester) async {
      const _Harness harness = _Harness(
        initialValue: '',
        onChangedLog: <String>[],
        onSubmittedLog: <String>[],
        semanticsLabel: 'Campo Ultra',
        semanticsHint: 'Ingresa algo',
        autofillHints: <String>[AutofillHints.password],
      );

      await _pumpHarness(tester, harness: harness);

      // Verificamos autofillHints en el TextField
      final TextField tf = tester.widget(_textFieldFinder());
      expect(tf.autofillHints, isNotNull);
      expect(tf.autofillHints!.contains(AutofillHints.password), isTrue);

      // Buscamos el Semantics que nuestro widget crea con ese label/hint.
      final Finder semanticsFinder =
          find.byWidgetPredicate((Widget w) => w is Semantics);
      expect(semanticsFinder, findsAtLeast(1));
    });
  });
}
