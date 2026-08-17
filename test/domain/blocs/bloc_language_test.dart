import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  const ModelLanguage spanishMexico = ModelLanguage.spanishMexico;

  const ModelLanguage englishUnitedKingdom = ModelLanguage.englishUnitedKingdom;

  group('BlocLanguage constructor', () {
    test('uses exact fallback when no preferred language is provided', () {
      final BlocLanguage bloc = BlocLanguage(
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.spanishColombia,
      );
      addTearDown(bloc.dispose);

      expect(
        bloc.language,
        ModelLanguage.spanishColombia,
      );
    });

    test('resolves initial preferred languages', () {
      final BlocLanguage bloc = BlocLanguage(
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
        preferredLanguages: const <ModelLanguage>[
          spanishMexico,
        ],
      );
      addTearDown(bloc.dispose);

      expect(
        bloc.language,
        ModelLanguage.spanishColombia,
      );
    });

    test('resolves compatible fallback when exact fallback is unavailable', () {
      final BlocLanguage bloc = BlocLanguage(
        supportedLanguages: const <ModelLanguage>[
          englishUnitedKingdom,
          ModelLanguage.spanishColombia,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );
      addTearDown(bloc.dispose);

      expect(
        bloc.language,
        englishUnitedKingdom,
      );
    });

    test('uses fallback when supported languages are empty', () {
      final BlocLanguage bloc = BlocLanguage(
        supportedLanguages: const <ModelLanguage>[],
        fallbackLanguage: ModelLanguage.spanishColombia,
      );
      addTearDown(bloc.dispose);

      expect(
        bloc.language,
        ModelLanguage.spanishColombia,
      );
      expect(bloc.supportedLanguages, isEmpty);
    });

    test('copies supported languages into an immutable list', () {
      final List<ModelLanguage> supportedLanguages = <ModelLanguage>[
        ModelLanguage.spanishColombia,
        ModelLanguage.englishUnitedStates,
      ];

      final BlocLanguage bloc = BlocLanguage(
        supportedLanguages: supportedLanguages,
        fallbackLanguage: ModelLanguage.spanishColombia,
      );
      addTearDown(bloc.dispose);

      supportedLanguages.clear();

      expect(
        bloc.supportedLanguages,
        const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedStates,
        ],
      );

      expect(
        () => bloc.supportedLanguages.add(
          ModelLanguage.portugueseBrazil,
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('BlocLanguage.isSupported', () {
    test('returns true only for exact supported languages', () {
      final BlocLanguage bloc = BlocLanguage(
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.spanishColombia,
      );
      addTearDown(bloc.dispose);

      expect(
        bloc.isSupported(ModelLanguage.spanishColombia),
        isTrue,
      );

      expect(
        bloc.isSupported(spanishMexico),
        isFalse,
      );

      expect(
        bloc.isSupported(ModelLanguage.portugueseBrazil),
        isFalse,
      );
    });
  });

  group('BlocLanguage.selectLanguage', () {
    test('selects an exact supported language', () {
      final BlocLanguage bloc = BlocLanguage(
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.spanishColombia,
      );
      addTearDown(bloc.dispose);

      final bool result = bloc.selectLanguage(
        ModelLanguage.englishUnitedStates,
      );

      expect(result, isTrue);
      expect(
        bloc.language,
        ModelLanguage.englishUnitedStates,
      );
    });

    test('rejects unsupported language and preserves current state', () {
      final BlocLanguage bloc = BlocLanguage(
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.spanishColombia,
      );
      addTearDown(bloc.dispose);

      final bool result = bloc.selectLanguage(
        spanishMexico,
      );

      expect(result, isFalse);
      expect(
        bloc.language,
        ModelLanguage.spanishColombia,
      );
    });

    test('does not emit duplicate language snapshots', () async {
      final BlocLanguage bloc = BlocLanguage(
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.spanishColombia,
      );
      addTearDown(bloc.dispose);

      final List<ModelLanguage> emissions = <ModelLanguage>[];

      final StreamSubscription<ModelLanguage> subscription =
          bloc.stream.listen(emissions.add);
      addTearDown(subscription.cancel);

      await Future<void>.delayed(Duration.zero);

      expect(
        emissions,
        const <ModelLanguage>[
          ModelLanguage.spanishColombia,
        ],
      );

      final bool sameLanguageResult = bloc.selectLanguage(
        ModelLanguage.spanishColombia,
      );

      await Future<void>.delayed(Duration.zero);

      expect(sameLanguageResult, isTrue);
      expect(
        emissions,
        const <ModelLanguage>[
          ModelLanguage.spanishColombia,
        ],
      );

      bloc.selectLanguage(
        ModelLanguage.englishUnitedStates,
      );

      await Future<void>.delayed(Duration.zero);

      expect(
        emissions,
        const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedStates,
        ],
      );
    });
  });

  group('BlocLanguage.resolvePreferredLanguages', () {
    test('resolves preferences and updates current language', () {
      final BlocLanguage bloc = BlocLanguage(
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );
      addTearDown(bloc.dispose);

      final ModelLanguage result = bloc.resolvePreferredLanguages(
        const <ModelLanguage>[
          spanishMexico,
        ],
      );

      expect(
        result,
        ModelLanguage.spanishColombia,
      );
      expect(
        bloc.language,
        ModelLanguage.spanishColombia,
      );
    });

    test('uses fallback when preferences cannot be resolved', () {
      final BlocLanguage bloc = BlocLanguage(
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );
      addTearDown(bloc.dispose);

      final ModelLanguage result = bloc.resolvePreferredLanguages(
        const <ModelLanguage>[
          ModelLanguage.germanGermany,
        ],
      );

      expect(
        result,
        ModelLanguage.englishUnitedStates,
      );
      expect(
        bloc.language,
        ModelLanguage.englishUnitedStates,
      );
    });
  });

  group('BlocLanguage.reset', () {
    test('restores exact fallback language', () {
      final BlocLanguage bloc = BlocLanguage(
        supportedLanguages: const <ModelLanguage>[
          ModelLanguage.spanishColombia,
          ModelLanguage.englishUnitedStates,
        ],
        fallbackLanguage: ModelLanguage.spanishColombia,
      );
      addTearDown(bloc.dispose);

      bloc.selectLanguage(
        ModelLanguage.englishUnitedStates,
      );

      final ModelLanguage result = bloc.reset();

      expect(
        result,
        ModelLanguage.spanishColombia,
      );
      expect(
        bloc.language,
        ModelLanguage.spanishColombia,
      );
    });

    test('resolves compatible fallback language', () {
      final BlocLanguage bloc = BlocLanguage(
        supportedLanguages: const <ModelLanguage>[
          englishUnitedKingdom,
          ModelLanguage.spanishColombia,
        ],
        fallbackLanguage: ModelLanguage.englishUnitedStates,
      );
      addTearDown(bloc.dispose);

      bloc.selectLanguage(
        ModelLanguage.spanishColombia,
      );

      final ModelLanguage result = bloc.reset();

      expect(
        result,
        englishUnitedKingdom,
      );
      expect(
        bloc.language,
        englishUnitedKingdom,
      );
    });
  });

  group('BlocLanguage metadata', () {
    test('exposes its canonical registry name', () {
      expect(
        BlocLanguage.name,
        'BlocLanguage',
      );
    });
  });
}
