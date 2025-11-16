part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Builds the mobile layout (floating row of secondary actions).
typedef SecondaryMenuMobileLayoutBuilder = Widget Function(
  BuildContext context,
  BlocResponsive responsive,
  Widget content,
  List<ModelMainMenuModel> items,
  Color backgroundColor,
  bool animate,
);
