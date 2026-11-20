part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Lays out the primary and optional secondary actions of a form.
///
/// A visible secondary action precedes the primary in layout and keyboard
/// traversal. The actions share the width in a row when their scaled labels
/// fit, and stack at full width when more space is needed. Give the group at
/// least 48 logical pixels of width and room to grow vertically.
///
/// The caller owns each action's state and responds to activation requests.
/// Loading and visibility are independent for each action.
class DsFormActionsWidget extends StatelessWidget {
  const DsFormActionsWidget({
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.primaryState = const ModelInteractiveState(
      semantic: ModelInteractiveSemantic.primary,
    ),
    this.secondaryState = const ModelInteractiveState(
      semantic: ModelInteractiveSemantic.secondary,
    ),
    this.primaryLoadingSemanticLabel = 'Loading',
    this.secondaryLoadingSemanticLabel = 'Loading',
    super.key,
  });

  /// Nonblank visible and accessible name of the primary action.
  final String primaryLabel;

  /// Called when the primary action is activated and its state allows it.
  final VoidCallback onPrimary;

  /// Nonblank name of the secondary action, or null to omit it.
  final String? secondaryLabel;

  /// Called on secondary activation. A visible action is disabled if null.
  final VoidCallback? onSecondary;

  /// Controlled interaction state and semantic intent of the primary action.
  final ModelInteractiveState primaryState;

  /// Controlled interaction state and semantic intent of the secondary action.
  final ModelInteractiveState secondaryState;

  /// Localizable status announced while the primary action is loading.
  final String primaryLoadingSemanticLabel;

  /// Localizable status announced while the secondary action is loading.
  final String secondaryLoadingSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final List<_DsActionButton> actions = <_DsActionButton>[
      if (secondaryLabel != null && secondaryState.isVisible)
        DsSecondaryButtonWidget(
          label: secondaryLabel!,
          onPressed: onSecondary ?? _noop,
          state: onSecondary == null
              ? secondaryState.copyWith(isEnabled: false)
              : secondaryState,
          loadingSemanticLabel: secondaryLoadingSemanticLabel,
        ),
      if (primaryState.isVisible)
        DsPrimaryButtonWidget(
          label: primaryLabel,
          onPressed: onPrimary,
          state: primaryState,
          loadingSemanticLabel: primaryLoadingSemanticLabel,
        ),
    ];
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (actions.length == 1) {
            return SizedBox(
              width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
              child: actions.single,
            );
          }

          final ModelDsExtendedTokens tokens = _itemTokensOf(context);
          final double gap = tokens.spacingSm;
          final double rowWidth =
              2 *
                  max(
                    actions.first._widthForLabel(context, tokens),
                    actions.last._widthForLabel(context, tokens),
                  ) +
              gap;
          final double width = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : max(constraints.minWidth, rowWidth);
          final bool horizontal = width >= rowWidth;
          final int flex = horizontal ? 1 : 0;
          return SizedBox(
            width: width,
            child: Flex(
              direction: horizontal ? Axis.horizontal : Axis.vertical,
              mainAxisSize: horizontal ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: horizontal
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(flex: flex, fit: FlexFit.tight, child: actions.first),
                SizedBox.square(dimension: gap),
                Flexible(flex: flex, fit: FlexFit.tight, child: actions.last),
              ],
            ),
          );
        },
      ),
    );
  }

  static void _noop() {}
}
