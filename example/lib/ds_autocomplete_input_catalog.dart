part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _autocompleteInputEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.autocomplete_input',
    'DsAutocompleteInputWidget',
    'Free-form text with ordered suggestions supplied by the form.',
    const <String>[
      'Publish filtered suggestions through ModelFieldState, including late results.',
      'Accept edits and explicit choices through onChangedAttempt.',
      'Use arrow keys to highlight an option, Enter to choose, and Escape to close.',
    ],
    const <String>[
      'textTheme.labelLarge',
      'textTheme.bodyLarge',
      'colorScheme.surfaceContainer',
      'colorScheme.secondaryContainer',
      'borderRadius',
    ],
  ),
  family: 'Forms',
  snippet: '''
DsAutocompleteInputWidget(
  field: city,
  label: 'Ciudad',
  placeholder: 'Escribe una ciudad',
  onChangedAttempt: acceptCityAndFilterSuggestions,
  onSubmittedAttempt: submitCity,
)''',
  preview: (BuildContext context) => const _AutocompleteInputPreview(),
);

class _AutocompleteInputPreview extends StatefulWidget {
  const _AutocompleteInputPreview();

  @override
  State<_AutocompleteInputPreview> createState() =>
      _AutocompleteInputPreviewState();
}

class _AutocompleteInputPreviewState extends State<_AutocompleteInputPreview> {
  static const List<String> _cities = <String>[
    'Bogotá',
    'Bucaramanga',
    'Medellín',
    'Santa Marta',
    'Santa Rosa de Cabal',
    'Cartagena de Indias',
  ];

  ModelFieldState _city = const ModelFieldState();
  Timer? _suggestionsTimer;
  String? _submitted;
  bool _largeText = false;

  void _acceptCity(ModelFieldState next) {
    _suggestionsTimer?.cancel();
    setState(() {
      _city = next.copyWith(suggestions: const <String>[]);
      _submitted = null;
    });
    final String query = next.value.trim().toLowerCase();
    if (query.isEmpty) {
      return;
    }
    _suggestionsTimer = Timer(const Duration(milliseconds: 450), () {
      final List<String> results = <String>[
        for (final String city in _cities)
          if (city.toLowerCase().contains(query)) city,
      ];
      setState(() => _city = _city.copyWith(suggestions: results));
    });
  }

  @override
  void dispose() {
    _suggestionsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context.dsTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Texto al 200 %'),
          controlAffinity: ListTileControlAffinity.leading,
          value: _largeText,
          onChanged: (bool? next) => setState(() => _largeText = next ?? false),
        ),
        SizedBox(height: tokens.spacingSm),
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: _largeText ? const TextScaler.linear(2) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DsAutocompleteInputWidget(
                field: _city,
                label: 'Ciudad',
                placeholder: 'Escribe una ciudad',
                helperText:
                    'Prueba con «Santa». Las sugerencias llegan después.',
                onChangedAttempt: _acceptCity,
                onSubmittedAttempt: (ModelFieldState next) =>
                    setState(() => _submitted = next.value),
              ),
              if (_submitted case final String city) ...<Widget>[
                SizedBox(height: tokens.spacingSm),
                Text('Enviado: $city'),
              ],
              SizedBox(height: tokens.spacing),
              const DsAutocompleteInputWidget(
                field: ModelFieldState(
                  isValid: false,
                  errorText: 'Indica una ciudad para la entrega.',
                ),
                label: 'Ciudad de entrega',
                required: true,
                requiredSemanticLabel: 'Obligatorio',
                onChangedAttempt: _ignoreTextAttempt,
              ),
              SizedBox(height: tokens.spacing),
              const DsAutocompleteInputWidget(
                field: ModelFieldState(value: 'Bogotá', suggestions: _cities),
                label: 'Ciudad registrada',
                readOnly: true,
                readOnlySemanticLabel: 'Solo lectura',
                onChangedAttempt: _ignoreTextAttempt,
              ),
              SizedBox(height: tokens.spacing),
              const DsAutocompleteInputWidget(
                field: ModelFieldState(value: 'Medellín', suggestions: _cities),
                label: 'Ciudad deshabilitada',
                enabled: false,
                onChangedAttempt: _ignoreTextAttempt,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
