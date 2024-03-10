import 'package:flutter/material.dart';

import '../../consts/enum_screen_size.dart';
import '../../models/model_main_menu.dart';
import 'movil_secondary_menu_widget.dart';
import 'secondary_option_widget.dart';

class PageWidthSecondaryMenuWidget extends StatelessWidget {
  const PageWidthSecondaryMenuWidget({
    required this.screenSizeEnum,
    required this.secondaryMenuWidth,
    required this.page,
    required this.listOfModelMainMenu,
    super.key,
  });
  final List<ModelMainMenu> listOfModelMainMenu;
  final double secondaryMenuWidth;
  final ScreenSizeEnum screenSizeEnum;
  final Widget page;
  @override
  Widget build(BuildContext context) {
    if (listOfModelMainMenu.isEmpty) {
      return page;
    }
    if (screenSizeEnum == ScreenSizeEnum.movil ||
        screenSizeEnum == ScreenSizeEnum.tablet) {
      final double menuItemWidth = secondaryMenuWidth * 0.8;
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            page,
            Positioned(
              bottom: 10.0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: menuItemWidth,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: MovilSecondaryMenuWidget(
                  listOfModelMainMenu: listOfModelMainMenu,
                  menuItemWidth: menuItemWidth,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (listOfModelMainMenu.isNotEmpty) {
      final List<Widget> secondaryMenuTmp = <Widget>[];
      for (final ModelMainMenu option in listOfModelMainMenu) {
        secondaryMenuTmp.add(
          SecondaryOptionWidget(
            onPressed: option.onPressed,
            label: option.label,
            icondata: option.iconData,
            description: option.description,
          ),
        );
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            Container(
              width: secondaryMenuWidth,
              decoration: BoxDecoration(
                color: Theme.of(context).focusColor,
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: ListView(
                children: secondaryMenuTmp,
              ),
            ),
            page,
          ],
        ),
      );
    }
    return page;
  }
}
