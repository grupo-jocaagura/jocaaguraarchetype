import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ModelSemanticColorsKeys', () {
    test(
        'Given keys registry When all is used Then it contains expected keys and has no duplicates',
        () {
      const List<String> keys = ModelSemanticColorsKeys.all;

      expect(keys.toSet().length, keys.length);

      // Smoke-check a few required keys
      expect(keys, contains(ModelSemanticColorsKeys.success));
      expect(keys, contains(ModelSemanticColorsKeys.onSuccess));
      expect(keys, contains(ModelSemanticColorsKeys.warningContainer));
      expect(keys, contains(ModelSemanticColorsKeys.onInfoContainer));

      // explain is informational, not part of JSON contract
      expect(keys, isNot(contains(ModelSemanticColorsKeys.explain)));
    });
  });

  group('ModelSemanticColors fallback palettes', () {
    test(
        'Given fallbackLight When built Then it is valid and contains expected base colors',
        () {
      final ModelSemanticColors c = ModelSemanticColors.fallbackLight();

      // Spot-check exact constants (these are part of your factory contract)
      expect(c.success, const Color(0xFF2E7D32));
      expect(c.warning, const Color(0xFFED6C02));
      expect(c.info, const Color(0xFF0288D1));
      expect(c.onSuccess, Colors.white);
      expect(c.onWarning, Colors.white);
      expect(c.onInfo, Colors.white);
    });

    test(
        'Given fallbackDark When built Then it is valid and contains expected base colors',
        () {
      final ModelSemanticColors c = ModelSemanticColors.fallbackDark();

      expect(c.success, const Color(0xFF66BB6A));
      expect(c.warning, const Color(0xFFFFB74D));
      expect(c.info, const Color(0xFF4FC3F7));
    });
  });

  group('ModelSemanticColors.fromColorScheme', () {
    test(
        'Given light ColorScheme When derived Then uses light base tones and produces valid containers',
        () {
      final ColorScheme cs = ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
      );

      final ModelSemanticColors c = ModelSemanticColors.fromColorScheme(cs);

      // Base hues for light brightness (per implementation)
      expect(c.success, const Color(0xFF2E7D32));
      expect(c.warning, const Color(0xFFED6C02));
      expect(c.info, const Color(0xFF0288D1));

      // Containers should be deterministic and non-null; also likely different from base
      expect(c.successContainer, isNot(equals(c.success)));
      expect(c.warningContainer, isNot(equals(c.warning)));
      expect(c.infoContainer, isNot(equals(c.info)));
    });

    test('Given dark ColorScheme When derived Then uses dark base tones', () {
      final ColorScheme cs = ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.dark,
      );

      final ModelSemanticColors c = ModelSemanticColors.fromColorScheme(cs);

      expect(c.success, const Color(0xFF66BB6A));
      expect(c.warning, const Color(0xFFFFB74D));
      expect(c.info, const Color(0xFF4FC3F7));
    });
  });

  group('ModelSemanticColors JSON', () {
    test('Given instance When toJson then fromJson Then round-trip equals', () {
      final ModelSemanticColors original = ModelSemanticColors.fallbackLight();

      final Map<String, dynamic> json = original.toJson();
      final ModelSemanticColors restored = ModelSemanticColors.fromJson(json);

      expect(restored, equals(original));
      expect(restored.hashCode, equals(original.hashCode));
    });

    test(
        'Given json missing a required key When fromJson Then throws FormatException',
        () {
      final Map<String, dynamic> json =
          ModelSemanticColors.fallbackLight().toJson();
      json.remove(ModelSemanticColorsKeys.success);

      expect(
        () => ModelSemanticColors.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ModelSemanticColors.copyWith', () {
    test(
        'Given override that keeps contrast When copyWith Then returns new valid instance',
        () {
      final ModelSemanticColors base = ModelSemanticColors.fallbackLight();

      final ModelSemanticColors out = base.copyWith(
        success: const Color(0xFF1B5E20),
        onSuccess: Colors.white,
      );

      expect(out, isNot(equals(base)));
      expect(out.success, const Color(0xFF1B5E20));
      expect(out.onSuccess, Colors.white);
    });

    test(
        'Given override that breaks contrast When copyWith Then throws RangeError',
        () {
      final ModelSemanticColors base = ModelSemanticColors.fallbackLight();

      // Make foreground equal to background to guarantee contrast ratio == 1.0
      expect(
        () => base.copyWith(
          success: const Color(0xFF2E7D32),
          onSuccess: const Color(0xFF2E7D32),
        ),
        throwsA(isA<RangeError>()),
      );
    });
  });

  group('ModelSemanticColors equality', () {
    test('Given two equal instances When compared Then equals is true', () {
      final ModelSemanticColors a = ModelSemanticColors.fallbackLight();
      final ModelSemanticColors b = ModelSemanticColors.fromJson(a.toJson());

      expect(a, equals(b));
    });

    test('Given one differing field When compared Then equals is false', () {
      final ModelSemanticColors a = ModelSemanticColors.fallbackLight();
      final ModelSemanticColors b = a.copyWith(info: const Color(0xFF000000));

      // Might throw if contrast fails; ensure it's valid by keeping onInfo consistent:
      // If this throws in your environment due to contrast, replace info with a brighter tone.
      expect(a == b, isFalse);
    });
  });
}
