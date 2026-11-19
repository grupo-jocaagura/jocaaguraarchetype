part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// An outlined Material text field with consumer-owned value and validation.
///
/// Edits propose a new [ModelFieldState]. Changing only validation leaves the
/// editor's current text, selection and IME composition in place. Use a new
/// [Key] to reset the editor to the same accepted value.
class DsTextInputWidget extends StatefulWidget {
  const DsTextInputWidget({
    required this.field,
    required this.onChangedAttempt,
    required this.label,
    this.onSubmittedAttempt,
    this.placeholder,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.textInputType,
    this.textInputAction,
    this.autofillHints,
    this.maxLines = 1,
    this.requiredSemanticLabel = 'Required',
    this.readOnlySemanticLabel = 'Read only',
    super.key,
  }) : assert(maxLines > 0);

  /// The accepted text and validation supplied by the consumer.
  final ModelFieldState field;

  /// Proposes the raw edited text with [ModelFieldState.isDirty] set to true.
  final ValueChanged<ModelFieldState> onChangedAttempt;

  /// Proposes the current editor text on a native keyboard submission.
  final ValueChanged<ModelFieldState>? onSubmittedAttempt;

  final String label;
  final String? placeholder;
  final String? helperText;

  /// Indicates a mandatory field. Validation belongs to the consumer.
  final bool required;

  final bool enabled;

  /// Allows an enabled field's text to be selected and copied without edits.
  final bool readOnly;

  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final int maxLines;

  /// Localizable status announced for a mandatory field.
  final String requiredSemanticLabel;

  /// Localizable status announced in read-only mode.
  final String readOnlySemanticLabel;

  @override
  State<DsTextInputWidget> createState() => _DsTextInputWidgetState();
}

class _DsTextInputWidgetState extends State<DsTextInputWidget> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _hasUnacceptedEdit = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.field.value);
  }

  @override
  void didUpdateWidget(covariant DsTextInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String text = widget.field.value;
    if (oldWidget.field.value == text) {
      return;
    }

    _hasUnacceptedEdit = false;
    final TextEditingValue current = _controller.value;
    if (current.text == text) {
      return;
    }

    final TextRange composing = _composingIn(current, text);
    final int shift = composing.isValid
        ? composing.start - current.composing.start
        : 0;
    int suffixStart = current.composing.start;
    if (shift != 0) {
      // The text from the composing range to the end is already known to
      // match. Include any unchanged text immediately before that range.
      while (suffixStart > 0 &&
          suffixStart + shift > 0 &&
          current.text.codeUnitAt(suffixStart - 1) ==
              text.codeUnitAt(suffixStart + shift - 1)) {
        suffixStart--;
      }
    }

    int newOffset(int offset) {
      return (offset + (offset >= suffixStart ? shift : 0)).clamp(
        0,
        text.length,
      );
    }

    _controller.value = TextEditingValue(
      text: text,
      selection: current.selection.isValid
          ? current.selection.copyWith(
              baseOffset: newOffset(current.selection.baseOffset),
              extentOffset: newOffset(current.selection.extentOffset),
            )
          : TextSelection.collapsed(offset: text.length),
      composing: composing,
    );
  }

  TextRange _composingIn(TextEditingValue current, String text) {
    final TextRange composing = current.composing;
    if (!current.isComposingRangeValid || composing.isCollapsed) {
      return TextRange.empty;
    }
    if (composing.end <= text.length &&
        composing.textInside(current.text) == composing.textInside(text)) {
      return composing;
    }
    // A change before an unchanged suffix can move the composing range.
    final String suffix = current.text.substring(composing.start);
    if (text.endsWith(suffix)) {
      final int start = text.length - suffix.length;
      return TextRange(
        start: start,
        end: start + composing.end - composing.start,
      );
    }
    return TextRange.empty;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.label.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(widget.label, 'label', 'Name the field.');
    }

    final bool canEdit = widget.enabled && !widget.readOnly;
    final bool isReadOnly = widget.enabled && widget.readOnly;
    final String? error = widget.field.errorTextToInput;
    final String? help =
        error == null && widget.helperText?.trim().isNotEmpty == true
        ? widget.helperText
        : null;
    final String status = <String>[
      if (widget.required) widget.requiredSemanticLabel,
      if (isReadOnly) widget.readOnlySemanticLabel,
    ].join('\n');
    final ThemeData theme = Theme.of(context);
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    final SemanticsValidationResult validation = error == null
        ? SemanticsValidationResult.none
        : SemanticsValidationResult.invalid;

    final Widget input = TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.textInputType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      maxLines: widget.maxLines,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      style: theme.textTheme.bodyLarge,
      onChanged: canEdit
          ? (String raw) {
              _hasUnacceptedEdit = true;
              widget.onChangedAttempt(
                widget.field.copyWith(value: raw, isDirty: true),
              );
            }
          : null,
      onSubmitted: canEdit && widget.onSubmittedAttempt != null
          ? (String raw) => widget.onSubmittedAttempt!(
              widget.field.copyWith(
                value: raw,
                isDirty: widget.field.isDirty || _hasUnacceptedEdit,
              ),
            )
          : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.borderRadius),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        label: Text(widget.required ? '$name *' : name, semanticsLabel: name),
        labelStyle: theme.textTheme.labelLarge,
        hintText: widget.placeholder,
        hintMaxLines: widget.maxLines,
        helperText: help,
        helperMaxLines: help?.length,
        errorText: error,
        errorMaxLines: error?.length,
      ),
    );

    if (kIsWeb && isReadOnly) {
      // Flutter web exposes native text-field semantics as an editable DOM
      // input even in read-only mode. Publish the readable value separately
      // and retain the native field's focus, selection and copy behavior.
      final String? supportingText = error ?? help;
      final String description = <String>[
        if (status.isNotEmpty) status,
        if (_controller.text.isEmpty && widget.placeholder != null)
          widget.placeholder!,
        if (supportingText != null) supportingText,
      ].join('\n');
      return ListenableBuilder(
        listenable: _focusNode,
        child: ExcludeSemantics(child: input),
        builder: (BuildContext context, Widget? child) => Semantics(
          container: true,
          enabled: true,
          readOnly: true,
          focusable: true,
          focused: _focusNode.hasFocus,
          onFocus: _focusNode.requestFocus,
          label: name,
          value: _controller.text,
          hint: description.isEmpty ? null : description,
          isRequired: widget.required,
          validationResult: validation,
          child: child,
        ),
      );
    }

    return Semantics(
      isRequired: widget.required,
      hint: status.isEmpty ? null : status,
      validationResult: validation,
      child: input,
    );
  }
}
