part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Builds the tablet/desktop layout (side panel of secondary actions).
typedef SecondaryMenuSidePanelLayoutBuilder = Widget Function(
  BuildContext context,
  BlocResponsive responsive,
  Widget content,
  List<ModelMainMenuModel> items,
  Color backgroundColor,
  int panelColumns,
  bool secondaryOnRight,
  bool animate,
);
