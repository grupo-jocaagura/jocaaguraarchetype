part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Base class for simple menu blocs that manage a list of menu options.
///
/// Exposes:
/// - [itemsStream]: reactive stream of the menu items.
/// - [items]: immutable snapshot (unmodifiable).
/// - [clear], [upsertOption], [removeByLabel].
///
/// Example
///
/// ```dart
/// final bloc = BlocMainMenuDrawer();
/// final sub = bloc.itemsStream.listen((it) => debugPrint('len: ${it.length}'));
///
/// bloc.upsertOption(
///   onPressed: () {},
///   label: 'Home',
///   iconData: Icons.home,
/// );
///
/// bloc.removeByLabel('home');
/// await sub.cancel();
/// bloc.dispose();
/// ```
abstract class BlocMenuBase extends BlocModule {
  BlocMenuBase();
  static const String name = 'BlocMenuBase';
  final BlocGeneral<List<ModelMainMenuModel>> _itemsCtrl =
      BlocGeneral<List<ModelMainMenuModel>>(<ModelMainMenuModel>[]);

  /// Reactive stream of current items.
  Stream<List<ModelMainMenuModel>> get itemsStream => _itemsCtrl.stream;

  /// Immutable snapshot of items.
  List<ModelMainMenuModel> get items =>
      List<ModelMainMenuModel>.unmodifiable(_itemsCtrl.value);

  /// True if underlying controller has been disposed.
  bool get isClosed => _itemsCtrl.isClosed;

  /// Remove all items.
  void clear() => _itemsCtrl.value = <ModelMainMenuModel>[];

  /// Insert or replace an option by label (case-insensitive).
  void upsertOption({
    required VoidCallback onPressed,
    required String label,
    required IconData iconData,
    String description = '',
  }) {
    final List<ModelMainMenuModel> list =
        List<ModelMainMenuModel>.from(_itemsCtrl.value);

    final String key = label.toLowerCase();
    list.removeWhere((ModelMainMenuModel m) => m.label.toLowerCase() == key);

    list.add(
      ModelMainMenuModel(
        onPressed: onPressed,
        label: label,
        iconData: iconData,
        description: description,
      ),
    );

    _itemsCtrl.value = list;
  }

  /// Remove by label (case-insensitive).
  void removeByLabel(String label) {
    final List<ModelMainMenuModel> list =
        List<ModelMainMenuModel>.from(_itemsCtrl.value);
    list.removeWhere(
      (ModelMainMenuModel m) => m.label.toLowerCase() == label.toLowerCase(),
    );
    _itemsCtrl.value = list;
  }

  bool _isDisposed = false;
  bool get disposed => _isDisposed;
  @override
  FutureOr<void> dispose() {
    if (_isDisposed) {
      return null;
    }
    _isDisposed = true;
    _itemsCtrl.dispose();
  }
}
