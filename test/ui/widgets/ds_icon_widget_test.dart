import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget host(Widget child, {IconThemeData? inherited, ThemeData? theme}) =>
      Theme(
        data: theme ?? ThemeData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: inherited == null
              ? child
              : IconTheme(data: inherited, child: child),
        ),
      );

  testWidgets('explicit appearance overrides inherited values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        const DsIconWidget(icon: Icons.info, size: 31, color: Colors.red),
        inherited: const IconThemeData(size: 45, color: Colors.blue),
      ),
    );
    final Icon icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, 31);
    expect(icon.color, Colors.red);
  });

  testWidgets('inherits raw fields and falls back independently to DS', (
    WidgetTester tester,
  ) async {
    final ThemeData theme = ThemeData(
      extensions: const <ThemeExtension<dynamic>>[
        DsExtendedTokensExtension(tokens: ModelDsExtendedTokens(spacing: 29)),
      ],
    );
    await tester.pumpWidget(
      host(
        const DsIconWidget(icon: Icons.info),
        inherited: const IconThemeData(color: Colors.blue),
        theme: theme,
      ),
    );
    Icon icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, 29);
    expect(icon.color, Colors.blue);
    await tester.pumpWidget(
      host(
        const DsIconWidget(icon: Icons.info),
        inherited: const IconThemeData(size: 45),
        theme: theme,
      ),
    );
    icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, 45);
    expect(icon.color, theme.colorScheme.onSurface);
  });

  testWidgets('works without a DS extension or app manager', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host(const DsIconWidget(icon: Icons.info)));
    expect(
      tester.widget<Icon>(find.byType(Icon)).size,
      const ModelDsExtendedTokens().spacing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reacts to inherited appearance updates', (
    WidgetTester tester,
  ) async {
    const Widget icon = DsIconWidget(icon: Icons.info);
    await tester.pumpWidget(
      host(icon, inherited: const IconThemeData(size: 20)),
    );
    await tester.pumpWidget(
      host(icon, inherited: const IconThemeData(size: 40)),
    );
    expect(tester.widget<Icon>(find.byType(Icon)).size, 40);
  });

  testWidgets('rejects nonpositive and nonfinite explicit sizes', (
    WidgetTester tester,
  ) async {
    for (final double size in <double>[0, -1, double.nan, double.infinity]) {
      await tester.pumpWidget(host(DsIconWidget(icon: Icons.info, size: size)));
      expect(tester.takeException(), isArgumentError);
    }
  });

  testWidgets(
    'informational label is trimmed and exposed once without actions',
    (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          const DsIconWidget(
            icon: Icons.info,
            semanticLabel: '  Information  ',
          ),
        ),
      );
      expect(find.bySemanticsLabel('Information'), findsOneWidget);
      final SemanticsNode node = tester.getSemantics(
        find.bySemanticsLabel('Information'),
      );
      expect(node.flagsCollection.isImage, isTrue);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      expect(node.childrenCount, 0);
      semantics.dispose();
    },
  );

  testWidgets('absent and blank labels are decorative', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    for (final String? label in <String?>[null, '', '   ']) {
      await tester.pumpWidget(
        host(DsIconWidget(icon: Icons.info, semanticLabel: label)),
      );
      bool checkDecorative(SemanticsNode node) {
        expect(node.flagsCollection.isImage, isFalse);
        expect(node.label, isEmpty);
        node.visitChildren(checkDecorative);
        return true;
      }

      checkDecorative(
        tester
            .binding
            .renderViews
            .first
            .owner!
            .semanticsOwner!
            .rootSemanticsNode!,
      );
    }
    semantics.dispose();
  });
}
