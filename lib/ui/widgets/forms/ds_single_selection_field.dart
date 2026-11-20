part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class _DsSingleSelectionField extends StatelessWidget {
  const _DsSingleSelectionField({
    required this.field,
    required this.onChangedAttempt,
    required this.options,
    required this.label,
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

  /// Localized, nonblank name of the field.
  final String label;

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

  String get _fieldName {
    final String name = label.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(label, 'label', 'Name the field.');
    }
    return name;
  }

  bool get _isReadOnly => enabled && readOnly;
  bool get _canChange => enabled && !readOnly;
  String? get _selection => options.contains(field.value) ? field.value : null;
  String? get _error => field.errorTextToInput;
  String? get _help => _error == null && helperText?.trim().isNotEmpty == true
      ? helperText
      : null;

  List<String> get _statusAnnouncements => <String>[
    if (required) requiredSemanticLabel,
    if (_isReadOnly) readOnlySemanticLabel,
  ];

  void _proposeSelection(String next) =>
      onChangedAttempt(field.copyWith(value: next, isDirty: true));

  String _optionLabel(String option) {
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
    return caption;
  }
}
