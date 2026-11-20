part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _formStepperEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.form_stepper',
    'DsFormStepperWidget',
    'Controlled linear form with one active step.',
    const <String>[
      'Give each step a stable ID and a localized title.',
      'Keep field values and errors in the form and accept requests after validation.',
      'Set the primary action to loading while validating or submitting.',
    ],
    const <String>['textTheme.titleLarge', 'textTheme.labelLarge', 'spacing'],
  ),
  family: 'Forms',
  snippet: '''
DsFormStepperWidget(
  steps: steps,
  activeStepId: activeStepId,
  onStepChangeAttempt: validateStepChange,
  onFinishAttempt: submitForm,
  primaryState: submitState,
)''',
  preview: (BuildContext context) => const _FormStepperPreview(),
);

class _FormStepperPreview extends StatefulWidget {
  const _FormStepperPreview();

  @override
  State<_FormStepperPreview> createState() => _FormStepperPreviewState();
}

class _FormStepperPreviewState extends State<_FormStepperPreview> {
  static const String _contactStep = 'contact';
  static const String _detailsStep = 'details';

  String _activeStepId = _contactStep;
  ModelFieldState _name = const ModelFieldState();
  ModelFieldState _reason = const ModelFieldState();
  bool _largeText = false;
  bool _submitting = false;
  bool _submitted = false;
  Timer? _submitTimer;

  @override
  void dispose() {
    _submitTimer?.cancel();
    super.dispose();
  }

  void _requestStep(String destination) {
    if (_submitting) {
      return;
    }
    if (destination == _detailsStep && _name.value.trim().isEmpty) {
      setState(() {
        _name = _name.copyWith(
          isDirty: true,
          isValid: false,
          errorText: 'Escribe tu nombre.',
        );
      });
      return;
    }
    setState(() {
      _activeStepId = destination;
      _submitted = false;
    });
  }

  void _requestFinish() {
    if (_submitting) {
      return;
    }
    if (_reason.value.trim().length < 3) {
      setState(() {
        _reason = _reason.copyWith(
          isDirty: true,
          isValid: false,
          errorText: 'Escribe al menos tres caracteres.',
        );
        _submitted = false;
      });
      return;
    }
    setState(() {
      _submitting = true;
      _submitted = false;
    });
    _submitTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _submitting = false;
        _submitted = true;
      });
    });
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
        SizedBox(height: tokens.spacingSm),
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: _largeText ? const TextScaler.linear(2) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DsFormStepperWidget(
                activeStepId: _activeStepId,
                primaryState: ModelInteractiveState(
                  isLoading: _submitting,
                  semantic: ModelInteractiveSemantic.primary,
                ),
                previousLabel: 'Atrás',
                continueLabel: 'Continuar',
                finishLabel: 'Finalizar',
                loadingSemanticLabel: 'Enviando',
                progressLabelBuilder: (int step, int total) =>
                    'Paso $step de $total',
                onStepChangeAttempt: _requestStep,
                onFinishAttempt: _requestFinish,
                steps: <DsFormStep>[
                  DsFormStep(
                    id: _contactStep,
                    title: 'Datos de contacto',
                    content: DsTextInputWidget(
                      field: _name,
                      label: 'Nombre',
                      required: true,
                      requiredSemanticLabel: 'Obligatorio',
                      enabled: !_submitting,
                      onChangedAttempt: (ModelFieldState next) => setState(
                        () =>
                            _name = next.copyWith(isValid: true, errorText: ''),
                      ),
                    ),
                  ),
                  DsFormStep(
                    id: _detailsStep,
                    title: 'Detalle de la solicitud',
                    content: DsTextInputWidget(
                      field: _reason,
                      label: 'Motivo',
                      required: true,
                      requiredSemanticLabel: 'Obligatorio',
                      enabled: !_submitting,
                      onChangedAttempt: (ModelFieldState next) => setState(
                        () => _reason = next.copyWith(
                          isValid: true,
                          errorText: '',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_submitted) ...<Widget>[
                SizedBox(height: tokens.spacingSm),
                Semantics(
                  liveRegion: true,
                  child: const Text('Formulario de ejemplo enviado.'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
