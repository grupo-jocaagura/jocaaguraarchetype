import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('Guardian tests', () {
    test('Given decoration empty list When fromJson Then does not throw', () {
      final ModelThemeData model = _makeBaselineModel();
      final Map<String, dynamic> json = model.toJson();

      final Map<String, dynamic> lightText =
          json[ModelThemeDataKeys.lightTextTheme] as Map<String, dynamic>;
      final Map<String, dynamic> displayMedium =
          lightText[TextThemeKeys.displayMedium] as Map<String, dynamic>;

      displayMedium[TextStyleKeys.decoration] = <String>[];

      expect(() => ModelThemeData.fromJson(json), returnsNormally);
    });

    test('Given decoration non-list When fromJson Then throws FormatException',
        () {
      final ModelThemeData model = _makeBaselineModel();
      final Map<String, dynamic> json = model.toJson();

      final Map<String, dynamic> lightText =
          json[ModelThemeDataKeys.lightTextTheme] as Map<String, dynamic>;
      final Map<String, dynamic> displayMedium =
          lightText[TextThemeKeys.displayMedium] as Map<String, dynamic>;

      displayMedium[TextStyleKeys.decoration] = 'underline';

      expect(
        () => ModelThemeData.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test(
        'Given missing TextStyle key When fromJson Then throws FormatException',
        () {
      final ModelThemeData model = _makeBaselineModel();
      final Map<String, dynamic> json = model.toJson();

      final Map<String, dynamic> lightText =
          json[ModelThemeDataKeys.lightTextTheme] as Map<String, dynamic>;
      final Map<String, dynamic> displayMedium =
          lightText[TextThemeKeys.displayMedium] as Map<String, dynamic>;

      displayMedium.remove(TextStyleKeys.fontSize);

      expect(
        () => ModelThemeData.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });
  group('ModelThemeData (Material 3 snapshot)', () {
    test(
        'Given a valid model When toJson/fromJson Then round-trip preserves equality',
        () {
      // Arrange
      final ModelThemeData model = _makeBaselineModel();

      // Act
      final Map<String, dynamic> json = model.toJson();
      final ModelThemeData restored = ModelThemeData.fromJson(json);

      // Assert
      expect(restored.toJson(), equals(model.toJson()));
      expect(restored.useMaterial3, isTrue);
    });

    test(
        'Given a model When toThemeData(light) Then uses light scheme and textTheme',
        () {
      // Arrange
      final ModelThemeData model = _makeBaselineModel();

      // Act
      final ThemeData td = model.toThemeData(brightness: Brightness.light);

      // Assert
      expect(td.useMaterial3, isTrue);
      expect(td.colorScheme.brightness, Brightness.light);
    });

    test(
        'Given a model When toThemeData(dark) Then uses dark scheme and textTheme',
        () {
      // Arrange
      final ModelThemeData model = _makeBaselineModel();

      // Act
      final ThemeData td = model.toThemeData(brightness: Brightness.dark);

      // Assert
      expect(td.useMaterial3, isTrue);
      expect(td.colorScheme.brightness, Brightness.dark);
    });

    test(
        'Given a json missing a top-level key When fromJson Then throws FormatException',
        () {
      // Arrange
      final ModelThemeData model = _makeBaselineModel();
      final Map<String, dynamic> json = model.toJson();
      json.remove(ModelThemeDataKeys.useMaterial3);

      // Act + Assert
      expect(
        () => ModelThemeData.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test(
        'Given a json with a non-map scheme When fromJson Then throws FormatException',
        () {
      // Arrange
      final ModelThemeData model = _makeBaselineModel();
      final Map<String, dynamic> json = model.toJson();
      json[ModelThemeDataKeys.lightScheme] = 'nope';

      // Act + Assert
      expect(
        () => ModelThemeData.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test(
        'Given a json missing one TextTheme key When fromJson Then throws FormatException',
        () {
      // Arrange
      final ModelThemeData model = _makeBaselineModel();
      final Map<String, dynamic> json = model.toJson();

      final Map<String, dynamic> lightText =
          json[ModelThemeDataKeys.lightTextTheme] as Map<String, dynamic>;
      lightText.remove(TextThemeKeys.displayLarge);

      // Act + Assert
      expect(
        () => ModelThemeData.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test(
        'Given a TextStyle map missing a required key When fromJson Then throws FormatException',
        () {
      // Arrange
      final ModelThemeData model = _makeBaselineModel();
      final Map<String, dynamic> json = model.toJson();

      final Map<String, dynamic> lightText =
          json[ModelThemeDataKeys.lightTextTheme] as Map<String, dynamic>;
      final Map<String, dynamic> displayLarge =
          lightText[TextThemeKeys.displayLarge] as Map<String, dynamic>;

      // Remove a required TextStyle key (strict contract).
      displayLarge.remove(TextStyleKeys.inherit);

      // Act + Assert
      expect(
        () => ModelThemeData.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('Given TextStyle.foreground When toJson Then throws StateError', () {
      // Arrange
      final Paint paint = Paint()..color = const Color(0xFFFF0000);
      final Typography typography = Typography.material2021();
      final TextTheme tt = typography.black.copyWith(
        displayLarge: TextStyle(
          foreground: paint,
          fontSize: 20,
        ),
      );

      final ModelThemeData model = ModelThemeData(
        lightScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
        ),
        darkScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        lightTextTheme: tt,
        darkTextTheme: typography.white,
        useMaterial3: true,
      );

      // Act + Assert
      expect(() => model.toJson(), throwsA(isA<StateError>()));
    });

    test('Given TextStyle.background When toJson Then throws StateError', () {
      // Arrange
      final Paint paint = Paint()..color = const Color(0xFF00FF00);
      final Typography typography = Typography.material2021();
      final TextTheme tt = typography.black.copyWith(
        displayLarge: TextStyle(
          background: paint,
          fontSize: 20,
        ),
      );

      final ModelThemeData model = ModelThemeData(
        lightScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
        ),
        darkScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        lightTextTheme: tt,
        darkTextTheme: typography.white,
        useMaterial3: true,
      );

      // Act + Assert
      expect(() => model.toJson(), throwsA(isA<StateError>()));
    });

    test(
        'Given a rich TextStyle When round-trip Then preserves supported fields',
        () {
      // Arrange
      const TextStyle rich = TextStyle(
        color: Color(0xFF112233),
        backgroundColor: Color(0xFF445566),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.5,
        wordSpacing: 1.25,
        textBaseline: TextBaseline.alphabetic,
        height: 1.2,
        leadingDistribution: TextLeadingDistribution.proportional,
        locale: Locale('es', 'CO'),
        decoration: TextDecoration.underline,
        decorationColor: Color(0xFF778899),
        decorationStyle: TextDecorationStyle.solid,
        decorationThickness: 2.0,
        fontFamily: 'Roboto',
        fontFamilyFallback: <String>['Arial', 'sans-serif'],
        overflow: TextOverflow.ellipsis,
        shadows: <Shadow>[
          Shadow(
            color: Color(0xAA000000),
            offset: Offset(1, 2),
            blurRadius: 3,
          ),
        ],
        fontFeatures: <FontFeature>[FontFeature('smcp')],
        fontVariations: <FontVariation>[FontVariation('wght', 650)],
        debugLabel: 'rich-style',
      );
      final Typography typography = Typography.material2021();
      final TextTheme lightText = typography.black.copyWith(
        displayLarge: rich,
      );

      final ModelThemeData model = ModelThemeData(
        lightScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
        ),
        darkScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        lightTextTheme: lightText,
        darkTextTheme: typography.white,
        useMaterial3: true,
      );

      // Act
      final Map<String, dynamic> json = model.toJson();
      final ModelThemeData restored = ModelThemeData.fromJson(json);

      // Assert
      final TextStyle? restoredStyle = restored.lightTextTheme.displayLarge;
      expect(restoredStyle, isNotNull);

      expect(restoredStyle!.fontSize, 18);
      expect(restoredStyle.fontWeight, FontWeight.w600);
      expect(restoredStyle.fontStyle, FontStyle.italic);
      expect(restoredStyle.letterSpacing, 0.5);
      expect(restoredStyle.wordSpacing, 1.25);
      expect(restoredStyle.height, 1.2);

      expect(restoredStyle.locale?.toLanguageTag(), 'es-CO');
      expect(restoredStyle.overflow, TextOverflow.ellipsis);

      expect(restoredStyle.shadows, isNotNull);
      expect(restoredStyle.shadows!.length, 1);
      expect(restoredStyle.shadows!.first.blurRadius, 3);

      expect(restoredStyle.fontFeatures, isNotNull);
      expect(restoredStyle.fontFeatures!.first.feature, 'smcp');
      expect(restoredStyle.fontFeatures!.first.value, 1);

      expect(restoredStyle.fontVariations, isNotNull);
      expect(restoredStyle.fontVariations!.first.axis, 'wght');
      expect(restoredStyle.fontVariations!.first.value, 650);

      expect(restoredStyle.debugLabel, 'rich-style');

      // Bonus: strict JSON shape (keys exist)
      final Map<String, dynamic> lightTextMap =
          json[ModelThemeDataKeys.lightTextTheme] as Map<String, dynamic>;
      expect(lightTextMap.keys.toSet(), containsAll(TextThemeKeys.all));

      final Map<String, dynamic> displayLargeMap =
          lightTextMap[TextThemeKeys.displayLarge] as Map<String, dynamic>;
      expect(displayLargeMap.keys.toSet(), containsAll(TextStyleKeys.all));
    });

    test('Given scheme colors When toJson Then emits canonical hex strings',
        () {
      // Arrange
      final ModelThemeData model = _makeBaselineModel();

      // Act
      final Map<String, dynamic> json = model.toJson();
      final Map<String, dynamic> lightScheme =
          json[ModelThemeDataKeys.lightScheme] as Map<String, dynamic>;

      final Object? primary = lightScheme[ColorSchemeKeys.primary];

      // Assert
      expect(primary, isA<String>());
      final String s = primary! as String;
      expect(s.startsWith('#'), isTrue);
      expect(s.length, 9); // #AARRGGBB
      expect(s.toUpperCase(), s); // uppercase canonical
    });
  });
}

ModelThemeData _makeBaselineModel() {
  final ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
  );
  final ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6750A4),
    brightness: Brightness.dark,
  );

  // Ensure we have at least one non-null style to test strict TextStyle maps.
  final Typography typography = Typography.material2021();
  final TextTheme lightText = typography.black.copyWith(
    displayLarge: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      debugLabel: 'baseline-displayLarge',
    ),
  );

  final TextTheme darkText = typography.white.copyWith(
    displayLarge: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      debugLabel: 'baseline-displayLarge-dark',
    ),
  );

  return ModelThemeData(
    lightScheme: lightScheme,
    darkScheme: darkScheme,
    lightTextTheme: lightText,
    darkTextTheme: darkText,
    useMaterial3: true,
  );
}
