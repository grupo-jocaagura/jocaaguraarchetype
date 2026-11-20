part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _dateRangeInputEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.date_range_input',
    'DsDateRangeInputWidget',
    'Controlled calendar range field with inclusive bounds.',
    const <String>[
      'Store both endpoints as yyyy-MM-dd in a JSON object.',
      'Supply inclusive limits and allow a range to cover a single day.',
      'Accept confirmed ranges and supply validation in the form state.',
    ],
    const <String>[
      'textTheme.labelLarge',
      'textTheme.bodyLarge',
      'borderRadius',
    ],
  ),
  family: 'Forms',
  snippet: '''
DsDateRangeInputWidget(
  field: reservation,
  label: 'Periodo de reserva',
  placeholder: 'Selecciona un rango de fechas',
  firstDate: DateTime(2026, 11, 1),
  lastDate: DateTime(2027, 1, 31),
  onChangedAttempt: acceptReservation,
)''',
  preview: (BuildContext context) => Localizations.override(
    context: context,
    locale: const Locale('es'),
    delegates: GlobalMaterialLocalizations.delegates,
    child: const _DateRangeInputPreview(),
  ),
);

class _DateRangeInputPreview extends StatefulWidget {
  const _DateRangeInputPreview();

  @override
  State<_DateRangeInputPreview> createState() => _DateRangeInputPreviewState();
}

class _DateRangeInputPreviewState extends State<_DateRangeInputPreview> {
  final DateTime _firstDate = DateTime(2026, 11);
  final DateTime _lastDate = DateTime(2027, 1, 31);
  ModelFieldState _reservation = const ModelFieldState();
  ModelFieldState _delivery = const ModelFieldState(
    value: '{"start":"2026-12-31","end":"2027-01-03"}',
  );
  ModelFieldState _review = const ModelFieldState(
    value: '{"start":"2026-12-01"}',
    isValid: false,
    errorText: 'Selecciona las fechas de inicio y fin.',
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
          subtitle: const Text('El selector aplica un máximo del 130 %.'),
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
              DsDateRangeInputWidget(
                field: _reservation,
                label: 'Periodo de reserva',
                placeholder: 'Selecciona un rango de fechas',
                firstDate: _firstDate,
                lastDate: _lastDate,
                required: true,
                requiredSemanticLabel: 'Obligatorio',
                onChangedAttempt: (ModelFieldState next) =>
                    setState(() => _reservation = next),
              ),
              SizedBox(height: tokens.spacing),
              DsDateRangeInputWidget(
                field: _delivery,
                label: 'Periodo de entrega',
                firstDate: _firstDate,
                lastDate: _lastDate,
                onChangedAttempt: (ModelFieldState next) =>
                    setState(() => _delivery = next),
              ),
              SizedBox(height: tokens.spacing),
              DsDateRangeInputWidget(
                field: _review,
                label: 'Periodo por corregir',
                placeholder: 'Selecciona un rango de fechas',
                firstDate: _firstDate,
                lastDate: _lastDate,
                onChangedAttempt: (ModelFieldState next) => setState(
                  () => _review = next.clearError().copyWith(isValid: true),
                ),
              ),
              SizedBox(height: tokens.spacing),
              DsDateRangeInputWidget(
                field: const ModelFieldState(
                  value: '{"start":"2026-11-09","end":"2026-11-09"}',
                ),
                label: 'Periodo registrado',
                firstDate: _firstDate,
                lastDate: _lastDate,
                readOnly: true,
                readOnlySemanticLabel: 'Solo lectura',
                onChangedAttempt: _ignoreTextAttempt,
              ),
              SizedBox(height: tokens.spacing),
              DsDateRangeInputWidget(
                field: const ModelFieldState(
                  value: '{"start":"2026-11-01","end":"2026-11-07"}',
                ),
                label: 'Periodo archivado',
                firstDate: _firstDate,
                lastDate: _lastDate,
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
