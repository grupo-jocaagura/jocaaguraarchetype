part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _checkboxFieldEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.checkbox_field',
    'DsCheckboxFieldWidget',
    'Controlled binary choice with form validation.',
    const <String>[
      "Store 'true' or 'false'. An empty value displays unchecked.",
      'Use the whole row for one choice and place links outside it.',
      'Accept the proposed value and supply validation in the form state.',
    ],
    const <String>[
      'checkboxTheme',
      'textTheme.labelLarge',
      'textTheme.bodySmall',
      'colorScheme.error',
      'spacingSm',
      'spacingXs',
      'borderRadius',
    ],
  ),
  family: 'Forms',
  snippet: '''
DsCheckboxFieldWidget(
  field: terms,
  label: 'Acepto los términos del servicio',
  required: true,
  requiredSemanticLabel: 'Obligatorio',
  onChangedAttempt: acceptTerms,
)''',
  preview: (BuildContext context) => const _CheckboxFieldPreview(),
);

class _CheckboxFieldPreview extends StatefulWidget {
  const _CheckboxFieldPreview();

  @override
  State<_CheckboxFieldPreview> createState() => _CheckboxFieldPreviewState();
}

class _CheckboxFieldPreviewState extends State<_CheckboxFieldPreview> {
  ModelFieldState _notifications = const ModelFieldState(value: 'true');
  ModelFieldState _reminders = const ModelFieldState();
  ModelFieldState _terms = const ModelFieldState(
    isValid: false,
    errorText: 'Marca la casilla para continuar con la solicitud.',
  );
  bool _largeText = false;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context.dsTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CheckboxListTile(
          title: const Text('Texto al 200 %'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _largeText,
          onChanged: (bool? next) => setState(() => _largeText = next!),
        ),
        SizedBox(height: tokens.spacingSm),
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: _largeText ? const TextScaler.linear(2) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DsCheckboxFieldWidget(
                field: _notifications,
                label: 'Recibir avisos por correo',
                onChangedAttempt: (ModelFieldState next) =>
                    setState(() => _notifications = next),
              ),
              DsCheckboxFieldWidget(
                field: _reminders,
                label: 'Recibir recordatorios',
                helperText: 'Puedes cambiar esta preferencia después.',
                onChangedAttempt: (ModelFieldState next) =>
                    setState(() => _reminders = next),
              ),
              DsCheckboxFieldWidget(
                field: _terms,
                label: 'Acepto los términos y condiciones del servicio',
                required: true,
                requiredSemanticLabel: 'Obligatorio',
                onChangedAttempt: (ModelFieldState next) => setState(() {
                  final bool accepted = next.value == 'true';
                  _terms = next.copyWith(
                    isValid: accepted,
                    errorText: accepted
                        ? ''
                        : 'Marca la casilla para continuar con la solicitud.',
                  );
                }),
              ),
              const DsCheckboxFieldWidget(
                field: ModelFieldState(value: 'true'),
                label: 'Consentimiento registrado',
                readOnly: true,
                readOnlySemanticLabel: 'Solo lectura',
                onChangedAttempt: _ignoreTextAttempt,
              ),
              const DsCheckboxFieldWidget(
                field: ModelFieldState(value: 'false'),
                label: 'Opción no disponible',
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
