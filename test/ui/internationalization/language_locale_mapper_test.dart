import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  const LanguageLocaleMapper mapper = LanguageLocaleMapper();

  group('LanguageLocaleMapper.toLocale', () {
    test('maps language without optional subtags', () {
      const ModelLanguage language = ModelLanguage(
        languageCode: 'es',
      );

      final Locale result = mapper.toLocale(language);

      expect(result.languageCode, 'es');
      expect(result.scriptCode, isNull);
      expect(result.countryCode, isNull);
    });

    test('maps language with region', () {
      const ModelLanguage language = ModelLanguage.spanishColombia;

      final Locale result = mapper.toLocale(language);

      expect(result.languageCode, 'es');
      expect(result.scriptCode, isNull);
      expect(result.countryCode, 'CO');
    });

    test('maps language with script only', () {
      const ModelLanguage language = ModelLanguage(
        languageCode: 'zh',
        scriptCode: 'Hans',
      );

      final Locale result = mapper.toLocale(language);

      expect(result.languageCode, 'zh');
      expect(result.scriptCode, 'Hans');
      expect(result.countryCode, isNull);
    });

    test('maps language with script and region', () {
      const ModelLanguage language = ModelLanguage.chineseChina;

      final Locale result = mapper.toLocale(language);

      expect(result.languageCode, 'zh');
      expect(result.scriptCode, 'Hans');
      expect(result.countryCode, 'CN');
    });

    test('maps undetermined language', () {
      const ModelLanguage language = ModelLanguage.undetermined;

      final Locale result = mapper.toLocale(language);

      expect(result.languageCode, ModelLanguage.undeterminedCode);
      expect(result.scriptCode, isNull);
      expect(result.countryCode, isNull);
    });
  });

  group('LanguageLocaleMapper.fromLocale', () {
    test('maps locale without optional subtags', () {
      const Locale locale = Locale.fromSubtags(
        languageCode: 'es',
      );

      final ModelLanguage result = mapper.fromLocale(locale);

      expect(
        result,
        const ModelLanguage(
          languageCode: 'es',
        ),
      );
      expect(result.scriptCode, '');
      expect(result.regionCode, '');
    });

    test('maps locale with region', () {
      const Locale locale = Locale.fromSubtags(
        languageCode: 'es',
        countryCode: 'CO',
      );

      final ModelLanguage result = mapper.fromLocale(locale);

      expect(result, ModelLanguage.spanishColombia);
    });

    test('maps locale with script only', () {
      const Locale locale = Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
      );

      final ModelLanguage result = mapper.fromLocale(locale);

      expect(
        result,
        const ModelLanguage(
          languageCode: 'zh',
          scriptCode: 'Hans',
        ),
      );
      expect(result.regionCode, '');
    });

    test('maps locale with script and region', () {
      const Locale locale = Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      );

      final ModelLanguage result = mapper.fromLocale(locale);

      expect(result, ModelLanguage.chineseChina);
    });

    test('maps undetermined locale', () {
      const Locale locale = Locale.fromSubtags();

      final ModelLanguage result = mapper.fromLocale(locale);

      expect(result, ModelLanguage.undetermined);
    });
  });

  group('LanguageLocaleMapper roundtrip', () {
    test('preserves supported domain language structures', () {
      const List<ModelLanguage> languages = <ModelLanguage>[
        ModelLanguage(
          languageCode: 'es',
        ),
        ModelLanguage.spanishColombia,
        ModelLanguage(
          languageCode: 'zh',
          scriptCode: 'Hans',
        ),
        ModelLanguage.chineseChina,
        ModelLanguage.chineseTaiwan,
        ModelLanguage.englishUnitedStates,
        ModelLanguage.portugueseBrazil,
        ModelLanguage.undetermined,
      ];

      for (final ModelLanguage language in languages) {
        final Locale locale = mapper.toLocale(language);
        final ModelLanguage result = mapper.fromLocale(locale);

        expect(
          result,
          language,
          reason: 'Roundtrip failed for ${language.canonicalTag}',
        );
      }
    });
  });
}
