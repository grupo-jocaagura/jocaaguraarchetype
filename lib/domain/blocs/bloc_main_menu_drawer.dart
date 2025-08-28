part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// BLoC for **main** drawer menu.
///
/// Public API (vigente):
/// - `listMenuOptionsStream`
/// - `listMenuOptions`
/// - `clearMainDrawer()`
/// - `addMainMenuOption(...)`
/// - `removeMainMenuOption(label)`
class BlocMainMenuDrawer extends BlocMenuBase {
  BlocMainMenuDrawer();

  static const String name = 'BlocMainMenuDrawer';

  // Stream y snapshot con los nombres ya usados en el proyecto
  Stream<List<ModelMainMenuModel>> get listMenuOptionsStream => itemsStream;
  List<ModelMainMenuModel> get listMenuOptions =>
      List<ModelMainMenuModel>.unmodifiable(items);

  void clearMainDrawer() => clear();

  void addMainMenuOption({
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

  void removeMainMenuOption(String label) => removeByLabel(label);
  // ---- Deprecated aliases (kept for binary/source compat) ----
  /// Deprecated: use [listMenuOptionsStream].
  @Deprecated('Use listMenuOptionsStream instead.')
  Stream<List<ModelMainMenuModel>> get listDrawerOptionSizeStream =>
      listMenuOptionsStream;
}
