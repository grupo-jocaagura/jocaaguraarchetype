part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A grid action whose appearance and availability follow a controlled state.
///
/// The passive [DsItemWidget] supplies the layout. Activate via pointer,
/// keyboard or semantics; the caller owns the action and all state transitions.
class DsItemButtonWidget extends StatelessWidget {
  const DsItemButtonWidget({
    required this.child,
    required this.label,
    required this.onPressed,
    this.size,
    this.variant = DsSurfaceVariant.filled,
    this.state = const ModelInteractiveState(),
    this.loading = const DsLoadingWidget(),
    this.semanticLabel,
    this.loadingSemanticLabel = 'Loading',
    super.key,
  });

  final Widget child;
  final String label;
  final VoidCallback onPressed;
  final Size? size;
  final DsSurfaceVariant variant;
  final ModelInteractiveState state;
  final DsLoading loading;
  final String? semanticLabel;

  /// Localizable announcement while interaction is blocked by loading.
  final String loadingSemanticLabel;

  @override
  Widget build(BuildContext context) => DsInteractiveBuilder(
    state: state,
    enabledBuilder: _buildButton,
    disabledBuilder: (BuildContext context, ModelInteractiveState state) =>
        _buildButton(context, state, intent: ModelInteractiveSemantic.neutral),
    selectedBuilder: (BuildContext context, ModelInteractiveState state) =>
        _buildButton(context, state, marker: Icons.check, emphasized: true),
    errorBuilder: (BuildContext context, ModelInteractiveState state) =>
        _buildButton(
          context,
          state,
          intent: ModelInteractiveSemantic.danger,
          marker: Icons.error_outline,
          emphasized: true,
        ),
    loadingBuilder: (BuildContext context, ModelInteractiveState state) =>
        _buildButton(context, state, showLoading: true),
  );

  Widget _buildButton(
    BuildContext context,
    ModelInteractiveState state, {
    ModelInteractiveSemantic? intent,
    IconData? marker,
    bool emphasized = false,
    bool showLoading = false,
  }) {
    final ThemeData theme = Theme.of(context);
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    final _DsSurfaceAppearance appearance = _DsSurfaceAppearance.resolve(
      theme,
      variant,
      intent: intent ?? state.semantic,
      emphasized: emphasized,
    );
    final VoidCallback? activate = state.canInteract ? onPressed : null;
    final String? feedback = state.feedbackTextToInput?.trim();
    final String? accessibleLabel = semanticLabel?.trim();
    Widget visual = child;
    if (showLoading) {
      visual = ProgressIndicatorTheme(
        data: theme.progressIndicatorTheme.copyWith(
          color: appearance.foreground,
        ),
        child: SizedBox.square(dimension: tokens.spacingLg, child: loading),
      );
    } else if (marker != null) {
      visual = Row(
        children: <Widget>[
          Expanded(child: Center(child: child)),
          Flexible(child: Icon(marker, size: tokens.spacing)),
        ],
      );
    }

    final Widget button = Semantics(
      container: true,
      button: true,
      enabled: state.canInteract,
      selected: state.isSelected,
      label: accessibleLabel == null || accessibleLabel.isEmpty
          ? label
          : accessibleLabel,
      value: showLoading ? loadingSemanticLabel : null,
      hint: feedback == null || feedback.isEmpty ? null : feedback,
      onTap: activate,
      child: ExcludeSemantics(
        child: Stack(
          children: <Widget>[
            IgnorePointer(
              child: DsItemWidget._styled(
                label: label,
                size: size,
                variant: variant,
                appearance: appearance,
                child: visual,
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                borderRadius: BorderRadius.circular(tokens.borderRadius),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: activate,
                  canRequestFocus: state.canInteract,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return feedback == null || feedback.isEmpty
        ? button
        : Tooltip(message: feedback, excludeFromSemantics: true, child: button);
  }
}
