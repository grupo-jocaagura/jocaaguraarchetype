part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class _DsBinaryFieldWidget extends StatelessWidget {
  const _DsBinaryFieldWidget({
    required this.field,
    required this.onChangedAttempt,
    required this.label,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.requiredSemanticLabel = 'Required',
    this.readOnlySemanticLabel = 'Read only',
    this._useSwitch = false,
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

  /// Displays the accepted state and blocks activation.
  final bool readOnly;

  /// Localizable announcement for a required choice.
  final String requiredSemanticLabel;

  /// Localizable announcement for an enabled choice in read-only mode.
  final String readOnlySemanticLabel;

  final bool _useSwitch;

  @override
  Widget build(BuildContext context) {
    final String name = label.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(label, 'label', 'Name the field.');
    }

    final ThemeData theme = Theme.of(context);
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    final bool active = field.value == 'true';
    final bool canChange = enabled && !readOnly;
    final String? error = field.errorTextToInput;
    final String? message =
        error ?? (helperText?.trim().isNotEmpty == true ? helperText : null);
    final String hint = <String>[
      if (required) requiredSemanticLabel,
      if (enabled && readOnly) readOnlySemanticLabel,
      if (message != null) message,
    ].join('\n');

    final ValueChanged<bool?>? change = canChange
        ? (bool? next) {
            if (next != null && next != active) {
              onChangedAttempt(
                field.copyWith(value: next ? 'true' : 'false', isDirty: true),
              );
            }
          }
        : null;
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: tokens.spacingSm,
    );
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.borderRadius),
    );
    // Both tiles merge the title with the native state and activation.
    final Widget title = Semantics(
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
    );
    final Widget? subtitle = message == null
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
          );

    if (_useSwitch) {
      return SwitchListTile(
        value: active,
        onChanged: change,
        controlAffinity: ListTileControlAffinity.trailing,
        minTileHeight: kMinInteractiveDimension,
        minVerticalPadding: tokens.spacingXs,
        horizontalTitleGap: tokens.spacingSm,
        contentPadding: padding,
        shape: shape,
        title: title,
        subtitle: subtitle,
      );
    }

    return CheckboxListTile(
      value: active,
      onChanged: change,
      enabled: enabled,
      isError: error != null,
      controlAffinity: ListTileControlAffinity.leading,
      titleAlignment: ListTileTitleAlignment.top,
      minTileHeight: kMinInteractiveDimension,
      minLeadingWidth: 0,
      minVerticalPadding: tokens.spacingXs,
      horizontalTitleGap: tokens.spacingSm,
      contentPadding: padding,
      shape: shape,
      title: title,
      subtitle: subtitle,
    );
  }
}
