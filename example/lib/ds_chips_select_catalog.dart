part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _chipsSelectEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.chips_select',
    'DsChipsSelectWidget',
    'Visible multiple-selection chips controlled by ModelFieldState.',
    const <String>[
      'Store a JSON array of string option keys.',
      'Tap a chip or use Space to propose a selection change.',
      'Accept proposed keys and supply validation in the form state.',
    ],
    const <String>[
      'chipTheme',
      'textTheme.labelLarge',
      'textTheme.bodySmall',
      'colorScheme.error',
      'spacingXs',
      'spacingSm',
    ],
  ),
  family: 'Forms',
  snippet: '''
DsChipsSelectWidget(
  field: capabilities,
  label: 'Capacidades de la tienda',
  options: const ['catalog', 'inventory'],
  optionLabelBuilder: (key) => key == 'catalog' ? 'Catálogo' : 'Inventario',
  onChangedAttempt: acceptCapabilities,
)''',
  preview: (BuildContext context) => const _ChipsSelectPreview(),
);

class _ChipsSelectPreview extends StatefulWidget {
  const _ChipsSelectPreview();

  @override
  State<_ChipsSelectPreview> createState() => _ChipsSelectPreviewState();
}

class _ChipsSelectPreviewState extends State<_ChipsSelectPreview> {
  static const List<String> _options = <String>[
    'catalog',
    'inventory',
    'reports',
  ];
  static const String _error = 'Selecciona al menos un canal de entrega.';
  ModelFieldState _capabilities = const ModelFieldState(
    value: '["catalog","reports"]',
  );
  ModelFieldState _channels = const ModelFieldState(
    isValid: false,
    errorText: _error,
  );
  bool _largeText = false;

  static String _capabilityLabel(String key) => switch (key) {
    'catalog' => 'Catálogo',
    'inventory' => 'Inventario',
    _ => 'Informes diarios de operaciones y movimientos de inventario',
  };

  static String _channelLabel(String key) =>
      key == 'store' ? 'Tienda' : 'Domicilio';

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
              DsChipsSelectWidget(
                field: _capabilities,
                label: 'Capacidades de la tienda',
                options: _options,
                optionLabelBuilder: _capabilityLabel,
                onChangedAttempt: (ModelFieldState next) =>
                    setState(() => _capabilities = next),
              ),
              SizedBox(height: tokens.spacing),
              DsChipsSelectWidget(
                field: _channels,
                label: 'Canales de entrega',
                options: const <String>['store', 'delivery'],
                optionLabelBuilder: _channelLabel,
                required: true,
                requiredSemanticLabel: 'Obligatorio',
                onChangedAttempt: (ModelFieldState next) => setState(() {
                  final bool hasChannel = next.value != '[]';
                  _channels = next.copyWith(
                    isValid: hasChannel,
                    errorText: hasChannel ? '' : _error,
                  );
                }),
              ),
              SizedBox(height: tokens.spacing),
              const DsChipsSelectWidget(
                field: ModelFieldState(),
                label: 'Opciones de temporada',
                options: <String>[],
                emptyMessage: 'Sin opciones disponibles',
                onChangedAttempt: _ignoreTextAttempt,
              ),
              SizedBox(height: tokens.spacing),
              const DsChipsSelectWidget(
                field: ModelFieldState(value: '["catalog"]'),
                label: 'Capacidades registradas',
                options: <String>['catalog', 'inventory'],
                optionLabelBuilder: _capabilityLabel,
                readOnly: true,
                readOnlySemanticLabel: 'Solo lectura',
                onChangedAttempt: _ignoreTextAttempt,
              ),
              SizedBox(height: tokens.spacing),
              const DsChipsSelectWidget(
                field: ModelFieldState(value: '["inventory"]'),
                label: 'Capacidades archivadas',
                options: <String>['catalog', 'inventory'],
                optionLabelBuilder: _capabilityLabel,
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
