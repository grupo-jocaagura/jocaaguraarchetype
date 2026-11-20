part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Select a calendar date with consumer-owned value and validation.
///
/// Use `yyyy-MM-dd` in [ModelFieldState.value], or an empty string for an
/// unselected field. The display follows Material localizations and includes
/// the year. Only an accepted update to [field] changes the displayed value.
/// Give the field a bounded width and room to grow with text scaling.
class DsDateInputWidget extends StatefulWidget {
  const DsDateInputWidget({
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

  /// The accepted calendar date and validation supplied by the consumer.
  final ModelFieldState field;

  /// Proposes a different confirmed date, setting [ModelFieldState.isDirty].
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

  /// Exposes the date for reading and prevents opening the picker.
  final bool readOnly;

  final String requiredSemanticLabel;
  final String readOnlySemanticLabel;

  @override
  State<DsDateInputWidget> createState() => _DsDateInputWidgetState();
}

class _DsDateInputWidgetState extends State<DsDateInputWidget> {
  static final RegExp _isoDay = RegExp(r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$');
  final FocusNode _focusNode = FocusNode(debugLabel: 'Date input');
  bool _pickerOpen = false;

  bool get _canChange => widget.enabled && !widget.readOnly;

  // Represent calendar components on a timezone-free axis for comparisons.
  static DateTime _day(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  static String _formatDay(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static DateTime? _parseDay(String value) {
    if (value.length != 10 || !_isoDay.hasMatch(value)) {
      return null;
    }
    final DateTime? parsed = DateTime.tryParse('${value}T00:00:00Z');
    return parsed != null && _formatDay(parsed) == value ? parsed : null;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _openPicker() async {
    if (!_canChange || _pickerOpen) {
      return;
    }
    final DateTime first = _day(widget.firstDate);
    final DateTime last = _day(widget.lastDate);
    final DateTime? accepted = _parseDay(widget.field.value);
    final DateTime today = _day(DateTime.now());
    final DateTime fallback = today.isBefore(first)
        ? first
        : today.isAfter(last)
        ? last
        : today;
    final DateTime initial =
        accepted != null && !accepted.isBefore(first) && !accepted.isAfter(last)
        ? accepted
        : fallback;
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    _pickerOpen = true;
    final DateTime? picked;
    try {
      picked = await showDatePicker(
        context: context,
        firstDate: first,
        lastDate: last,
        initialDate: initial,
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
    final DateTime day = _day(picked);
    // The consumer may change availability or bounds while the dialog is open.
    if (day.isBefore(_day(widget.firstDate)) ||
        day.isAfter(_day(widget.lastDate))) {
      return;
    }
    final String value = _formatDay(day);
    if (value != widget.field.value) {
      widget.onChangedAttempt(
        widget.field.copyWith(value: value, isDirty: true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.label.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(widget.label, 'label', 'Name the field.');
    }
    if (_day(widget.lastDate).isBefore(_day(widget.firstDate))) {
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
    final bool isEmpty = widget.field.value.isEmpty;
    final DateTime? date = _parseDay(widget.field.value);
    final String caption = date != null
        ? MaterialLocalizations.of(context).formatShortDate(date)
        : isEmpty
        ? widget.placeholder ?? ''
        : widget.field.value;
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
        value: caption.isEmpty ? null : caption,
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
