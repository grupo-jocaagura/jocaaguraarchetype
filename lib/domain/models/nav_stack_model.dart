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

  // Meta-param reservado para preservar el name cuando difiere de los segments.
  static const String _kNameMeta = '__n';

  static String _routeFromPage(PageModel p) {
    // path
    final List<String> segs =
        p.segments.isNotEmpty ? p.segments : <String>[p.name];
    final String path = '/${segs.join('/')}';

    // query (sin el meta por si venía de antes)
    final Map<String, String> q = <String, String>{};
    q.addAll(
      p.query.map((String k, String v) => MapEntry<String, String>(k, v)),
    );
    q.remove(_kNameMeta);

    // Si el name no coincide con el primer segmento, añadimos meta `__n`.
    final bool needsNameMeta = segs.isNotEmpty && segs.first != p.name;
    if (needsNameMeta) {
      q[_kNameMeta] = p.name;
    }

    String queryStr = '';
    if (q.isNotEmpty) {
      queryStr = '?${q.entries.map(
            (MapEntry<String, String> e) =>
                '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
          ).join('&')}';
    }

    // fragment
    final String fragStr = (p.fragment == null || p.fragment!.isEmpty)
        ? ''
        : '#${Uri.encodeComponent(p.fragment!)}';

    return '$path$queryStr$fragStr';
  }

  /// Codifica la pila como rutas separadas por `;`.
  /// Si `toUriString()` es vacío o sin path, se reconstruye; además, cuando
  /// `name != first(segments)` se inyecta `__n=<name>` para asegurar reversibilidad.
  String encodeAsRouteChain() {
    if (pages.isEmpty) {
      return '';
    }

    final List<String> routes = <String>[];
    for (int i = 0; i < pages.length; i += 1) {
      final PageModel p = pages[i];
      String raw = p.toUriString().trim();

      // falta path => reconstruimos y añadimos meta si hace falta
      final bool missingPath =
          raw.isEmpty || raw.startsWith('?') || raw.startsWith('#');

      if (missingPath) {
        raw = _routeFromPage(p);
      } else {
        // Si vino un path válido, aún así garantizamos meta si corresponde.
        // (ej: alguien implementó toUriString sin preservar name).
        final bool needsNameMeta =
            p.segments.isNotEmpty && p.segments.first != p.name;
        if (needsNameMeta) {
          final Uri u = Uri.parse(raw);
          final Map<String, String> q = <String, String>{};
          q.addAll(u.queryParameters);
          q[_kNameMeta] = p.name;

          raw = Uri(
            path: u.path.isEmpty ? '/${p.segments.join('/')}' : u.path,
            queryParameters: q.isEmpty ? null : q,
            fragment: u.fragment.isEmpty ? null : u.fragment,
          ).toString();
        }
      }

      routes.add(raw);
    }
    return routes.join(';');
  }

  /// Decodifica la cadena y restaura `name` cuando exista el meta `__n`.
  static NavStackModel decodeRouteChain(String chain) {
    final String input = chain.trim();
    if (input.isEmpty) {
      return defaultNavStackModel;
    }

    final List<String> tokens = input
        .split(';')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);

    if (tokens.isEmpty) {
      return defaultNavStackModel;
    }

    final List<PageModel> out = <PageModel>[];
    for (final String token in tokens) {
      final Uri uri = Uri.parse(token);

      // Primero construimos la página desde la URI.
      PageModel page = PageModel.fromUri(uri);

      // Si viene meta de nombre, lo aplicamos y limpiamos del query.
      final String? metaName = uri.queryParameters[_kNameMeta];
      if (metaName != null && metaName.isNotEmpty && metaName != page.name) {
        final Map<String, String> q = <String, String>{};
        q.addAll(page.query);
        q.remove(_kNameMeta);
        page = page.copyWith(name: metaName, query: q);
      }

      out.add(page);
    }
    return out.isEmpty ? defaultNavStackModel : NavStackModel(out);
  }

  @override
  NavStackModel copyWith({List<PageModel>? pages}) {
    final List<PageModel> next = pages ?? this.pages;
    return NavStackModel(
      List<PageModel>.unmodifiable(next),
    );
  }

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
