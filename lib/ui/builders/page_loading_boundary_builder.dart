part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Signature for building the loading boundary widget.
///
/// This allows projects to override the default loading behavior while still
/// delegating to [AppManager] and [BlocResponsive].
///
/// ```dart
/// // Custom loading boundary that uses a different loading page.
/// Widget myLoadingBoundary(
///   BuildContext context,
///   AppManager app,
///   BlocResponsive responsive,
///   Widget? page,
/// ) {
///   return StreamBuilder<String>(
///     stream: app.loading.loadingMsgStream,
///     initialData: app.loading.loadingMsg,
///     builder: (BuildContext context, AsyncSnapshot<String> snap) {
///       final String msg = snap.data ?? '';
///       if (msg.isNotEmpty) {
///         return MyCustomLoadingScreen(message: msg);
///       }
///       return PageScaffoldShell(
///         app: app,
///         responsive: responsive,
///         page: page,
///       );
///     },
///   );
/// }
/// ```
typedef PageLoadingBoundaryBuilder = Widget Function(
  BuildContext context,
  AbstractAppManager app,
  BlocResponsive responsive,
  Widget? page,
);
