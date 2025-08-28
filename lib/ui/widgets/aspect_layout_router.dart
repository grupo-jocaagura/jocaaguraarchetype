part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Routes layout selection based on the container's aspect ratio.
///
/// This widget inspects the available **width/height** (using `LayoutBuilder`)
/// and chooses one of the provided widgets:
///
/// - `square`   → when aspect ratio is ~ **1:1**
/// - `wide2x1`  → when aspect ratio is ~ **2:1**  (aka your *1x2*)
/// - `wide3x1`  → when aspect ratio is ~ **3:1**  (aka your *1x3*)
/// - `horizontal` → when aspect > 1.0 and it doesn't snap to 2:1 or 3:1
/// - `vertical`   → when aspect < 1.0
///
/// A small **snap tolerance** (default: `0.08`) is applied to treat near-matches
/// (e.g., 1.94 considered 2.0) as exact.
///
/// If constraints are unbounded (e.g., inside an unconstrained box), it falls
/// back to `MediaQuery.sizeOf(context)`; if still unknown it defaults to
/// `horizontal`.
///
/// ### Example
/// ```dart
/// Widget build(BuildContext context) {
///   return AspectLayoutRouter(
///     square: const Center(child: Text('1:1')),
///     wide2x1: const Center(child: Text('2:1')),
///     wide3x1: const Center(child: Text('3:1')),
///     horizontal: const Center(child: Text('> 1 (generic horizontal)')),
///     vertical: const Center(child: Text('< 1 (generic vertical)')),
///     // snapTolerance: 0.06, // optional
///   );
/// }
/// ```
///
/// ### Public API notes
/// - `snapTolerance` defines how close the real aspect must be to 1.0/2.0/3.0
///   to snap to `square`/`wide2x1`/`wide3x1`.
/// - Use `AspectLayoutRouter.routeFor(aspect, snapTolerance)` in tests to
///   validate routing logic without pumping a widget tree.
@immutable
class AspectLayoutRouter extends StatelessWidget {
  const AspectLayoutRouter({
    required this.square,
    required this.wide2x1,
    required this.wide3x1,
    required this.horizontal,
    required this.vertical,
    this.snapTolerance = 0.08,
    super.key,
  }) : assert(snapTolerance >= 0.0);

  /// Widget returned when aspect ratio is ~1:1.
  final Widget square;

  /// Widget returned when aspect ratio is ~2:1 (aka *1x2*).
  final Widget wide2x1;

  /// Widget returned when aspect ratio is ~3:1 (aka *1x3*).
  final Widget wide3x1;

  /// Widget returned when aspect ratio > 1 and not snapped to 2:1 or 3:1.
  final Widget horizontal;

  /// Widget returned when aspect ratio < 1.
  final Widget vertical;

  /// Tolerance used to snap near-matches to 1.0/2.0/3.0.
  ///
  /// For example, with `0.08`, 1.94..2.06 snaps to `2.0`.
  final double snapTolerance;

  /// Route decision that can be unit-tested without rendering.
  static AspectRoute routeFor(double aspect, double snapTolerance) {
    if ((aspect - 1.0).abs() <= snapTolerance) {
      return AspectRoute.square;
    }
    if ((aspect - 2.0).abs() <= snapTolerance) {
      return AspectRoute.wide2x1;
    }
    if ((aspect - 3.0).abs() <= snapTolerance) {
      return AspectRoute.wide3x1;
    }
    if (aspect > 1.0) {
      return AspectRoute.horizontal;
    }
    return AspectRoute.vertical;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double? w = constraints.hasBoundedWidth ? constraints.maxWidth : null;
        double? h = constraints.hasBoundedHeight ? constraints.maxHeight : null;

        if (w == null ||
            w == double.infinity ||
            h == null ||
            h == double.infinity ||
            h == 0) {
          // Fallback to MediaQuery when constraints are unbounded.
          final Size mq =
              MediaQuery.maybeOf(context)?.size ?? const Size(800, 600);
          w ??= mq.width;
          h ??= mq.height == 0 ? 1 : mq.height;
        }

        final double aspect = w / h;
        final AspectRoute route =
            AspectLayoutRouter.routeFor(aspect, snapTolerance);

        switch (route) {
          case AspectRoute.square:
            return square;
          case AspectRoute.wide2x1:
            return wide2x1;
          case AspectRoute.wide3x1:
            return wide3x1;
          case AspectRoute.horizontal:
            return horizontal;
          case AspectRoute.vertical:
            return vertical;
        }
      },
    );
  }
}

/// Enumerates the five possible routing outcomes.
enum AspectRoute {
  /// ~1:1 (within tolerance).
  square,

  /// ~2:1 (within tolerance). Also referred as *1x2* by team convention.
  wide2x1,

  /// ~3:1 (within tolerance). Also referred as *1x3* by team convention.
  wide3x1,

  /// > 1.0 and not snapped to 2:1 or 3:1.
  horizontal,

  /// < 1.0.
  vertical,
}
