part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Display a controlled binary choice with consumer-owned validation.
///
/// Store `'true'` or `'false'` in [ModelFieldState.value]. An empty or
/// unrecognized value displays unchecked. The row proposes a canonical value
/// through [onChangedAttempt] and reflects it when the consumer updates
/// [field]. Place links and other interactive content outside the row.
class DsCheckboxFieldWidget extends _DsBinaryFieldWidget {
  const DsCheckboxFieldWidget({
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
  });
}
