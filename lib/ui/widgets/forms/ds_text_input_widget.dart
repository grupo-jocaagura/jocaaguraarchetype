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
  }) : assert(maxLines > 0),
       _passwordLabels = null;

  const DsTextInputWidget._password({
    required this.field,
    required this.onChangedAttempt,
    required this.label,
    required this._passwordLabels,
    this.onSubmittedAttempt,
    this.placeholder,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.textInputAction,
    this.autofillHints = const <String>[AutofillHints.password],
    this.requiredSemanticLabel = 'Required',
    this.readOnlySemanticLabel = 'Read only',
    super.key,
  }) : textInputType = TextInputType.visiblePassword,
       maxLines = 1;

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

  final ({String show, String hide})? _passwordLabels;

  bool get _enableKeyboardAssistance => _passwordLabels == null;

  @override
  State<DsTextInputWidget> createState() => _DsTextInputWidgetState();
}

class _DsTextInputWidgetState extends State<DsTextInputWidget> {
  static final _DsPasswordSelectionControls _passwordSelectionControls =
      _DsPasswordSelectionControls();

  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  FocusNode? _passwordFocus;
  VoidCallback? _removeClipboardListener;
  bool _hasUnacceptedEdit = false;
  bool _revealed = false;

  bool get _canEdit => widget.enabled && !widget.readOnly;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.field.value);
    if (widget._passwordLabels != null) {
      _passwordFocus = FocusNode(debugLabel: 'Password input');
      _removeClipboardListener = blockPasswordClipboard(
        () => _focusNode.hasFocus,
      );
    } else if (kIsWeb) {
      _focusNode.addListener(_syncReadOnlyCopyListener);
    }
  }

  @override
  void didUpdateWidget(covariant DsTextInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kIsWeb && widget._passwordLabels == null) {
      _syncReadOnlyCopyListener();
    }
    if (!_canEdit) {
      _revealed = false;
    }
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

  void _syncReadOnlyCopyListener() {
    if (_focusNode.hasFocus && widget.enabled && widget.readOnly) {
      _removeClipboardListener ??= listenToReadOnlyCopy(() {
        final TextEditingValue value = _controller.value;
        final TextSelection selection = value.selection;
        return selection.isValid && !selection.isCollapsed
            ? selection.textInside(value.text)
            : null;
      });
      return;
    }
    _removeClipboardListener?.call();
    _removeClipboardListener = null;
  }

  @override
  void dispose() {
    _removeClipboardListener?.call();
    _passwordFocus?.dispose();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _togglePassword() {
    if (!_canEdit) {
      return;
    }
    if (!_passwordFocus!.hasFocus) {
      _focusNode.requestFocus();
    }
    setState(() => _revealed = !_revealed);
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.label.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(widget.label, 'label', 'Name the field.');
    }

    final bool canEdit = _canEdit;
    final bool isReadOnly = widget.enabled && widget.readOnly;
    final ({String show, String hide})? passwordLabels = widget._passwordLabels;
    final bool isPassword = passwordLabels != null;
    final bool enableKeyboardAssistance = widget._enableKeyboardAssistance;
    final bool obscured = isPassword && (!_revealed || !canEdit);
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

    Widget input = TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.textInputType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      maxLines: widget.maxLines,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      obscureText: obscured,
      autocorrect: enableKeyboardAssistance ? null : false,
      enableSuggestions: enableKeyboardAssistance,
      enableIMEPersonalizedLearning: !isPassword,
      smartDashesType: enableKeyboardAssistance
          ? null
          : SmartDashesType.disabled,
      smartQuotesType: enableKeyboardAssistance
          ? null
          : SmartQuotesType.disabled,
      selectionControls: isPassword ? _passwordSelectionControls : null,
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
        suffixIcon: passwordLabels != null && canEdit
            ? DsIconButtonWidget(
                icon: obscured ? Icons.visibility : Icons.visibility_off,
                semanticLabel: obscured
                    ? passwordLabels.show
                    : passwordLabels.hide,
                variant: DsSurfaceVariant.outlined,
                onPressed: _togglePassword,
              )
            : null,
      ),
    );

    if (isPassword) {
      input = Focus(
        focusNode: _passwordFocus,
        canRequestFocus: false,
        includeSemantics: false,
        onFocusChange: (bool focused) {
          if (!focused && _revealed && mounted) {
            setState(() => _revealed = false);
          }
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            CopySelectionTextIntent: CallbackAction<CopySelectionTextIntent>(
              onInvoke: (CopySelectionTextIntent intent) => null,
            ),
          },
          child: input,
        ),
      );
    }

    if (kIsWeb && isReadOnly) {
      // Flutter web exposes native text-field semantics as an editable DOM
      // input even in read-only mode. Publish the field's name and status
      // separately, including the value only for ordinary text fields.
      final String? supportingText = error ?? help;
      final String description = <String>[
        if (status.isNotEmpty) status,
        if (_controller.text.isEmpty && widget.placeholder != null)
          widget.placeholder!,
        if (supportingText != null) supportingText,
      ].join('\n');
      if (!isPassword) {
        // The semantic node has no native selection. Select the editor's text
        // here and let the focused clipboard listener handle the copy event.
        input = Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.keyA, control: true):
                SelectAllTextIntent(SelectionChangedCause.keyboard),
            SingleActivator(LogicalKeyboardKey.keyA, meta: true):
                SelectAllTextIntent(SelectionChangedCause.keyboard),
          },
          child: input,
        );
      }
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
          value: isPassword ? null : _controller.text,
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
