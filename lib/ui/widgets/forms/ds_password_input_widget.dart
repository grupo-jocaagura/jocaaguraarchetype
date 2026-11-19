part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A single-line password field with consumer-owned value and validation.
///
/// The password starts hidden and is hidden again when focus leaves the field
/// and its visibility button. The button is available while editing. Paste
/// remains available while editing, and the field blocks copy and cut.
///
/// Defaults to [AutofillHints.password]. Pass [AutofillHints.newPassword] as
/// the hint for a new password, or pass null to disable autofill.
/// Keep the password in memory only as long as needed. Avoid logging or
/// persisting the [ModelFieldState] passed to callbacks, since it contains
/// the raw password.
class DsPasswordInputWidget extends DsTextInputWidget {
  const DsPasswordInputWidget({
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
    String showPasswordLabel = 'Show password',
    String hidePasswordLabel = 'Hide password',
    super.key,
  }) : super._password(
         passwordLabels: (show: showPasswordLabel, hide: hidePasswordLabel),
       );
}

class _DsPasswordSelectionControls extends MaterialTextSelectionControls {
  @override
  bool canCopy(TextSelectionDelegate delegate) => false;

  @override
  bool canCut(TextSelectionDelegate delegate) => false;

  @override
  Future<void> handlePaste(TextSelectionDelegate delegate) async {
    // Flutter 3.50 invokes this legacy hook before pasting again for
    // SemanticsAction.paste. The toolbar below uses EditableText's paste
    // action directly, so let EditableText perform each paste once.
  }

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ValueListenable<ClipboardStatus>? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    final EditableTextState editor = delegate as EditableTextState;
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editor.contextMenuAnchors,
      buttonItems: editor.contextMenuButtonItems
          .where(
            (ContextMenuButtonItem item) =>
                item.type == ContextMenuButtonType.paste ||
                item.type == ContextMenuButtonType.selectAll,
          )
          .toList(),
    );
  }
}
