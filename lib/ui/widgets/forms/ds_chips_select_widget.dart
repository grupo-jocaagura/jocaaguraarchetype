part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Display a controlled multiple selection as a group of filter chips.
///
/// Store a JSON array of strings in [ModelFieldState.value]. Empty or invalid
/// input displays no selection. Proposals preserve stored order and keys not
/// currently in [options]. Accept a proposal by updating [field]. Give the
/// group a bounded width to wrap chips and their labels.
class DsChipsSelectWidget extends _DsSelectionField {
  const DsChipsSelectWidget({
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

  Set<String> _acceptedKeys() {
    if (field.value.isEmpty) {
      return <String>{};
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(field.value);
    } on FormatException {
      return <String>{};
    }
    if (decoded is! List<Object?> ||
        decoded.any((Object? key) => key is! String)) {
      return <String>{};
    }
    return <String>{...decoded.cast<String>()};
  }

  @override
  Widget build(BuildContext context) {
    final String name = _fieldName;
    _validateEmptyMessage(emptyMessage);
    final Map<String, String> labels = _optionLabels();
    final Set<String> accepted = _acceptedKeys();
    final String? error = _error;
    final String? message = error ?? _help;
    final ThemeData theme = Theme.of(context);
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    final bool showCheckmark = ChipTheme.of(context).showCheckmark ?? true;
    final String hint = <String>[
      ..._statusAnnouncements,
      if (labels.isEmpty) emptyMessage,
      if (message != null) message,
    ].join('\n');

    return Material(
      type: MaterialType.transparency,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: name,
        hint: hint.isEmpty ? null : hint,
        enabled: enabled,
        isRequired: this.required,
        validationResult: error == null
            ? SemanticsValidationResult.none
            : SemanticsValidationResult.invalid,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ExcludeSemantics(
              child: Text(
                this.required ? '$name *' : name,
                style: theme.textTheme.labelLarge,
              ),
            ),
            SizedBox(height: tokens.spacingXs),
            if (labels.isEmpty)
              ExcludeSemantics(
                child: Text(emptyMessage, style: theme.textTheme.bodyMedium),
              )
            else
              Wrap(
                spacing: tokens.spacingXs,
                runSpacing: tokens.spacingXs,
                children: <Widget>[
                  for (final MapEntry<String, String> entry in labels.entries)
                    _buildChip(entry, accepted, tokens, showCheckmark),
                ],
              ),
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
    );
  }

  Widget _buildChip(
    MapEntry<String, String> option,
    Set<String> accepted,
    ModelDsExtendedTokens tokens,
    bool showCheckmark,
  ) {
    final bool selected = accepted.contains(option.key);
    return FilterChip(
      key: ValueKey<String>(option.key),
      selected: selected,
      onSelected: _canChange
          ? (bool next) {
              final Set<String> keys = <String>{...accepted};
              final bool changed = next
                  ? keys.add(option.key)
                  : keys.remove(option.key);
              if (changed) {
                _proposeSelection(jsonEncode(keys.toList()));
              }
            }
          : null,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.zero,
      showCheckmark: false,
      // Keep all horizontal space for the text and mark in the label's own
      // layout. RawChip measures the label before reserving its leading slot.
      label: Builder(
        builder: (BuildContext context) {
          final TextStyle style = DefaultTextStyle.of(context).style;
          return DefaultTextStyle(
            style: style,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: kMinInteractiveDimension,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.spacingSm,
                  vertical: tokens.spacingXs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (selected && showCheckmark) ...<Widget>[
                      Icon(
                        Icons.check,
                        size: tokens.spacing,
                        color: style.color,
                      ),
                      SizedBox(width: tokens.spacingXs),
                    ],
                    Flexible(child: Text(option.value)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
