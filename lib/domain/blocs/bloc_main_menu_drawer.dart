part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A BLoC (Business Logic Component) for managing the main menu drawer.
///
/// The `BlocMainMenuDrawer` class handles the state of the main menu drawer,
/// allowing options to be dynamically added, removed, or cleared. It provides
/// reactive streams to notify changes to the menu options.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/bloc_main_menu_drawer.dart';
/// import 'package:flutter/material.dart';
///
/// void main() {
///   final blocMainMenuDrawer = BlocMainMenuDrawer();
///
///   // Listen to changes in the main menu options
///   blocMainMenuDrawer.listDrawerOptionSizeStream.listen((options) {
///     print('Main menu options updated: ${options.length}');
///   });
///
///   // Add a new menu option
///   blocMainMenuDrawer.addMainMenuOption(
///     onPressed: () => print('Home pressed'),
///     label: 'Home',
///     iconData: Icons.home,
///   );
///
///   // Remove a menu option
///   blocMainMenuDrawer.removeMainMenuOption('Home');
/// }
/// ```
class BlocMainMenuDrawer extends BlocModule {
  /// Creates an instance of `BlocMainMenuDrawer`.
  ///
  /// This initializes an empty list of main menu options.
  BlocMainMenuDrawer();

  /// The name identifier for the BLoC, used for tracking or debugging.
  static const String name = 'drawerMainMenuBloc';

  /// Internal controller for managing the main menu options.
  final BlocGeneral<List<ModelMainMenuModel>> _drawerMainMenu =
      BlocGeneral<List<ModelMainMenuModel>>(<ModelMainMenuModel>[]);

  /// A stream of main menu options.
  ///
  /// This stream emits changes to the list of menu options, which can be
  /// used to update the UI dynamically.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocMainMenuDrawer.listDrawerOptionSizeStream.listen((options) {
  ///   print('Menu options updated: ${options.length}');
  /// });
  /// ```
  Stream<List<ModelMainMenuModel>> get listDrawerOptionSizeStream =>
      _drawerMainMenu.stream;

  /// The current list of main menu options.
  ///
  /// Returns the latest list of menu options.
  List<ModelMainMenuModel> get listMenuOptions => _drawerMainMenu.value;

  /// Clears all main menu options.
  ///
  /// Resets the menu options to an empty list.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocMainMenuDrawer.clearMainDrawer();
  /// ```
  void clearMainDrawer() {
    _drawerMainMenu.value = <ModelMainMenuModel>[];
  }

  /// Adds a new option to the main menu drawer.
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
  /// blocMainMenuDrawer.addMainMenuOption(
  ///   onPressed: () => print('Home pressed'),
  ///   label: 'Home',
  ///   iconData: Icons.home,
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

  /// Removes an option from the main menu drawer by its [label].
  ///
  /// The [label] is case-insensitive.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocMainMenuDrawer.removeMainMenuOption('Home');
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

  /// Checks if the main menu drawer is closed.
  ///
  /// Returns `true` if the internal stream controller is closed.
  bool get isClosed => _drawerMainMenu.isClosed;

  /// Releases resources held by the BLoC.
  ///
  /// This method must be called when the BLoC is no longer needed to prevent
  /// memory leaks.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocMainMenuDrawer.dispose();
  /// ```
  @override
  void dispose() {
    _drawerMainMenu.dispose();
  }
}
