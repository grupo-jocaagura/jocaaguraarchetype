part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _dropdownButtonEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.dropdown_button',
    'DsDropdownButtonWidget',
    'Borderless, controlled single selection from a list of options.',
    const <String>[
      'Provide a field label or an accessible name for an externally labeled control.',
      'Supply distinct, non-null option values and a localized placeholder.',
      'Provide ModelInteractiveState whenever the current value is non-null.',
      'Use InputDecorator when the layout calls for a field outline.',
    ],
    const <String>['textTheme.labelLarge', 'textTheme.bodyLarge', 'spacingSm'],
  ),
  family: 'Buttons',
  snippet: '''
DsDropdownButtonWidget<String>(
  label: 'Estado',
  value: status,
  state: status == null ? null : const ModelInteractiveState(),
  placeholder: 'Seleccionar estado',
  items: const [
    DropdownMenuItem(value: 'open', child: Text('Abierto')),
    DropdownMenuItem(value: 'closed', child: Text('Cerrado')),
  ],
  onChanged: onStatusChanged,
)''',
  preview: _buildDropdownButtonPreview,
);

Widget _buildDropdownButtonPreview(BuildContext context) {
  final ModelDsExtendedTokens tokens = context.dsTokens;
  String? status;
  String priority = 'normal';
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setPreviewState) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DsDropdownButtonWidget<String>(
          label: 'Estado',
          value: status,
          state: status == null ? null : const ModelInteractiveState(),
          placeholder: 'Seleccionar estado',
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(value: 'open', child: Text('Abierto')),
            DropdownMenuItem<String>(value: 'closed', child: Text('Cerrado')),
            DropdownMenuItem<String>(
              value: 'archived',
              enabled: false,
              child: Text('Archivado'),
            ),
          ],
          onChanged: (String value) => setPreviewState(() => status = value),
        ),
        SizedBox(height: tokens.spacing),
        InputDecorator(
          decoration: const InputDecoration(
            label: ExcludeSemantics(child: Text('Prioridad')),
            border: OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          child: DsDropdownButtonWidget<String>(
            semanticLabel: 'Prioridad',
            value: priority,
            state: const ModelInteractiveState(),
            isExpanded: true,
            placeholder: 'Seleccionar prioridad',
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(value: 'normal', child: Text('Normal')),
              DropdownMenuItem<String>(value: 'high', child: Text('Alta')),
            ],
            onChanged: (String value) =>
                setPreviewState(() => priority = value),
          ),
        ),
        SizedBox(height: tokens.spacing),
        const DsDropdownButtonWidget<String>(
          label: 'Categoría',
          value: null,
          items: <DropdownMenuItem<String>>[],
          placeholder: 'Sin categorías disponibles',
          onChanged: _onExampleSelection,
        ),
        SizedBox(height: tokens.spacing),
        const Text('Texto ampliado al 200 %'),
        SizedBox(height: tokens.spacingXs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: MediaQuery.withClampedTextScaling(
            minScaleFactor: 2,
            maxScaleFactor: 2,
            child: const DsDropdownButtonWidget<String>(
              label: 'Periodo',
              value: 'quarter',
              state: ModelInteractiveState(),
              placeholder: 'Seleccionar periodo',
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: 'quarter',
                  child: Text('Último trimestre del año'),
                ),
              ],
              onChanged: _onExampleSelection,
            ),
          ),
        ),
      ],
    ),
  );
}

void _onExampleSelection(String value) {}
