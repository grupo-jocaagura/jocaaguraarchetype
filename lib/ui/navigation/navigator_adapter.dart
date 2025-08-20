part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Backward-compat navigation adapter that preserves the old imperative API.
///
/// It delegates to the new PageManager (NavStackModel + PageModel).
class AppNavigator {
  AppNavigator({required this.pageManager});

  final PageManager pageManager;

  /// Old API kept: push a page providing a title and a logical name.
  ///
  /// - `pageName` must exist in PageRegistry (builder key).
  /// - `title` is carried in PageModel.state['title'] (UI reads it for AppBar).
  /// - `legacyWidget` is ignored (the registry is the source of truth),
  ///   but kept for source-compat.
  void pushPageWithTitle(
    String title,
    String pageName,
    Widget legacyWidget, {
    List<String> segments = const <String>[],
    Map<String, String> query = const <String, String>{},
    PageKind kind = PageKind.material,
    bool requiresAuth = false,
  }) {
    final List<String> segs =
        segments.isEmpty ? <String>[pageName] : List<String>.from(segments);
    final PageModel page = PageModel(
      name: pageName,
      segments: segs,
      query: query,
      kind: kind,
      requiresAuth: requiresAuth,
      state: <String, dynamic>{'title': title},
    );
    pageManager.push(page);
  }

  /// Old API debug helper: list of page names in the back stack.
  List<String> get historyPageNames => pageManager.stack.pages
      .map((PageModel p) => p.name)
      .toList(growable: false);
}
