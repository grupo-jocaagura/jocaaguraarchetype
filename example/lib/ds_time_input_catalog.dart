part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _timeInputEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.time_input',
    'DsTimeInputWidget',
    'Controlled time of day with localized display and validation.',
    const <String>[
      'Store HH:mm, or an empty string for no selection.',
      'Use the app locale and time format for the field and picker.',
      'Accept a confirmed time and supply validation in the form state.',
    ],
    const <String>[
      'textTheme.labelLarge',
      'textTheme.bodyLarge',
      'borderRadius',
    ],
  ),
  family: 'Forms',
  snippet: '''
DsTimeInputWidget(
  field: openingTime,
  label: 'Hora de apertura',
  placeholder: 'Selecciona una hora',
  onChangedAttempt: acceptOpeningTime,
)''',
  preview: (BuildContext context) => Localizations.override(
    context: context,
    locale: const Locale('en', 'US'),
    delegates: GlobalMaterialLocalizations.delegates,
    child: const _TimeInputPreview(),
  ),
);

class _TimeInputPreview extends StatefulWidget {
  const _TimeInputPreview();

  @override
  State<_TimeInputPreview> createState() => _TimeInputPreviewState();
}

class _TimeInputPreviewState extends State<_TimeInputPreview> {
  ModelFieldState _appointment = const ModelFieldState();
  ModelFieldState _closing = const ModelFieldState(value: '21:30');
  ModelFieldState _review = const ModelFieldState(
    value: '24:80',
    isValid: false,
    errorText: 'Selecciona una hora válida.',
  );
  bool _largeText = false;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context.dsTokens;
    final MediaQueryData media = MediaQuery.of(context).copyWith(
      textScaler: _largeText ? const TextScaler.linear(2) : null,
      alwaysUse24HourFormat: false,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Texto al 200 %'),
          controlAffinity: ListTileControlAffinity.leading,
          value: _largeText,
          onChanged: (bool? value) =>
              setState(() => _largeText = value ?? false),
        ),
        SizedBox(height: tokens.spacingSm),
        MediaQuery(
          data: media,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DsTimeInputWidget(
                field: _appointment,
                label: 'Hora de la cita (12 h)',
                placeholder: 'Selecciona una hora',
                required: true,
                requiredSemanticLabel: 'Obligatorio',
                onChangedAttempt: (ModelFieldState next) =>
                    setState(() => _appointment = next),
              ),
              SizedBox(height: tokens.spacing),
              Localizations.override(
                context: context,
                locale: const Locale('es'),
                child: MediaQuery(
                  data: media.copyWith(alwaysUse24HourFormat: true),
                  child: DsTimeInputWidget(
                    field: _closing,
                    label: 'Hora de cierre (24 h)',
                    onChangedAttempt: (ModelFieldState next) =>
                        setState(() => _closing = next),
                  ),
                ),
              ),
              SizedBox(height: tokens.spacing),
              DsTimeInputWidget(
                field: _review,
                label: 'Hora por corregir',
                onChangedAttempt: (ModelFieldState next) => setState(
                  () => _review = next.clearError().copyWith(isValid: true),
                ),
              ),
              SizedBox(height: tokens.spacing),
              const DsTimeInputWidget(
                field: ModelFieldState(value: '00:00'),
                label: 'Hora registrada',
                readOnly: true,
                readOnlySemanticLabel: 'Solo lectura',
                onChangedAttempt: _ignoreTextAttempt,
              ),
              SizedBox(height: tokens.spacing),
              const DsTimeInputWidget(
                field: ModelFieldState(value: '23:59'),
                label: 'Hora archivada',
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
