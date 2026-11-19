part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A circular icon action with a 32 px surface centered in a 48 px target.
///
/// Give the control at least 48 logical pixels on both axes. The caller owns
/// [state] and the action. Supply a localized name for that action in
/// [semanticLabel], such as “Add item”.
class DsIconButtonWidget extends StatelessWidget {
  const DsIconButtonWidget({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.selectedIcon,
    this.variant = DsSurfaceVariant.filled,
    this.state = const ModelInteractiveState(),
    this.loading = const DsLoadingWidget(),
    this.loadingSemanticLabel = 'Loading',
    super.key,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String semanticLabel;
  final VoidCallback onPressed;
  final DsSurfaceVariant variant;
  final ModelInteractiveState state;
  final DsLoading loading;

  /// Localizable state announced separately from the action name.
  final String loadingSemanticLabel;

  static const double _surfaceDiameter = 32;
  static const double _glyphSize = 16;
  static const double _markerSize = 10;

  @override
  Widget build(BuildContext context) {
    if (semanticLabel.trim().isEmpty) {
      throw ArgumentError.value(
        semanticLabel,
        'semanticLabel',
        'Name the action.',
      );
    }
    return DsInteractiveBuilder(
      state: state,
      enabledBuilder: _buildButton,
      disabledBuilder: (BuildContext context, ModelInteractiveState state) =>
          _buildButton(
            context,
            state,
            intent: ModelInteractiveSemantic.neutral,
          ),
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
  }

  Widget _buildButton(
    BuildContext context,
    ModelInteractiveState state, {
    ModelInteractiveSemantic? intent,
    IconData? marker,
    bool emphasized = false,
    bool showLoading = false,
  }) {
    final ThemeData theme = Theme.of(context);
    final _DsSurfaceAppearance appearance = _DsSurfaceAppearance.resolve(
      theme,
      variant,
      intent: intent ?? state.semantic,
      emphasized: emphasized,
    );
    final String name = semanticLabel.trim();
    final String feedback = state.feedbackTextToInput?.trim() ?? '';
    final VoidCallback? activate = state.canInteract ? onPressed : null;
    final Widget surface = SizedBox.square(
      dimension: _surfaceDiameter,
      child: Material(
        color: appearance.background,
        shape: CircleBorder(
          side: appearance.border == null
              ? BorderSide.none
              : BorderSide(
                  color: appearance.border!,
                  width: appearance.emphasized ? 2 : 1,
                ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (showLoading)
              ProgressIndicatorTheme(
                data: theme.progressIndicatorTheme.copyWith(
                  color: appearance.foreground,
                ),
                child: SizedBox.square(
                  dimension: _glyphSize,
                  child: ClipRect(child: loading),
                ),
              )
            else
              DsIconWidget(
                icon: state.isSelected ? selectedIcon ?? icon : icon,
                size: _glyphSize,
                color: appearance.foreground,
              ),
            if (marker != null)
              PositionedDirectional(
                end: 3,
                bottom: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: appearance.background,
                    shape: BoxShape.circle,
                  ),
                  child: DsIconWidget(
                    icon: marker,
                    size: _markerSize,
                    color: appearance.foreground,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    final Widget target = Tooltip(
      message: feedback.isEmpty ? name : feedback,
      excludeFromSemantics: true,
      child: Focus(
        canRequestFocus: false,
        includeSemantics: false,
        child: Builder(
          builder: (BuildContext context) {
            final bool focused =
                state.canInteract && Focus.of(context).hasFocus;
            return Semantics(
              container: true,
              button: true,
              enabled: state.canInteract,
              focusable: state.canInteract,
              focused: focused,
              selected: state.isSelected,
              label: name,
              hint: feedback.isEmpty ? null : feedback,
              value: showLoading ? loadingSemanticLabel : null,
              onTap: activate,
              child: ExcludeSemantics(
                child: SizedBox.square(
                  dimension: kMinInteractiveDimension,
                  child: Material(
                    color: Colors.transparent,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        InkWell(
                          onTap: activate,
                          canRequestFocus: state.canInteract,
                          customBorder: const CircleBorder(),
                          child: Center(child: surface),
                        ),
                        if (focused)
                          IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.onSurface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    return Center(widthFactor: 1, heightFactor: 1, child: target);
  }
}
