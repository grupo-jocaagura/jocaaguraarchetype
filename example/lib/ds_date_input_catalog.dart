part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _dateInputEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.date_input',
    'DsDateInputWidget',
    'Controlled calendar date field with inclusive bounds.',
    const <String>[
      'Use yyyy-MM-dd for a calendar day and an empty string for no selection.',
      'Supply the earliest and latest selectable dates.',
      'Accept confirmed changes and supply validation in the form state.',
    ],
    const <String>[
      'textTheme.labelLarge',
      'textTheme.bodyLarge',
      'borderRadius',
    ],
  ),
  family: 'Forms',
  snippet: '''
DsDateInputWidget(
  field: appointment,
  label: 'Fecha de la cita',
  placeholder: 'Selecciona una fecha',
  firstDate: DateTime(2026, 11, 1),
  lastDate: DateTime(2026, 11, 30),
  onChangedAttempt: acceptAppointment,
)''',
  preview: (BuildContext context) => Localizations.override(
    context: context,
    locale: const Locale('es'),
    delegates: GlobalMaterialLocalizations.delegates,
    child: const _DateInputPreview(),
  ),
);

class _DateInputPreview extends StatefulWidget {
  const _DateInputPreview();

  @override
  State<_DateInputPreview> createState() => _DateInputPreviewState();
}

class _DateInputPreviewState extends State<_DateInputPreview> {
  final DateTime _firstDate = DateTime(2026, 11);
  final DateTime _lastDate = DateTime(2026, 11, 30);
  ModelFieldState _appointment = const ModelFieldState();
  ModelFieldState _delivery = const ModelFieldState(value: '2026-11-19');
  ModelFieldState _review = const ModelFieldState(
    value: '2026-02-30',
    isValid: false,
    errorText: 'Selecciona una fecha válida.',
  );
  bool _largeText = false;

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
          onChanged: (bool? value) =>
              setState(() => _largeText = value ?? false),
        ),
        SizedBox(height: tokens.spacingSm),
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: _largeText ? const TextScaler.linear(2) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DsDateInputWidget(
                field: _appointment,
                label: 'Fecha de la cita',
                placeholder: 'Selecciona una fecha',
                helperText: 'Del 1 al 30 de noviembre de 2026.',
                required: true,
                requiredSemanticLabel: 'Obligatorio',
                firstDate: _firstDate,
                lastDate: _lastDate,
                onChangedAttempt: (ModelFieldState next) =>
                    setState(() => _appointment = next),
              ),
              SizedBox(height: tokens.spacing),
              DsDateInputWidget(
                field: _delivery,
                label: 'Fecha de entrega',
                firstDate: _firstDate,
                lastDate: _lastDate,
                onChangedAttempt: (ModelFieldState next) =>
                    setState(() => _delivery = next),
              ),
              SizedBox(height: tokens.spacing),
              DsDateInputWidget(
                field: _review,
                label: 'Fecha por corregir',
                firstDate: _firstDate,
                lastDate: _lastDate,
                onChangedAttempt: (ModelFieldState next) => setState(
                  () => _review = next.clearError().copyWith(isValid: true),
                ),
              ),
              SizedBox(height: tokens.spacing),
              DsDateInputWidget(
                field: const ModelFieldState(value: '2026-11-09'),
                label: 'Fecha registrada',
                firstDate: _firstDate,
                lastDate: _lastDate,
                onChangedAttempt: _ignoreTextAttempt,
                readOnly: true,
                readOnlySemanticLabel: 'Solo lectura',
              ),
              SizedBox(height: tokens.spacing),
              DsDateInputWidget(
                field: const ModelFieldState(value: '2026-11-30'),
                label: 'Fecha archivada',
                firstDate: _firstDate,
                lastDate: _lastDate,
                onChangedAttempt: _ignoreTextAttempt,
                enabled: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
