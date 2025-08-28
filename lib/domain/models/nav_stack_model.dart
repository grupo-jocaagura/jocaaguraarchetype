part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

typedef PageEquals = bool Function(PageModel a, PageModel b);

/// Compara por destino de ruta (name + segments + query + kind + requiresAuth).
bool _routeEquals(PageModel a, PageModel b) {
  return a.name == b.name &&
      listEquals(a.segments, b.segments) &&
      mapEquals(a.query, b.query) &&
      a.kind == b.kind &&
      a.requiresAuth == b.requiresAuth;
}

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

  static const String rootName = 'root';
  static const String pagesKey = 'pages';

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
      pagesKey: pages.map((PageModel p) => p.toJson()).toList(growable: false),
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
        const PageModel(name: rootName, segments: <String>[]),
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
          ? <PageModel>[const PageModel(name: rootName, segments: <String>[])]
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

  /// Push pero **evitando duplicado consecutivo** (no-op si la top es "igual").
  /// Útil cuando quieres permitir repetidos en el stack, pero no dos iguales seguidos.
  NavStackModel pushDistinctTop(
    PageModel page, {
    PageEquals equals = _routeEquals,
  }) {
    if (equals(top, page)) {
      return this;
    }
    return push(page);
  }

  /// Garantiza que **solo exista una** instancia "igual" a [page] en el stack:
  /// si ya existe, la remueve y agrega la nueva al top.
  ///
  /// Por defecto la comparación es por "ruta" (_routeEquals). Puedes pasar [equals]
  /// para comparar solo por name (_nameEquals) u otra estrategia.
  ///
  /// Ejemplo:
  /// ```dart
  /// stack = stack.pushOnce(PageModel(name:'home', segments:['home']));
  /// stack = stack.pushOnce(PageModel(name:'home', segments:['home'])); // no duplica
  /// ```
  NavStackModel pushOnce(
    PageModel page, {
    PageEquals equals = _routeEquals,
  }) {
    final List<PageModel> next = <PageModel>[];
    for (final PageModel p in pages) {
      if (!equals(p, page)) {
        next.add(p);
      }
    }
    next.add(page);
    return NavStackModel(next);
  }

  /// Deduplica **el stack completo** conservando el primer encontrado
  /// (elimina subsecuentes "iguales" según [equals]).
  NavStackModel dedupAll({PageEquals equals = _routeEquals}) {
    final List<PageModel> out = <PageModel>[];
    for (final PageModel p in pages) {
      final bool already = out.any((PageModel q) => equals(q, p));
      if (!already) {
        out.add(p);
      }
    }
    // Asegura siempre al menos 1
    return out.isEmpty ? this : NavStackModel(out);
  }

  /// Busca una página "igual" y la **mueve al top** (si no existe, hace push).
  NavStackModel moveToTopOrPush(
    PageModel page, {
    PageEquals equals = _routeEquals,
  }) {
    final List<PageModel> next = <PageModel>[];
    for (final PageModel p in pages) {
      if (!equals(p, page)) {
        next.add(p);
      }
    }
    next.add(page);
    return NavStackModel(next);
  }

  @override
  String toString() =>
      'NavStackModel(pages: [${pages.map((PageModel pageModel) => pageModel.name).join(', ')}])';
}
