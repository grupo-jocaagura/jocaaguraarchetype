import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// A BLoC (Business Logic Component) for managing the secondary menu drawer.
///
/// The `BlocSecondaryMenuDrawer` class handles the state of the secondary menu drawer,
/// allowing options to be dynamically added, removed, or cleared. It provides
/// reactive streams to notify changes to the menu options.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/bloc_secondary_menu_drawer.dart';
/// import 'package:flutter/material.dart';
///
/// void main() {
///   final blocSecondaryMenuDrawer = BlocSecondaryMenuDrawer();
///
///   // Listen to changes in the secondary menu options
///   blocSecondaryMenuDrawer.listDrawerOptionSizeStream.listen((options) {
///     print('Secondary menu options updated: ${options.length}');
///   });
///
///   // Add a new menu option
///   blocSecondaryMenuDrawer.addMainMenuOption(
///     onPressed: () => print('Settings pressed'),
///     label: 'Settings',
///     iconData: Icons.settings,
///   );
///
///   // Remove a menu option
///   blocSecondaryMenuDrawer.removeMainMenuOption('Settings');
/// }
/// ```
class BlocSecondaryMenuDrawer extends BlocModule {
  /// Creates an instance of `BlocSecondaryMenuDrawer`.
  ///
  /// This initializes an empty list of secondary menu options.
  BlocSecondaryMenuDrawer();

  /// The name identifier for the BLoC, used for tracking or debugging.
  static const String name = 'secondaryMenuBloc';

  /// Internal controller for managing the secondary menu options.
  final BlocGeneral<List<ModelMainMenuModel>> _drawerMainMenu =
      BlocGeneral<List<ModelMainMenuModel>>(<ModelMainMenuModel>[]);

  /// A stream of secondary menu options.
  ///
  /// This stream emits changes to the list of menu options, which can be
  /// used to update the UI dynamically.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocSecondaryMenuDrawer.listDrawerOptionSizeStream.listen((options) {
  ///   print('Menu options updated: ${options.length}');
  /// });
  /// ```
  Stream<List<ModelMainMenuModel>> get listDrawerOptionSizeStream =>
      _drawerMainMenu.stream;

  /// The current list of secondary menu options.
  ///
  /// Returns the latest list of menu options.
  List<ModelMainMenuModel> get listMenuOptions => _drawerMainMenu.value;

  /// Clears all secondary menu options.
  ///
  /// Resets the menu options to an empty list.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocSecondaryMenuDrawer.clearMainDrawer();
  /// ```
  void clearMainDrawer() {
    _drawerMainMenu.value = <ModelMainMenuModel>[];
  }

  /// Adds a new option to the secondary menu drawer.
  ///
  /// The [onPressed] callback is executed when the option is selected.
  /// The [label] and [iconData] define the option's display text and icon.
  /// The [description] parameter is optional and provides additional details.
  ///
  /// If an option with the same [label] already exists, it is replaced with
  /// the new option.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocSecondaryMenuDrawer.addMainMenuOption(
  ///   onPressed: () => print('Settings pressed'),
  ///   label: 'Settings',
  ///   iconData: Icons.settings,
  /// );
  /// ```
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

  /// Removes an option from the secondary menu drawer by its [label].
  ///
  /// The [label] is case-insensitive.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocSecondaryMenuDrawer.removeMainMenuOption('Settings');
  /// ```
  void removeMainMenuOption(String label) {
    final List<ModelMainMenuModel> existingOptions =
        List<ModelMainMenuModel>.from(_drawerMainMenu.value);
    existingOptions.removeWhere(
      (ModelMainMenuModel option) =>
          option.label.toLowerCase() == label.toLowerCase(),
    );
    _drawerMainMenu.value = existingOptions;
  }

  /// Releases resources held by the BLoC.
  ///
  /// This method must be called when the BLoC is no longer needed to prevent
  /// memory leaks.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocSecondaryMenuDrawer.dispose();
  /// ```
  @override
  FutureOr<void> dispose() {
    _drawerMainMenu.dispose();
  }
}
