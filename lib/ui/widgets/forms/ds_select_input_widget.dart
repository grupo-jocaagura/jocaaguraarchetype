part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A controlled form field for selecting a string key.
///
/// Give the field a bounded width and localized [label] and [placeholder].
/// The consumer owns [field] and handles validation after [onChangedAttempt].
class DsSelectInputWidget extends StatelessWidget {
  const DsSelectInputWidget({
    required this.field,
    required this.onChangedAttempt,
    required this.options,
    required this.label,
    required this.placeholder,
    this.optionLabelBuilder,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.requiredSemanticLabel = 'Required',
    this.readOnlySemanticLabel = 'Read only',
    super.key,
  });

  /// The last accepted value and validation result from the consumer.
  final ModelFieldState field;

  /// Proposes a new value with [ModelFieldState.isDirty] set to true.
  final ValueChanged<ModelFieldState> onChangedAttempt;

  /// Unique, nonblank keys. An empty [ModelFieldState.value] is unselected.
  final List<String> options;

  final String label;
  final String placeholder;

  /// Maps a key to its display text. Defaults to displaying the key itself.
  final String Function(String option)? optionLabelBuilder;

  /// Guidance shown when [field] has no validation message.
  final String? helperText;

  /// Marks the field as mandatory. The consumer decides when to validate it.
  final bool required;

  final bool enabled;

  /// Shows the current value and blocks editing in an otherwise enabled field.
  final bool readOnly;

  /// Localizable status announced for a mandatory field.
  final String requiredSemanticLabel;

  /// Localizable status announced in read-only mode.
  final String readOnlySemanticLabel;

  @override
  Widget build(BuildContext context) {
    final String name = label.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(label, 'label', 'Name the field.');
    }
    final bool isReadOnly = enabled && readOnly;
    final bool canChange = enabled && !readOnly;
    final String? selection = options.contains(field.value)
        ? field.value
        : null;
    final String? error = field.errorTextToInput;
    final String? help = error == null && helperText?.trim().isNotEmpty == true
        ? helperText
        : null;
    final String status = <String>[
      if (required) requiredSemanticLabel,
      if (isReadOnly) readOnlySemanticLabel,
    ].join('\n');
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    final ThemeData theme = Theme.of(context);

    return Focus(
      canRequestFocus: false,
      includeSemantics: false,
      child: Builder(
        builder: (BuildContext context) => InputDecorator(
          isFocused: canChange && Focus.of(context).hasFocus,
          isEmpty: selection == null,
          decoration: InputDecoration(
            enabled: enabled,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.borderRadius),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            label: ExcludeSemantics(
              child: Text.rich(
                TextSpan(
                  text: required ? '$name *' : name,
                  children: <InlineSpan>[
                    if (isReadOnly)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            start: tokens.spacingXs,
                          ),
                          child: DsIconWidget(
                            icon: Icons.lock_outline,
                            size: tokens.spacing,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            labelStyle: theme.textTheme.labelLarge,
            helperText: help,
            helperMaxLines: help?.length,
            errorText: error,
            errorMaxLines: error?.length,
          ),
          child: Semantics(
            isRequired: required,
            readOnly: isReadOnly,
            hint: status.isEmpty ? null : status,
            validationResult: error == null
                ? SemanticsValidationResult.none
                : SemanticsValidationResult.invalid,
            child: DsDropdownButtonWidget<String>(
              value: selection,
              items: options.map(_menuItem).toList(),
              onChanged: (String next) =>
                  onChangedAttempt(field.copyWith(value: next, isDirty: true)),
              placeholder: placeholder,
              semanticLabel: name,
              state: ModelInteractiveState(isEnabled: canChange),
              isExpanded: true,
            ),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _menuItem(String option) {
    if (option.trim().isEmpty) {
      throw ArgumentError.value(option, 'options', 'Use nonblank keys.');
    }
    final String caption = optionLabelBuilder?.call(option) ?? option;
    if (caption.trim().isEmpty) {
      throw ArgumentError.value(
        caption,
        'optionLabelBuilder',
        'Name the option.',
      );
    }
    return DropdownMenuItem<String>(
      value: option,
      child: DsTextParagraphWidget(
        label: caption,
        role: DsTextStyleKey.bodyLarge,
        maxLines: caption.length,
        overflow: TextOverflow.clip,
      ),
    );
  }
}
