part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Signature for building the main drawer widget.
///
/// Returns `null` when no drawer should be displayed.
///
/// ```dart
/// Widget? myDrawerBuilder(
///   BuildContext context,
///   AppManager app,
///   BlocResponsive responsive,
///   List<ModelMainMenuModel> items,
/// ) {
///   if (items.isEmpty) {
///     return null;
///   }
///   return MainDrawer(
///     app: app,
///     responsive: responsive,
///     items: items,
///   );
/// }
/// ```
typedef MainDrawerBuilder = Widget? Function(
  BuildContext context,
  AppManager app,
  BlocResponsive responsive,
  List<ModelMainMenuModel> items,
);
