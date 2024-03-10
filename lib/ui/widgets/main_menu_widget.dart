import 'package:flutter/material.dart';

import '../../models/model_main_menu.dart';
import 'main_menu_option_widget.dart';

class MainMenuWidget extends StatelessWidget {
  const MainMenuWidget({
    required this.listMenuOptions,
    required this.drawerWidth,
    super.key,
  });

  final List<ModelMainMenu> listMenuOptions;
  final double drawerWidth;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    for (final ModelMainMenu option in listMenuOptions) {
      children.add(
        MainMenuOptionWidget(option: option),
      );
    }

    if (listMenuOptions.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: drawerWidth,
      child: ListView(
        children: children,
      ),
    );
  }
}
