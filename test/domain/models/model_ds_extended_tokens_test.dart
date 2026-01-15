import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ModelDsExtendedTokensKeys', () {
    test(
        'Given keys registry When all is used Then it contains every expected key and no duplicates',
        () {
      // Arrange
      const List<String> keys = ModelDsExtendedTokensKeys.all;

      // Assert: no duplicates
      expect(keys.toSet().length, keys.length);

      // Assert: contains representative keys (smoke)
      expect(keys, contains(ModelDsExtendedTokensKeys.spacingXs));
      expect(keys, contains(ModelDsExtendedTokensKeys.borderRadiusXXl));
      expect(keys, contains(ModelDsExtendedTokensKeys.elevation));
      expect(keys, contains(ModelDsExtendedTokensKeys.withAlphaXl));
      expect(keys, contains(ModelDsExtendedTokensKeys.animationDurationLong));
    });
  });

  group('ModelDsExtendedTokens - defaults', () {
    test(
        'Given default ctor When instance created Then it is valid and has expected defaults',
        () {
      // Arrange
      const ModelDsExtendedTokens tokens = ModelDsExtendedTokens();

      // Assert (spot-check a few values)
      expect(tokens.spacingXs, 4.0);
      expect(tokens.spacing, 16.0);
      expect(tokens.borderRadius, 8.0);
      expect(tokens.elevation, 3.0);
      expect(tokens.withAlphaXs, 0.04);
      expect(tokens.animationDurationShort, const Duration(milliseconds: 100));
      expect(tokens.animationDuration, const Duration(milliseconds: 300));
      expect(tokens.animationDurationLong, const Duration(milliseconds: 800));
    });

    test(
        'Given default ctor When comparing equality Then identical values are equal and hashCodes match',
        () {
      // Arrange
      const ModelDsExtendedTokens a = ModelDsExtendedTokens();
      const ModelDsExtendedTokens b = ModelDsExtendedTokens();

      // Assert
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('ModelDsExtendedTokens.copyWith', () {
    test(
        'Given no params When copyWith called Then returns same instance (optimization)',
        () {
      // Arrange
      const ModelDsExtendedTokens tokens = ModelDsExtendedTokens();

      // Act
      final ModelDsExtendedTokens out = tokens.copyWith();

      // Assert
      expect(identical(tokens, out), isTrue);
    });

    test(
        'Given a param override When copyWith called Then returns new instance with that value',
        () {
      // Arrange
      const ModelDsExtendedTokens tokens = ModelDsExtendedTokens();

      // Act
      final ModelDsExtendedTokens out = tokens.copyWith(spacing: 20.0);

      // Assert
      expect(identical(tokens, out), isFalse);
      expect(out.spacing, 20.0);
      // unchanged sample
      expect(out.spacingXs, tokens.spacingXs);
    });

    test('Given invalid override When copyWith called Then throws RangeError',
        () {
      // Arrange
      const ModelDsExtendedTokens tokens = ModelDsExtendedTokens();

      // Act + Assert: break ascending rule
      expect(
        () => tokens.copyWith(spacingSm: 1.0), // spacingXs default is 4.0
        throwsA(isA<RangeError>()),
      );
    });
  });

  group('ModelDsExtendedTokens.toJson/fromJson', () {
    test(
        'Given a valid instance When toJson then fromJson Then round-trip equals',
        () {
      // Arrange
      final ModelDsExtendedTokens tokens = ModelDsExtendedTokens.fromFactor();

      // Act
      final Map<String, dynamic> json = tokens.toJson();
      final ModelDsExtendedTokens restored =
          ModelDsExtendedTokens.fromJson(json);

      // Assert
      expect(restored, equals(tokens));
      expect(restored.hashCode, equals(tokens.hashCode));
    });

    test(
        'Given json missing a required key When fromJson Then throws FormatException',
        () {
      // Arrange
      final Map<String, dynamic> json = const ModelDsExtendedTokens().toJson();
      json.remove(ModelDsExtendedTokensKeys.spacingXs);

      // Act + Assert
      expect(
        () => ModelDsExtendedTokens.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('Given json with invalid alpha When fromJson Then throws RangeError',
        () {
      // Arrange
      final Map<String, dynamic> json = const ModelDsExtendedTokens().toJson();
      json[ModelDsExtendedTokensKeys.withAlpha] = 2.0; // out of 0..1

      // Act + Assert
      expect(
        () => ModelDsExtendedTokens.fromJson(json),
        throwsA(isA<RangeError>()),
      );
    });

    test(
        'Given json with negative duration When fromJson Then throws RangeError',
        () {
      // Arrange
      final Map<String, dynamic> json = const ModelDsExtendedTokens().toJson();
      json[ModelDsExtendedTokensKeys.animationDuration] = -1;

      // Act + Assert
      expect(
        () => ModelDsExtendedTokens.fromJson(json),
        throwsA(isA<RangeError>()),
      );
    });
  });

  group('ModelDsExtendedTokens.fromFactor - behavior', () {
    test(
        'Given known factors When fromFactor Then generates expected geometric values',
        () {
      // Arrange + Act
      final ModelDsExtendedTokens t = ModelDsExtendedTokens.fromFactor();

      // Assert spacing (4, 8, 16, 32, 64, 128)
      expect(t.spacingXs, 4.0);
      expect(t.spacingSm, 8.0);
      expect(t.spacing, 16.0);
      expect(t.spacingLg, 32.0);
      expect(t.spacingXl, 64.0);
      expect(t.spacingXXl, 128.0);

      // Assert radius (2, 4, 8, 16, 32, 64)
      expect(t.borderRadiusXs, 2.0);
      expect(t.borderRadiusSm, 4.0);
      expect(t.borderRadius, 8.0);
      expect(t.borderRadiusLg, 16.0);
      expect(t.borderRadiusXl, 32.0);
      expect(t.borderRadiusXXl, 64.0);

      // Assert elevation (1, 2, 4, 8, 16, 32) + xs is base
      expect(t.elevationXs, 1.0);
      expect(t.elevationSm, 2.0);
      expect(t.elevation, 4.0);
      expect(t.elevationLg, 8.0);
      expect(t.elevationXl, 16.0);
      expect(t.elevationXXl, 32.0);

      // Assert durations (100, 300, 900) milliseconds
      expect(t.animationDurationShort, const Duration(milliseconds: 100));
      expect(t.animationDuration, const Duration(milliseconds: 300));
      expect(t.animationDurationLong, const Duration(milliseconds: 900));
    });

    test(
        'Given alpha factor that would exceed 1 When fromFactor Then alpha values are clamped within 0..1',
        () {
      // Arrange + Act
      final ModelDsExtendedTokens t = ModelDsExtendedTokens.fromFactor(
        withAlphaFactor: 10.0,
        initialWithAlpha: 0.2, // 0.2, 2.0, 20.0... -> clamp to 1.0
      );

      // Assert
      expect(t.withAlphaXs, inInclusiveRange(0.0, 1.0));
      expect(t.withAlphaSm, inInclusiveRange(0.0, 1.0));
      expect(t.withAlpha, inInclusiveRange(0.0, 1.0));
      expect(t.withAlphaLg, inInclusiveRange(0.0, 1.0));
      expect(t.withAlphaXl, inInclusiveRange(0.0, 1.0));
      expect(t.withAlphaXXl, inInclusiveRange(0.0, 1.0));

      // And should be ascending
      expect(t.withAlphaXs <= t.withAlphaSm, isTrue);
      expect(t.withAlphaSm <= t.withAlpha, isTrue);
      expect(t.withAlpha <= t.withAlphaLg, isTrue);
      expect(t.withAlphaLg <= t.withAlphaXl, isTrue);
      expect(t.withAlphaXl <= t.withAlphaXXl, isTrue);
    });

    test(
        'Given factor that breaks ascending When fromFactor Then throws RangeError',
        () {
      // Arrange: spacingFactor < 1 makes spacingSm < spacingXs (unless initialSpacing is 0)
      expect(
        () => ModelDsExtendedTokens.fromFactor(
          spacingFactor: 0.5,
        ),
        throwsA(isA<RangeError>()),
      );
    });

    test('Given NaN initial values When fromFactor Then throws RangeError', () {
      expect(
        () => ModelDsExtendedTokens.fromFactor(initialSpacing: double.nan),
        throwsA(isA<RangeError>()),
      );
    });
  });

  group('ModelDsExtendedTokens - equality negative cases', () {
    test(
        'Given one different field When comparing Then not equal and hashCode may differ',
        () {
      // Arrange
      const ModelDsExtendedTokens a = ModelDsExtendedTokens();
      const ModelDsExtendedTokens b = ModelDsExtendedTokens(spacing: 17.0);

      // Assert
      expect(a == b, isFalse);
    });
  });
}
