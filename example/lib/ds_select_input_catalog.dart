part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _selectInputEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.select_input',
    'DsSelectInputWidget',
    'Outlined single-select field controlled by ModelFieldState.',
    const <String>[
      'Supply distinct option keys and localized labels.',
      'Accept and validate proposed changes in the form controller.',
      'Use readOnly for a value that can be consulted and enabled to control availability.',
    ],
    const <String>[
      'textTheme.labelLarge',
      'textTheme.bodyLarge',
      'borderRadius',
    ],
  ),
  family: 'Forms',
  snippet: '''
DsSelectInputWidget(
  field: documentType,
  label: 'Tipo de documento',
  placeholder: 'Selecciona un tipo',
  required: true,
  options: const ['id_card', 'passport'],
  optionLabelBuilder: (key) => key == 'id_card' ? 'Cédula' : 'Pasaporte',
  onChangedAttempt: onDocumentTypeChanged,
)''',
  preview: _buildSelectInputPreview,
);

Widget _buildSelectInputPreview(BuildContext context) {
  final ModelDsExtendedTokens tokens = context.dsTokens;
  ModelFieldState documentType = const ModelFieldState();
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setPreviewState) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // The first floating label paints above its field's outline.
        SizedBox(height: tokens.spacingSm),
        DsSelectInputWidget(
          field: documentType,
          label: 'Tipo de documento',
          placeholder: 'Selecciona un tipo',
          helperText: 'Elige el documento que vas a presentar.',
          required: true,
          requiredSemanticLabel: 'Obligatorio',
          options: _documentTypes,
          optionLabelBuilder: _documentLabel,
          onChangedAttempt: (ModelFieldState next) =>
              setPreviewState(() => documentType = next),
        ),
        SizedBox(height: tokens.spacing),
        const DsSelectInputWidget(
          field: ModelFieldState(
            errorText: 'Selecciona un tipo de documento.',
            isValid: false,
          ),
          label: 'Documento del titular',
          placeholder: 'Selecciona un tipo',
          required: true,
          requiredSemanticLabel: 'Obligatorio',
          options: _documentTypes,
          optionLabelBuilder: _documentLabel,
          onChangedAttempt: _ignoreDocumentAttempt,
        ),
        SizedBox(height: tokens.spacing),
        const DsSelectInputWidget(
          field: ModelFieldState(value: 'passport'),
          label: 'Documento registrado',
          placeholder: 'Selecciona un tipo',
          readOnly: true,
          readOnlySemanticLabel: 'Solo lectura',
          options: _documentTypes,
          optionLabelBuilder: _documentLabel,
          onChangedAttempt: _ignoreDocumentAttempt,
        ),
        SizedBox(height: tokens.spacing),
        const DsSelectInputWidget(
          field: ModelFieldState(value: 'id_card'),
          label: 'Documento del representante',
          placeholder: 'Selecciona un tipo',
          enabled: false,
          options: _documentTypes,
          optionLabelBuilder: _documentLabel,
          onChangedAttempt: _ignoreDocumentAttempt,
        ),
        SizedBox(height: tokens.spacing),
        const Text('Texto ampliado al 200 %'),
        SizedBox(height: tokens.spacingSm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 240),
          child: MediaQuery.withClampedTextScaling(
            minScaleFactor: 2,
            maxScaleFactor: 2,
            child: const DsSelectInputWidget(
              field: ModelFieldState(value: 'foreign_id'),
              label: 'Tipo de documento',
              placeholder: 'Selecciona un tipo',
              options: _documentTypes,
              optionLabelBuilder: _documentLabel,
              onChangedAttempt: _ignoreDocumentAttempt,
            ),
          ),
        ),
      ],
    ),
  );
}

const List<String> _documentTypes = <String>[
  'id_card',
  'passport',
  'foreign_id',
];

String _documentLabel(String key) => switch (key) {
  'id_card' => 'Cédula de ciudadanía',
  'passport' => 'Pasaporte',
  'foreign_id' => 'Documento de identidad para residentes extranjeros',
  _ => key,
};

void _ignoreDocumentAttempt(ModelFieldState next) {}
