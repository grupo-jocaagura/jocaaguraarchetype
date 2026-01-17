part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Panel transversal para editar tokens (usa dsBloc.patchTokens).
/// Incluye un bloque superior con mini-previews para ver el impacto inmediato.
///
/// ✅ A prueba de fallos:
/// - Nunca tumba la UI si el DS entra en Left (usa requireDs + lastGoodDs en bloc).
/// - DRY-RUN (copyWith) antes de hacer commit al DS.
/// - Banner de error local (warning) sin romper render.
/// - Listener key único por instancia.
/// - Debouncers con guardia de dispose para evitar callbacks post-dispose.
class DsTokenEditorWidget extends StatefulWidget {
  const DsTokenEditorWidget({
    required this.dsBloc,
    super.key,
  });

  final BlocDesignSystem dsBloc;

  @override
  State<DsTokenEditorWidget> createState() => _DsTokenEditorWidgetState();
}

class _DsTokenEditorWidgetState extends State<DsTokenEditorWidget> {
  late final String _listenerKey;

  late ModelDsExtendedTokens _tokens;
  ErrorItem? _localError;

  @override
  void initState() {
    super.initState();

    _listenerKey = 'DsTokenEditorWidget.${identityHashCode(this)}';
    _tokens = widget.dsBloc.requireDs().tokens;

    widget.dsBloc.addDsListener(
      _listenerKey,
      (ModelDesignSystem ds) {
        if (!mounted) {
          return;
        }
        if (ds.tokens == _tokens) {
          return;
        }
        setState(() {
          _tokens = ds.tokens;
          _localError = null;
        });
      },
      true,
    );
  }

  @override
  void dispose() {
    if (widget.dsBloc.hasListener(_listenerKey)) {
      widget.dsBloc.removeListener(_listenerKey);
    }
    super.dispose();
  }

  void _patchTokens({
    double? borderRadiusXs,
    double? borderRadiusSm,
    double? borderRadius,
    double? borderRadiusLg,
    double? borderRadiusXl,
    double? borderRadiusXXl,
    double? spacingXs,
    double? spacingSm,
    double? spacing,
    double? spacingLg,
    double? spacingXl,
    double? spacingXXl,
    double? elevationXs,
    double? elevationSm,
    double? elevation,
    double? elevationLg,
    double? elevationXl,
    double? elevationXXl,
    double? withAlphaXs,
    double? withAlphaSm,
    double? withAlpha,
    double? withAlphaLg,
    double? withAlphaXl,
    double? withAlphaXXl,
    Duration? animationDurationShort,
    Duration? animationDuration,
    Duration? animationDurationLong,
  }) {
    final ModelDsExtendedTokens base = _tokens;

    try {
      // DRY-RUN: valida sin tocar el DS (copyWith ejecuta validadores).
      base.copyWith(
        borderRadiusXs: borderRadiusXs,
        borderRadiusSm: borderRadiusSm,
        borderRadius: borderRadius,
        borderRadiusLg: borderRadiusLg,
        borderRadiusXl: borderRadiusXl,
        borderRadiusXXl: borderRadiusXXl,
        spacingXs: spacingXs,
        spacingSm: spacingSm,
        spacing: spacing,
        spacingLg: spacingLg,
        spacingXl: spacingXl,
        spacingXXl: spacingXXl,
        elevationXs: elevationXs,
        elevationSm: elevationSm,
        elevation: elevation,
        elevationLg: elevationLg,
        elevationXl: elevationXl,
        elevationXXl: elevationXXl,
        withAlphaXs: withAlphaXs,
        withAlphaSm: withAlphaSm,
        withAlpha: withAlpha,
        withAlphaLg: withAlphaLg,
        withAlphaXl: withAlphaXl,
        withAlphaXXl: withAlphaXXl,
        animationDurationShort: animationDurationShort,
        animationDuration: animationDuration,
        animationDurationLong: animationDurationLong,
      );

      if (!mounted) {
        return;
      }
      setState(() => _localError = null);

      widget.dsBloc.patchTokens(
        borderRadiusXs: borderRadiusXs,
        borderRadiusSm: borderRadiusSm,
        borderRadius: borderRadius,
        borderRadiusLg: borderRadiusLg,
        borderRadiusXl: borderRadiusXl,
        borderRadiusXXl: borderRadiusXXl,
        spacingXs: spacingXs,
        spacingSm: spacingSm,
        spacing: spacing,
        spacingLg: spacingLg,
        spacingXl: spacingXl,
        spacingXXl: spacingXXl,
        elevationXs: elevationXs,
        elevationSm: elevationSm,
        elevation: elevation,
        elevationLg: elevationLg,
        elevationXl: elevationXl,
        elevationXXl: elevationXXl,
        withAlphaXs: withAlphaXs,
        withAlphaSm: withAlphaSm,
        withAlpha: withAlpha,
        withAlphaLg: withAlphaLg,
        withAlphaXl: withAlphaXl,
        withAlphaXXl: withAlphaXXl,
        animationDurationShort: animationDurationShort,
        animationDuration: animationDuration,
        animationDurationLong: animationDurationLong,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _localError = ErrorItem(
          title: 'Invalid token values',
          code: 'DS_TOKENS_INVALID',
          description: e.toString(),
          errorLevel: ErrorLevelEnum.warning,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final ColorScheme cs = t.colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(_tokens.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Tokens editor', style: t.textTheme.titleLarge),
            SizedBox(height: _tokens.spacingXs),
            Text(
              'Edita valores numéricos y verás el cambio reflejado en el preview.',
              style: t.textTheme.bodySmall,
            ),
            SizedBox(height: _tokens.spacingSm),
            if (_localError != null)
              Card(
                color: cs.errorContainer,
                child: Padding(
                  padding: EdgeInsets.all(_tokens.spacingSm),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: cs.onErrorContainer),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.warning_amber_rounded,
                          color: cs.onErrorContainer,
                        ),
                        SizedBox(width: _tokens.spacingSm),
                        Expanded(
                          child: Text(
                            _localError!.description,
                            style: t.textTheme.bodySmall
                                ?.copyWith(color: cs.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(height: _tokens.spacing),
            _DsTokenPreviewRow(
              tokens: _tokens,
              primary: cs.primary,
              onSurface: cs.onSurface,
              surface: cs.surface,
            ),
            SizedBox(height: _tokens.spacing),
            const _SectionHeader(title: 'Spacing'),
            SizedBox(height: _tokens.spacingXs),
            Wrap(
              spacing: _tokens.spacingSm,
              runSpacing: _tokens.spacingSm,
              children: <Widget>[
                DsTokenDoubleEditWidget(
                  label: 'spacingXs',
                  value: _tokens.spacingXs,
                  onChangedAttempt: (double v) => _patchTokens(spacingXs: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'spacingSm',
                  value: _tokens.spacingSm,
                  onChangedAttempt: (double v) => _patchTokens(spacingSm: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'spacing',
                  value: _tokens.spacing,
                  onChangedAttempt: (double v) => _patchTokens(spacing: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'spacingLg',
                  value: _tokens.spacingLg,
                  onChangedAttempt: (double v) => _patchTokens(spacingLg: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'spacingXl',
                  value: _tokens.spacingXl,
                  onChangedAttempt: (double v) => _patchTokens(spacingXl: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'spacingXXl',
                  value: _tokens.spacingXXl,
                  onChangedAttempt: (double v) => _patchTokens(spacingXXl: v),
                  min: 0,
                ),
              ],
            ),
            SizedBox(height: _tokens.spacing),
            const _SectionHeader(title: 'Border radius'),
            SizedBox(height: _tokens.spacingXs),
            Wrap(
              spacing: _tokens.spacingSm,
              runSpacing: _tokens.spacingSm,
              children: <Widget>[
                DsTokenDoubleEditWidget(
                  label: 'borderRadiusXs',
                  value: _tokens.borderRadiusXs,
                  onChangedAttempt: (double v) =>
                      _patchTokens(borderRadiusXs: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'borderRadiusSm',
                  value: _tokens.borderRadiusSm,
                  onChangedAttempt: (double v) =>
                      _patchTokens(borderRadiusSm: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'borderRadius',
                  value: _tokens.borderRadius,
                  onChangedAttempt: (double v) => _patchTokens(borderRadius: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'borderRadiusLg',
                  value: _tokens.borderRadiusLg,
                  onChangedAttempt: (double v) =>
                      _patchTokens(borderRadiusLg: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'borderRadiusXl',
                  value: _tokens.borderRadiusXl,
                  onChangedAttempt: (double v) =>
                      _patchTokens(borderRadiusXl: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'borderRadiusXXl',
                  value: _tokens.borderRadiusXXl,
                  onChangedAttempt: (double v) =>
                      _patchTokens(borderRadiusXXl: v),
                  min: 0,
                ),
              ],
            ),
            SizedBox(height: _tokens.spacing),
            const _SectionHeader(title: 'Elevation'),
            SizedBox(height: _tokens.spacingXs),
            Wrap(
              spacing: _tokens.spacingSm,
              runSpacing: _tokens.spacingSm,
              children: <Widget>[
                DsTokenDoubleEditWidget(
                  label: 'elevationXs',
                  value: _tokens.elevationXs,
                  onChangedAttempt: (double v) => _patchTokens(elevationXs: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'elevationSm',
                  value: _tokens.elevationSm,
                  onChangedAttempt: (double v) => _patchTokens(elevationSm: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'elevation',
                  value: _tokens.elevation,
                  onChangedAttempt: (double v) => _patchTokens(elevation: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'elevationLg',
                  value: _tokens.elevationLg,
                  onChangedAttempt: (double v) => _patchTokens(elevationLg: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'elevationXl',
                  value: _tokens.elevationXl,
                  onChangedAttempt: (double v) => _patchTokens(elevationXl: v),
                  min: 0,
                ),
                DsTokenDoubleEditWidget(
                  label: 'elevationXXl',
                  value: _tokens.elevationXXl,
                  onChangedAttempt: (double v) => _patchTokens(elevationXXl: v),
                  min: 0,
                ),
              ],
            ),
            SizedBox(height: _tokens.spacing),
            const _SectionHeader(title: 'Alpha presets (0..1)'),
            SizedBox(height: _tokens.spacingXs),
            Wrap(
              spacing: _tokens.spacingSm,
              runSpacing: _tokens.spacingSm,
              children: <Widget>[
                DsTokenDoubleEditWidget(
                  label: 'withAlphaXs',
                  value: _tokens.withAlphaXs,
                  onChangedAttempt: (double v) => _patchTokens(withAlphaXs: v),
                  min: 0,
                  max: 1,
                ),
                DsTokenDoubleEditWidget(
                  label: 'withAlphaSm',
                  value: _tokens.withAlphaSm,
                  onChangedAttempt: (double v) => _patchTokens(withAlphaSm: v),
                  min: 0,
                  max: 1,
                ),
                DsTokenDoubleEditWidget(
                  label: 'withAlpha',
                  value: _tokens.withAlpha,
                  onChangedAttempt: (double v) => _patchTokens(withAlpha: v),
                  min: 0,
                  max: 1,
                ),
                DsTokenDoubleEditWidget(
                  label: 'withAlphaLg',
                  value: _tokens.withAlphaLg,
                  onChangedAttempt: (double v) => _patchTokens(withAlphaLg: v),
                  min: 0,
                  max: 1,
                ),
                DsTokenDoubleEditWidget(
                  label: 'withAlphaXl',
                  value: _tokens.withAlphaXl,
                  onChangedAttempt: (double v) => _patchTokens(withAlphaXl: v),
                  min: 0,
                  max: 1,
                ),
                DsTokenDoubleEditWidget(
                  label: 'withAlphaXXl',
                  value: _tokens.withAlphaXXl,
                  onChangedAttempt: (double v) => _patchTokens(withAlphaXXl: v),
                  min: 0,
                  max: 1,
                ),
              ],
            ),
            SizedBox(height: _tokens.spacing),
            const _SectionHeader(title: 'Animation durations (ms)'),
            SizedBox(height: _tokens.spacingXs),
            Wrap(
              spacing: _tokens.spacingSm,
              runSpacing: _tokens.spacingSm,
              children: <Widget>[
                DsTokenDurationEditWidget(
                  label: 'animationDurationShort',
                  value: _tokens.animationDurationShort,
                  onChangedAttempt: (Duration d) =>
                      _patchTokens(animationDurationShort: d),
                ),
                DsTokenDurationEditWidget(
                  label: 'animationDuration',
                  value: _tokens.animationDuration,
                  onChangedAttempt: (Duration d) =>
                      _patchTokens(animationDuration: d),
                ),
                DsTokenDurationEditWidget(
                  label: 'animationDurationLong',
                  value: _tokens.animationDurationLong,
                  onChangedAttempt: (Duration d) =>
                      _patchTokens(animationDurationLong: d),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// PREVIEW widgets (ejemplos de uso de tokens)
/// ---------------------------------------------------------------------------

class _DsTokenPreviewRow extends StatefulWidget {
  const _DsTokenPreviewRow({
    required this.tokens,
    required this.primary,
    required this.onSurface,
    required this.surface,
  });

  final ModelDsExtendedTokens tokens;
  final Color primary;
  final Color onSurface;
  final Color surface;

  @override
  State<_DsTokenPreviewRow> createState() => _DsTokenPreviewRowState();
}

class _DsTokenPreviewRowState extends State<_DsTokenPreviewRow> {
  bool _toggled = false;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tok = widget.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionHeader(title: 'Token usage preview'),
        SizedBox(height: tok.spacingXs),
        Wrap(
          spacing: tok.spacingSm,
          runSpacing: tok.spacingSm,
          children: <Widget>[
            // Padding + radius
            Container(
              width: 220,
              padding: EdgeInsets.all(tok.spacingSm),
              decoration: BoxDecoration(
                color: widget.surface,
                borderRadius: BorderRadius.circular(tok.borderRadius),
                border: Border.all(
                  color: widget.onSurface.withAlpha(
                    (255 * tok.withAlphaSm).round().clamp(0, 255),
                  ),
                ),
              ),
              child: Text(
                'Padding: spacingSm\nRadius: borderRadius\nAlpha: withAlphaSm',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

            // Elevation
            Material(
              elevation: tok.elevation,
              borderRadius: BorderRadius.circular(tok.borderRadiusSm),
              color: widget.surface,
              child: SizedBox(
                width: 220,
                child: Padding(
                  padding: EdgeInsets.all(tok.spacingSm),
                  child: Text(
                    'Elevation: elevation\nRadius: borderRadiusSm',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),

            // Animation duration
            InkWell(
              onTap: () => setState(() => _toggled = !_toggled),
              borderRadius: BorderRadius.circular(tok.borderRadiusSm),
              child: AnimatedContainer(
                duration: tok.animationDuration,
                curve: Curves.easeOut,
                width: _toggled ? 220 : 140,
                height: 54,
                decoration: BoxDecoration(
                  color: widget.primary.withAlpha(
                    (255 * tok.withAlphaLg).round().clamp(0, 255),
                  ),
                  borderRadius: BorderRadius.circular(tok.borderRadiusSm),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Tap • duration=animationDuration',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: widget.onSurface),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// Editable fields (transversales)
/// ---------------------------------------------------------------------------

class DsTokenDoubleEditWidget extends StatefulWidget {
  const DsTokenDoubleEditWidget({
    required this.label,
    required this.value,
    required this.onChangedAttempt,
    this.min,
    this.max,
    super.key,
  });

  final String label;
  final double value;
  final void Function(double v) onChangedAttempt;
  final double? min;
  final double? max;

  @override
  State<DsTokenDoubleEditWidget> createState() =>
      _DsTokenDoubleEditWidgetState();
}

class _DsTokenDoubleEditWidgetState extends State<DsTokenDoubleEditWidget> {
  late final BlocGeneral<ModelFieldState> _state;
  final Debouncer _debouncer = Debouncer(milliseconds: 250);
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _state = BlocGeneral<ModelFieldState>(
      ModelFieldState(value: widget.value.toStringAsFixed(2)),
    );
  }

  @override
  void didUpdateWidget(covariant DsTokenDoubleEditWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final ModelFieldState next = _state.value.copyWith(
        value: widget.value.toStringAsFixed(2),
        isDirty: false,
        isValid: true,
      );
      if (next != _state.value) {
        _state.value = next;
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _state.dispose();
    super.dispose();
  }

  void _onChangeAttempt(String raw) {
    final String txt = raw.trim();
    final double? parsed = double.tryParse(txt.replaceAll(',', '.'));
    final double? min = widget.min;
    final double? max = widget.max;

    bool isValid = parsed != null;
    String? err;

    if (!isValid) {
      err = 'Expected number';
    } else {
      if (min != null && parsed < min) {
        isValid = false;
        err = 'Min $min';
      }
      if (max != null && parsed > max) {
        isValid = false;
        err = 'Max $max';
      }
    }

    final ModelFieldState next = _state.value.copyWith(
      value: txt,
      errorText: isValid ? null : err,
      isDirty: true,
      isValid: isValid,
    );
    if (next != _state.value) {
      _state.value = next;
    }

    if (isValid) {
      _debouncer.call(() {
        if (_isDisposed) {
          return;
        }
        widget.onChangedAttempt(parsed!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: StreamBuilder<ModelFieldState>(
        stream: _state.stream,
        builder: (_, __) {
          final ModelFieldState s = _state.value;
          return JocaaguraAutocompleteInputWidget(
            label: widget.label,
            value: s.value,
            errorText: s.errorTextToInput,
            onChangedAttempt: _onChangeAttempt,
            onSubmittedAttempt: _onChangeAttempt,
            placeholder: widget.max == 1 ? '0.00 .. 1.00' : 'e.g. 12.0',
            semanticsLabel: 'Token ${widget.label}',
          );
        },
      ),
    );
  }
}

class DsTokenDurationEditWidget extends StatefulWidget {
  const DsTokenDurationEditWidget({
    required this.label,
    required this.value,
    required this.onChangedAttempt,
    this.minMs = 0,
    super.key,
  });

  final String label;
  final Duration value;
  final int minMs;
  final void Function(Duration d) onChangedAttempt;

  @override
  State<DsTokenDurationEditWidget> createState() =>
      _DsTokenDurationEditWidgetState();
}

class _DsTokenDurationEditWidgetState extends State<DsTokenDurationEditWidget> {
  late final BlocGeneral<ModelFieldState> _state;
  final Debouncer _debouncer = Debouncer(milliseconds: 250);
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _state = BlocGeneral<ModelFieldState>(
      ModelFieldState(value: widget.value.inMilliseconds.toString()),
    );
  }

  @override
  void didUpdateWidget(covariant DsTokenDurationEditWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final ModelFieldState next = _state.value.copyWith(
        value: widget.value.inMilliseconds.toString(),
        isDirty: false,
        isValid: true,
      );
      if (next != _state.value) {
        _state.value = next;
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _state.dispose();
    super.dispose();
  }

  void _onChangeAttempt(String raw) {
    final String txt = raw.trim();
    final int? ms = int.tryParse(txt);
    final bool isValid = ms != null && ms >= widget.minMs;
    final String? err = isValid ? null : 'Min ${widget.minMs} ms';

    final ModelFieldState next = _state.value.copyWith(
      value: txt,
      errorText: err,
      isDirty: true,
      isValid: isValid,
    );
    if (next != _state.value) {
      _state.value = next;
    }

    if (isValid) {
      _debouncer.call(() {
        if (_isDisposed) {
          return;
        }
        widget.onChangedAttempt(Duration(milliseconds: ms));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: StreamBuilder<ModelFieldState>(
        stream: _state.stream,
        builder: (_, __) {
          final ModelFieldState s = _state.value;
          return JocaaguraAutocompleteInputWidget(
            label: widget.label,
            value: s.value,
            errorText: s.errorText,
            onChangedAttempt: _onChangeAttempt,
            onSubmittedAttempt: _onChangeAttempt,
            placeholder: 'milliseconds (e.g. 250)',
            semanticsLabel: 'Token ${widget.label} duration',
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Minor UI helper
/// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
