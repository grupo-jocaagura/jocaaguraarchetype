part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// App-level button with Material 3 variants and responsive sizing.
///
/// See previous description (se mantiene igual).
class MyAppButtonWidget extends StatelessWidget {
  const MyAppButtonWidget({
    required this.responsive,
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.filled,
    this.size = AppButtonSize.medium,
    this.loading = false,
    this.enabled = true,
    this.leadingIcon,
    this.trailingIcon,
    this.leading,
    this.trailing,
    this.fullWidth = false,
    this.maxWidthColumns,
    this.tooltip,
    this.semanticsLabel,
    this.danger = false,
  });

  final BlocResponsive responsive;
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final bool enabled;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? leading;
  final Widget? trailing;
  final bool fullWidth;
  final int? maxWidthColumns;
  final String? tooltip;
  final String? semanticsLabel;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    if (context.mounted) {
      responsive.setSizeFromContext(context);
    }

    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final _SizeTokens t = _resolveSizeTokens(responsive, size);
    final bool isEnabled = enabled && onPressed != null && !loading;

    final Widget? leadingWidget = leading ??
        (leadingIcon != null
            ? Icon(
                leadingIcon,
                size: t.icon,
                color: _iconColor(scheme, isEnabled),
              )
            : null);
    final Widget? trailingWidget = trailing ??
        (trailingIcon != null
            ? Icon(
                trailingIcon,
                size: t.icon,
                color: _iconColor(scheme, isEnabled),
              )
            : null);

    final Widget content = _buildContent(
      context: context,
      textTheme: textTheme,
      spacing: t.gap,
      leading: leadingWidget,
      trailing: trailingWidget,
      minHeight: t.minHeight,
      labelStyle: _labelTextStyle(textTheme, t),
      scheme: scheme,
      isEnabled: isEnabled,
    );

    final ButtonStyle style = _buildStyle(
      scheme: scheme,
      t: t,
      danger: danger,
    );

    final Widget button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
          onPressed: isEnabled ? onPressed : null,
          style: style,
          child: content,
        ),
      AppButtonVariant.tonal => FilledButton.tonal(
          onPressed: isEnabled ? onPressed : null,
          style: style,
          child: content,
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: style,
          child: content,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: style,
          child: content,
        ),
    };

    final double? maxW = (maxWidthColumns != null)
        ? responsive.widthByColumns(
            maxWidthColumns!.clamp(1, responsive.columnsNumber),
          )
        : null;

    final Widget constrained = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: t.minHeight,
        maxWidth: maxW ?? double.infinity,
      ),
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        child: button,
      ),
    );

    final Widget withTooltip = (tooltip == null)
        ? constrained
        : Tooltip(message: tooltip, child: constrained);

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticsLabel ?? label,
      value: loading ? 'Loading' : null,
      child: withTooltip,
    );
  }

  // ---------- content ----------
  Widget _buildContent({
    required BuildContext context,
    required TextTheme textTheme,
    required double spacing,
    required Widget? leading,
    required Widget? trailing,
    required double minHeight,
    required TextStyle labelStyle,
    required ColorScheme scheme,
    required bool isEnabled,
  }) {
    final Widget labelText = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: labelStyle,
        textAlign: TextAlign.center,
      ),
    );

    final List<Widget> rowChildren = <Widget>[
      if (leading != null) ...<Widget>[leading, SizedBox(width: spacing)],
      labelText,
      if (trailing != null) ...<Widget>[SizedBox(width: spacing), trailing],
    ];

    final Widget baseRow = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: spacing, vertical: spacing * 0.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowChildren,
        ),
      ),
    );

    if (!loading) {
      return baseRow;
    }

    final Color spinnerColor = switch (variant) {
      AppButtonVariant.filled ||
      AppButtonVariant.tonal =>
        (danger ? scheme.onError : scheme.onPrimary),
      AppButtonVariant.outlined ||
      AppButtonVariant.text =>
        (danger ? scheme.error : scheme.primary),
    };

    final double spinner = (minHeight * 0.5).clamp(14.0, 20.0);

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Opacity(opacity: 0.0, child: baseRow),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: spinner,
              height: spinner,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- style (WidgetStateProperty) ----------
  ButtonStyle _buildStyle({
    required ColorScheme scheme,
    required _SizeTokens t,
    required bool danger,
  }) {
    final BorderRadius radius = BorderRadius.circular(12);

    // Colors depending on variant and danger flag.
    final Color bgFilled = danger ? scheme.error : scheme.primary;
    final Color fgFilled = danger ? scheme.onError : scheme.onPrimary;

    final Color bgTonal =
        danger ? scheme.errorContainer : scheme.secondaryContainer;
    final Color fgTonal =
        danger ? scheme.onErrorContainer : scheme.onSecondaryContainer;

    final Color fgPlain = danger ? scheme.error : scheme.primary;

    Color? background(Set<WidgetState> states) {
      if (variant == AppButtonVariant.filled) {
        return bgFilled;
      }
      if (variant == AppButtonVariant.tonal) {
        return bgTonal;
      }
      return null; // outlined/text use transparent background
    }

    Color? foreground(Set<WidgetState> states) {
      if (variant == AppButtonVariant.filled) {
        return fgFilled;
      }
      if (variant == AppButtonVariant.tonal) {
        return fgTonal;
      }
      return fgPlain; // outlined/text foreground
    }

    Color? overlay(Set<WidgetState> states) {
      final bool pressed = states.contains(WidgetState.pressed);
      final bool hovered = states.contains(WidgetState.hovered);
      final bool focused = states.contains(WidgetState.focused);
      final double o = pressed
          ? 0.16
          : (hovered || focused)
              ? 0.10
              : 0.06;
      final Color base = danger ? scheme.error : scheme.primary;
      return base.withValues(alpha: o);
    }

    OutlinedBorder shape(Set<WidgetState> states) =>
        RoundedRectangleBorder(borderRadius: radius);

    BorderSide? side(Set<WidgetState> states) {
      if (variant != AppButtonVariant.outlined) {
        return null;
      }
      final Color c = danger ? scheme.error : scheme.outline;
      return BorderSide(color: c);
    }

    return ButtonStyle(
      minimumSize: WidgetStateProperty.all<Size>(Size(t.minWidth, t.minHeight)),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
      shape: WidgetStateProperty.resolveWith<OutlinedBorder>(shape),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(background),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(foreground),
      overlayColor: WidgetStateProperty.resolveWith<Color?>(overlay),
      side: WidgetStateProperty.resolveWith<BorderSide?>(side),
      // textStyle: se hereda del contenido; no se fuerza aquí.
      enableFeedback: true,
    );
  }

  TextStyle _labelTextStyle(TextTheme textTheme, _SizeTokens t) {
    final TextStyle base = (t.text == _TextToken.large)
        ? textTheme.labelLarge ??
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)
        : textTheme.labelMedium ??
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
    return base.copyWith(letterSpacing: 0.2);
  }

  Color _iconColor(ColorScheme scheme, bool isEnabled) {
    return isEnabled
        ? scheme.onSurface
        : scheme.onSurface.withValues(alpha: 0.38);
  }
}

/// Button visual variant.
enum AppButtonVariant { filled, tonal, outlined, text }

/// Button sizing token.
enum AppButtonSize { small, medium, large }

class _SizeTokens {
  const _SizeTokens({
    required this.minHeight,
    required this.minWidth,
    required this.icon,
    required this.gap,
    required this.text,
  });
  final double minHeight;
  final double minWidth;
  final double icon;
  final double gap;
  final _TextToken text;
}

enum _TextToken { medium, large }

_SizeTokens _resolveSizeTokens(BlocResponsive r, AppButtonSize size) {
  final double cw = r.columnWidth;

  switch (size) {
    case AppButtonSize.small:
      return _SizeTokens(
        minHeight: (cw * 0.70).clamp(36.0, 40.0),
        minWidth: (r.widthByColumns(2) * 0.6).clamp(80.0, 140.0),
        icon: (cw * 0.38).clamp(16.0, 18.0),
        gap: r.gutterWidth.clamp(8.0, 14.0),
        text: _TextToken.medium,
      );
    case AppButtonSize.medium:
      return _SizeTokens(
        minHeight: (cw * 0.85).clamp(40.0, 48.0),
        minWidth: (r.widthByColumns(2) * 0.8).clamp(120.0, 200.0),
        icon: (cw * 0.44).clamp(18.0, 20.0),
        gap: r.gutterWidth.clamp(8.0, 16.0),
        text: _TextToken.large,
      );
    case AppButtonSize.large:
      return _SizeTokens(
        minHeight: (cw * 1.10).clamp(48.0, 56.0),
        minWidth: (r.widthByColumns(3) * 0.8).clamp(160.0, 280.0),
        icon: (cw * 0.50).clamp(20.0, 24.0),
        gap: (r.gutterWidth * 1.1).clamp(10.0, 18.0),
        text: _TextToken.large,
      );
  }
}
