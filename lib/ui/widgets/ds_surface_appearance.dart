part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Visual treatment shared by DS surfaces.
enum DsSurfaceVariant { filled, outlined }

class _DsSurfaceAppearance {
  const _DsSurfaceAppearance(
    this.background,
    this.foreground,
    this.border,
    this.emphasized,
  );

  final Color background;
  final Color foreground;
  final Color? border;
  final bool emphasized;

  static _DsSurfaceAppearance resolve(
    ThemeData theme,
    DsSurfaceVariant variant, {
    ModelInteractiveSemantic intent = ModelInteractiveSemantic.neutral,
    bool emphasized = false,
  }) {
    final ColorScheme colors = theme.colorScheme;
    final (Color container, Color onContainer, Color accent) = switch (intent) {
      ModelInteractiveSemantic.primary => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
        colors.primary,
      ),
      ModelInteractiveSemantic.secondary => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
        colors.secondary,
      ),
      ModelInteractiveSemantic.neutral => (
        colors.surfaceContainerHighest,
        colors.onSurface,
        emphasized ? colors.primary : colors.outline,
      ),
      ModelInteractiveSemantic.danger => (
        colors.errorContainer,
        colors.onErrorContainer,
        colors.error,
      ),
      ModelInteractiveSemantic.success ||
      ModelInteractiveSemantic.warning => _positivePalette(theme, intent),
    };
    return switch (variant) {
      DsSurfaceVariant.filled => _DsSurfaceAppearance(
        container,
        onContainer,
        emphasized ? accent : null,
        emphasized,
      ),
      DsSurfaceVariant.outlined => _DsSurfaceAppearance(
        colors.surface,
        colors.onSurface,
        accent,
        emphasized,
      ),
    };
  }

  static (Color, Color, Color) _positivePalette(
    ThemeData theme,
    ModelInteractiveSemantic intent,
  ) {
    final ModelSemanticColors semantic =
        theme.extension<DsSemanticColorsExtension>()?.semantic ??
        (theme.brightness == Brightness.dark
            ? ModelSemanticColors.fallbackDark()
            : ModelSemanticColors.fallbackLight());
    return intent == ModelInteractiveSemantic.success
        ? (
            semantic.successContainer,
            semantic.onSuccessContainer,
            semantic.success,
          )
        : (
            semantic.warningContainer,
            semantic.onWarningContainer,
            semantic.warning,
          );
  }
}
