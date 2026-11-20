part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _emailInputEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.email_input',
    'DsEmailInputWidget',
    'Single-line email field with consumer-owned validation.',
    const <String>[
      'Supply a localized field label and an optional placeholder.',
      'Edits preserve spaces and case. Validate and normalize in the form.',
      'Autofill uses the email hint by default and can be configured.',
    ],
    const <String>[
      'textTheme.labelLarge',
      'textTheme.bodyLarge',
      'borderRadius',
    ],
  ),
  family: 'Forms',
  snippet: '''
DsEmailInputWidget(
  field: email,
  label: 'Correo electrónico',
  placeholder: 'nombre@example.com',
  required: true,
  requiredSemanticLabel: 'Obligatorio',
  onChangedAttempt: onEmailChanged,
)''',
  preview: _buildEmailInputPreview,
);

Widget _buildEmailInputPreview(BuildContext context) {
  final ModelDsExtendedTokens tokens = context.dsTokens;
  ModelFieldState email = const ModelFieldState();
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setPreviewState) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: tokens.spacingSm),
        DsEmailInputWidget(
          field: email,
          label: 'Correo electrónico',
          placeholder: 'nombre@example.com',
          helperText: 'Usa un correo ficticio en esta vista.',
          required: true,
          requiredSemanticLabel: 'Obligatorio',
          autofillHints: null,
          onChangedAttempt: (ModelFieldState next) =>
              setPreviewState(() => email = next),
        ),
        SizedBox(height: tokens.spacing),
        const DsEmailInputWidget(
          field: ModelFieldState(
            value: 'correo-incompleto',
            errorText: 'Ingresa un correo válido.',
            isValid: false,
          ),
          label: 'Correo alternativo',
          autofillHints: null,
          onChangedAttempt: _ignoreTextAttempt,
        ),
        SizedBox(height: tokens.spacing),
        const DsEmailInputWidget(
          field: ModelFieldState(value: 'lectura@example.com'),
          label: 'Correo registrado',
          readOnly: true,
          readOnlySemanticLabel: 'Solo lectura',
          onChangedAttempt: _ignoreTextAttempt,
        ),
        SizedBox(height: tokens.spacing),
        const DsEmailInputWidget(
          field: ModelFieldState(value: 'reserva@example.com'),
          label: 'Correo deshabilitado',
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
            child: const DsEmailInputWidget(
              field: ModelFieldState(value: 'ds@example.com'),
              label: 'Correo',
              helperText: 'Ejemplo con texto ampliado.',
              autofillHints: null,
              onChangedAttempt: _ignoreTextAttempt,
            ),
          ),
        ),
      ],
    ),
  );
}
