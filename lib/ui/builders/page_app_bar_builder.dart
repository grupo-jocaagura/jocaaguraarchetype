part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Signature for building the page app bar widget.
///
/// Returns `null` when no app bar should be displayed.
///
/// ```dart
/// PreferredSizeWidget? myAppBarBuilder(
///   BuildContext context,
///   AppManager app,
///   BlocResponsive responsive,
///   bool hasDrawer,
/// ) {
///   return PageAppBar(
///     app: app,
///     responsive: responsive,
///     hasDrawer: hasDrawer,
///   );
/// }
/// ```
typedef PageAppBarBuilder = PreferredSizeWidget? Function(
  BuildContext context,
  AppManager app,
  BlocResponsive responsive,
  bool hasDrawer,
);
