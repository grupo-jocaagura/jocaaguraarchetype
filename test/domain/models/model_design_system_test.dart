import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ModelDesignSystem.copyWith', () {
    test('Given no params When copyWith Then returns same instance', () {
      final ModelDesignSystem ds = ModelDesignSystem(
        theme: ModelDesignSystem.fromThemeData(
          lightTheme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
        ),
        tokens: const ModelDsExtendedTokens(),
        dataViz: ModelDataVizPalette.fallback(),
        semanticLight: ModelSemanticColors.fallbackLight(),
        semanticDark: ModelSemanticColors.fallbackDark(),
      );

      final ModelDesignSystem out = ds.copyWith();

      expect(identical(ds, out), isTrue);
    });
  });

  group('ModelDesignSystem JSON', () {
    test('Given invalid theme shape When fromJson Then throws FormatException',
        () {
      expect(
        () => ModelDesignSystem.fromJson(const <String, dynamic>{
          ModelDesignSystemKeys.theme: 'nope',
          ModelDesignSystemKeys.tokens: <String, dynamic>{},
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ModelDesignSystem.toThemeData', () {
    test(
        'Given valid ds When toThemeData Then attaches DsExtendedTokensExtension',
        () {
      final ModelDesignSystem ds = ModelDesignSystem(
        theme: ModelDesignSystem.fromThemeData(
          lightTheme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
        ),
        tokens: const ModelDsExtendedTokens(),
        dataViz: ModelDataVizPalette.fallback(),
        semanticLight: ModelSemanticColors.fallbackLight(),
        semanticDark: ModelSemanticColors.fallbackDark(),
      );

      final ThemeData t = ds.toThemeData(brightness: Brightness.light);

      final Iterable<ThemeExtension<dynamic>> exts = t.extensions.values;
      expect(
        exts.any(
          (ThemeExtension<dynamic> e) =>
              e.runtimeType == DsExtendedTokensExtension,
        ),
        isTrue,
      );
    });
  });
}
