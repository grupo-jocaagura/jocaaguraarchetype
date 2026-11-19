part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A single-line email field with consumer-owned value and validation.
///
/// Edits and submissions preserve the entered text, including spaces and
/// case. Decide when to validate and normalize it in the consumer.
///
/// Autofill uses [AutofillHints.email] by default. Pass different hints for
/// the form's purpose, such as [AutofillHints.username] for sign-in, or pass
/// null to disable autofill. Supply a localized [label] and an optional
/// [placeholder].
class DsEmailInputWidget extends DsTextInputWidget {
  const DsEmailInputWidget({
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
    super.autofillHints = const <String>[AutofillHints.email],
    super.requiredSemanticLabel,
    super.readOnlySemanticLabel,
    super.key,
  }) : super(textInputType: TextInputType.emailAddress);

  @override
  bool get _enableKeyboardAssistance => false;
}
