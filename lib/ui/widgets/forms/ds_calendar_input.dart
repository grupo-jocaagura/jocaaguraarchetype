part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class _DsCalendarInputWidget extends _DsPickerInputWidget {
  const _DsCalendarInputWidget({
    required super.field,
    required super.onChangedAttempt,
    required super.label,
    required this.firstDate,
    required this.lastDate,
    super.placeholder,
    super.helperText,
    super.required,
    super.enabled,
    super.readOnly,
    super.requiredSemanticLabel,
    super.readOnlySemanticLabel,
    super.key,
  });

  /// Earliest selectable date, inclusive. Uses the supplied year, month and day.
  final DateTime firstDate;

  /// Latest selectable date, inclusive. Uses the supplied year, month and day.
  final DateTime lastDate;
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
    extends _DsPickerInputState<W, T> {
  bool _fitsBounds(T selection, DateTime first, DateTime last);

  Future<T?> _showPicker({
    required DateTime first,
    required DateTime last,
    required T? initial,
    required Locale locale,
    required TransitionBuilder builder,
  });

  @override
  IconData get _pickerIcon => Icons.calendar_today_outlined;

  @override
  bool _canUseSelection(T selection) => _fitsBounds(
    selection,
    _calendarDay(widget.firstDate),
    _calendarDay(widget.lastDate),
  );

  @override
  void _validateConfiguration() {
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
  }

  @override
  Future<T?> _showSelectionPicker({
    required T? initial,
    required TransitionBuilder builder,
  }) => _showPicker(
    first: _calendarDay(widget.firstDate),
    last: _calendarDay(widget.lastDate),
    initial: initial,
    locale:
        DatePickerTheme.of(context).locale ?? Localizations.localeOf(context),
    builder: builder,
  );
}
