part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Select a calendar date with consumer-owned value and validation.
///
/// Use `yyyy-MM-dd` in [ModelFieldState.value], or an empty string for an
/// unselected field. The display follows Material localizations and includes
/// the year. Only an accepted update to [field] changes the displayed value.
/// Give the field a bounded width and room to grow with text scaling.
class DsDateInputWidget extends _DsCalendarInputWidget {
  const DsDateInputWidget({
    required super.field,
    required super.onChangedAttempt,
    required super.label,
    required super.firstDate,
    required super.lastDate,
    super.placeholder,
    super.helperText,
    super.required,
    super.enabled,
    super.readOnly,
    super.requiredSemanticLabel,
    super.readOnlySemanticLabel,
    super.key,
  });

  @override
  State<DsDateInputWidget> createState() => _DsDateInputWidgetState();
}

class _DsDateInputWidgetState
    extends _DsCalendarInputState<DsDateInputWidget, DateTime> {
  @override
  DateTime? _parseValue(String value) => _parseCalendarDay(value);

  @override
  String _encodeValue(DateTime selection) => _formatCalendarDay(selection);

  @override
  bool _fitsBounds(DateTime selection, DateTime first, DateTime last) =>
      !selection.isBefore(first) && !selection.isAfter(last);

  @override
  ({String caption, String accessibleValue}) _describeValue(
    MaterialLocalizations localizations,
    DateTime selection,
  ) {
    final String date = localizations.formatShortDate(selection);
    return (caption: date, accessibleValue: date);
  }

  @override
  String? get _invalidCaption =>
      widget.field.value.isEmpty ? null : widget.field.value;

  @override
  Future<DateTime?> _showPicker({
    required DateTime first,
    required DateTime last,
    required DateTime? initial,
    required Locale locale,
    required TransitionBuilder builder,
  }) async {
    final DateTime today = _calendarDay(DateTime.now());
    final DateTime fallback = today.isBefore(first)
        ? first
        : today.isAfter(last)
        ? last
        : today;
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDate: initial ?? fallback,
      locale: locale,
      builder: builder,
    );
    return picked == null ? null : _calendarDay(picked);
  }
}
