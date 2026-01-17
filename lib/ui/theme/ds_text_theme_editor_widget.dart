part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Panel transversal para editar TextTheme (usa dsBloc.patchThemeTextTheme).
/// Seguro ante cambios de Theme/DS (no depende de Theme.of en initState).
class DsTextThemeEditorWidget extends StatefulWidget {
  const DsTextThemeEditorWidget({
    required this.dsBloc,
    super.key,
  });

  final BlocDesignSystem dsBloc;

  @override
  State<DsTextThemeEditorWidget> createState() =>
      _DsTextThemeEditorWidgetState();
}

class _DsTextThemeEditorWidgetState extends State<DsTextThemeEditorWidget> {
  static const String _listenerKey = 'DsTextThemeEditorWidget.listener';

  DsThemeTarget _applyTarget = DsThemeTarget.both;
  DsTextStyleKey _selected = DsTextStyleKey.bodyMedium;

  TextTheme _current = const TextTheme();
  bool _hasScheduledSync = false;

  @override
  void initState() {
    super.initState();

    // IMPORTANTE:
    // - NO llamar Theme.of(context) aquí.
    // - NO ejecutar "executeNow" porque el callback corre antes de que initState termine.
    widget.dsBloc.addDsListener(_listenerKey, (_) {
      _scheduleThemeSync();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Aquí sí es seguro leer Theme.of(context)
    _syncFromTheme();
  }

  void _scheduleThemeSync() {
    if (!mounted) {
      return;
    }
    if (_hasScheduledSync) {
      return;
    }
    _hasScheduledSync = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hasScheduledSync = false;
      if (!mounted) {
        return;
      }
      _syncFromTheme();
    });
  }

  void _syncFromTheme() {
    final ThemeData t = Theme.of(context);
    final TextTheme next = t.textTheme;

    if (next == _current) {
      return;
    }
    setState(() => _current = next);
  }

  @override
  void dispose() {
    if (widget.dsBloc.hasListener(_listenerKey)) {
      widget.dsBloc.removeListener(_listenerKey);
    }
    super.dispose();
  }

  void _patchSelectedStyle(TextStyle Function(TextStyle current) builder) {
    final DsTextStyleKey key = _selected;
    final DsThemeTarget target = _applyTarget;

    widget.dsBloc.patchThemeTextTheme(
      target: target,
      builder: (TextTheme tt) {
        final TextStyle base = key.get(tt) ?? const TextStyle();
        final TextStyle next = builder(base);
        return key.set(tt, next);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final ModelDsExtendedTokens tok = context.dsTokens;

    final TextStyle previewStyle =
        _selected.get(_current) ?? const TextStyle(fontSize: 14);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tok.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('TextTheme editor', style: t.textTheme.titleLarge),
            SizedBox(height: tok.spacingXs),
            Text(
              'Edita estilos tipográficos del DS (size/weight/spacing/height/italic).',
              style: t.textTheme.bodySmall,
            ),
            SizedBox(height: tok.spacing),
            _TextThemePreview(
              title: _selected.label,
              style: previewStyle,
            ),
            SizedBox(height: tok.spacing),
            Wrap(
              spacing: tok.spacingSm,
              runSpacing: tok.spacingSm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                _DsDropdown<DsTextStyleKey>(
                  label: 'Style',
                  value: _selected,
                  items: DsTextStyleKey.values,
                  toLabel: (DsTextStyleKey v) => v.label,
                  onChanged: (DsTextStyleKey v) =>
                      setState(() => _selected = v),
                ),
                _DsDropdown<DsThemeTarget>(
                  label: 'Apply to',
                  value: _applyTarget,
                  items: const <DsThemeTarget>[
                    DsThemeTarget.light,
                    DsThemeTarget.dark,
                    DsThemeTarget.both,
                  ],
                  toLabel: (DsThemeTarget v) => v.name,
                  onChanged: (DsThemeTarget v) =>
                      setState(() => _applyTarget = v),
                ),
              ],
            ),
            SizedBox(height: tok.spacing),
            Wrap(
              spacing: tok.spacingSm,
              runSpacing: tok.spacingSm,
              children: <Widget>[
                _DsTextStyleDoubleField(
                  label: 'fontSize',
                  value: previewStyle.fontSize,
                  placeholder: 'e.g. 14',
                  onChangedAttempt: (double? v) => _patchSelectedStyle(
                    (TextStyle s) => s.copyWith(fontSize: v),
                  ),
                ),
                _DsTextStyleDoubleField(
                  label: 'letterSpacing',
                  value: previewStyle.letterSpacing,
                  placeholder: 'e.g. 0.2',
                  onChangedAttempt: (double? v) => _patchSelectedStyle(
                    (TextStyle s) => s.copyWith(letterSpacing: v),
                  ),
                ),
                _DsTextStyleDoubleField(
                  label: 'height',
                  value: previewStyle.height,
                  placeholder: 'e.g. 1.2',
                  onChangedAttempt: (double? v) => _patchSelectedStyle(
                    (TextStyle s) => s.copyWith(height: v),
                  ),
                ),
                _DsFontWeightField(
                  value: previewStyle.fontWeight,
                  onChangedAttempt: (FontWeight? w) => _patchSelectedStyle(
                    (TextStyle s) => s.copyWith(fontWeight: w),
                  ),
                ),
              ],
            ),
            SizedBox(height: tok.spacingSm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Italic'),
              value: (previewStyle.fontStyle ?? FontStyle.normal) ==
                  FontStyle.italic,
              onChanged: (bool v) => _patchSelectedStyle(
                (TextStyle s) => s.copyWith(
                  fontStyle: v ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
            SizedBox(height: tok.spacingSm),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _patchSelectedStyle((_) => const TextStyle()),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset selected style'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Preview
/// ---------------------------------------------------------------------------

class _TextThemePreview extends StatelessWidget {
  const _TextThemePreview({
    required this.title,
    required this.style,
  });

  final String title;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tok = context.dsTokens;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tok.spacingSm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tok.borderRadiusSm),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Preview • $title',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SizedBox(height: tok.spacingXs),
          Text(
            'El veloz murciélago hindú comía feliz cardillo y kiwi.',
            style: style,
          ),
          SizedBox(height: tok.spacingXs),
          Text(
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789',
            style: style,
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Enum para mapear TextTheme <-> selected style (get/set)
/// ---------------------------------------------------------------------------

enum DsTextStyleKey {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall;

  String get label => name;

  TextStyle? get(TextTheme t) {
    switch (this) {
      case DsTextStyleKey.displayLarge:
        return t.displayLarge;
      case DsTextStyleKey.displayMedium:
        return t.displayMedium;
      case DsTextStyleKey.displaySmall:
        return t.displaySmall;
      case DsTextStyleKey.headlineLarge:
        return t.headlineLarge;
      case DsTextStyleKey.headlineMedium:
        return t.headlineMedium;
      case DsTextStyleKey.headlineSmall:
        return t.headlineSmall;
      case DsTextStyleKey.titleLarge:
        return t.titleLarge;
      case DsTextStyleKey.titleMedium:
        return t.titleMedium;
      case DsTextStyleKey.titleSmall:
        return t.titleSmall;
      case DsTextStyleKey.bodyLarge:
        return t.bodyLarge;
      case DsTextStyleKey.bodyMedium:
        return t.bodyMedium;
      case DsTextStyleKey.bodySmall:
        return t.bodySmall;
      case DsTextStyleKey.labelLarge:
        return t.labelLarge;
      case DsTextStyleKey.labelMedium:
        return t.labelMedium;
      case DsTextStyleKey.labelSmall:
        return t.labelSmall;
    }
  }

  TextTheme set(TextTheme t, TextStyle s) {
    switch (this) {
      case DsTextStyleKey.displayLarge:
        return t.copyWith(displayLarge: s);
      case DsTextStyleKey.displayMedium:
        return t.copyWith(displayMedium: s);
      case DsTextStyleKey.displaySmall:
        return t.copyWith(displaySmall: s);
      case DsTextStyleKey.headlineLarge:
        return t.copyWith(headlineLarge: s);
      case DsTextStyleKey.headlineMedium:
        return t.copyWith(headlineMedium: s);
      case DsTextStyleKey.headlineSmall:
        return t.copyWith(headlineSmall: s);
      case DsTextStyleKey.titleLarge:
        return t.copyWith(titleLarge: s);
      case DsTextStyleKey.titleMedium:
        return t.copyWith(titleMedium: s);
      case DsTextStyleKey.titleSmall:
        return t.copyWith(titleSmall: s);
      case DsTextStyleKey.bodyLarge:
        return t.copyWith(bodyLarge: s);
      case DsTextStyleKey.bodyMedium:
        return t.copyWith(bodyMedium: s);
      case DsTextStyleKey.bodySmall:
        return t.copyWith(bodySmall: s);
      case DsTextStyleKey.labelLarge:
        return t.copyWith(labelLarge: s);
      case DsTextStyleKey.labelMedium:
        return t.copyWith(labelMedium: s);
      case DsTextStyleKey.labelSmall:
        return t.copyWith(labelSmall: s);
    }
  }
}

/// ---------------------------------------------------------------------------
/// UI: Dropdown genérico
/// ---------------------------------------------------------------------------

class _DsDropdown<T> extends StatelessWidget {
  const _DsDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.toLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T v) toLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tok = context.dsTokens;

    return SizedBox(
      width: 260,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          contentPadding: EdgeInsets.symmetric(
            horizontal: tok.spacingSm,
            vertical: tok.spacingXs,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            items: items
                .map(
                  (T v) => DropdownMenuItem<T>(
                    value: v,
                    child: Text(toLabel(v)),
                  ),
                )
                .toList(),
            onChanged: (T? v) {
              if (v != null) {
                onChanged(v);
              }
            },
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// UI: editor double nullable (permite limpiar -> null)
/// ---------------------------------------------------------------------------

class _DsTextStyleDoubleField extends StatefulWidget {
  const _DsTextStyleDoubleField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onChangedAttempt,
  });

  final String label;
  final double? value;
  final String placeholder;
  final void Function(double? v) onChangedAttempt;

  @override
  State<_DsTextStyleDoubleField> createState() =>
      _DsTextStyleDoubleFieldState();
}

class _DsTextStyleDoubleFieldState extends State<_DsTextStyleDoubleField> {
  late final BlocGeneral<ModelFieldState> _state;
  final Debouncer _debouncer = Debouncer(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _state = BlocGeneral<ModelFieldState>(
      ModelFieldState(value: _toTxt(widget.value)),
    );
  }

  @override
  void didUpdateWidget(covariant _DsTextStyleDoubleField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final ModelFieldState next = _state.value.copyWith(
        value: _toTxt(widget.value),
        errorText: '',
        isDirty: false,
        isValid: true,
      );
      if (next != _state.value) {
        _state.value = next;
      }
    }
  }

  String _toTxt(double? v) {
    if (v == null) {
      return '';
    }
    return v.toStringAsFixed(2);
  }

  void _onChangeAttempt(String raw) {
    final String txt = raw.trim();

    if (txt.isEmpty) {
      final ModelFieldState next = _state.value.copyWith(
        value: '',
        errorText: '',
        isDirty: true,
        isValid: true,
      );
      if (next != _state.value) {
        _state.value = next;
      }
      _debouncer.call(() => widget.onChangedAttempt(null));
      return;
    }

    final double? parsed = double.tryParse(txt.replaceAll(',', '.'));
    final bool isValid = parsed != null;

    final ModelFieldState next = _state.value.copyWith(
      value: txt,
      errorText: isValid ? '' : 'Expected number',
      isDirty: true,
      isValid: isValid,
    );
    if (next != _state.value) {
      _state.value = next;
    }

    if (isValid) {
      _debouncer.call(() => widget.onChangedAttempt(parsed));
    }
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
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
            placeholder: widget.placeholder,
            semanticsLabel: 'TextStyle ${widget.label}',
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// UI: FontWeight editor (nullable)
/// ---------------------------------------------------------------------------

class _DsFontWeightField extends StatelessWidget {
  const _DsFontWeightField({
    required this.value,
    required this.onChangedAttempt,
  });

  final FontWeight? value;
  final void Function(FontWeight? w) onChangedAttempt;

  static const List<FontWeight?> _weights = <FontWeight?>[
    null,
    FontWeight.w100,
    FontWeight.w200,
    FontWeight.w300,
    FontWeight.w400,
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800,
    FontWeight.w900,
  ];

  String _label(FontWeight? w) =>
      w == null ? 'null (inherit)' : w.toString().split('.').last;

  @override
  Widget build(BuildContext context) {
    return _DsDropdown<FontWeight?>(
      label: 'fontWeight',
      value: _weights.contains(value) ? value : null,
      items: _weights,
      toLabel: _label,
      onChanged: onChangedAttempt,
    );
  }
}
