part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Picks a builder based on the current [ScreenSizeEnum] reported by [BlocResponsive].
///
/// Useful when the UI needs different composition across breakpoints, without
/// sprinkling `if (isMobile)` everywhere.
///
/// - If a specific builder (e.g. [mobile]) is not provided, [fallback] is used.
/// - Metrics (margins, columns, gutters) come from [responsive].
///
/// ### Example
/// ```dart
/// ResponsiveSizeWidget(
///   responsive: resp,
///   mobile: (ctx, r) => const _MobileLayout(),
///   tablet: (ctx, r) => const _TabletLayout(),
///   desktop: (ctx, r) => const _DesktopLayout(),
///   // tv falls back to desktop if not provided
/// );
/// ```
class ResponsiveSizeWidget extends StatelessWidget {
  const ResponsiveSizeWidget({
    required this.responsive,
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.tv,
    this.fallback,
  });

  final BlocResponsive responsive;

  /// Builders per device class
  final Widget Function(BuildContext, BlocResponsive)? mobile;
  final Widget Function(BuildContext, BlocResponsive)? tablet;
  final Widget Function(BuildContext, BlocResponsive)? desktop;
  final Widget Function(BuildContext, BlocResponsive)? tv;

  /// Used when the specific builder is null.
  final Widget Function(BuildContext, BlocResponsive)? fallback;

  @override
  Widget build(BuildContext context) {
    // keep metrics in sync with current context
    if (context.mounted) {
      responsive.setSizeFromContext(context);
    }

    Widget Function(BuildContext, BlocResponsive)? builder;
    switch (responsive.deviceType) {
      case ScreenSizeEnum.mobile:
        builder = mobile ?? fallback;
        break;
      case ScreenSizeEnum.tablet:
        builder = tablet ?? fallback;
        break;
      case ScreenSizeEnum.desktop:
        builder = desktop ?? fallback;
        break;
      case ScreenSizeEnum.tv:
        builder = tv ?? desktop ?? fallback;
        break;
    }
    assert(
      builder != null,
      'No builder provided for the current device, and no fallback.',
    );

    return builder!(context, responsive);
  }
}
