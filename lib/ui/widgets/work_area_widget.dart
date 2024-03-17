import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../consts/enum_screen_size.dart';
import 'columns_blueprint_widget.dart';
import 'main_menu_widget.dart';
import 'page_with_secondary_menu_widget.dart';

class WorkAreaWidget extends StatelessWidget {
  const WorkAreaWidget({
    required this.columnsNumber,
    required this.workAreaSize,
    required this.marginWidth,
    required this.columnWidth,
    required this.gutterWidth,
    required this.screenSizeEnum,
    required this.listMenuOptions,
    required this.drawerWidth,
    required this.listSecondaryMenuOptions,
    super.key,
    this.page,
  });

  final int columnsNumber;
  final Size workAreaSize;
  final double marginWidth;
  final double columnWidth;
  final double gutterWidth;
  final double drawerWidth;
  final ScreenSizeEnum screenSizeEnum;
  final List<ModelMainMenuModel> listMenuOptions;
  final List<ModelMainMenuModel> listSecondaryMenuOptions;

  final Widget? page;
  @override
  Widget build(BuildContext context) {
    final ColumnsBluePrintWidget columnsBluePrintWidget =
        ColumnsBluePrintWidget(
      numberOfColumns: columnsNumber,
      workAreaSize: workAreaSize,
      marginWidth: marginWidth,
      columnWidth: columnWidth,
      gutterWidth: gutterWidth,
    );

    final Widget child = PageWidthSecondaryMenuWidget(
      screenSizeEnum: screenSizeEnum,
      secondaryMenuWidth: columnWidth * 2,
      page: page ?? columnsBluePrintWidget,
      listOfModelMainMenu: listSecondaryMenuOptions,
    );

    /// TV
    if (screenSizeEnum == ScreenSizeEnum.tv ||
        screenSizeEnum == ScreenSizeEnum.desktop) {
      if (listMenuOptions.isNotEmpty) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              MainMenuWidget(
                listMenuOptions: listMenuOptions,
                drawerWidth: drawerWidth,
              ),
              child,
            ],
          ),
        );
      }
      return child;
    }

    /// Tablet
    if (screenSizeEnum == ScreenSizeEnum.tablet) {
      return child;
    }

    /// movil

    return child;
  }
}
