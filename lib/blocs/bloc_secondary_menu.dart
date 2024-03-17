import 'dart:async';

import 'package:flutter/material.dart';

import '../jocaaguraarchetype.dart';

/// [BlocSecondaryMenuDrawer] A BLoC for managing the main menu drawer options.
///
/// This BLoC manages a list of [MenuOptionWidget] instances, which are used to
/// build the main menu drawer. It provides methods for adding, removing, and
/// clearing the list of options, as well as for opening and closing the drawer.
class BlocSecondaryMenuDrawer extends BlocModule {
  BlocSecondaryMenuDrawer();

  static const String name = 'secondaryMenuBloc';
  final BlocGeneral<List<ModelMainMenuModel>> _drawerMainMenu =
      BlocGeneral<List<ModelMainMenuModel>>(<ModelMainMenuModel>[]);

  Stream<List<ModelMainMenuModel>> get listDrawerOptionSizeStream =>
      _drawerMainMenu.stream;

  List<ModelMainMenuModel> get listMenuOptions => _drawerMainMenu.value;

  void clearMainDrawer() {
    _drawerMainMenu.value = <ModelMainMenuModel>[];
  }

  void addMainMenuOption({
    required VoidCallback onPressed,
    required String label,
    required IconData iconData,
    String description = '',
  }) {
    final List<ModelMainMenuModel> existingOptions =
        List<ModelMainMenuModel>.from(_drawerMainMenu.value);
    final ModelMainMenuModel optionMenu = ModelMainMenuModel(
      onPressed: onPressed,
      label: label,
      iconData: iconData,
    );
    existingOptions
        .removeWhere((ModelMainMenuModel option) => option == optionMenu);
    existingOptions.add(optionMenu);
    _drawerMainMenu.value = existingOptions;
  }

  void removeMainMenuOption(String label) {
    final List<ModelMainMenuModel> existingOptions =
        List<ModelMainMenuModel>.from(_drawerMainMenu.value);
    existingOptions.removeWhere(
      (ModelMainMenuModel option) =>
          option.label.toLowerCase() == label.toLowerCase(),
    );
    _drawerMainMenu.value = existingOptions;
  }

  @override
  FutureOr<void> dispose() {
    _drawerMainMenu.dispose();
  }
}
