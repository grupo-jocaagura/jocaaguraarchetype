part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// BLoC for **secondary** drawer menu.
///
/// Public API actual (conservado):
/// - `listDrawerOptionSizeStream`
/// - `listMenuOptions`
/// - `clearSecondaryDrawer()`
/// - `addSecondaryMenuOption(...)`
/// - `removeSecondaryMenuOption(label)`
///
/// Aliases deprecated (retrocompat):
/// - `addMainMenuOption`, `removeMainMenuOption`, `clearMainDrawer`,
///   `listMenuOptionsStream`.
class BlocSecondaryMenuDrawer extends BlocMenuBase {
  BlocSecondaryMenuDrawer();

  static const String name = 'BlocSecondaryMenuDrawer';

  // Stream y snapshot con nombres actuales
  Stream<List<ModelMainMenuModel>> get listDrawerOptionSizeStream =>
      itemsStream;
  List<ModelMainMenuModel> get listMenuOptions => items;

  void clearSecondaryDrawer() => clear();

  void addSecondaryMenuOption({
    required VoidCallback onPressed,
    required String label,
    required IconData iconData,
    String description = '',
  }) =>
      upsertOption(
        onPressed: onPressed,
        label: label,
        iconData: iconData,
        description: description,
      );

  void removeSecondaryMenuOption(String label) => removeByLabel(label);

  // --- Aliases deprecated ---
  @Deprecated('Use addSecondaryMenuOption instead.')
  void addMainMenuOption({
    required VoidCallback onPressed,
    required String label,
    required IconData iconData,
    String description = '',
  }) =>
      addSecondaryMenuOption(
        onPressed: onPressed,
        label: label,
        iconData: iconData,
        description: description,
      );

  @Deprecated('Use removeSecondaryMenuOption instead.')
  void removeMainMenuOption(String label) => removeSecondaryMenuOption(label);

  @Deprecated('Use clearSecondaryDrawer instead.')
  void clearMainDrawer() => clearSecondaryDrawer();

  @Deprecated('Use listDrawerOptionSizeStream (or itemsStream).')
  Stream<List<ModelMainMenuModel>> get listMenuOptionsStream =>
      listDrawerOptionSizeStream;
}
