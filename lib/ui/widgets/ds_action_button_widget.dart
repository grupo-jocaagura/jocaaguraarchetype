part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A filled, high-emphasis action such as saving or continuing.
///
/// Use a localized action [label]. The label wraps at the available width
/// using [TextTheme.labelLarge]. Allow at least 48 logical pixels on both axes
/// and room for the button to grow vertically when the text wraps.
class DsPrimaryButtonWidget extends _DsActionButton {
  const DsPrimaryButtonWidget({
    required super.label,
    required super.onPressed,
    super.icon,
    super.state = const ModelInteractiveState(
      semantic: ModelInteractiveSemantic.primary,
    ),
    super.loading,
    super.loadingSemanticLabel,
    super.key,
  }) : super(variant: DsSurfaceVariant.filled);
}

/// An outlined, lower-emphasis action such as canceling or going back.
///
/// Use a localized action [label]. The label wraps at the available width
/// using [TextTheme.labelLarge]. Allow at least 48 logical pixels on both axes
/// and room for the button to grow vertically when the text wraps.
class DsSecondaryButtonWidget extends _DsActionButton {
  const DsSecondaryButtonWidget({
    required super.label,
    required super.onPressed,
    super.icon,
    super.state = const ModelInteractiveState(
      semantic: ModelInteractiveSemantic.secondary,
    ),
    super.loading,
    super.loadingSemanticLabel,
    super.key,
  }) : super(variant: DsSurfaceVariant.outlined);
}

abstract class _DsActionButton extends StatelessWidget {
  const _DsActionButton({
    required this.label,
    required this.onPressed,
    required this.state,
    required this._variant,
    this.icon,
    this.loading = const DsLoadingWidget(),
    this.loadingSemanticLabel = 'Loading',
    super.key,
  });

  /// Visible and accessible name of the action. Must contain nonblank text.
  final String label;

  /// Called when the button is activated and [state] allows interaction.
  final VoidCallback onPressed;

  /// Controlled interaction state and semantic intent.
  final ModelInteractiveState state;

  /// Optional decorative icon at the start of the label.
  final IconData? icon;

  /// Replaces the default circular indicator in the leading slot.
  final DsLoading loading;

  /// Localizable status announced while the action is loading.
  final String loadingSemanticLabel;

  final DsSurfaceVariant _variant;

  double _widthForLabel(BuildContext context, ModelDsExtendedTokens tokens) {
    TextStyle style = DefaultTextStyle.of(context).style
        .merge(Theme.of(context).textTheme.labelLarge);
    if (MediaQuery.boldTextOf(context)) {
      style = style.merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    final double textWidth = TextPainter.computeWidth(
      text: TextSpan(text: label.trim(), style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
    );
    // Include the padding and the leading slot reserved by _buildButton.
    return max(
      kMinInteractiveDimension,
      textWidth + tokens.spacingSm * 2 + tokens.spacing + tokens.spacingXs,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) {
      throw ArgumentError.value(label, 'label', 'Name the action.');
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
          _buildButton(context, state, marker: Icons.check),
      errorBuilder: (BuildContext context, ModelInteractiveState state) =>
          _buildButton(
            context,
            state,
            intent: ModelInteractiveSemantic.danger,
            marker: Icons.error_outline,
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
    bool showLoading = false,
  }) {
    final ThemeData theme = Theme.of(context);
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    final _DsSurfaceAppearance appearance = _DsSurfaceAppearance.resolve(
      theme,
      _variant,
      intent: intent ?? state.semantic,
      emphasized: marker != null,
    );
    final String name = label.trim();
    final String feedback = state.feedbackTextToInput?.trim() ?? '';
    final VoidCallback? activate = state.canInteract ? onPressed : null;
    final RoundedRectangleBorder shape = _itemShape(tokens, appearance);
    final IconData? leadingIcon = marker ?? icon;
    final ThemeData labelTheme = theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        labelLarge: theme.textTheme.labelLarge?.copyWith(
          color: appearance.foreground,
        ),
      ),
    );
    final Widget? leading;
    if (showLoading) {
      leading = ProgressIndicatorTheme(
        data: theme.progressIndicatorTheme.copyWith(
          color: appearance.foreground,
        ),
        child: ClipRect(child: loading),
      );
    } else if (leadingIcon != null) {
      leading = DsIconWidget(
        icon: leadingIcon,
        size: tokens.spacing,
        color: appearance.foreground,
      );
    } else {
      leading = null;
    }

    // Paint the rounded surface separately so its border does not change
    // layout or clip the rectangular activation target.
    final Widget target = DecoratedBox(
      decoration: ShapeDecoration(color: appearance.background, shape: shape),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: activate,
          canRequestFocus: state.canInteract,
          customBorder: shape,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: kMinInteractiveDimension,
              minHeight: kMinInteractiveDimension,
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacingSm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Reserve space for the loading indicator with or without an icon.
                  SizedBox.square(dimension: tokens.spacing, child: leading),
                  SizedBox(width: tokens.spacingXs),
                  Flexible(
                    child: Theme(
                      data: labelTheme,
                      child: DsTextParagraphWidget(
                        label: name,
                        role: DsTextStyleKey.labelLarge,
                        // The paragraph requires a finite limit. Even at one
                        // character per line, this leaves room to wrap.
                        maxLines: name.length,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final Widget button = Focus(
      canRequestFocus: false,
      includeSemantics: false,
      child: Builder(
        builder: (BuildContext context) => Semantics(
          container: true,
          button: true,
          enabled: state.canInteract,
          focusable: state.canInteract,
          focused: state.canInteract && Focus.of(context).hasFocus,
          selected: state.isSelected,
          label: name,
          hint: feedback.isEmpty ? null : feedback,
          value: showLoading ? loadingSemanticLabel : null,
          liveRegion: showLoading,
          onTap: activate,
          child: ExcludeSemantics(child: target),
        ),
      ),
    );
    return feedback.isEmpty
        ? button
        : Tooltip(message: feedback, excludeFromSemantics: true, child: button);
  }
}
