part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Display a controlled single choice as a vertical group of radio options.
///
/// Keep [field] in the form controller and update it to accept a proposal
/// from [onChangedAttempt]. An empty or unavailable key leaves all options
/// unselected. Give the group a bounded width and room for labels to wrap.
class DsRadioGroupFieldWidget extends _DsSelectionField {
  const DsRadioGroupFieldWidget({
    required super.field,
    required super.onChangedAttempt,
    required super.options,
    required super.label,
    this.emptyMessage = 'No options available',
    super.optionLabelBuilder,
    super.helperText,
    super.required,
    super.enabled,
    super.readOnly,
    super.requiredSemanticLabel,
    super.readOnlySemanticLabel,
    super.key,
  });

  /// Localizable, nonblank message displayed when [options] is empty.
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final String name = _fieldName;
    final String? selection = _singleSelection;
    final String? error = _error;
    final String? message = error ?? _help;
    final bool isEmpty = options.isEmpty;
    _validateEmptyMessage(emptyMessage);
    final Map<String, String> labels = _optionLabels();

    final ThemeData theme = Theme.of(context);
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    final List<Widget> rows = <Widget>[
      for (final MapEntry<String, String> entry in labels.entries)
        RadioListTile<String>(
          key: ValueKey<String>(entry.key),
          value: entry.key,
          enabled: _canChange,
          controlAffinity: ListTileControlAffinity.leading,
          titleAlignment: ListTileTitleAlignment.top,
          minTileHeight: kMinInteractiveDimension,
          minLeadingWidth: 0,
          horizontalTitleGap: tokens.spacingSm,
          minVerticalPadding: tokens.spacingXs,
          contentPadding: EdgeInsets.symmetric(horizontal: tokens.spacingSm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.borderRadius),
          ),
          title: Text(entry.value, style: theme.textTheme.bodyLarge),
        ),
    ];

    final String hint = <String>[
      ..._statusAnnouncements,
      if (isEmpty) emptyMessage,
      if (message != null) message,
    ].join('\n');
    return Material(
      type: MaterialType.transparency,
      child: RadioGroup<String>(
        groupValue: selection,
        onChanged: (String? next) {
          if (_canChange &&
              next != null &&
              next != selection &&
              labels.containsKey(next)) {
            _proposeSelection(next);
          }
        },
        // Annotate the native group while keeping its option nodes distinct.
        child: Semantics(
          label: name,
          hint: hint.isEmpty ? null : hint,
          enabled: enabled,
          isRequired: this.required,
          validationResult: error == null
              ? SemanticsValidationResult.none
              : SemanticsValidationResult.invalid,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ExcludeSemantics(
                child: Text(
                  this.required ? '$name *' : name,
                  style: theme.textTheme.labelLarge,
                ),
              ),
              SizedBox(height: tokens.spacingXs),
              if (isEmpty)
                ExcludeSemantics(
                  child: Text(emptyMessage, style: theme.textTheme.bodyMedium),
                )
              else
                ...rows,
              if (message != null) ...<Widget>[
                SizedBox(height: tokens.spacingXs),
                ExcludeSemantics(
                  child: Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: error == null ? null : theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
