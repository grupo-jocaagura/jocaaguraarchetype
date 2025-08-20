part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Immutable back stack of [PageModel] used by the RouterDelegate.
///
/// Provides pure push/pop/replace operations and JSON/URI round-trips.
///
/// ### Example
/// ```dart
/// NavStackModel stack = NavStackModel.single(PageModel(name: 'home', segments: <String>['home']));
/// stack = stack.push(PageModel(name: 'details', segments: <String>['products','42']));
/// assert(stack.top.name == 'details');
/// stack = stack.pop();
/// assert(stack.top.name == 'home');
/// ```
@immutable
class NavStackModel extends Model {
  const NavStackModel(this.pages)
      : assert(pages.length >= 1, 'Stack must not be empty');

  /// Creates a stack with a single page.
  factory NavStackModel.single(PageModel page) =>
      NavStackModel(<PageModel>[page]);

  factory NavStackModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> raw = json['pages'] as List<dynamic>? ?? <dynamic>[];
    final List<PageModel> parsed = raw
        .cast<Map<String, dynamic>>()
        .map<Map<String, dynamic>>(
          (Map<String, dynamic> e) => e.cast<String, dynamic>(),
        )
        .map<PageModel>(PageModel.fromJson)
        .toList(growable: false);
    if (parsed.isEmpty) {
      return NavStackModel.single(
        const PageModel(name: 'root', segments: <String>[]),
      );
    }
    return NavStackModel(parsed);
  }

  /// Back stack, bottom→top.
  final List<PageModel> pages;

  /// Top-most page (current).
  PageModel get top => pages.last;

  /// True when stack has only one page.
  bool get isRoot => pages.length <= 1;

  /// Push a page.
  NavStackModel push(PageModel page) {
    final List<PageModel> next = List<PageModel>.from(pages)..add(page);
    return NavStackModel(next);
  }

  /// Replace top with [page].
  NavStackModel replaceTop(PageModel page) {
    final List<PageModel> next = List<PageModel>.from(pages);
    next.removeLast();
    next.add(page);
    return NavStackModel(next);
  }

  /// Pop one page. If root, returns same instance.
  NavStackModel pop() {
    if (isRoot) {
      return this;
    }
    final List<PageModel> next = List<PageModel>.from(pages)..removeLast();
    return NavStackModel(next);
  }

  /// Clear and set a new single root.
  NavStackModel resetTo(PageModel root) => NavStackModel.single(root);

  // ---- Model API ----

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'pages': pages.map((PageModel p) => p.toJson()).toList(growable: false),
    };
  }

  /// Encode to a route-like chain joining pages with ';'
  /// Example: `/home;/products/42?ref=home`
  String encodeAsRouteChain() {
    return pages.map((PageModel p) => p.toUriString()).join(';');
  }

  /// Decode route chain produced by [encodeAsRouteChain].
  static NavStackModel decodeRouteChain(String chain) {
    if (chain.trim().isEmpty) {
      return NavStackModel.single(
        const PageModel(name: 'root', segments: <String>[]),
      );
    }
    final List<PageModel> parsed = chain
        .split(';')
        .where((String s) => s.isNotEmpty)
        .map<Uri>(Uri.parse)
        .map<PageModel>(PageModel.fromUri)
        .toList(growable: false);

    return NavStackModel(
      parsed.isEmpty
          ? <PageModel>[const PageModel(name: 'root', segments: <String>[])]
          : parsed,
    );
  }

  @override
  NavStackModel copyWith({List<PageModel>? pages}) =>
      NavStackModel(pages ?? this.pages);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }

    if (other is NavStackModel) {
      final NavStackModel o = other;
      if (pages.length != o.pages.length) {
        return false;
      }
      for (int i = 0; i < pages.length; i += 1) {
        if (pages[i] != o.pages[i]) {
          return false;
        }
      }
    } else {
      return false;
    }

    return true;
  }

  @override
  int get hashCode {
    int h = 17;
    for (final PageModel p in pages) {
      h = 0x1fffffff & (h * 31 ^ p.hashCode);
    }
    return h;
  }

  @override
  String toString() =>
      'NavStackModel(pages: [${pages.map((PageModel pageModel) => pageModel.name).join(', ')}])';
}
