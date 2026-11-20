part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class _DsPickerInputWidget extends StatefulWidget {
  const _DsPickerInputWidget({
    required this.field,
    required this.onChangedAttempt,
    required this.label,
    this.placeholder,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.requiredSemanticLabel = 'Required',
    this.readOnlySemanticLabel = 'Read only',
    super.key,
  });

  /// The accepted selection and validation supplied by the consumer.
  final ModelFieldState field;

  /// Proposes a different confirmed selection, setting [ModelFieldState.isDirty].
  final ValueChanged<ModelFieldState> onChangedAttempt;

  /// Nonblank, localized name of the field.
  final String label;

  final String? placeholder;
  final String? helperText;

  /// Marks the field as mandatory. The consumer decides when to validate it.
  final bool required;

  final bool enabled;

  /// Exposes the current selection for reading and prevents opening the picker.
  final bool readOnly;

  final String requiredSemanticLabel;
  final String readOnlySemanticLabel;
}

abstract class _DsPickerInputState<
  W extends _DsPickerInputWidget,
  T extends Object
>
    extends State<W> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'Picker input');
  bool _pickerOpen = false;

  bool get _canChange => widget.enabled && !widget.readOnly;

  T? _parseValue(String value);
  String _encodeValue(T selection);
  bool _canUseSelection(T selection) => true;
  void _validateConfiguration() {}
  IconData get _pickerIcon;
  TextScaler get _pickerTextScaler => MediaQuery.textScalerOf(context);

  ({String caption, String accessibleValue}) _describeValue(
    MaterialLocalizations localizations,
    T selection,
  );

  String? get _invalidCaption => null;

  Future<T?> _showSelectionPicker({
    required T? initial,
    required TransitionBuilder builder,
  });

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _openPicker() async {
    if (!_canChange || _pickerOpen) {
      return;
    }
    final T? accepted = _parseValue(widget.field.value);
    final TextScaler textScaler = _pickerTextScaler;
    final bool use24HourFormat = MediaQuery.alwaysUse24HourFormatOf(context);

    _pickerOpen = true;
    final T? picked;
    try {
      picked = await _showSelectionPicker(
        initial: accepted != null && _canUseSelection(accepted)
            ? accepted
            : null,
        builder: (BuildContext context, Widget? child) => MediaQuery(
          // The dialog route can sit above a field's local MediaQuery.
          data: MediaQuery.of(context).copyWith(
            textScaler: textScaler,
            alwaysUse24HourFormat: use24HourFormat,
          ),
          child: child!,
        ),
      );
    } finally {
      _pickerOpen = false;
      if (mounted && _canChange) {
        _focusNode.requestFocus();
      }
    }

    if (picked == null || !mounted || !_canChange) {
      return;
    }
    // Use the current configuration and accepted value at confirmation.
    if (_canUseSelection(picked) && picked != _parseValue(widget.field.value)) {
      widget.onChangedAttempt(
        widget.field.copyWith(value: _encodeValue(picked), isDirty: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.label.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(widget.label, 'label', 'Name the field.');
    }
    _validateConfiguration();

    final ThemeData theme = Theme.of(context);
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    final T? selection = _parseValue(widget.field.value);
    final ({String caption, String accessibleValue})? summary =
        selection == null
        ? null
        : _describeValue(MaterialLocalizations.of(context), selection);
    final String? invalidCaption = _invalidCaption;
    final bool isEmpty = summary == null && invalidCaption == null;
    final String caption =
        summary?.caption ?? invalidCaption ?? widget.placeholder ?? '';
    final String accessibleValue = summary?.accessibleValue ?? caption;
    final String? error = widget.field.errorTextToInput;
    final String? help =
        error == null && widget.helperText?.trim().isNotEmpty == true
        ? widget.helperText
        : null;
    final bool isReadOnly = widget.enabled && widget.readOnly;
    final String hint = <String>[
      if (widget.required) widget.requiredSemanticLabel,
      if (isReadOnly) widget.readOnlySemanticLabel,
      if (error != null) error else if (help != null) help,
    ].join('\n');
    final VoidCallback? open = _canChange ? _openPicker : null;
    final BorderRadius radius = BorderRadius.circular(tokens.borderRadius);
    final Color iconColor = !widget.enabled
        ? theme.disabledColor
        : theme.colorScheme.onSurfaceVariant;

    return ListenableBuilder(
      listenable: _focusNode,
      builder: (BuildContext context, Widget? child) => Semantics(
        container: true,
        button: !isReadOnly,
        enabled: widget.enabled,
        readOnly: isReadOnly,
        isRequired: widget.required,
        focusable: _canChange,
        focused: _canChange && _focusNode.hasFocus,
        label: name,
        value: accessibleValue.isEmpty ? null : accessibleValue,
        hint: hint.isEmpty ? null : hint,
        validationResult: error == null
            ? SemanticsValidationResult.none
            : SemanticsValidationResult.invalid,
        onTap: open,
        onFocus: _canChange ? _focusNode.requestFocus : null,
        child: ExcludeSemantics(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              focusNode: _focusNode,
              canRequestFocus: _canChange,
              onTap: open,
              borderRadius: radius,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: kMinInteractiveDimension,
                  minHeight: kMinInteractiveDimension,
                ),
                child: InputDecorator(
                  isFocused: _canChange && _focusNode.hasFocus,
                  isEmpty: isEmpty,
                  decoration: InputDecoration(
                    enabled: widget.enabled,
                    border: OutlineInputBorder(borderRadius: radius),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: widget.required ? '$name *' : name,
                    labelStyle: theme.textTheme.labelLarge,
                    helperText: help,
                    helperMaxLines: help?.length,
                    errorText: error,
                    errorMaxLines: error?.length,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          caption,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isEmpty || !widget.enabled
                                ? iconColor
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(width: tokens.spacingXs),
                      DsIconWidget(
                        icon: isReadOnly ? Icons.lock_outline : _pickerIcon,
                        size: tokens.spacing,
                        color: iconColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
