import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  const LanguageResolutionPolicy policy = LanguageResolutionPolicy();

  const ModelLanguage spanish = ModelLanguage(
    languageCode: 'es',
  );

  const ModelLanguage spanishMexico = ModelLanguage.spanishMexico;

  const ModelLanguage chineseHansTaiwan = ModelLanguage(
    languageCode: 'zh',
    scriptCode: 'Hans',
    regionCode: 'TW',
  );

  group('LanguageResolutionPolicy.resolve', () {
    test('returns exact supported language match', () {
      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
        ],
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.englishUnitedStates,
          ModelLanguage.spanishColombia,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(result, ModelLanguage.spanishColombia);
    });

    test('preserves preferred languages order', () {
      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[
          ModelLanguage.portugueseBrazil,
          ModelLanguage.spanishColombia,
        ],
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.portugueseBrazil,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(result, ModelLanguage.portugueseBrazil);
    });

    test('matches same language and script before region', () {
      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[
          chineseHansTaiwan,
        ],
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.chineseTaiwan,
          ModelLanguage.chineseChina,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(result, ModelLanguage.chineseChina);
    });

    test('matches same language and compatible region', () {
      const ModelLanguage preferred = ModelLanguage.spanishColombia;

      const ModelLanguage candidate = ModelLanguage(
        languageCode: 'es',
        scriptCode: 'Latn',
        regionCode: 'CO',
      );

      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[
          preferred,
        ],
        supportedLanguages: const <ModelLanguage>[
          candidate,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(result, candidate);
    });

    test('prefers generic language over regional variant', () {
      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[
          spanishMexico,
        ],
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          spanish,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(result, spanish);
    });

    test('matches compatible language variant when generic is unavailable', () {
      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[
          spanishMexico,
        ],
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.englishUnitedStates,
          ModelLanguage.spanishColombia,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(result, ModelLanguage.spanishColombia);
    });

    test('does not match explicitly incompatible scripts', () {
      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[
          chineseHansTaiwan,
        ],
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.chineseTaiwan,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(result, ModelLanguage.englishUnitedStates);
    });

    test('accepts candidate without script as compatible', () {
      const ModelLanguage preferred = ModelLanguage(
        languageCode: 'zh',
        scriptCode: 'Hans',
        regionCode: 'TW',
      );

      const ModelLanguage candidate = ModelLanguage(
        languageCode: 'zh',
        regionCode: 'CN',
      );

      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[
          preferred,
        ],
        supportedLanguages: const <ModelLanguage>[
          candidate,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(result, candidate);
    });

    test('resolves fallback language when preferred language is unsupported',
        () {
      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[
          ModelLanguage.germanGermany,
        ],
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(result, ModelLanguage.englishUnitedStates);
    });

    test('resolves fallback using the same matching policy', () {
      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[
          ModelLanguage(
            languageCode: 'de',
          ),
        ],
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedKingdom,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(
        result,
        ModelLanguage.englishUnitedKingdom,
      );
    });

    test('returns first supported language when fallback cannot be resolved',
        () {
      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[
          ModelLanguage(
            languageCode: 'de',
          ),
        ],
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.portugueseBrazil,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(result, ModelLanguage.spanishColombia);
    });

    test('uses fallback when preferred languages are empty', () {
      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[],
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(result, ModelLanguage.englishUnitedStates);
    });

    test('returns fallback when supported languages are empty', () {
      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
        ],
        supportedLanguages: const <ModelLanguage>[],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(result, ModelLanguage.englishUnitedStates);
    });

    test('uses supported order to break ties at the same match level', () {
      const ModelLanguage spanishArgentina = ModelLanguage.spanishArgentina;

      final ModelLanguage result = policy.resolve(
        preferredLanguages: const <ModelLanguage>[
          spanishMexico,
        ],
        supportedLanguages: const <ModelLanguage>[
          spanishArgentina,
          ModelLanguage.spanishColombia,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );

      expect(result, spanishArgentina);
    });
  });
}
