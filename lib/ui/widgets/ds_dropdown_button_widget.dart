part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A borderless, controlled single-value selector for a Material layout.
///
/// Give it a localized [label] or [semanticLabel]. Use [isExpanded] inside a
/// bounded width, for example when composing with an [InputDecorator]. Allow
/// at least 48 logical pixels on both axes and room for option text to wrap.
class DsDropdownButtonWidget<T extends Object> extends StatelessWidget {
  const DsDropdownButtonWidget({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.placeholder,
    this.state,
    this.enabled = true,
    this.label,
    this.semanticLabel,
    this.isExpanded = false,
    super.key,
  });

  /// Current selection. A null or removed value displays [placeholder].
  final T? value;

  /// Options with unique, non-null values and display-only children.
  ///
  /// For plain text that follows the DS typography, use [DsTextBodyLargeWidget]
  /// for a short label or [DsTextParagraphWidget] with [DsTextStyleKey.bodyLarge]
  /// when the label needs multiple lines.
  final List<DropdownMenuItem<T>> items;

  /// Called for a different option that is still present and enabled.
  final ValueChanged<T> onChanged;

  /// Localized prompt for the empty selection.
  final String placeholder;

  /// Controlled visibility and availability. Required when [value] is set.
  final ModelInteractiveState? state;

  /// Whether interaction is allowed in addition to [state].
  final bool enabled;

  /// Optional visible field label, styled using [TextTheme.labelLarge].
  final String? label;

  /// Name for assistive technology when the label is supplied by a parent.
  final String? semanticLabel;

  /// Whether the selector fills the available width.
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final ModelInteractiveState? interactiveState = state;
    if (value != null && interactiveState == null) {
      throw ArgumentError.notNull('state (required when value is set)');
    }
    if (interactiveState?.isVisible == false) {
      return const SizedBox.shrink();
    }

    final String visibleLabel = label?.trim() ?? '';
    final String accessibleLabel = semanticLabel?.trim() ?? '';
    if (visibleLabel.isEmpty && accessibleLabel.isEmpty) {
      throw ArgumentError('Provide a nonblank label or semanticLabel.');
    }
    if (placeholder.trim().isEmpty) {
      throw ArgumentError.value(placeholder, 'placeholder', 'Name the prompt.');
    }

    final Map<T, DropdownMenuItem<T>> options = <T, DropdownMenuItem<T>>{};
    for (final DropdownMenuItem<T> item in items) {
      final T? optionValue = item.value;
      if (optionValue == null || options.containsKey(optionValue)) {
        throw ArgumentError.value(
          optionValue,
          'items',
          'Option values must be unique and non-null.',
        );
      }
      options[optionValue] = item;
    }

    final ThemeData theme = Theme.of(context);
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final T? selection = options.containsKey(value) ? value : null;
    final String fieldName = accessibleLabel.isEmpty
        ? visibleLabel
        : accessibleLabel;
    final bool canOpen =
        enabled &&
        (interactiveState?.canInteract ?? true) &&
        options.isNotEmpty;
    final Widget dropdown = DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: selection,
        items: <DropdownMenuItem<T>>[
          for (final MapEntry<T, DropdownMenuItem<T>> entry in options.entries)
            DropdownMenuItem<T>(
              key: entry.value.key,
              value: entry.key,
              enabled: entry.value.enabled,
              alignment: entry.value.alignment,
              child: Semantics(
                enabled: entry.value.enabled,
                // The menu route can sit above the trigger's local MediaQuery.
                child: Builder(
                  builder: (BuildContext context) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: textScaler),
                    child: entry.value.child,
                  ),
                ),
              ),
            ),
        ],
        // Render the current option with the field's availability semantics.
        selectedItemBuilder: (BuildContext context) => <Widget>[
          for (final DropdownMenuItem<T> item in options.values)
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: kMinInteractiveDimension,
              ),
              child: Align(alignment: item.alignment, child: item.child),
            ),
        ],
        onChanged: canOpen
            ? (T? next) {
                // The open route can hold an older list. Validate against the
                // current widget before dispatching either of the callbacks.
                final DropdownMenuItem<T>? option = options[next];
                if (next == null || option == null || !option.enabled) {
                  return;
                }
                option.onTap?.call();
                if (next != value) {
                  onChanged(next);
                }
              }
            : null,
        hint: Text(
          placeholder,
          softWrap: true,
          semanticsLabel: '$fieldName\n$placeholder',
        ),
        isExpanded: true,
        itemHeight: null,
        style: theme.textTheme.bodyLarge,
        padding: EdgeInsets.symmetric(horizontal: tokens.spacingSm),
        borderRadius: BorderRadius.circular(tokens.borderRadius),
        iconSize: tokens.spacingLg,
      ),
    );
    // Material supplies the button role and combined label through the hint.
    final Widget target = Semantics(
      button: selection != null,
      label: selection == null ? null : fieldName,
      enabled: canOpen,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: kMinInteractiveDimension),
        child: isExpanded ? dropdown : IntrinsicWidth(child: dropdown),
      ),
    );
    return Align(
      alignment: AlignmentDirectional.topStart,
      widthFactor: 1,
      heightFactor: 1,
      child: visibleLabel.isEmpty
          ? target
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ExcludeSemantics(
                  child: DsTextParagraphWidget(
                    label: visibleLabel,
                    role: DsTextStyleKey.labelLarge,
                    maxLines: visibleLabel.length,
                    overflow: TextOverflow.clip,
                  ),
                ),
                SizedBox(height: tokens.spacingXs),
                target,
              ],
            ),
    );
  }
}
