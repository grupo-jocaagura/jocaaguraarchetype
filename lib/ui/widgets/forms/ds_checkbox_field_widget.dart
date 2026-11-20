part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Display a controlled binary choice with consumer-owned validation.
///
/// Store `'true'` or `'false'` in [ModelFieldState.value]. An empty or
/// unrecognized value displays unchecked. The row proposes a canonical value
/// through [onChangedAttempt] and reflects it when the consumer updates
/// [field]. Place links and other interactive content outside the row.
class DsCheckboxFieldWidget extends StatelessWidget {
  const DsCheckboxFieldWidget({
    required this.field,
    required this.onChangedAttempt,
    required this.label,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.requiredSemanticLabel = 'Required',
    this.readOnlySemanticLabel = 'Read only',
    super.key,
  });

  /// The latest accepted value and validation supplied by the consumer.
  final ModelFieldState field;

  /// Proposes a new value with [ModelFieldState.isDirty] set to true.
  final ValueChanged<ModelFieldState> onChangedAttempt;

  /// Localized, nonblank text describing the choice.
  final String label;

  /// Guidance shown while [field] carries no error message.
  final String? helperText;

  /// Marks the choice as mandatory. The consumer decides when to validate it.
  final bool required;

  final bool enabled;

  /// Displays the accepted check state and blocks activation.
  final bool readOnly;

  /// Localizable announcement for a required choice.
  final String requiredSemanticLabel;

  /// Localizable announcement for an enabled choice in read-only mode.
  final String readOnlySemanticLabel;

  @override
  Widget build(BuildContext context) {
    final String name = label.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(label, 'label', 'Name the field.');
    }

    final ThemeData theme = Theme.of(context);
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    final bool checked = field.value == 'true';
    final bool canChange = enabled && !readOnly;
    final String? error = field.errorTextToInput;
    final String? message =
        error ?? (helperText?.trim().isNotEmpty == true ? helperText : null);
    final String hint = <String>[
      if (required) requiredSemanticLabel,
      if (enabled && readOnly) readOnlySemanticLabel,
      if (message != null) message,
    ].join('\n');

    return CheckboxListTile(
      value: checked,
      onChanged: canChange
          ? (_) => onChangedAttempt(
              field.copyWith(value: checked ? 'false' : 'true', isDirty: true),
            )
          : null,
      enabled: enabled,
      isError: error != null,
      controlAffinity: ListTileControlAffinity.leading,
      titleAlignment: ListTileTitleAlignment.top,
      minTileHeight: kMinInteractiveDimension,
      minLeadingWidth: 0,
      minVerticalPadding: tokens.spacingXs,
      horizontalTitleGap: tokens.spacingSm,
      contentPadding: EdgeInsets.symmetric(horizontal: tokens.spacingSm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.borderRadius),
      ),
      // The tile merges these properties with its check state and activation.
      title: Semantics(
        label: name,
        hint: hint.isEmpty ? null : hint,
        isRequired: required,
        validationResult: error == null
            ? SemanticsValidationResult.none
            : SemanticsValidationResult.invalid,
        excludeSemantics: true,
        child: Text(
          required ? '$name *' : name,
          style: theme.textTheme.labelLarge,
        ),
      ),
      subtitle: message == null
          ? null
          : ExcludeSemantics(
              child: Padding(
                padding: EdgeInsets.only(top: tokens.spacingXs),
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: error != null ? theme.colorScheme.error : null,
                  ),
                ),
              ),
            ),
    );
  }
}
