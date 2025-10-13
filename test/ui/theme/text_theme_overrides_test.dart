import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('TextThemeOverrides – roundtrip', () {
    test(
        'Given light/dark TextTheme When toJson/fromJson Then preserves styles',
        () {
      // Arrange
      const TextTheme light = TextTheme(
        bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.2),
        titleLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
      );
      const TextTheme dark = TextTheme(
        bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.2),
        titleLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
      );

      const TextThemeOverrides original =
          TextThemeOverrides(light: light, dark: dark);

      // Act
      final Map<String, dynamic> json = original.toJson();
      final TextThemeOverrides restored = TextThemeOverrides.fromJson(json)!;

      // Assert
      expect(restored, isA<TextThemeOverrides>());
      expect(restored, equals(original));
      expect(restored.hashCode == original.hashCode, isTrue);
      expect(restored.fontName, isEmpty);
      expect(restored.light!.bodyMedium!.fontFamily, 'Inter');
      expect(restored.dark!.titleLarge!.fontWeight, FontWeight.w700);
    });

    test(
        'Given partial TextTheme When roundtrip Then preserves only provided styles',
        () {
      const TextTheme onlyLight = TextTheme(
        labelSmall: TextStyle(fontFamily: 'Roboto', letterSpacing: 0.5),
      );

      const TextThemeOverrides original = TextThemeOverrides(light: onlyLight);
      final TextThemeOverrides restored =
          TextThemeOverrides.fromJson(original.toJson())!;

      expect(restored.light!.labelSmall!.letterSpacing, 0.5);
      expect(restored.dark, isNull); // se preserva el null
    });
  });

  group('Theme + TextTheme – combined config', () {
    test(
        'Given both overrides When serialized Then maps can be merged and restored',
        () {
      final ThemeOverrides theme = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        dark: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
      );
      const TextThemeOverrides text = TextThemeOverrides(
        light:
            TextTheme(bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14)),
        dark:
            TextTheme(bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14)),
      );

      final Map<String, dynamic> cfg = <String, dynamic>{
        'theme_overrides': theme.toJson(),
        'text_overrides': text.toJson(),
      };

      final ThemeOverrides theme2 = ThemeOverrides.fromJson(
        cfg['theme_overrides'] as Map<String, dynamic>,
      )!;
      final TextThemeOverrides text2 = TextThemeOverrides.fromJson(
        cfg['text_overrides'] as Map<String, dynamic>,
      )!;

      expect(theme2, equals(theme));
      expect(text2, equals(text));
    });
  });

  group('Null handling & equals edge-cases', () {
    test(
        'Given null vs empty TextTheme When comparing Then they are not equal (_textThemeEquals false)',
        () {
      const TextThemeOverrides a = TextThemeOverrides();
      const TextThemeOverrides b = TextThemeOverrides(light: TextTheme());

      expect(a == b, isFalse);
    });

    test('copyWith can clear nullable fields explicitly', () {
      const TextThemeOverrides a = TextThemeOverrides(fontName: 'Inter');
      final TextThemeOverrides b = a.copyWith(fontName: 'Roboto');
      final TextThemeOverrides c = b.copyWith(fontName: '');

      expect(a.fontName, 'Inter');
      expect(b.fontName, 'Roboto');
      expect(c.fontName, isEmpty);
    });
  });
}
