part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _textInputEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.text_input',
    'DsTextInputWidget',
    'Outlined Material text field with consumer-owned validation.',
    const <String>[
      'Supply a localized label and update ModelFieldState from edit attempts.',
      'Use helper text for guidance and return validation errors through the field.',
      'Use readOnly for text that can be copied and enabled to control availability.',
    ],
    const <String>[
      'textTheme.labelLarge',
      'textTheme.bodyLarge',
      'borderRadius',
    ],
  ),
  family: 'Forms',
  snippet: '''
DsTextInputWidget(
  field: name,
  label: 'Nombre',
  placeholder: 'Escribe tu nombre',
  required: true,
  requiredSemanticLabel: 'Obligatorio',
  onChangedAttempt: onNameChanged,
)''',
  preview: _buildTextInputPreview,
);

Widget _buildTextInputPreview(BuildContext context) {
  final ModelDsExtendedTokens tokens = context.dsTokens;
  ModelFieldState name = const ModelFieldState();
  ModelFieldState notes = const ModelFieldState();
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setPreviewState) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: tokens.spacingSm),
        DsTextInputWidget(
          field: name,
          label: 'Nombre',
          placeholder: 'Escribe tu nombre',
          helperText: 'Usa el nombre que figura en tu documento.',
          required: true,
          requiredSemanticLabel: 'Obligatorio',
          onChangedAttempt: (ModelFieldState next) =>
              setPreviewState(() => name = next),
        ),
        SizedBox(height: tokens.spacing),
        const DsTextInputWidget(
          field: ModelFieldState(
            errorText: 'Completa el apellido.',
            isValid: false,
          ),
          label: 'Apellido',
          placeholder: 'Escribe tu apellido',
          required: true,
          requiredSemanticLabel: 'Obligatorio',
          onChangedAttempt: _ignoreTextAttempt,
        ),
        SizedBox(height: tokens.spacing),
        const DsTextInputWidget(
          field: ModelFieldState(value: 'Bogotá'),
          label: 'Ciudad registrada',
          readOnly: true,
          readOnlySemanticLabel: 'Solo lectura',
          onChangedAttempt: _ignoreTextAttempt,
        ),
        SizedBox(height: tokens.spacing),
        const DsTextInputWidget(
          field: ModelFieldState(value: 'AB-2381'),
          label: 'Referencia',
          enabled: false,
          onChangedAttempt: _ignoreTextAttempt,
        ),
        SizedBox(height: tokens.spacing),
        DsTextInputWidget(
          field: notes,
          label: 'Notas de entrega',
          placeholder: 'Agrega indicaciones',
          maxLines: 3,
          textInputAction: TextInputAction.newline,
          onChangedAttempt: (ModelFieldState next) =>
              setPreviewState(() => notes = next),
        ),
        SizedBox(height: tokens.spacing),
        const Text('Texto ampliado al 200 %'),
        SizedBox(height: tokens.spacingSm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: MediaQuery.withClampedTextScaling(
            minScaleFactor: 2,
            maxScaleFactor: 2,
            child: const DsTextInputWidget(
              field: ModelFieldState(value: 'Entrega en recepción'),
              label: 'Indicaciones',
              helperText: 'Incluye un punto de referencia.',
              maxLines: 3,
              onChangedAttempt: _ignoreTextAttempt,
            ),
          ),
        ),
      ],
    ),
  );
}

void _ignoreTextAttempt(ModelFieldState next) {}
