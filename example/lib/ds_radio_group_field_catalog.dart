part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _radioGroupFieldEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.radio_group_field',
    'DsRadioGroupFieldWidget',
    'Visible single-select options controlled by ModelFieldState.',
    const <String>[
      'Supply distinct option keys in display order.',
      'Accept a proposed key and validate it in the form controller.',
      'Use arrow keys or tap an option row to propose a selection.',
    ],
    const <String>[
      'radioTheme',
      'textTheme.labelLarge',
      'textTheme.bodyLarge',
      'textTheme.bodySmall',
      'colorScheme.error',
      'spacingSm',
    ],
  ),
  family: 'Forms',
  snippet: '''
DsRadioGroupFieldWidget(
  field: movement,
  label: 'Tipo de movimiento',
  options: const ['income', 'expense'],
  optionLabelBuilder: (key) => key == 'income' ? 'Ingreso' : 'Gasto',
  onChangedAttempt: acceptMovement,
)''',
  preview: (BuildContext context) => const _RadioGroupFieldPreview(),
);

class _RadioGroupFieldPreview extends StatefulWidget {
  const _RadioGroupFieldPreview();

  @override
  State<_RadioGroupFieldPreview> createState() =>
      _RadioGroupFieldPreviewState();
}

class _RadioGroupFieldPreviewState extends State<_RadioGroupFieldPreview> {
  static const List<String> _directions = <String>['income', 'expense'];
  ModelFieldState _movement = const ModelFieldState(value: 'income');
  ModelFieldState _frequency = const ModelFieldState(
    isValid: false,
    errorText: 'Elige cuándo quieres recibir los avisos de la cuenta.',
  );
  bool _largeText = false;

  static String _directionLabel(String key) =>
      key == 'income' ? 'Ingreso' : 'Gasto';

  static String _frequencyLabel(String key) => key == 'daily'
      ? 'Resumen de todas las operaciones de la cuenta al final del día'
      : 'Aviso cuando se registra un movimiento';

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
              DsRadioGroupFieldWidget(
                field: _movement,
                label: 'Tipo de movimiento',
                options: _directions,
                optionLabelBuilder: _directionLabel,
                onChangedAttempt: (ModelFieldState next) =>
                    setState(() => _movement = next),
              ),
              SizedBox(height: tokens.spacing),
              DsRadioGroupFieldWidget(
                field: _frequency,
                label: 'Frecuencia de avisos',
                options: const <String>['daily', 'immediate'],
                optionLabelBuilder: _frequencyLabel,
                required: true,
                requiredSemanticLabel: 'Obligatorio',
                onChangedAttempt: (ModelFieldState next) => setState(
                  () => _frequency = next.clearError().copyWith(isValid: true),
                ),
              ),
              SizedBox(height: tokens.spacing),
              const DsRadioGroupFieldWidget(
                field: ModelFieldState(),
                label: 'Medio de entrega',
                options: <String>[],
                emptyMessage: 'Sin opciones disponibles',
                onChangedAttempt: _ignoreTextAttempt,
              ),
              SizedBox(height: tokens.spacing),
              const DsRadioGroupFieldWidget(
                field: ModelFieldState(value: 'expense'),
                label: 'Movimiento registrado',
                options: _directions,
                optionLabelBuilder: _directionLabel,
                readOnly: true,
                readOnlySemanticLabel: 'Solo lectura',
                onChangedAttempt: _ignoreTextAttempt,
              ),
              SizedBox(height: tokens.spacing),
              const DsRadioGroupFieldWidget(
                field: ModelFieldState(value: 'income'),
                label: 'Movimiento archivado',
                options: _directions,
                optionLabelBuilder: _directionLabel,
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
