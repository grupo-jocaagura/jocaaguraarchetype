part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A passive icon with explicit, inherited, then DS appearance.
///
/// Size falls back to the theme's DS spacing token, or the default spacing token
/// when no DS extension is installed. Color falls back to onSurface.
/// A nonblank trimmed [semanticLabel] exposes one informational image node;
/// otherwise the icon is decorative. This widget never handles input.
class DsIconWidget extends StatelessWidget {
  const DsIconWidget({
    required this.icon,
    this.size,
    this.color,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;

  /// Logical size. A supplied value must be finite and positive.
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (size != null && (!size!.isFinite || size! <= 0)) {
      throw ArgumentError.value(size, 'size', 'Must be finite and positive.');
    }
    final IconThemeData? inherited = context
        .dependOnInheritedWidgetOfExactType<IconTheme>()
        ?.data
        .resolve(context);
    final ThemeData theme = Theme.of(context);
    final double resolvedSize =
        size ??
        inherited?.size ??
        theme.extension<DsExtendedTokensExtension>()?.tokens.spacing ??
        const ModelDsExtendedTokens().spacing;
    final Color resolvedColor =
        color ?? inherited?.color ?? theme.colorScheme.onSurface;
    final String label = semanticLabel?.trim() ?? '';
    final Widget glyph = ExcludeSemantics(
      child: Icon(icon, size: resolvedSize, color: resolvedColor),
    );
    return label.isEmpty
        ? glyph
        : Semantics(image: true, label: label, child: glyph);
  }
}
