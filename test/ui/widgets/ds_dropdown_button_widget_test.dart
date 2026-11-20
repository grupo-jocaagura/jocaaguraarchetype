import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

const List<DropdownMenuItem<String>> _items = <DropdownMenuItem<String>>[
  DropdownMenuItem<String>(value: 'open', child: Text('Abierto')),
  DropdownMenuItem<String>(value: 'closed', child: Text('Cerrado')),
  DropdownMenuItem<String>(
    value: 'archived',
    enabled: false,
    child: Text('Archivado'),
  ),
];

void main() {
  testWidgets('selection is controlled and a removed value shows the prompt', (
    WidgetTester tester,
  ) async {
    final List<String> changes = <String>[];
    Future<void> render(String? value) => tester.pumpWidget(
      _host(
        _selector(
          value: value,
          state: value == null ? null : const ModelInteractiveState(),
          onChanged: changes.add,
        ),
      ),
    );
    final Finder button = find.byType(DropdownButton<String>);
    await render(null);
    expect(find.text('Seleccionar estado'), findsOneWidget);
    await _open(tester);
    final SemanticsData archived = tester
        .getSemantics(find.bySemanticsLabel('Archivado'))
        .getSemanticsData();
    expect(archived.flagsCollection.isEnabled, Tristate.isFalse);
    expect(archived.hasAction(SemanticsAction.tap), isFalse);
    await tester.tap(_menuText('Archivado'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(_menuText('Abierto'), findsOneWidget);
    await tester.tap(_menuText('Cerrado'));
    await tester.pumpAndSettle();
    expect(changes, <String>['closed']);
    expect(tester.widget<DropdownButton<String>>(button).value, isNull);

    await render('closed');
    expect(tester.widget<DropdownButton<String>>(button).value, 'closed');
    await _open(tester);
    await tester.tap(_menuText('Cerrado'));
    await tester.pumpAndSettle();
    expect(changes, <String>['closed']);
    await render('removed');
    expect(tester.widget<DropdownButton<String>>(button).value, isNull);
    expect(find.text('Seleccionar estado'), findsOneWidget);
    expect(changes, <String>['closed']);
  });

  testWidgets(
    'rejects duplicate or null options and a selection without state',
    (WidgetTester tester) async {
      for (final Widget selector in <Widget>[
        _selector(
          items: <DropdownMenuItem<String>>[_items.first, _items.first],
        ),
        _selector(
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(child: Text('Sin valor')),
          ],
        ),
        _selector(value: 'open'),
        _selector(label: null),
      ]) {
        await tester.pumpWidget(_host(selector));
        expect(tester.takeException(), isArgumentError);
      }
    },
  );

  testWidgets('an open menu cannot dispatch a removed or disabled option', (
    WidgetTester tester,
  ) async {
    final List<String> changes = <String>[];
    int taps = 0;
    Future<void> render(List<DropdownMenuItem<String>> items) => tester
        .pumpWidget(_host(_selector(items: items, onChanged: changes.add)));

    for (final List<DropdownMenuItem<String>> updated
        in <List<DropdownMenuItem<String>>>[
          <DropdownMenuItem<String>>[_items.first],
          <DropdownMenuItem<String>>[
            _items.first,
            DropdownMenuItem<String>(
              value: 'closed',
              enabled: false,
              onTap: () => taps++,
              child: const Text('Cerrado'),
            ),
          ],
        ]) {
      await render(<DropdownMenuItem<String>>[
        _items.first,
        DropdownMenuItem<String>(
          value: 'closed',
          onTap: () => taps++,
          child: const Text('Cerrado'),
        ),
      ]);
      await _open(tester);
      await render(updated);
      await tester.tap(_menuText('Cerrado'));
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(taps, 0);
    }

    await render(<DropdownMenuItem<String>>[
      _items.first,
      DropdownMenuItem<String>(
        value: 'closed',
        onTap: () => taps++,
        child: const Text('Cerrado'),
      ),
    ]);
    await _open(tester);
    await tester.tap(_menuText('Cerrado'));
    await tester.pumpAndSettle();
    expect(changes, <String>['closed']);
    expect(taps, 1);
  });

  testWidgets('enabled and model state gate opening and pending selection', (
    WidgetTester tester,
  ) async {
    final List<String> changes = <String>[];
    Future<void> render({
      bool enabled = true,
      ModelInteractiveState state = const ModelInteractiveState(),
    }) => tester.pumpWidget(
      _host(
        _selector(
          value: 'open',
          enabled: enabled,
          state: state,
          onChanged: changes.add,
        ),
      ),
    );

    final Finder button = find.byType(DropdownButton<String>);
    for (final (bool enabled, ModelInteractiveState state)
        in const <(bool, ModelInteractiveState)>[
          (false, ModelInteractiveState()),
          (true, ModelInteractiveState(isLoading: true)),
          (true, ModelInteractiveState(isEnabled: false)),
        ]) {
      await render();
      await _open(tester);
      await render(enabled: enabled, state: state);
      await tester.tap(_menuText('Cerrado'));
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(tester.widget<DropdownButton<String>>(button).value, 'open');
      expect(tester.widget<DropdownButton<String>>(button).onChanged, isNull);
      expect(find.text('Abierto'), findsOneWidget);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(_menuText('Cerrado'), findsNothing);
    }

    await render();
    await _open(tester);
    await render(state: const ModelInteractiveState(isVisible: false));
    await tester.pumpAndSettle();
    expect(button, findsNothing);
    expect(_menuText('Cerrado'), findsNothing);

    await tester.pumpWidget(
      _host(_selector(items: const <DropdownMenuItem<String>>[])),
    );
    expect(tester.widget<DropdownButton<String>>(button).onChanged, isNull);
    expect(find.text('Seleccionar estado'), findsOneWidget);
  });

  testWidgets('the empty selection announces the field and prompt together', (
    WidgetTester tester,
  ) async {
    const String announcement = 'Estado\nSeleccionar estado';
    for (final bool hasOptions in <bool>[true, false]) {
      await tester.pumpWidget(
        _host(
          _selector(
            items: hasOptions ? _items : const <DropdownMenuItem<String>>[],
          ),
        ),
      );
      expect(find.bySemanticsLabel('Estado'), findsNothing);
      expect(find.bySemanticsLabel('Seleccionar estado'), findsNothing);
      final Finder field = find.bySemanticsLabel(announcement);
      expect(field, findsOneWidget);
      final SemanticsNode node = tester.getSemantics(field);
      expect(node.childrenCount, 0);
      final SemanticsData data = node.getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(
        data.flagsCollection.isEnabled,
        hasOptions ? Tristate.isTrue : Tristate.isFalse,
      );
      expect(data.hasAction(SemanticsAction.tap), hasOptions);
      if (hasOptions) {
        tester.semantics.tap(find.semantics.byLabel(announcement));
        await tester.pumpAndSettle();
        expect(_menuText('Abierto'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
      }
    }
  });

  testWidgets('accessible name and selection survive keyboard navigation', (
    WidgetTester tester,
  ) async {
    final List<String> changes = <String>[];
    await tester.pumpWidget(
      _host(
        InputDecorator(
          decoration: const InputDecoration(
            label: ExcludeSemantics(child: Text('Estado del pedido')),
            border: OutlineInputBorder(),
          ),
          child: _selector(
            label: null,
            semanticLabel: 'Estado del pedido',
            value: 'open',
            state: const ModelInteractiveState(),
            onChanged: changes.add,
          ),
        ),
        width: 260,
      ),
    );
    final Finder trigger = find.bySemanticsLabel(
      RegExp(r'Estado del pedido\s+Abierto'),
    );
    expect(trigger, findsOneWidget);
    final SemanticsData data = tester.getSemantics(trigger).getSemanticsData();
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final FocusNode triggerFocus = FocusManager.instance.primaryFocus!;
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_menuText('Cerrado'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_menuText('Cerrado'), findsNothing);
    expect(triggerFocus.hasPrimaryFocus, isTrue);
    expect(changes, isEmpty);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(changes, <String>['closed']);
    expect(triggerFocus.hasPrimaryFocus, isTrue);
    tester.semantics.tap(
      find.semantics.byLabel(RegExp(r'Estado del pedido\s+Abierto')),
    );
    await tester.pumpAndSettle();
    expect(_menuText('Cerrado'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  });

  testWidgets('trigger and menu wrap enlarged text with usable touch targets', (
    WidgetTester tester,
  ) async {
    const String longOption = 'Último trimestre del año';
    final ThemeData theme = ThemeData(
      textTheme: const TextTheme(labelLarge: TextStyle(fontSize: 17)),
    );
    final Finder button = find.byType(DropdownButton<String>);
    for (final bool expanded in <bool>[false, true]) {
      await tester.pumpWidget(
        _host(
          _selector(
            isExpanded: expanded,
            value: 'quarter',
            state: const ModelInteractiveState(),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: 'quarter',
                child: Text(longOption),
              ),
            ],
          ),
          theme: theme,
          width: 148,
          scaler: const TextScaler.linear(2),
        ),
      );
      final Size targetSize = tester.getSize(button);
      expect(targetSize.width, inInclusiveRange(48, 148));
      expect(targetSize.height, greaterThan(48));
      final DsTextParagraphWidget label = tester.widget<DsTextParagraphWidget>(
        find.byType(DsTextParagraphWidget),
      );
      expect(label.role, DsTextStyleKey.labelLarge);
      _expectWrapped(tester, find.text(longOption), longOption);

      await _open(tester);
      final Finder menuText = _menuText(longOption);
      final Finder option = find.ancestor(
        of: menuText,
        matching: find.byType(DropdownMenuItem<String>),
      );
      expect(tester.getSize(option).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(option).height, greaterThanOrEqualTo(48));
      _expectWrapped(tester, menuText, longOption);
      expect(tester.takeException(), isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    }
  });

  testWidgets('a short natural trigger keeps a 48 × 48 minimum', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const DsDropdownButtonWidget<String>(
          value: null,
          items: <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(value: 'x', child: Text('X')),
          ],
          onChanged: _ignore,
          placeholder: 'X',
          semanticLabel: 'Filter',
        ),
        width: 240,
      ),
    );
    final Size size = tester.getSize(find.byType(DropdownButton<String>));
    expect(size.width, inInclusiveRange(48, 239));
    expect(size.height, greaterThanOrEqualTo(48));
    await _open(tester);
    final Finder optionTarget = find.ancestor(
      of: _menuText('X'),
      matching: find.byType(InkWell),
    );
    final Size optionSize = tester.getSize(optionTarget);
    expect(optionSize.width, greaterThanOrEqualTo(48));
    expect(optionSize.height, greaterThanOrEqualTo(48));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  });
}

Widget _selector({
  String? value,
  List<DropdownMenuItem<String>> items = _items,
  ValueChanged<String> onChanged = _ignore,
  ModelInteractiveState? state,
  bool enabled = true,
  bool isExpanded = false,
  String? label = 'Estado',
  String? semanticLabel,
}) => DsDropdownButtonWidget<String>(
  value: value,
  items: items,
  onChanged: onChanged,
  placeholder: 'Seleccionar estado',
  state: state,
  enabled: enabled,
  isExpanded: isExpanded,
  label: label,
  semanticLabel: semanticLabel,
);

Widget _host(
  Widget child, {
  double? width,
  ThemeData? theme,
  TextScaler? scaler,
}) => MaterialApp(
  theme: theme,
  home: Scaffold(
    body: Center(
      child: Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scaler),
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byType(DropdownButton<String>));
  await tester.pumpAndSettle();
}

Finder _menuText(String label) =>
    find.descendant(of: find.byType(Scrollable), matching: find.text(label));

void _expectWrapped(WidgetTester tester, Finder text, String label) {
  final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(text);
  final List<TextBox> boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: 0, extentOffset: label.length),
  );
  expect(paragraph.textScaler.scale(10), 20);
  expect(boxes.map((TextBox box) => box.top).toSet().length, greaterThan(1));
  expect(boxes.last.bottom, lessThanOrEqualTo(paragraph.size.height));
}

void _ignore(String value) {}
