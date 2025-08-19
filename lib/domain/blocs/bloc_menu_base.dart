part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Base menu BLoC that manages a reactive list of [ModelMainMenuModel].
///
/// Responsibilities:
/// - Expose a stream of immutable lists for UI rendering.
/// - Provide safe mutations (clear, upsert by label, removeWhere).
/// - Keep public API in children aligned with archetype naming.
///
/// ### Example
/// ```dart
/// final BlocMainMenuDrawer mainBloc = BlocMainMenuDrawer();
/// mainBloc.upsertOption(
///   onPressed: () {},
///   label: 'Home',
///   iconData: Icons.home,
///   description: 'Go to home',
/// );
/// mainBloc.itemsStream.listen((List<ModelMainMenuModel> items) {
///   debugPrint('Items: ${items.length}');
/// });
/// ```
abstract class BlocMenuBase extends BlocModule {
  BlocMenuBase();
  static const String name = 'BlocMenuBase';

  @protected
  final BlocGeneral<List<ModelMainMenuModel>> itemsController =
      BlocGeneral<List<ModelMainMenuModel>>(<ModelMainMenuModel>[]);

  /// Stream of the current immutable menu options.
  Stream<List<ModelMainMenuModel>> get itemsStream => itemsController.stream;

  /// Snapshot of the current immutable menu options.
  List<ModelMainMenuModel> get items =>
      List<ModelMainMenuModel>.unmodifiable(itemsController.value);

  /// Remove all menu options.
  @mustCallSuper
  void clear() {
    itemsController.value = <ModelMainMenuModel>[];
  }

  /// Insert or replace an option **by label (case-insensitive)**.
  ///
  /// If an option with the same label exists, it is replaced keeping
  /// FIFO for the rest.
  void upsertOption({
    required VoidCallback onPressed,
    required String label,
    required IconData iconData,
    String description = '',
  }) {
    final List<ModelMainMenuModel> list =
        List<ModelMainMenuModel>.from(itemsController.value);

    final int idx = list.indexWhere(
      (ModelMainMenuModel e) => e.label.toLowerCase() == label.toLowerCase(),
    );

    final ModelMainMenuModel newItem = ModelMainMenuModel(
      onPressed: onPressed,
      label: label,
      iconData: iconData,
      description: description,
    );

    if (idx >= 0) {
      list[idx] = newItem;
    } else {
      list.add(newItem);
    }
    itemsController.value = list;
  }

  /// Remove options matching [test].
  void removeWhere(bool Function(ModelMainMenuModel e) test) {
    final List<ModelMainMenuModel> list =
        List<ModelMainMenuModel>.from(itemsController.value);
    list.removeWhere(test);
    itemsController.value = list;
  }

  /// Convenience: remove by label (case-insensitive).
  void removeByLabel(String label) {
    removeWhere(
      (ModelMainMenuModel e) => e.label.toLowerCase() == label.toLowerCase(),
    );
  }

  bool get isClosed => itemsController.isClosed;

  @override
  FutureOr<void> dispose() {
    itemsController.dispose();
  }
}
