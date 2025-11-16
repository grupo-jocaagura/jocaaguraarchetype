part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// ---------------------------------------------------------------------------
// UI extensions for ModelMainMenuModel (unchanged, but documented).
// ---------------------------------------------------------------------------

/// UI-attached state for [ModelMainMenuModel] using [Expando].
///
/// These expandos allow the UI layer to attach ephemeral state to
/// [ModelMainMenuModel] instances **without** modifying the domain
/// definition in `jocaagura_domain`.
final Expando<bool> _mmSelected = Expando<bool>('mm.selected');
final Expando<bool> _mmEnabled = Expando<bool>('mm.enabled');
final Expando<int> _mmBadgeCount = Expando<int>('mm.badgeCount');
final Expando<String> _mmTooltip = Expando<String>('mm.tooltip');

/// UI extensions for [ModelMainMenuModel].
///
/// These properties are meant to be used **only from the UI layer**
/// and must not be relied upon in the domain or infrastructure layers.
///
/// ### Usage
///
/// ```dart
/// final ModelMainMenuModel item = ModelMainMenuModel(
///   label: 'Home',
///   onPressed: goHome,
/// );
///
/// // Mark as selected with a badge and tooltip:
/// item.ui(
///   selected: true,
///   badgeCount: 3,
///   tooltip: 'You have 3 pending items',
/// );
///
/// // Later in the drawer:
/// DrawerOptionWidget(
///   responsive: responsive,
///   label: item.label,
///   icon: item.iconData,
///   selected: item.selected,
///   onTap: item.onPressed,
/// );
/// ```
extension ModelMainMenuModelX on ModelMainMenuModel {
  /// Whether this menu item is currently selected in the UI.
  bool get selected => _mmSelected[this] ?? false;
  set selected(bool value) => _mmSelected[this] = value;

  /// Alias for [selected] for readability.
  bool get isSelected => selected;

  /// Whether this menu item is enabled in the UI.
  bool get enabled => _mmEnabled[this] ?? true;
  set enabled(bool value) => _mmEnabled[this] = value;

  /// Optional badge count to be displayed alongside the item.
  int? get badgeCount => _mmBadgeCount[this];
  set badgeCount(int? value) => _mmBadgeCount[this] = value;

  /// Optional tooltip text for this item.
  String? get tooltip => _mmTooltip[this];
  set tooltip(String? value) => _mmTooltip[this] = value;

  /// Fluent UI configuration helper.
  ///
  /// This method mutates the underlying UI-attached state and returns
  /// `this` for chaining.
  ///
  /// ```dart
  /// final ModelMainMenuModel item = ModelMainMenuModel(
  ///   label: 'Dashboard',
  ///   onPressed: goDashboard,
  /// ).ui(
  ///   selected: true,
  ///   tooltip: 'Main dashboard',
  /// );
  /// ```
  ModelMainMenuModel ui({
    bool? selected,
    bool? enabled,
    int? badgeCount,
    String? tooltip,
  }) {
    if (selected != null) {
      this.selected = selected;
    }
    if (enabled != null) {
      this.enabled = enabled;
    }
    if (badgeCount != null) {
      this.badgeCount = badgeCount;
    }
    if (tooltip != null) {
      this.tooltip = tooltip;
    }
    return this;
  }
}
