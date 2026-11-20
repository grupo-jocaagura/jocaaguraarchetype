part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A controlled form field for selecting a string key.
///
/// Give the field a bounded width and localized [label] and [placeholder].
/// The consumer owns [field] and handles validation after [onChangedAttempt].
class DsSelectInputWidget extends _DsSingleSelectionField {
  const DsSelectInputWidget({
    required super.field,
    required super.onChangedAttempt,
    required super.options,
    required super.label,
    required this.placeholder,
    super.optionLabelBuilder,
    super.helperText,
    super.required,
    super.enabled,
    super.readOnly,
    super.requiredSemanticLabel,
    super.readOnlySemanticLabel,
    super.key,
  });

  /// Localized prompt for the empty selection.
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final String name = _fieldName;
    final String? selection = _selection;
    final String? error = _error;
    final String? help = _help;
    final String status = _statusAnnouncements.join('\n');
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    final ThemeData theme = Theme.of(context);

    return Focus(
      canRequestFocus: false,
      includeSemantics: false,
      child: Builder(
        builder: (BuildContext context) => InputDecorator(
          isFocused: _canChange && Focus.of(context).hasFocus,
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
                  text: this.required ? '$name *' : name,
                  children: <InlineSpan>[
                    if (_isReadOnly)
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
            isRequired: this.required,
            readOnly: _isReadOnly,
            hint: status.isEmpty ? null : status,
            validationResult: error == null
                ? SemanticsValidationResult.none
                : SemanticsValidationResult.invalid,
            child: DsDropdownButtonWidget<String>(
              value: selection,
              items: options.map(_menuItem).toList(),
              onChanged: _proposeSelection,
              placeholder: placeholder,
              semanticLabel: name,
              state: ModelInteractiveState(isEnabled: _canChange),
              isExpanded: true,
            ),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _menuItem(String option) {
    final String caption = _optionLabel(option);
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
