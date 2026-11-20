part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Select a time of day with consumer-owned value and validation.
///
/// Store `HH:mm` from `00:00` to `23:59` in [ModelFieldState.value], or an empty
/// string for no selection. The field and picker use the locale and time format
/// of the surrounding app. Confirming a different time proposes an update to
/// [field] through [onChangedAttempt].
///
/// The dialog opens on the clock face and offers a text entry mode. Its text
/// scales up to 110% to fit Material's dialog layout.
class DsTimeInputWidget extends _DsPickerInputWidget {
  const DsTimeInputWidget({
    required super.field,
    required super.onChangedAttempt,
    required super.label,
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
  State<DsTimeInputWidget> createState() => _DsTimeInputWidgetState();
}

class _DsTimeInputWidgetState
    extends _DsPickerInputState<DsTimeInputWidget, TimeOfDay> {
  static final RegExp _timePattern = RegExp(
    r'^(?:[01][0-9]|2[0-3]):[0-5][0-9]$',
  );

  @override
  IconData get _pickerIcon => Icons.access_time;

  // Match the sizing limit of Material's dialog so the typing labels fit.
  @override
  TextScaler get _pickerTextScaler =>
      super._pickerTextScaler.clamp(maxScaleFactor: 1.1);

  @override
  TimeOfDay? _parseValue(String value) {
    if (value.length != 5 || !_timePattern.hasMatch(value)) {
      return null;
    }
    return TimeOfDay(
      hour: int.parse(value.substring(0, 2)),
      minute: int.parse(value.substring(3)),
    );
  }

  @override
  String _encodeValue(TimeOfDay selection) =>
      '${selection.hour.toString().padLeft(2, '0')}:'
      '${selection.minute.toString().padLeft(2, '0')}';

  @override
  ({String caption, String accessibleValue}) _describeValue(
    MaterialLocalizations localizations,
    TimeOfDay selection,
  ) {
    final String time = localizations.formatTimeOfDay(
      selection,
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return (caption: time, accessibleValue: time);
  }

  @override
  String? get _invalidCaption =>
      widget.field.value.isEmpty ? null : widget.field.value;

  @override
  Future<TimeOfDay?> _showSelectionPicker({
    required TimeOfDay? initial,
    required TransitionBuilder builder,
  }) {
    final Localizations localizations = context
        .findAncestorWidgetOfExactType<Localizations>()!;
    final TextDirection direction = Directionality.of(context);
    return showTimePicker(
      context: context,
      initialTime: initial ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) => builder(
        context,
        // A root navigator may sit above this field's localization overrides.
        Localizations(
          locale: localizations.locale,
          delegates: localizations.delegates,
          child: Directionality(textDirection: direction, child: child!),
        ),
      ),
    );
  }
}
