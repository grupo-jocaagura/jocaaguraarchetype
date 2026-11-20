part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _switchFieldEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.switch_field',
    'DsSwitchFieldWidget',
    'Controlled on/off preference with form validation.',
    const <String>[
      "Store 'true' or 'false'. An empty value displays off.",
      'Tap the row or drag the switch to propose a change.',
      'Accept the proposal and supply validation in the form state.',
    ],
    const <String>[
      'switchTheme',
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
DsSwitchFieldWidget(
  field: notifications,
  label: 'Activar avisos por correo',
  onChangedAttempt: acceptNotifications,
)''',
  preview: (BuildContext context) => const _SwitchFieldPreview(),
);

class _SwitchFieldPreview extends StatefulWidget {
  const _SwitchFieldPreview();

  @override
  State<_SwitchFieldPreview> createState() => _SwitchFieldPreviewState();
}

class _SwitchFieldPreviewState extends State<_SwitchFieldPreview> {
  static const String _error = 'Activa los avisos para poder continuar.';
  ModelFieldState _notifications = const ModelFieldState(value: 'true');
  ModelFieldState _reminders = const ModelFieldState();
  ModelFieldState _security = const ModelFieldState(
    isValid: false,
    errorText: _error,
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
              DsSwitchFieldWidget(
                field: _notifications,
                label: 'Activar avisos por correo',
                onChangedAttempt: (ModelFieldState next) =>
                    setState(() => _notifications = next),
              ),
              DsSwitchFieldWidget(
                field: _reminders,
                label: 'Activar recordatorios',
                helperText: 'Puedes cambiar esta preferencia después.',
                onChangedAttempt: (ModelFieldState next) =>
                    setState(() => _reminders = next),
              ),
              DsSwitchFieldWidget(
                field: _security,
                label: 'Activar avisos de seguridad para esta cuenta',
                required: true,
                requiredSemanticLabel: 'Obligatorio',
                onChangedAttempt: (ModelFieldState next) => setState(() {
                  final bool active = next.value == 'true';
                  _security = next.copyWith(
                    isValid: active,
                    errorText: active ? '' : _error,
                  );
                }),
              ),
              const DsSwitchFieldWidget(
                field: ModelFieldState(value: 'true'),
                label: 'Avisos de la organización',
                readOnly: true,
                readOnlySemanticLabel: 'Solo lectura',
                onChangedAttempt: _ignoreTextAttempt,
              ),
              const DsSwitchFieldWidget(
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
