part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _passwordInputEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.password_input',
    'DsPasswordInputWidget',
    'Single-line password field with consumer-owned validation.',
    const <String>[
      'Use a localizable name for the field and for each visibility action.',
      'The password is hidden when focus leaves the field and its button.',
      'Editable passwords can be pasted. Copy and cut are blocked.',
    ],
    const <String>[
      'textTheme.labelLarge',
      'textTheme.bodyLarge',
      'borderRadius',
    ],
  ),
  family: 'Forms',
  snippet: '''
DsPasswordInputWidget(
  field: password,
  label: 'Contraseña',
  showPasswordLabel: 'Mostrar contraseña',
  hidePasswordLabel: 'Ocultar contraseña',
  onChangedAttempt: onPasswordChanged,
)''',
  preview: _buildPasswordInputPreview,
);

Widget _buildPasswordInputPreview(BuildContext context) {
  final ModelDsExtendedTokens tokens = context.dsTokens;
  ModelFieldState password = const ModelFieldState(value: 'Ejemplo-42');
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setPreviewState) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: tokens.spacingSm),
        DsPasswordInputWidget(
          field: password,
          label: 'Contraseña de ejemplo',
          helperText: 'Usa solo datos ficticios en esta vista.',
          required: true,
          requiredSemanticLabel: 'Obligatorio',
          showPasswordLabel: 'Mostrar contraseña',
          hidePasswordLabel: 'Ocultar contraseña',
          autofillHints: null,
          onChangedAttempt: (ModelFieldState next) =>
              setPreviewState(() => password = next),
        ),
        SizedBox(height: tokens.spacing),
        const DsPasswordInputWidget(
          field: ModelFieldState(
            value: 'demo',
            errorText: 'Usa al menos 8 caracteres.',
            isValid: false,
          ),
          label: 'Nueva contraseña',
          autofillHints: null,
          showPasswordLabel: 'Mostrar nueva contraseña',
          hidePasswordLabel: 'Ocultar nueva contraseña',
          onChangedAttempt: _ignoreTextAttempt,
        ),
        SizedBox(height: tokens.spacing),
        const DsPasswordInputWidget(
          field: ModelFieldState(value: 'Ficticia-19'),
          label: 'Contraseña de solo lectura',
          readOnly: true,
          readOnlySemanticLabel: 'Solo lectura',
          autofillHints: null,
          onChangedAttempt: _ignoreTextAttempt,
        ),
        SizedBox(height: tokens.spacing),
        const DsPasswordInputWidget(
          field: ModelFieldState(value: 'Ficticia-27'),
          label: 'Contraseña deshabilitada',
          enabled: false,
          autofillHints: null,
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
            child: const DsPasswordInputWidget(
              field: ModelFieldState(value: 'Ficticia-33'),
              label: 'Contraseña',
              helperText: 'Ejemplo con texto ampliado.',
              autofillHints: null,
              showPasswordLabel: 'Mostrar contraseña con texto ampliado',
              hidePasswordLabel: 'Ocultar contraseña con texto ampliado',
              onChangedAttempt: _ignoreTextAttempt,
            ),
          ),
        ),
      ],
    ),
  );
}
