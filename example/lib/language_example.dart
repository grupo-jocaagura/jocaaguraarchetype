import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

const String _mathAssessmentKey = 'math';
const String _artAssessmentKey = 'art';

/// Language configuration used only by this example.
///
/// Notice that [AppManager] does not expose a dedicated language API yet.
/// [BlocLanguage] is registered through the existing `blocModuleList`
/// extension point.
final BlocLanguage _blocLanguage = BlocLanguage(
  supportedLanguages: const <ModelLanguage>[
    ModelLanguage.spanishColombia,
    ModelLanguage.englishUnitedStates,
    ModelLanguage.portugueseBrazil,
  ],
  fallbackLanguage: ModelLanguage.spanishColombia,
);

const LanguageResolutionPolicy _languageResolutionPolicy =
    LanguageResolutionPolicy();

final Map<String, ModelAssessment> _assessments = <String, ModelAssessment>{
  _mathAssessmentKey: _buildMathAssessment(),
  _artAssessmentKey: _buildDigitalArtAssessmentAdvanced(),
};

// -----------------------------------------------------------------------------
// Localized example texts
// -----------------------------------------------------------------------------

ModelLocalizedText _text({
  required String es,
  required String en,
  required String pt,
}) {
  return ModelLocalizedText(
    translations: <ModelLanguage, String>{
      ModelLanguage.spanishColombia: es,
      ModelLanguage.englishUnitedStates: en,
      ModelLanguage.portugueseBrazil: pt,
    },
    fallbackLanguage: ModelLanguage.spanishColombia,
  );
}

final ModelLocalizedText _internationalizationDemoText = _text(
  es: 'Demostración de internacionalización',
  en: 'Internationalization demo',
  pt: 'Demonstração de internacionalização',
);

final ModelLocalizedText _blocLanguageDescriptionText = _text(
  es: 'BlocLanguage está registrado como un módulo opcional de AppManager. '
      'AppManager no ha sido modificado.',
  en: 'BlocLanguage is registered as an optional AppManager module. '
      'The AppManager itself has not been modified.',
  pt: 'BlocLanguage está registrado como um módulo opcional do AppManager. '
      'O AppManager não foi modificado.',
);

final ModelLocalizedText _activeLanguageText = _text(
  es: 'Idioma activo',
  en: 'Active language',
  pt: 'Idioma ativo',
);

final ModelLocalizedText _simulatePreferenceText = _text(
  es: 'Simular preferencia del dispositivo: es-MX',
  en: 'Simulate device preference: es-MX',
  pt: 'Simular preferência do dispositivo: es-MX',
);

final ModelLocalizedText _integrationPendingText = _text(
  es: 'Esta demostración todavía no asigna el Locale resuelto a MaterialApp. '
      'Esa integración pertenece a una futura fase de internacionalización '
      'de AppManager.',
  en: 'This demo intentionally does not assign the resolved Locale to '
      'MaterialApp yet. That integration belongs to the future AppManager '
      'internationalization phase.',
  pt: 'Esta demonstração ainda não atribui o Locale resolvido ao MaterialApp. '
      'Essa integração pertence a uma futura fase de internacionalização '
      'do AppManager.',
);

final ModelLocalizedText _chooseAssessmentText = _text(
  es: 'Elige una evaluación',
  en: 'Choose an assessment',
  pt: 'Escolha uma avaliação',
);

final ModelLocalizedText _questionsText = _text(
  es: 'Preguntas',
  en: 'Questions',
  pt: 'Perguntas',
);

final ModelLocalizedText _timeText = _text(
  es: 'Tiempo',
  en: 'Time',
  pt: 'Tempo',
);

final ModelLocalizedText _withoutLimitText = _text(
  es: 'sin límite',
  en: 'no limit',
  pt: 'sem limite',
);

final ModelLocalizedText _passScoreText = _text(
  es: 'Aprobación',
  en: 'Pass score',
  pt: 'Aprovação',
);

final ModelLocalizedText _startAssessmentText = _text(
  es: 'Iniciar evaluación',
  en: 'Start assessment',
  pt: 'Iniciar avaliação',
);

final ModelLocalizedText _questionText = _text(
  es: 'Pregunta',
  en: 'Question',
  pt: 'Pergunta',
);

final ModelLocalizedText _ofText = _text(
  es: 'de',
  en: 'of',
  pt: 'de',
);

final ModelLocalizedText _timeLimitText = _text(
  es: 'Tiempo límite',
  en: 'Time limit',
  pt: 'Tempo limite',
);

final ModelLocalizedText _informationalText = _text(
  es: 'informativo',
  en: 'informational',
  pt: 'informativo',
);

final ModelLocalizedText _backText = _text(
  es: 'Atrás',
  en: 'Back',
  pt: 'Voltar',
);

final ModelLocalizedText _nextText = _text(
  es: 'Siguiente',
  en: 'Next',
  pt: 'Próxima',
);

final ModelLocalizedText _finishText = _text(
  es: 'Finalizar',
  en: 'Finish',
  pt: 'Finalizar',
);

final ModelLocalizedText _passedText = _text(
  es: 'Aprobado',
  en: 'Passed',
  pt: 'Aprovado',
);

final ModelLocalizedText _notPassedText = _text(
  es: 'No aprobado',
  en: 'Not passed',
  pt: 'Não aprovado',
);

final ModelLocalizedText _yourAnswerText = _text(
  es: 'Tu respuesta',
  en: 'Your answer',
  pt: 'Sua resposta',
);

final ModelLocalizedText _correctAnswerText = _text(
  es: 'Respuesta correcta',
  en: 'Correct answer',
  pt: 'Resposta correta',
);

final ModelLocalizedText _explanationText = _text(
  es: 'Explicación',
  en: 'Explanation',
  pt: 'Explicação',
);

final ModelLocalizedText _goalText = _text(
  es: 'Meta',
  en: 'Goal',
  pt: 'Meta',
);

final ModelLocalizedText _standardText = _text(
  es: 'Estándar',
  en: 'Standard',
  pt: 'Padrão',
);

final ModelLocalizedText _retryText = _text(
  es: 'Reintentar',
  en: 'Retry',
  pt: 'Tentar novamente',
);

final ModelLocalizedText _homeText = _text(
  es: 'Inicio',
  en: 'Home',
  pt: 'Início',
);

final ModelLocalizedText _architectureNoteText = _text(
  es: 'Límite de la demostración:\n\n'
      'UI → AppManager → BlocLanguage → LanguageResolutionPolicy\n\n'
      'La conversión a Locale permanece en LanguageLocaleMapper.\n'
      'AppManager no ha sido modificado.\n\n'
      'El chrome de la UI usa ModelLocalizedText. '
      'El contenido de las evaluaciones conserva sus String de dominio.',
  en: 'Demo boundary:\n\n'
      'UI → AppManager → BlocLanguage → LanguageResolutionPolicy\n\n'
      'Locale conversion remains in LanguageLocaleMapper.\n'
      'AppManager has not been modified.\n\n'
      'The UI chrome uses ModelLocalizedText. '
      'Assessment content keeps its domain String values.',
  pt: 'Limite da demonstração:\n\n'
      'UI → AppManager → BlocLanguage → LanguageResolutionPolicy\n\n'
      'A conversão para Locale permanece em LanguageLocaleMapper.\n'
      'O AppManager não foi modificado.\n\n'
      'O chrome da UI usa ModelLocalizedText. '
      'O conteúdo das avaliações mantém seus valores String de domínio.',
);

String _localizedText(
  ModelLocalizedText localizedText,
  ModelLanguage preferredLanguage,
) {
  if (localizedText.translations.isEmpty) {
    return '';
  }

  final ModelLanguage resolvedLanguage = _languageResolutionPolicy.resolve(
    preferredLanguages: <ModelLanguage>[
      preferredLanguage,
    ],
    supportedLanguages: localizedText.translations.keys,
    fallbackLanguage: localizedText.fallbackLanguage,
  );

  return localizedText.translations[resolvedLanguage] ?? '';
}

// -----------------------------------------------------------------------------
// Bootstrap
// -----------------------------------------------------------------------------

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final PageRegistry registry = _buildRegistry();

  final AppConfig defaults = AppConfig.dev(
    registry: registry,
  );

  final AppConfig config = AppConfig(
    blocTheme: defaults.blocTheme,
    blocUserNotifications: defaults.blocUserNotifications,
    blocLoading: defaults.blocLoading,
    blocMainMenuDrawer: defaults.blocMainMenuDrawer,
    blocSecondaryMenuDrawer: defaults.blocSecondaryMenuDrawer,
    blocResponsive: defaults.blocResponsive,
    blocOnboarding: defaults.blocOnboarding,
    pageManager: defaults.pageManager,
    blocModelVersion: defaults.blocModelVersion,
    blocModuleList: <String, BlocModule>{
      ...defaults.blocModuleList,
      BlocLanguage.name: _blocLanguage,
    },
  );

  final AppManager appManager = AppManager(config);

  runApp(
    JocaaguraApp(
      appManager: appManager,
      registry: registry,
      ownsManager: true,
      seedInitialFromPageManager: true,
    ),
  );
}

PageRegistry _buildRegistry() {
  return PageRegistry.fromDefs(
    <PageDef>[
      PageDef(
        model: AssessmentChooserPage.pageModel,
        builder: AssessmentChooserPage.builder(),
      ),
      PageDef(
        model: AssessmentHomePage.pageModel,
        builder: AssessmentHomePage.builder(),
      ),
      PageDef(
        model: AssessmentRunnerPage.pageModel,
        builder: AssessmentRunnerPage.builder(),
      ),
      PageDef(
        model: AssessmentResultPage.pageModel,
        builder: AssessmentResultPage.builder(),
      ),
    ],
    defaultPage: AssessmentChooserPage.pageModel,
  );
}

BlocLanguage _languageBloc(BuildContext context) {
  return context.appManager.requireModuleByKey<BlocLanguage>(
    BlocLanguage.name,
  );
}

ModelAssessment _assessmentFor(String key) {
  return _assessments[key] ?? _assessments[_mathAssessmentKey]!;
}

// -----------------------------------------------------------------------------
// Reactive language boundary
// -----------------------------------------------------------------------------

class _LanguageBuilder extends StatelessWidget {
  const _LanguageBuilder({
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    ModelLanguage language,
  ) builder;

  @override
  Widget build(BuildContext context) {
    final BlocLanguage bloc = _languageBloc(context);

    return StreamBuilder<ModelLanguage>(
      stream: bloc.stream,
      initialData: bloc.language,
      builder: (
        BuildContext context,
        AsyncSnapshot<ModelLanguage> snapshot,
      ) {
        return builder(
          context,
          snapshot.data ?? bloc.language,
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Education home
// -----------------------------------------------------------------------------

class AssessmentChooserPage extends StatelessWidget {
  const AssessmentChooserPage({super.key});

  static const String name = 'home';

  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>['home'],
    state: <String, dynamic>{
      'title': 'Jocaagura Education Demo',
    },
  );

  static PageWidgetBuilder builder() {
    return (BuildContext context, PageModel page) {
      return const AssessmentChooserPage();
    };
  }

  @override
  Widget build(BuildContext context) {
    return _LanguageBuilder(
      builder: (
        BuildContext context,
        ModelLanguage language,
      ) {
        final ModelAssessment math = _assessmentFor(
          _mathAssessmentKey,
        );
        final ModelAssessment art = _assessmentFor(
          _artAssessmentKey,
        );

        return PageBuilder(
          page: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _LanguageDemoCard(
                language: language,
              ),
              const SizedBox(height: 24),
              Text(
                _localizedText(
                  _chooseAssessmentText,
                  language,
                ),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _AssessmentCard(
                title: math.title,
                subtitle: _assessmentSummary(
                  math,
                  language,
                ),
                onTap: () {
                  context.appManager.pushOnceModel(
                    AssessmentHomePage.make(
                      assessmentKey: _mathAssessmentKey,
                      title: math.title,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _AssessmentCard(
                title: art.title,
                subtitle: _assessmentSummary(
                  art,
                  language,
                ),
                onTap: () {
                  context.appManager.pushOnceModel(
                    AssessmentHomePage.make(
                      assessmentKey: _artAssessmentKey,
                      title: art.title,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _ArchitectureNote(
                language: language,
              ),
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Internationalization demo
// -----------------------------------------------------------------------------

class _LanguageDemoCard extends StatelessWidget {
  const _LanguageDemoCard({
    required this.language,
  });

  final ModelLanguage language;

  static const LanguageLocaleMapper _mapper = LanguageLocaleMapper();

  @override
  Widget build(BuildContext context) {
    final BlocLanguage bloc = _languageBloc(context);
    final Locale locale = _mapper.toLocale(language);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _localizedText(
                _internationalizationDemoText,
                language,
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _localizedText(
                _blocLanguageDescriptionText,
                language,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ModelLanguage>(
              key: ValueKey<String>(
                language.canonicalTag,
              ),
              initialValue: language,
              decoration: InputDecoration(
                labelText: _localizedText(
                  _activeLanguageText,
                  language,
                ),
                border: const OutlineInputBorder(),
              ),
              items: bloc.supportedLanguages
                  .map(
                    (ModelLanguage item) => DropdownMenuItem<ModelLanguage>(
                      value: item,
                      child: Text(
                        _languageLabel(item),
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (ModelLanguage? selected) {
                if (selected == null) {
                  return;
                }

                bloc.selectLanguage(selected);
              },
            ),
            const SizedBox(height: 12),
            Text(
              'ModelLanguage: ${language.canonicalTag}',
            ),
            Text(
              'Flutter Locale: ${_localeTag(locale)}',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                final ModelLanguage resolved = bloc.resolvePreferredLanguages(
                  const <ModelLanguage>[
                    ModelLanguage.spanishMexico,
                  ],
                );

                context.appManager.notify(
                  'es-MX → ${resolved.canonicalTag}',
                );
              },
              icon: const Icon(Icons.travel_explore),
              label: Text(
                _localizedText(
                  _simulatePreferenceText,
                  language,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _localizedText(
                _integrationPendingText,
                language,
              ),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _languageLabel(ModelLanguage language) {
    switch (language.canonicalTag) {
      case 'es-CO':
        return 'Español — Colombia';
      case 'en-US':
        return 'English — United States';
      case 'pt-BR':
        return 'Português — Brasil';
      default:
        return language.canonicalTag;
    }
  }

  static String _localeTag(Locale locale) {
    return <String>[
      locale.languageCode,
      if (locale.scriptCode != null) locale.scriptCode!,
      if (locale.countryCode != null) locale.countryCode!,
    ].join('-');
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.quiz,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchitectureNote extends StatelessWidget {
  const _ArchitectureNote({
    required this.language,
  });

  final ModelLanguage language;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          _localizedText(
            _architectureNoteText,
            language,
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Assessment details
// -----------------------------------------------------------------------------

class AssessmentHomePage extends StatelessWidget {
  const AssessmentHomePage({
    required this.assessmentKey,
    super.key,
  });

  factory AssessmentHomePage.fromPageModel(PageModel page) {
    return AssessmentHomePage(
      assessmentKey: page.query['assessment'] ?? _mathAssessmentKey,
    );
  }

  final String assessmentKey;

  static const String name = 'assessment';

  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>['assessment'],
  );

  static PageWidgetBuilder builder() {
    return (BuildContext context, PageModel page) {
      return AssessmentHomePage.fromPageModel(page);
    };
  }

  static PageModel make({
    required String assessmentKey,
    required String title,
  }) {
    return pageModel.copyWith(
      query: <String, String>{
        'assessment': assessmentKey,
      },
      state: <String, dynamic>{
        'title': title,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _LanguageBuilder(
      builder: (
        BuildContext context,
        ModelLanguage language,
      ) {
        final ModelAssessment assessment = _assessmentFor(assessmentKey);

        return PageBuilder(
          page: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  assessment.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _assessmentSummary(
                    assessment,
                    language,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SingleChildScrollView(
                        child: Text(
                          'JSON (enum.name stable):\n'
                          '${assessment.toJson()}',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () {
                      context.appManager.pushOnceModel(
                        AssessmentRunnerPage.make(
                          assessmentKey: assessmentKey,
                          title: assessment.title,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.play_arrow,
                    ),
                    label: Text(
                      _localizedText(
                        _startAssessmentText,
                        language,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Assessment runner
// -----------------------------------------------------------------------------

class AssessmentRunnerPage extends StatefulWidget {
  const AssessmentRunnerPage({
    required this.assessmentKey,
    super.key,
  });

  factory AssessmentRunnerPage.fromPageModel(PageModel page) {
    return AssessmentRunnerPage(
      assessmentKey: page.query['assessment'] ?? _mathAssessmentKey,
    );
  }

  final String assessmentKey;

  static const String name = 'assessmentRunner';

  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>['assessment', 'run'],
  );

  static PageWidgetBuilder builder() {
    return (BuildContext context, PageModel page) {
      return AssessmentRunnerPage.fromPageModel(page);
    };
  }

  static PageModel make({
    required String assessmentKey,
    required String title,
  }) {
    return pageModel.copyWith(
      query: <String, String>{
        'assessment': assessmentKey,
      },
      state: <String, dynamic>{
        'title': title,
      },
    );
  }

  @override
  State<AssessmentRunnerPage> createState() => _AssessmentRunnerPageState();
}

class _AssessmentRunnerPageState extends State<AssessmentRunnerPage> {
  late final ModelAssessment _assessment;
  late final List<ItemInstance> _instances;

  final Map<String, String> _answers = <String, String>{};

  int _index = 0;

  @override
  void initState() {
    super.initState();

    _assessment = _assessmentFor(widget.assessmentKey);
    _instances = _createInstances(_assessment);
  }

  void _choose(String itemId, String option) {
    setState(() {
      _answers[itemId] = option;
    });
  }

  void _nextOrFinish() {
    if (_index + 1 < _instances.length) {
      setState(() {
        _index++;
      });
      return;
    }

    context.appManager.replaceTopModel(
      AssessmentResultPage.make(
        assessmentKey: widget.assessmentKey,
        answers: _answers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _LanguageBuilder(
      builder: (
        BuildContext context,
        ModelLanguage language,
      ) {
        final ItemInstance instance = _instances[_index];
        final String? chosen = _answers[instance.item.id];

        return PageBuilder(
          page: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                LinearProgressIndicator(
                  value: (_index + 1) / _instances.length,
                ),
                const SizedBox(height: 12),
                Text(
                  '${_localizedText(_questionText, language)} '
                  '${_index + 1} '
                  '${_localizedText(_ofText, language)} '
                  '${_instances.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_assessment.timeLimit != Duration.zero) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    '${_localizedText(_timeLimitText, language)}: '
                    '${_assessment.timeLimit.inMinutes} min '
                    '(${_localizedText(_informationalText, language)})',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      instance.item.label,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...instance.options.map(
                  (String option) {
                    final bool isSelected = chosen == option;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        title: Text(option),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check,
                              )
                            : null,
                        onTap: () {
                          _choose(
                            instance.item.id,
                            option,
                          );
                        },
                      ),
                    );
                  },
                ),
                const Spacer(),
                Row(
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: _index == 0
                          ? null
                          : () {
                              setState(() {
                                _index--;
                              });
                            },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                      label: Text(
                        _localizedText(
                          _backText,
                          language,
                        ),
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: chosen == null ? null : _nextOrFinish,
                      icon: Icon(
                        _index + 1 < _instances.length
                            ? Icons.arrow_forward
                            : Icons.flag,
                      ),
                      label: Text(
                        _localizedText(
                          _index + 1 < _instances.length
                              ? _nextText
                              : _finishText,
                          language,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Result
// -----------------------------------------------------------------------------

class AssessmentResultPage extends StatelessWidget {
  const AssessmentResultPage({
    required this.assessmentKey,
    required this.answers,
    super.key,
  });

  factory AssessmentResultPage.fromPageModel(PageModel page) {
    final Map<String, dynamic> rawAnswers =
        page.state['answers'] is Map<String, dynamic>
            ? page.state['answers'] as Map<String, dynamic>
            : <String, dynamic>{};

    return AssessmentResultPage(
      assessmentKey: page.query['assessment'] ?? _mathAssessmentKey,
      answers: <String, String>{
        for (final MapEntry<String, dynamic> entry in rawAnswers.entries)
          entry.key: entry.value.toString(),
      },
    );
  }

  final String assessmentKey;
  final Map<String, String> answers;

  static const String name = 'assessmentResult';

  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>['assessment', 'result'],
  );

  static PageWidgetBuilder builder() {
    return (BuildContext context, PageModel page) {
      return AssessmentResultPage.fromPageModel(page);
    };
  }

  static PageModel make({
    required String assessmentKey,
    required Map<String, String> answers,
  }) {
    return pageModel.copyWith(
      query: <String, String>{
        'assessment': assessmentKey,
      },
      state: <String, dynamic>{
        'title': 'Resultado',
        'answers': Map<String, String>.from(answers),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _LanguageBuilder(
      builder: (
        BuildContext context,
        ModelLanguage language,
      ) {
        final ModelAssessment assessment = _assessmentFor(assessmentKey);

        final List<ItemInstance> instances = _createInstances(assessment);

        final AssessmentResult result = _computeResult(
          assessment: assessment,
          instances: instances,
          answers: answers,
        );

        return PageBuilder(
          page: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      result.passed ? Icons.verified : Icons.error_outline,
                      size: 32,
                      color: result.passed
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _localizedText(
                        result.passed ? _passedText : _notPassedText,
                        language,
                      ),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Text(
                      '${result.percent}% '
                      '(${result.correct}/${result.total})',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: instances.length,
                    separatorBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      return const Divider(
                        height: 1,
                      );
                    },
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      final ItemInstance instance = instances[index];

                      final String? chosen = answers[instance.item.id];

                      final bool isRight =
                          chosen == instance.item.correctAnswer;

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            '${index + 1}',
                          ),
                        ),
                        title: Text(
                          instance.item.label,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 4),
                            Text(
                              '${_localizedText(_yourAnswerText, language)}: '
                              '${chosen ?? '-'}',
                            ),
                            Text(
                              '${_localizedText(_correctAnswerText, language)}: '
                              '${instance.item.correctAnswer}',
                            ),
                            if (instance
                                .item.explanation.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 8),
                              Text(
                                '${_localizedText(_explanationText, language)}: '
                                '${instance.item.explanation}',
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              '${_localizedText(_goalText, language)}: '
                              '${instance.item.achievementOne.modelLearningGoal.label} '
                              '• '
                              '${_localizedText(_standardText, language)}: '
                              '${instance.item.achievementOne.modelLearningGoal.standard.code}',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          isRight ? Icons.check_circle : Icons.cancel,
                          color: isRight
                              ? Colors.green
                              : Theme.of(context).colorScheme.error,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () {
                        context.appManager.replaceTopModel(
                          AssessmentRunnerPage.make(
                            assessmentKey: assessmentKey,
                            title: assessment.title,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.replay,
                      ),
                      label: Text(
                        _localizedText(
                          _retryText,
                          language,
                        ),
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () {
                        context.appManager.goToModel(
                          AssessmentChooserPage.pageModel,
                        );
                      },
                      icon: const Icon(
                        Icons.home,
                      ),
                      label: Text(
                        _localizedText(
                          _homeText,
                          language,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Shared assessment helpers
// -----------------------------------------------------------------------------

class ItemInstance {
  const ItemInstance({
    required this.item,
    required this.options,
  });

  final ModelLearningItem item;
  final List<String> options;
}

class AssessmentResult {
  const AssessmentResult({
    required this.correct,
    required this.total,
    required this.percent,
    required this.passed,
  });

  final int correct;
  final int total;
  final int percent;
  final bool passed;
}

List<ItemInstance> _createInstances(
  ModelAssessment assessment,
) {
  final List<ModelLearningItem> items = List<ModelLearningItem>.from(
    assessment.items,
  );

  if (assessment.shuffleItems) {
    items.shuffle(
      Random(
        assessment.id.hashCode,
      ),
    );
  }

  return items.map(
    (ModelLearningItem item) {
      return ItemInstance(
        item: item,
        options: item.optionsShuffled(
          item.id.hashCode,
        ),
      );
    },
  ).toList(growable: false);
}

AssessmentResult _computeResult({
  required ModelAssessment assessment,
  required List<ItemInstance> instances,
  required Map<String, String> answers,
}) {
  int correct = 0;

  for (final ItemInstance instance in instances) {
    if (answers[instance.item.id] == instance.item.correctAnswer) {
      correct++;
    }
  }

  final int total = instances.length;
  final int percent = total == 0 ? 0 : ((correct / total) * 100).round();

  return AssessmentResult(
    correct: correct,
    total: total,
    percent: percent,
    passed: percent >= assessment.passScore,
  );
}

String _assessmentSummary(
  ModelAssessment assessment,
  ModelLanguage language,
) {
  final String time = assessment.timeLimit == Duration.zero
      ? _localizedText(
          _withoutLimitText,
          language,
        )
      : '${assessment.timeLimit.inMinutes} min';

  return '${_localizedText(_questionsText, language)}: '
      '${assessment.items.length} '
      '• ${_localizedText(_timeText, language)}: $time '
      '• ${_localizedText(_passScoreText, language)}: '
      '${assessment.passScore}%';
}

// -----------------------------------------------------------------------------
// Dataset #1 — Matemáticas (3°) — 5 sumas/restas
// -----------------------------------------------------------------------------

ModelAssessment _buildMathAssessment() {
  const ModelCompetencyStandard std = ModelCompetencyStandard(
    id: 'STD-MATH-OPS-3',
    label: 'Resuelve operaciones básicas de suma y resta (3°)',
    area: ModelCategory(
      category: 'math',
      description: 'Matemáticas',
    ),
    cineLevel: 1,
    code: 'MATH.OPS.L1',
  );

  const ModelLearningGoal goal = ModelLearningGoal(
    id: 'GOAL-MATH-OPS-3',
    standard: std,
    label: 'Aplica sumas y restas con números pequeños.',
    code: 'MATH.OPS.GOAL.3',
  );

  const ModelPerformanceIndicator indicator = ModelPerformanceIndicator(
    id: 'PI-ACCURACY',
    modelLearningGoal: goal,
    label: 'Selecciona respuestas correctas con consistencia.',
    level: PerformanceLevel.basic,
    code: 'MATH.OPS.PI.1',
  );

  ModelLearningItem q({
    required String id,
    required String label,
    required String correct,
    required String w1,
    required String w2,
    required String w3,
  }) {
    return ModelLearningItem(
      id: id,
      label: label,
      correctAnswer: correct,
      wrongAnswerOne: w1,
      wrongAnswerTwo: w2,
      wrongAnswerThree: w3,
      explanation: '',
      attributes: const <ModelAttribute<dynamic>>[],
      achievementOne: indicator,
      estimatedTimeForAnswer: const Duration(
        minutes: 1,
      ),
      category: const ModelCategory(
        category: 'math',
        description: 'Matemáticas',
      ),
      cineLevel: 1,
    );
  }

  final List<ModelLearningItem> items = <ModelLearningItem>[
    q(
      id: 'Q1',
      label: '2 + 3 = ?',
      correct: '5',
      w1: '4',
      w2: '6',
      w3: '7',
    ),
    q(
      id: 'Q2',
      label: '7 - 4 = ?',
      correct: '3',
      w1: '2',
      w2: '4',
      w3: '1',
    ),
    q(
      id: 'Q3',
      label: '5 + 6 = ?',
      correct: '11',
      w1: '10',
      w2: '12',
      w3: '9',
    ),
    q(
      id: 'Q4',
      label: '9 - 5 = ?',
      correct: '4',
      w1: '3',
      w2: '5',
      w3: '6',
    ),
    q(
      id: 'Q5',
      label: '8 + 7 = ?',
      correct: '15',
      w1: '14',
      w2: '16',
      w3: '13',
    ),
  ];

  return ModelAssessment(
    id: 'ASMT-MATH-3RD-OPS',
    title: 'Matemáticas 3° — Sumas y Restas',
    items: items,
    shuffleItems: true,
    shuffleOptions: true,
    timeLimit: const Duration(
      minutes: 10,
    ),
    passScore: 60,
  );
}

// -----------------------------------------------------------------------------
// Dataset #2 — Arte Digital (Avanzado) — 10 preguntas, 5 minutos
// -----------------------------------------------------------------------------

ModelAssessment _buildDigitalArtAssessmentAdvanced() {
  const ModelCompetencyStandard std = ModelCompetencyStandard(
    id: 'STD-ART-DIG-ADV',
    label:
        'Domina conceptos avanzados de arte digital y gráficos por computadora',
    area: ModelCategory(
      category: 'art',
      description: 'Arte Digital',
    ),
    cineLevel: 3,
    code: 'ART.DIG.ADV',
  );

  const ModelLearningGoal goal = ModelLearningGoal(
    id: 'GOAL-ART-DIG-ADV',
    standard: std,
    label: 'Aplica conocimientos avanzados en flujos de arte digital.',
    code: 'ART.DIG.GOAL.ADV',
  );

  const ModelPerformanceIndicator indicator = ModelPerformanceIndicator(
    id: 'PI-ADV-MASTERY',
    modelLearningGoal: goal,
    label: 'Domina terminología y decisiones técnicas correctas.',
    level: PerformanceLevel.high,
    code: 'ART.DIG.PI.MASTERY',
  );

  ModelLearningItem q({
    required String id,
    required String label,
    required String correct,
    required String w1,
    required String w2,
    required String w3,
  }) {
    return ModelLearningItem(
      id: id,
      label: label,
      correctAnswer: correct,
      wrongAnswerOne: w1,
      wrongAnswerTwo: w2,
      wrongAnswerThree: w3,
      explanation: '',
      attributes: const <ModelAttribute<dynamic>>[],
      achievementOne: indicator,
      estimatedTimeForAnswer: const Duration(
        seconds: 20,
      ),
      category: const ModelCategory(
        category: 'art',
        description: 'Arte Digital',
      ),
      cineLevel: 3,
    );
  }

  final List<ModelLearningItem> items = <ModelLearningItem>[
    q(
      id: 'A1',
      label: '¿Ventaja clave del vector frente al raster?',
      correct: 'Escala sin pérdida',
      w1: 'Mejor fotos',
      w2: 'Más bits de color',
      w3: 'Anti-aliasing automático',
    ),
    q(
      id: 'A2',
      label: 'Lienzo 300 DPI y 3000 px de alto ≈ ¿cuántas pulgadas?',
      correct: '10 pulgadas',
      w1: '5',
      w2: '15',
      w3: '30',
    ),
    q(
      id: 'A3',
      label: 'Modo de fusión que aclara sin afectar sombras:',
      correct: 'Trama (Screen)',
      w1: 'Multiplicar',
      w2: 'Superponer',
      w3: 'Luz dura',
    ),
    q(
      id: 'A4',
      label: 'Espacio de color adecuado para offset:',
      correct: 'CMYK',
      w1: 'RGB',
      w2: 'HSV',
      w3: 'LAB solo',
    ),
    q(
      id: 'A5',
      label: 'Anti-aliasing:',
      correct: 'Suaviza bordes dentados',
      w1: 'Sube saturación',
      w2: 'BN automático',
      w3: 'Duplica resolución',
    ),
    q(
      id: 'A6',
      label: 'Curva Bézier cúbica:',
      correct: '2 controles + 2 extremos',
      w1: '1 control + 1 extremo',
      w2: '4 extremos',
      w3: '3 controles + 1 extremo',
    ),
    q(
      id: 'A7',
      label: 'Alpha premultiplicado:',
      correct: 'Colores ya multiplicados por alpha',
      w1: 'Alpha separado',
      w2: 'Sin transparencia',
      w3: 'Sin corrección gamma',
    ),
    q(
      id: 'A8',
      label: '¿Cuál NO es ventaja de capas de ajuste?',
      correct: 'Duplican píxeles y pesan más',
      w1: 'No destructivas',
      w2: 'Reordenables y enmascarables',
      w3: 'Cambios globales rápidos',
    ),
    q(
      id: 'A9',
      label: '“Resolución independiente” se asocia con:',
      correct: 'Vectorial',
      w1: 'Raster 8-bit',
      w2: 'Bitmap escalado',
      w3: 'Spritesheet baja res',
    ),
    q(
      id: 'A10',
      label: 'En PBR, mapa que controla especular directo:',
      correct: 'Rugosidad (Roughness)',
      w1: 'Albedo',
      w2: 'Normal',
      w3: 'Altura',
    ),
  ];

  return ModelAssessment(
    id: 'ASMT-ART-DIG-ADV',
    title: 'Arte Digital (Avanzado) — Conceptos Clave',
    items: items,
    shuffleItems: true,
    shuffleOptions: true,
    timeLimit: const Duration(
      minutes: 5,
    ),
    passScore: 70,
  );
}
