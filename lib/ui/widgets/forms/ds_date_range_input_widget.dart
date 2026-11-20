part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Select an inclusive date range with consumer-owned value and validation.
///
/// Use a JSON object with `start` and `end` strings in `yyyy-MM-dd` format in
/// [ModelFieldState.value], or an empty string for an unselected field. Both
/// dates are shown in the app's locale. Only an accepted update to [field]
/// changes the displayed range.
///
/// Give the field a bounded width and room to wrap. The native range dialog
/// limits its internal text scaling to 1.3 in the current Material UI version.
class DsDateRangeInputWidget extends _DsCalendarInputWidget {
  const DsDateRangeInputWidget({
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
  State<DsDateRangeInputWidget> createState() => _DsDateRangeInputWidgetState();
}

class _DsDateRangeInputWidgetState
    extends
        _DsCalendarInputState<DsDateRangeInputWidget, DateTimeRange<DateTime>> {
  static const Size _landscapeDialogMinimum = Size(720, 200);

  @override
  DateTimeRange<DateTime>? _parseValue(String value) {
    if (value.isEmpty) {
      return null;
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(value);
    } on FormatException {
      return null;
    }
    if (decoded case {'start': final String start, 'end': final String end}) {
      final DateTime? startDay = _parseCalendarDay(start);
      final DateTime? endDay = _parseCalendarDay(end);
      if (startDay != null && endDay != null && !startDay.isAfter(endDay)) {
        return DateTimeRange<DateTime>(start: startDay, end: endDay);
      }
    }
    return null;
  }

  @override
  String _encodeValue(DateTimeRange<DateTime> selection) =>
      jsonEncode(<String, String>{
        'start': _formatCalendarDay(selection.start),
        'end': _formatCalendarDay(selection.end),
      });

  @override
  bool _fitsBounds(
    DateTimeRange<DateTime> selection,
    DateTime first,
    DateTime last,
  ) => !selection.start.isBefore(first) && !selection.end.isAfter(last);

  @override
  ({String caption, String accessibleValue}) _describeValue(
    MaterialLocalizations localizations,
    DateTimeRange<DateTime> selection,
  ) {
    final String start = localizations.formatShortDate(selection.start);
    final String end = localizations.formatShortDate(selection.end);
    return (
      caption: '$start – $end',
      accessibleValue:
          '${localizations.dateRangeStartLabel}: $start\n'
          '${localizations.dateRangeEndLabel}: $end',
    );
  }

  @override
  Future<DateTimeRange<DateTime>?> _showPicker({
    required DateTime first,
    required DateTime last,
    required DateTimeRange<DateTime>? initial,
    required Locale locale,
    required TransitionBuilder builder,
  }) async {
    final DateTimeRange<DateTime>? picked = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDateRange: initial,
      locale: locale,
      builder: (BuildContext context, Widget? child) {
        if (MediaQuery.orientationOf(context) == Orientation.portrait) {
          return builder(context, child);
        }
        final ThemeData theme = Theme.of(context);
        final DialogThemeData dialogTheme = DialogTheme.of(context);
        final BoxConstraints constraints =
            dialogTheme.constraints ?? const BoxConstraints();
        final DatePickerThemeData pickerTheme = DatePickerTheme.of(context);
        final Size minimum = constraints.constrain(_landscapeDialogMinimum);
        // Material reserves a sidebar next to two side-by-side date editors.
        // Give the editors more room and use a body style for the sidebar's
        // two-line date summary. Material still controls the text-scale cap.
        return builder(
          context,
          Theme(
            data: theme.copyWith(
              textTheme: theme.textTheme.copyWith(
                headlineSmall: theme.textTheme.bodyMedium,
              ),
            ),
            child: DialogTheme(
              data: dialogTheme.copyWith(
                constraints: constraints.copyWith(
                  minWidth: minimum.width,
                  minHeight: minimum.height,
                ),
              ),
              child: DatePickerTheme(
                data: pickerTheme.copyWith(
                  headerHelpStyle:
                      pickerTheme.headerHelpStyle ?? theme.textTheme.labelSmall,
                ),
                child: child!,
              ),
            ),
          ),
        );
      },
    );
    return picked == null
        ? null
        : DateTimeRange<DateTime>(
            start: _calendarDay(picked.start),
            end: _calendarDay(picked.end),
          );
  }
}
