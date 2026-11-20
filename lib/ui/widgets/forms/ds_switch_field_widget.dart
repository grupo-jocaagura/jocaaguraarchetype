part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Display a controlled on/off preference with consumer-owned validation.
///
/// Store `'true'` or `'false'` in [ModelFieldState.value]. An empty or
/// unrecognized value displays off. Tapping the row or dragging the switch
/// proposes a change through [onChangedAttempt]. The consumer accepts it
/// by updating [field].
class DsSwitchFieldWidget extends _DsBinaryFieldWidget {
  const DsSwitchFieldWidget({
    required super.field,
    required super.onChangedAttempt,
    required super.label,
    super.helperText,
    super.required,
    super.enabled,
    super.readOnly,
    super.requiredSemanticLabel,
    super.readOnlySemanticLabel,
    super.key,
  }) : super(useSwitch: true);
}
