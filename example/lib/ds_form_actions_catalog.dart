part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _formActionsEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.form_actions',
    'DsFormActionsWidget',
    'Adaptive form actions with independent states.',
    const <String>[
      'Place the secondary action first and the primary action last.',
      'Omit the secondary label to show only the primary action.',
      'Control visibility, availability and loading for each action.',
    ],
    const <String>['textTheme.labelLarge', 'spacingSm'],
  ),
  family: 'Forms',
  snippet: '''
DsFormActionsWidget(
  primaryLabel: 'Guardar',
  onPrimary: save,
  primaryState: saveState,
  primaryLoadingSemanticLabel: 'Guardando',
  secondaryLabel: 'Cancelar',
  onSecondary: cancel,
  secondaryState: cancelState,
  secondaryLoadingSemanticLabel: 'Cancelando',
)''',
  preview: (BuildContext context) => const _FormActionsPreview(),
);

class _FormActionsPreview extends StatefulWidget {
  const _FormActionsPreview();

  @override
  State<_FormActionsPreview> createState() => _FormActionsPreviewState();
}

class _FormActionsPreviewState extends State<_FormActionsPreview> {
  bool _largeText = false;
  Timer? _saveTimer;
  Timer? _cancelTimer;
  String? _result;

  @override
  void dispose() {
    _saveTimer?.cancel();
    _cancelTimer?.cancel();
    super.dispose();
  }

  Timer _completeAfterDelay(String result) =>
      Timer(const Duration(seconds: 4), () => setState(() => _result = result));

  void _save() {
    _saveTimer?.cancel();
    setState(() => _saveTimer = _completeAfterDelay('Cambios guardados'));
  }

  void _cancel() {
    _cancelTimer?.cancel();
    setState(() => _cancelTimer = _completeAfterDelay('Edición cancelada'));
  }

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
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: _largeText ? const TextScaler.linear(2) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const DsTextParagraphWidget(label: 'Carga por acción'),
              SizedBox(height: tokens.spacingSm),
              DsFormActionsWidget(
                primaryLabel: 'Guardar todos los cambios',
                onPrimary: _save,
                primaryState: ModelInteractiveState(
                  semantic: ModelInteractiveSemantic.primary,
                  isLoading: _saveTimer?.isActive ?? false,
                ),
                primaryLoadingSemanticLabel: 'Guardando',
                secondaryLabel: 'Cancelar edición',
                onSecondary: _cancel,
                secondaryState: ModelInteractiveState(
                  semantic: ModelInteractiveSemantic.secondary,
                  isLoading: _cancelTimer?.isActive ?? false,
                ),
                secondaryLoadingSemanticLabel: 'Cancelando',
              ),
              if (_result case final String result) ...<Widget>[
                SizedBox(height: tokens.spacingSm),
                Semantics(liveRegion: true, child: Text(result)),
              ],
              SizedBox(height: tokens.spacing),
              const DsTextParagraphWidget(label: 'Una sola acción visible'),
              SizedBox(height: tokens.spacingSm),
              DsFormActionsWidget(
                primaryLabel: 'Enviar formulario',
                onPrimary: () => setState(() => _result = 'Formulario enviado'),
                secondaryLabel: 'Volver',
                secondaryState: const ModelInteractiveState(isVisible: false),
              ),
              SizedBox(height: tokens.spacing),
              const DsTextParagraphWidget(label: 'Secundaria deshabilitada'),
              SizedBox(height: tokens.spacingSm),
              DsFormActionsWidget(
                primaryLabel: 'Continuar',
                onPrimary: () =>
                    setState(() => _result = 'Formulario guardado'),
                secondaryLabel: 'Restablecer',
                onSecondary: () =>
                    setState(() => _result = 'Valores restablecidos'),
                secondaryState: const ModelInteractiveState(
                  isEnabled: false,
                  semantic: ModelInteractiveSemantic.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
