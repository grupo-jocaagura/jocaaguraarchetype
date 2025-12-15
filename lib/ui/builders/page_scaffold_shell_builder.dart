part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Signature for building the main scaffold shell widget.
///
/// This is responsible for composing the [Scaffold] (app bar, drawer, body).
///
/// ```dart
/// Widget myShellBuilder(
///   BuildContext context,
///   AppManager app,
///   BlocResponsive responsive,
///   Widget? page,
/// ) {
///   return PageScaffoldShell(
///     app: app,
///     responsive: responsive,
///     page: page,
///     drawerBuilder: myDrawerBuilder,
///   );
/// }
/// ```
typedef PageScaffoldShellBuilder = Widget Function(
  BuildContext context,
  AbstractAppManager app,
  BlocResponsive responsive,
  Widget? page,
);
