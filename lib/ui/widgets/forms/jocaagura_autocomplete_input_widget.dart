part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

typedef JgTextAttempt = void Function(String text);

/// A declarative, controlled Autocomplete text input for Jocaagura apps.
///
/// This widget is designed for *controlled* UI flows driven by a BLoC:
/// - The parent is the **single source of truth** providing [value] and [errorText].
/// - The widget emits **user intents** via [onChangedAttempt] and [onSubmittedAttempt].
/// - No internal validation is performed; validation and formatting live in the BLoC.
///
/// ### Highlights
/// - Material Autocomplete with custom suggestions via [suggestList].
/// - Password-ready: [obscureText], visibility toggle, and [autofillHints].
/// - Accessibility: semantics label/hint, IME action configuration,
///   capitalization, autocorrect and suggestions flags.
/// - Overlay sizing: [maxOptionsHeight], [minOptionsWidth].
///
/// ### Usage (Controlled)
/// Provide `value` and `errorText` from your BLoC (streams/state), and handle
/// user intents with `onChangedAttempt` / `onSubmittedAttempt`.
///
/// ## Example
/// ```dart
/// // Inside your build:
/// return StreamBuilder<SessionFieldState>(
///   stream: blocSession.passwordStream, // emits {value, errorText, suggestions}
///   initialData: const SessionFieldState('', null, const []),
///   builder: (context, snapshot) {
///     final s = snapshot.data!;
///     return JocaaguraAutocompleteInputWidget(
///       label: 'Password',
///       placeholder: 'Enter your password',
///       value: s.value,
///       errorText: s.errorText,
///       suggestList: s.suggestions,
///       obscureText: true,
///       icondata: Icons.lock_outline,
///       textInputAction: TextInputAction.done,
///       autofillHints: const [AutofillHints.password],
///       onChangedAttempt: blocSession.onPasswordChangedAttempt,
///       onSubmittedAttempt: blocSession.onPasswordSubmittedAttempt,
///     );
///   },
/// );
/// ```
///
/// See a full `BlocSession` sketch below the widget definition.
///
class JocaaguraAutocompleteInputWidget extends StatefulWidget {
  const JocaaguraAutocompleteInputWidget({
    // Controlled inputs:
    required this.value,
    required this.onChangedAttempt,
    super.key,
    this.errorText,
    this.onSubmittedAttempt,
    // Autocomplete:
    this.suggestList,
    // Look & feel:
    this.label = '',
    this.placeholder = '',
    this.icondata,
    // Text config:
    this.textInputType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.autofillHints,
    // Accessibility:
    this.semanticsLabel,
    this.semanticsHint,
    // Overlay sizing:
    this.maxOptionsHeight = 240,
    this.minOptionsWidth = 280,
    // Password helpers:
    this.obscureText = false,
    this.showToggleObscure = true,
  });

  // ----- Controlled props -----
  /// Current text value controlled by the parent (BLoC).
  final String value;

  /// Current error text provided by the parent (BLoC).
  final String? errorText;

  /// Emits raw user text changes (pre-validation).
  final JgTextAttempt onChangedAttempt;

  /// Emits raw submitted value (e.g., IME "done" or fieldComplete).
  final JgTextAttempt? onSubmittedAttempt;

  // ----- Autocomplete -----
  /// Suggestions to be filtered with a simple `contains` strategy.
  final List<String>? suggestList;

  // ----- Look & feel -----
  final String label;
  final String placeholder;
  final IconData? icondata;

  // ----- Text config -----
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final Iterable<String>? autofillHints;

  // ----- Accessibility -----
  final String? semanticsLabel;
  final String? semanticsHint;

  // ----- Overlay sizing -----
  final double maxOptionsHeight;
  final double minOptionsWidth;

  // ----- Password helpers -----
  /// If true, the input is obscured (password-like field).
  final bool obscureText;

  /// If true and [obscureText] is enabled, shows an eye icon to toggle.
  final bool showToggleObscure;

  @override
  State<JocaaguraAutocompleteInputWidget> createState() =>
      _JocaaguraAutocompleteInputWidgetState();
}

class _JocaaguraAutocompleteInputWidgetState
    extends State<JocaaguraAutocompleteInputWidget> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: widget.value),
      optionsBuilder: (TextEditingValue tev) {
        if (tev.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        final List<String> base = widget.suggestList ?? const <String>[];
        final String q = tev.text.toLowerCase();
        return base.where((String s) => s.toLowerCase().contains(q));
      },
      optionsViewBuilder:
          (_, void Function(String) onSelected, Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: widget.maxOptionsHeight,
                minWidth: widget.minOptionsWidth,
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, int i) {
                  final String option = options.elementAt(i);
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      onSelected(option);
                      // Parent must update `value` via onChangedAttempt → state.
                      widget.onChangedAttempt(option);
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: (String val) {
        widget.onChangedAttempt(val);
        FocusScope.of(context).unfocus();
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController controller,
        FocusNode focusNode,
        void Function() onEditingComplete,
      ) {
        // Keep controller in sync with external value.
        if (controller.text != widget.value) {
          controller.value = controller.value.copyWith(
            text: widget.value,
            selection: TextSelection.collapsed(offset: widget.value.length),
          );
        }

        final InputDecoration decoration = InputDecoration(
          prefixIcon: widget.icondata != null ? Icon(widget.icondata) : null,
          label: widget.label.isNotEmpty ? Text(widget.label) : null,
          hintText: widget.placeholder,
          errorText: widget.errorText,
          suffixIcon: (widget.obscureText && widget.showToggleObscure)
              ? IconButton(
                  tooltip: _obscure ? 'Show' : 'Hide',
                  icon:
                      Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.orange),
          ),
        );

        final TextField textField = TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: widget.textInputType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          autofillHints: widget.autofillHints,
          obscureText: _obscure,
          onChanged: widget.onChangedAttempt,
          onEditingComplete: () {
            widget.onSubmittedAttempt?.call(controller.text);
            onEditingComplete();
            FocusScope.of(context).unfocus();
          },
          decoration: decoration,
        );

        return Semantics(
          label: widget.semanticsLabel ?? widget.label,
          hint: widget.semanticsHint ?? widget.placeholder,
          textField: true,
          child: textField,
        );
      },
    );
  }
}
