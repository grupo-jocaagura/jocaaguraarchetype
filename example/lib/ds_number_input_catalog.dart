part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _numberInputEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.number_input',
    'DsNumberInputWidget',
    'Single-line numeric keyboard field with consumer-owned validation.',
    const <String>[
      'Use signed and decimal to request the relevant keyboard keys.',
      'The field preserves entered text. Interpret and validate it in the form.',
      'Give the field a localized label and use helper text for units or ranges.',
    ],
    const <String>[
      'textTheme.labelLarge',
      'textTheme.bodyLarge',
      'borderRadius',
    ],
  ),
  family: 'Forms',
  snippet: '''
DsNumberInputWidget(
  field: measurement,
  label: 'Medición',
  signed: true,
  decimal: true,
  onChangedAttempt: onMeasurementChanged,
)''',
  preview: _buildNumberInputPreview,
);

Widget _buildNumberInputPreview(BuildContext context) {
  final ModelDsExtendedTokens tokens = context.dsTokens;
  ModelFieldState quantity = const ModelFieldState(value: '0007');
  ModelFieldState measurement = const ModelFieldState(value: '-1,5');
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setPreviewState) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: tokens.spacingSm),
        DsNumberInputWidget(
          field: quantity,
          label: 'Cantidad',
          helperText: 'Los ceros iniciales se conservan.',
          required: true,
          requiredSemanticLabel: 'Obligatorio',
          onChangedAttempt: (ModelFieldState next) =>
              setPreviewState(() => quantity = next),
        ),
        SizedBox(height: tokens.spacing),
        DsNumberInputWidget(
          field: measurement,
          label: 'Medición',
          signed: true,
          decimal: true,
          onChangedAttempt: (ModelFieldState next) =>
              setPreviewState(() => measurement = next),
        ),
        SizedBox(height: tokens.spacing),
        const DsNumberInputWidget(
          field: ModelFieldState(
            value: '0',
            errorText: 'Ingresa una cantidad mayor que cero.',
            isValid: false,
          ),
          label: 'Cantidad mínima',
          onChangedAttempt: _ignoreTextAttempt,
        ),
        SizedBox(height: tokens.spacing),
        const DsNumberInputWidget(
          field: ModelFieldState(value: '00125'),
          label: 'Cantidad registrada',
          readOnly: true,
          readOnlySemanticLabel: 'Solo lectura',
          onChangedAttempt: _ignoreTextAttempt,
        ),
        SizedBox(height: tokens.spacing),
        const DsNumberInputWidget(
          field: ModelFieldState(value: '250'),
          label: 'Cantidad deshabilitada',
          enabled: false,
          onChangedAttempt: _ignoreTextAttempt,
        ),
        SizedBox(height: tokens.spacing),
        const Text('Texto ampliado al 200 %'),
        SizedBox(height: tokens.spacingSm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: MediaQuery.withClampedTextScaling(
            minScaleFactor: 2,
            maxScaleFactor: 2,
            child: const DsNumberInputWidget(
              field: ModelFieldState(value: '-12,5'),
              label: 'Medición',
              helperText: 'Ejemplo con texto ampliado.',
              signed: true,
              decimal: true,
              onChangedAttempt: _ignoreTextAttempt,
            ),
          ),
        ),
      ],
    ),
  );
}
