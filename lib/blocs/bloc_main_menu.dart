import 'dart:async';

import 'package:flutter/material.dart';

import '../jocaaguraarchetype.dart';
import '../models/model_main_menu.dart';

/// [BlocMainMenuDrawer] A BLoC for managing the main menu drawer options.
///
/// This BLoC manages a list of [DrawerOptionWidget] instances, which are used to
/// build the main menu drawer. It provides methods for adding, removing, and
/// clearing the list of options, as well as for opening and closing the drawer.
class BlocMainMenuDrawer extends BlocModule {
  BlocMainMenuDrawer();

  static const String name = 'drawerMainMenuBloc';
  final BlocGeneral<List<ModelMainMenu>> _drawerMainMenu =
      BlocGeneral<List<ModelMainMenu>>(<ModelMainMenu>[]);

  Stream<List<ModelMainMenu>> get listDrawerOptionSizeStream =>
      _drawerMainMenu.stream;

  List<ModelMainMenu> get listMenuOptions => _drawerMainMenu.value;

  void clearMainDrawer() {
    _drawerMainMenu.value = <ModelMainMenu>[];
  }

  void addMainMenuOption({
    required VoidCallback onPressed,
    required String label,
    required IconData iconData,
    String description = '',
  }) {
    final List<ModelMainMenu> existingOptions =
        List<ModelMainMenu>.from(_drawerMainMenu.value);
    final ModelMainMenu optionMenu = ModelMainMenu(
      onPressed: onPressed,
      label: label,
      iconData: iconData,
    );
    existingOptions.removeWhere((ModelMainMenu option) => option == optionMenu);
    existingOptions.add(optionMenu);
    _drawerMainMenu.value = existingOptions;
  }

  void removeMainMenuOption(String label) {
    final List<ModelMainMenu> existingOptions =
        List<ModelMainMenu>.from(_drawerMainMenu.value);
    existingOptions.removeWhere(
      (ModelMainMenu option) =>
          option.label.toLowerCase() == label.toLowerCase(),
    );
    _drawerMainMenu.value = existingOptions;
  }

  bool get isClosed => _drawerMainMenu.isClosed;
  @override
  void dispose() {
    _drawerMainMenu.dispose();
  }
}
