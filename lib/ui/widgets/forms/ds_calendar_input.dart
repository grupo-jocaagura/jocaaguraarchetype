part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class _DsCalendarInputWidget extends StatefulWidget {
  const _DsCalendarInputWidget({
    required this.field,
    required this.onChangedAttempt,
    required this.label,
    required this.firstDate,
    required this.lastDate,
    this.placeholder,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.requiredSemanticLabel = 'Required',
    this.readOnlySemanticLabel = 'Read only',
    super.key,
  });

  /// The accepted calendar selection and validation supplied by the consumer.
  final ModelFieldState field;

  /// Proposes a different confirmed selection, setting [ModelFieldState.isDirty].
  final ValueChanged<ModelFieldState> onChangedAttempt;

  /// Nonblank, localized name of the field.
  final String label;

  /// Earliest selectable date, inclusive. Uses the supplied year, month and day.
  final DateTime firstDate;

  /// Latest selectable date, inclusive. Uses the supplied year, month and day.
  final DateTime lastDate;

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

// Use only calendar components so comparisons do not depend on timezone or time.
DateTime _calendarDay(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

String _formatCalendarDay(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

final RegExp _calendarDayPattern = RegExp(r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$');

DateTime? _parseCalendarDay(String value) {
  if (value.length != 10 || !_calendarDayPattern.hasMatch(value)) {
    return null;
  }
  final DateTime? parsed = DateTime.tryParse('${value}T00:00:00Z');
  return parsed != null && _formatCalendarDay(parsed) == value ? parsed : null;
}

abstract class _DsCalendarInputState<
  W extends _DsCalendarInputWidget,
  T extends Object
>
    extends State<W> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'Date input');
  bool _pickerOpen = false;

  bool get _canChange => widget.enabled && !widget.readOnly;

  T? _parseValue(String value);
  String _encodeValue(T selection);
  bool _fitsBounds(T selection, DateTime first, DateTime last);

  ({String caption, String accessibleValue}) _describeValue(
    MaterialLocalizations localizations,
    T selection,
  );

  String? get _invalidCaption => null;

  Future<T?> _showPicker({
    required DateTime first,
    required DateTime last,
    required T? initial,
    required Locale locale,
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
    final DateTime first = _calendarDay(widget.firstDate);
    final DateTime last = _calendarDay(widget.lastDate);
    final T? accepted = _parseValue(widget.field.value);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    _pickerOpen = true;
    final T? picked;
    try {
      picked = await _showPicker(
        first: first,
        last: last,
        initial: accepted != null && _fitsBounds(accepted, first, last)
            ? accepted
            : null,
        locale:
            DatePickerTheme.of(context).locale ??
            Localizations.localeOf(context),
        builder: (BuildContext context, Widget? child) => MediaQuery(
          // The dialog route can sit above a field's local MediaQuery.
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
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
    // Recheck against the latest accepted value and bounds after the dialog.
    if (_fitsBounds(
          picked,
          _calendarDay(widget.firstDate),
          _calendarDay(widget.lastDate),
        ) &&
        picked != _parseValue(widget.field.value)) {
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
    if (_calendarDay(widget.lastDate)
        .isBefore(_calendarDay(widget.firstDate))) {
      throw ArgumentError.value(
        widget.lastDate,
        'lastDate',
        'Use a day on or after firstDate.',
      );
    }
    if (widget.firstDate.year < 0 || widget.lastDate.year > 9999) {
      throw ArgumentError('Date bounds must have four-digit years.');
    }

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
                        icon: isReadOnly
                            ? Icons.lock_outline
                            : Icons.calendar_today_outlined,
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
