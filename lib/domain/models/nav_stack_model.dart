part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

typedef PageEquals = bool Function(PageModel a, PageModel b);

/// Compara por destino de ruta (name + segments + query + kind + requiresAuth).
///
/// Útil como estrategia por defecto para evitar duplicados lógicos en el stack./// Compara por destino de ruta (name + segments + query + kind + requiresAuth).
bool routeEquals(PageModel a, PageModel b) {
  return a.name == b.name &&
      listEquals(a.segments, b.segments) &&
      mapEquals(a.query, b.query) &&
      a.kind == b.kind &&
      a.requiresAuth == b.requiresAuth;
}

const NavStackModel defaultNavStackModel = NavStackModel.notFound;

/// Modelo inmutable de pila de [PageModel] para navegación.
///
/// Garantiza **al menos una página** en cada momento (invariante de no-vacío).
/// Provee operaciones puras que devuelven nuevas instancias sin mutar el estado:
/// - [push], [pushDistinctTop], [pushOnce], [replaceTop], [pop], [resetTo],
///   [dedupAll], [moveToTopOrPush].
///
/// ### Contratos
/// - Invariante: `pages.isNotEmpty == true`.
/// - `pop()` en raíz devuelve la misma instancia (no lanza).
/// - `replaceTop()` asume pila no vacía (garantizada por la clase).
///
/// ### Ejemplo mínimo
/// ```dart
/// void main() {
///   NavStackModel stack = NavStackModel.single(const PageModel(name: 'home'));
///   stack = stack.push(const PageModel(name: 'details', segments: <String>['products','42']));
///   assert(stack.top.name == 'details');
///   stack = stack.pop();
///   assert(stack.isRoot && stack.top.name == 'home');
/// }
/// ```
@immutable
class NavStackModel extends Model {
  factory NavStackModel(List<PageModel> pages) {
    return NavStackModel._internal(
      pages.isEmpty
          ? defaultNavStackModel.pages
          : List<PageModel>.unmodifiable(pages),
    );
  }

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
      return defaultNavStackModel;
    }
    return NavStackModel(parsed);
  }

  const NavStackModel._internal(this.pages);

  static const NavStackModel notFound =
      NavStackModel._internal(<PageModel>[PageModel(name: defaultName)]);

  static const String defaultName = 'notFound';
  static const String pagesKey = 'pages';

  /// Back stack, bottom→top.
  final List<PageModel> pages;

  /// Top-most page (current).
  PageModel get top => pages.isEmpty ? defaultNavStackModel.top : pages.last;

  /// Back stack, bottom→top.

  /// True when stack has only one page.
  bool get isRoot => pages.length == 1;

  /// Push a page.
  NavStackModel push(PageModel page) {
    final List<PageModel> next = List<PageModel>.from(pages)..add(page);
    return NavStackModel(next);
  }

  /// Replace top with [page].
  NavStackModel replaceTop(PageModel page) {
    if (pages.isEmpty) {
      return defaultNavStackModel;
    }
    final List<PageModel> next = List<PageModel>.from(pages);
    next.removeLast();
    next.add(page);
    return NavStackModel(next);
  }

  /// Pop one page. If root, returns same instance.
  NavStackModel pop() {
    if (pages.isEmpty) {
      return defaultNavStackModel;
    }
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

  /// Codifica la pila como cadena de rutas separada por `;`.
  ///
  /// Ejemplo: `/home;/products/42?ref=home`
  String encodeAsRouteChain() {
    return pages.map((PageModel p) => p.toUriString()).join(';');
  }

  /// Decodifica una cadena producida por [encodeAsRouteChain].
  ///
  /// Si la cadena está vacía o sin páginas válidas, retorna una pila con [`rootName`].
  static NavStackModel decodeRouteChain(String chain) {
    if (chain.trim().isEmpty) {
      return defaultNavStackModel;
    }
    final List<PageModel> parsed = chain
        .split(';')
        .where((String s) => s.isNotEmpty)
        .map<Uri>(Uri.parse)
        .map<PageModel>(PageModel.fromUri)
        .toList(growable: false);

    return parsed.isEmpty ? defaultNavStackModel : NavStackModel(parsed);
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

  /// Empuja [page] **evitando duplicado consecutivo** según [equals] (por defecto [routeEquals]).
  ///
  /// Retorna `this` si `top` ya es "igual" a [page]; en otro caso, una nueva pila.
  NavStackModel pushDistinctTop(
    PageModel page, {
    PageEquals equals = routeEquals,
  }) {
    if (pages.isEmpty) {
      return NavStackModel.single(page);
    }
    return equals(top, page) ? this : push(page);
  }

  /// Empuja [page] garantizando que **solo exista una** instancia "igual" (según [equals]).
  ///
  /// Si ya existe en el stack, se remueve la previa y se agrega [page] al top.
  NavStackModel pushOnce(
    PageModel page, {
    PageEquals equals = routeEquals,
  }) {
    if (pages.isEmpty) {
      return NavStackModel.single(page);
    }
    final List<PageModel> next = <PageModel>[];
    for (final PageModel p in pages) {
      if (!equals(p, page)) {
        next.add(p);
      }
    }
    next.add(page);
    return NavStackModel(next);
  }

  /// Deduplica el stack completo conservando la **primera** ocurrencia según [equals].
  ///
  /// Nunca devuelve una pila vacía (respeta la invariante de no-vacío).
  NavStackModel dedupAll({PageEquals equals = routeEquals}) {
    if (pages.isEmpty) {
      return defaultNavStackModel;
    }

    final List<PageModel> out = <PageModel>[];
    for (final PageModel p in pages) {
      final bool already = out.any((PageModel q) => equals(q, p));
      if (!already) {
        out.add(p);
      }
    }
    return out.isEmpty ? this : NavStackModel(out);
  }

  /// Busca una página "igual" y la **mueve al top** (si no existe, hace push).
  NavStackModel moveToTopOrPush(
    PageModel page, {
    PageEquals equals = routeEquals,
  }) {
    if (pages.isEmpty) {
      return NavStackModel.single(page);
    }
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
      'NavStackModel(pages: [${pages.map((PageModel pageModel) => pageModel.toString()).join(', ')}])';
}
