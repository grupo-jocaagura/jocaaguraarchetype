part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

typedef PageEquals = bool Function(PageModel a, PageModel b);

/// Compara dos [PageModel] por destino de ruta (`name + segments + query + kind + requiresAuth`).
///
/// Útil como estrategia por defecto para evitar duplicados lógicos en la pila.
bool routeEquals(PageModel a, PageModel b) {
  return a.name == b.name &&
      listEquals(a.segments, b.segments) &&
      mapEquals(a.query, b.query) &&
      a.kind == b.kind &&
      a.requiresAuth == b.requiresAuth;
}

const NavStackModel defaultNavStackModel = NavStackModel.notFound;

/// Representa una pila inmutable de [PageModel] para navegación.
///
/// Mantiene la invariante de **no-vacío** (siempre existe al menos una página).
/// Expone operaciones puras que generan nuevas instancias sin mutar estado:
/// [push], [pushDistinctTop], [pushOnce], [replaceTop], [pop], [resetTo],
/// [dedupAll], [moveToTopOrPush].
///
/// ### Contratos
/// - `pages.isNotEmpty == true` siempre.
/// - `pop()` en raíz retorna la misma instancia (no lanza).
/// - `replaceTop()` asume pila no vacía (garantizado por la clase).
///
/// ### Ejemplo funcional
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

  /// Crea una pila con una única página raíz.
  factory NavStackModel.single(PageModel page) =>
      NavStackModel(<PageModel>[page]);

  /// Restaura la pila a partir de un JSON serializado.
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

  /// Instancia especial que representa una ruta no encontrada.
  static const NavStackModel notFound =
      NavStackModel._internal(<PageModel>[PageModel(name: defaultName)]);

  static const String defaultName = 'notFound';
  static const String pagesKey = 'pages';

  /// Páginas de la pila, ordenadas de raíz a tope.
  final List<PageModel> pages;

  /// Página superior de la pila (actual).
  PageModel get top => pages.isEmpty ? defaultNavStackModel.top : pages.last;

  /// Indica si la pila contiene solo una página raíz.
  bool get isRoot => pages.length == 1;

  /// Empuja una nueva página al tope.
  NavStackModel push(PageModel page) {
    final List<PageModel> next = List<PageModel>.from(pages)..add(page);
    return NavStackModel(next);
  }

  /// Reemplaza la página superior por [page].
  NavStackModel replaceTop(PageModel page) {
    if (pages.isEmpty) {
      return defaultNavStackModel;
    }
    final List<PageModel> next = List<PageModel>.from(pages);
    next.removeLast();
    next.add(page);
    return NavStackModel(next);
  }

  /// Retira la página superior. Si es raíz, retorna la misma instancia.
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

  /// Limpia la pila y la reinicia con una nueva raíz.
  NavStackModel resetTo(PageModel root) => NavStackModel.single(root);

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      pagesKey: pages.map((PageModel p) => p.toJson()).toList(growable: false),
    };
  }

  static const String _kNameMeta = '__n';

  static String _routeFromPage(PageModel p) {
    final List<String> segs =
        p.segments.isNotEmpty ? p.segments : <String>[p.name];
    final String path = '/${segs.join('/')}';

    final Map<String, String> q = <String, String>{};
    q.addAll(
      p.query.map((String k, String v) => MapEntry<String, String>(k, v)),
    );
    q.remove(_kNameMeta);

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

    final String fragStr = (p.fragment == null || p.fragment!.isEmpty)
        ? ''
        : '#${Uri.encodeComponent(p.fragment!)}';

    return '$path$queryStr$fragStr';
  }

  /// Codifica la pila como cadena de rutas separadas por `;`.
  ///
  /// Reconstruye el path si `toUriString()` está vacío, y añade meta `__n=<name>`
  /// cuando `name != first(segments)` para asegurar reversibilidad.
  String encodeAsRouteChain() {
    if (pages.isEmpty) {
      return '';
    }

    final List<String> routes = <String>[];
    for (int i = 0; i < pages.length; i += 1) {
      final PageModel p = pages[i];
      String raw = p.toUriString().trim();

      final bool missingPath =
          raw.isEmpty || raw.startsWith('?') || raw.startsWith('#');

      if (missingPath) {
        raw = _routeFromPage(p);
      } else {
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

  /// Decodifica una cadena de rutas y restaura nombres cuando exista meta `__n`.
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

      PageModel page = PageModel.fromUri(uri);

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

  /// Crea una copia con nuevas [pages]. Mantiene la invariante de no-vacío.
  @override
  NavStackModel copyWith({List<PageModel>? pages}) {
    if (pages == null) {
      return this;
    }
    return NavStackModel(pages);
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

  /// Empuja [page] evitando duplicado consecutivo según [equals] (por defecto [routeEquals]).
  ///
  /// Retorna `this` si el tope ya es "igual"; en otro caso, crea una nueva pila.
  NavStackModel pushDistinctTop(
    PageModel page, {
    PageEquals equals = routeEquals,
  }) {
    if (pages.isEmpty) {
      return NavStackModel.single(page);
    }
    return equals(top, page) ? this : push(page);
  }

  /// Empuja [page] garantizando que solo exista una instancia "igual" según [equals].
  ///
  /// Si ya existe en la pila, la remueve y agrega [page] al tope.
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

  /// Elimina duplicados conservando la primera ocurrencia según [equals].
  ///
  /// Respeta la invariante de no-vacío.
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

  /// Busca una página "igual" y la mueve al tope. Si no existe, hace push.
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
