import 'package:flutter/material.dart';

import '../../models/model_main_menu.dart';
import 'movil_secondary_option_widget.dart';

class MovilSecondaryMenuWidget extends StatelessWidget {
  const MovilSecondaryMenuWidget({
    required this.listOfModelMainMenu,
    required this.menuItemWidth,
    super.key,
  });

  final List<ModelMainMenu> listOfModelMainMenu;
  final double menuItemWidth;
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    final double tmp = menuItemWidth.clamp(40.0, 70.0);
    final Widget separator = SizedBox(
      width: tmp * 0.2,
    );
    for (final ModelMainMenu option in listOfModelMainMenu) {
      children.add(
        MovilSecondaryOptionWidget(
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
