part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A single-line field that requests a numeric keyboard.
///
/// Edits and submissions preserve the entered text, including leading zeros,
/// signs, separators and incomplete values. The consumer interprets and
/// validates [ModelFieldState.value].
class DsNumberInputWidget extends DsTextInputWidget {
  const DsNumberInputWidget({
    required super.field,
    required super.onChangedAttempt,
    required super.label,
    super.onSubmittedAttempt,
    super.placeholder,
    super.helperText,
    super.required,
    super.enabled,
    super.readOnly,
    super.textInputAction,
    super.autofillHints,
    super.requiredSemanticLabel,
    super.readOnlySemanticLabel,
    this.signed = false,
    this.decimal = false,
    super.key,
  });

  /// Requests a keyboard with a sign.
  final bool signed;

  /// Requests a keyboard with a decimal separator.
  final bool decimal;

  @override
  TextInputType get textInputType =>
      TextInputType.numberWithOptions(signed: signed, decimal: decimal);

  @override
  bool get _enableKeyboardAssistance => false;
}
