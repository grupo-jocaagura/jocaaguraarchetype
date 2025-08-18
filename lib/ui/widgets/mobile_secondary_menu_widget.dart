part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class MobileSecondaryMenuWidget extends StatelessWidget {
  const MobileSecondaryMenuWidget({
    required this.listOfModelMainMenu,
    required this.menuItemWidth,
    super.key,
  });

  final List<ModelMainMenuModel> listOfModelMainMenu;
  final double menuItemWidth;
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    final double tmp = menuItemWidth.clamp(40.0, 70.0);
    final Widget separator = SizedBox(
      width: tmp * 0.2,
    );
    for (final ModelMainMenuModel option in listOfModelMainMenu) {
      children.add(
        MobileSecondaryOptionWidget(
          width: tmp,
          icondata: option.iconData,
          onPressed: option.onPressed,
          label: option.label,
          description: option.description,
        ),
      );
      children.add(separator);
    }
    return SizedBox(
      height: tmp,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: children,
        ),
      ),
    );
  }
}
