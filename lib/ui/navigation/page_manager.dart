part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Controla el comportamiento del módulo después de `dispose()`.
///
/// - [throwStateError] (estricto): cualquier acceso tras `dispose()`
///   lanza [StateError].
/// - [returnLastSnapshotNoop] (tolerante): getters devuelven el último
///   snapshot conocido y los mutadores se convierten en **no-op**.
enum ModulePostDisposePolicy {
  /// Estricto: cualquier acceso tras `dispose()` lanza StateError.
  throwStateError,

  /// Tolerante: getters devuelven último snapshot; mutadores son no-op.
  returnLastSnapshotNoop,
}

/// Gestiona el **stack de navegación** como un BLoC de alto nivel.
///
/// Mantiene un [NavStackModel] interno y expone operaciones declarativas
/// para **push/pop/replace/reset**, además de utilidades por nombre/URI.
/// Su estado se publica mediante [stackStream] y derivadas (p. ej. [canPopStream]).
///
/// ### Políticas post-dispose
/// El comportamiento posterior a `dispose()` se rige por [postDisposePolicy]:
/// - **Estricto**: lanza [StateError] en cualquier acceso.
/// - **Tolerante**: los getters usan el último snapshot; mutadores son **no-op**.
///
/// ### Ejemplo mínimo
/// ```dart
/// void main() {
///   final NavStackModel initial = NavStackModel(<PageModel>[
///     PageModel.material('home'),
///   ]);
///
///   final PageManager pm = PageManager(initial: initial);
///   pm.pushNamed('details', query: <String, String>{'id': '42'});
///   // pm.stack.top.name == 'details'
///   // pm.canPop == true
///
///   pm.pop(); // vuelve a 'home'
/// }
/// ```
///
/// ### Contratos
/// - **Precondición**: [initial] debe describir un stack **válido**.
/// - **Postcondición**: todas las mutaciones preservan la coherencia del stack
///   (p. ej. sin duplicados consecutivos cuando `allowDuplicate == false`).
/// - **Post-dispose**: ver [postDisposePolicy].
class PageManager extends BlocModule {
  /// Crea un gestor de navegación con un [initial] stack.
  ///
  /// - [postDisposePolicy] define el contrato de acceso luego de `dispose()`.
  PageManager({
    required this.initial,
    this.postDisposePolicy = ModulePostDisposePolicy.throwStateError,
  }) : _stack = BlocGeneral<NavStackModel>(initial);

  /// Nombre simbólico del módulo para registro/DI.
  static const String name = 'pageManager';

  /// BLoC interno que mantiene el stack de navegación.
  final BlocGeneral<NavStackModel> _stack;

  /// Política de acceso tras `dispose()`. Ver [ModulePostDisposePolicy].
  final ModulePostDisposePolicy postDisposePolicy;

  /// Stack inicial usado por [goHome] cuando ya se está en root.
  final NavStackModel initial;

  bool _isDisposed = false;

  /// Ejecuta [body] si el módulo **no** está `disposed`; de lo contrario
  /// aplica la [postDisposePolicy] usando [lastSnapshot] o lanzando error.
  T _guard<T>({
    required T Function() body,
    required T Function() lastSnapshot,
  }) {
    if (!_isDisposed && !_stack.isClosed) {
      return body();
    }
    switch (postDisposePolicy) {
      case ModulePostDisposePolicy.throwStateError:
        throw StateError('PageManager has been disposed');
      case ModulePostDisposePolicy.returnLastSnapshotNoop:
        return lastSnapshot();
    }
  }

  /// Indica si el BLoC interno ha sido cerrado.
  bool get isClosed => _stack.isClosed;

  /// `true` si existe al menos una página para hacer `pop`.
  ///
  /// - **Estricto**: tras `dispose()` lanza [StateError].
  /// - **Tolerante**: calcula a partir del último snapshot.
  bool get canPop => _guard<bool>(
        body: () => !stack.isRoot,
        lastSnapshot: () {
          return !_stack.value.isRoot;
        },
      );

  /// Stream derivado que emite `true/false` según el stack **no** esté en root.
  Stream<bool> get canPopStream =>
      stackStream.map((NavStackModel s) => !s.isRoot).distinct();

  /// Referencia al stream del BLoC interno (inmutable).
  late final Stream<NavStackModel> _stackStreamRef = _stack.stream;

  /// Stream del stack de navegación.
  ///
  /// En modo tolerante, se devuelve la misma instancia aunque se haya cerrado.
  Stream<NavStackModel> get stackStream => _guard<Stream<NavStackModel>>(
        body: () => _stackStreamRef,
        lastSnapshot: () =>
            _stackStreamRef, // misma instancia, aunque ya esté cerrado
      );

  /// Snapshot actual del stack de navegación.
  ///
  /// En modo tolerante, devuelve el último valor conocido.
  NavStackModel get stack => _guard<NavStackModel>(
        body: () => _stack.value,
        lastSnapshot: () => _stack.value,
      );

  // ---- Mutaciones con no-op en leniente ------------------------------------

  /// Reemplaza el stack completo por [next].
  ///
  /// - Cuando [allowDuplicate] es `false`, elimina duplicados **consecutivos**
  ///   de destino (ver [_dedupConsecutive]).
  /// - **Estricto**: tras `dispose()` lanza [StateError].
  /// - **Tolerante**: **no-op** tras `dispose()`.
  void setStack(NavStackModel next, {bool allowDuplicate = false}) {
    if (_isDisposed || _stack.isClosed) {
      if (postDisposePolicy == ModulePostDisposePolicy.returnLastSnapshotNoop) {
        return; // no-op
      }
      throw StateError('PageManager has been disposed');
    }

    final NavStackModel sanitized =
        allowDuplicate ? next : _dedupConsecutive(next);

    if (identical(sanitized, _stack.value) || sanitized == _stack.value) {
      return;
    }
    _stack.value = sanitized;
  }

  /// Hace `push` de [page] sobre el top.
  ///
  /// - Evita duplicar el **mismo destino** si [allowDuplicate] es `false`.
  /// - **Estricto**: tras `dispose()` lanza [StateError].
  /// - **Tolerante**: **no-op** tras `dispose()`.
  void push(PageModel page, {bool allowDuplicate = false}) {
    if (_isDisposed || _stack.isClosed) {
      if (postDisposePolicy == ModulePostDisposePolicy.returnLastSnapshotNoop) {
        return; // no-op
      }
      throw StateError('PageManager has been disposed');
    }
    if (!allowDuplicate && _sameTarget(stack.top, page)) {
      return;
    }
    final NavStackModel next = stack.push(page);
    setStack(next, allowDuplicate: allowDuplicate);
  }

  /// Navega al **root** del flujo actual o al [initial] si ya está en root.
  ///
  /// Útil para “volver al inicio” del contexto vigente.
  void goHome() {
    if (_isDisposed || _stack.isClosed) {
      if (postDisposePolicy == ModulePostDisposePolicy.returnLastSnapshotNoop) {
        return;
      }
      throw StateError('PageManager has been disposed');
    }
    if (stack.isRoot) {
      setStack(initial);
      return;
    }
    setStack(stack.resetTo(stack.pages.first));
  }

  /// Reemplaza el top por [page]. Si [allowNoop] es `false`, evita
  /// reemplazar por el mismo destino.
  void replaceTop(PageModel page, {bool allowNoop = false}) {
    if (_isDisposed || _stack.isClosed) {
      if (postDisposePolicy == ModulePostDisposePolicy.returnLastSnapshotNoop) {
        return;
      }
      throw StateError('PageManager has been disposed');
    }
    if (!allowNoop && _sameTarget(stack.top, page)) {
      return;
    }
    setStack(stack.replaceTop(page));
  }

  /// Intenta hacer `pop` del stack.
  ///
  /// Retorna `true` si el `pop` fue aplicado; `false` si ya estaba en root.
  /// - **Estricto**: tras `dispose()` lanza [StateError].
  /// - **Tolerante**: retorna `false` tras `dispose()`.
  bool pop() {
    if (_isDisposed || _stack.isClosed) {
      if (postDisposePolicy == ModulePostDisposePolicy.returnLastSnapshotNoop) {
        return false;
      }
      throw StateError('PageManager has been disposed');
    }
    if (stack.isRoot) {
      return false;
    }
    setStack(stack.pop());
    return true;
  }

  /// Reinicia el stack a [root] como única página.
  void resetTo(PageModel root) {
    if (_isDisposed || _stack.isClosed) {
      if (postDisposePolicy == ModulePostDisposePolicy.returnLastSnapshotNoop) {
        return;
      }
      throw StateError('PageManager has been disposed');
    }
    setStack(stack.resetTo(root));
  }

  /// `push` por nombre. Guarda [title] (si se provee) en `state['title']`.
  ///
  /// Parámetros clave:
  /// - [segments]: si es `null` o vacío, se infiere `<name>`.
  /// - [query], [kind], [requiresAuth], [state], [allowDuplicate].
  void pushNamed(
    String name, {
    String? title,
    List<String>? segments,
    Map<String, String>? query,
    PageKind kind = PageKind.material,
    bool requiresAuth = false,
    Map<String, dynamic>? state,
    bool allowDuplicate = false,
  }) {
    final PageModel page = PageModel(
      name: name,
      segments: (segments == null || segments.isEmpty)
          ? <String>[name]
          : List<String>.from(segments),
      query: query ?? const <String, String>{},
      kind: kind,
      requiresAuth: requiresAuth,
      state: <String, dynamic>{...?state, if (title != null) 'title': title},
    );
    push(page, allowDuplicate: allowDuplicate);
  }

  /// Reemplaza el top usando un nombre y metadatos equivalentes a [pushNamed].
  ///
  /// Si [allowNoop] es `false`, evita reemplazar por el mismo destino.
  void replaceTopNamed(
    String name, {
    String? title,
    List<String>? segments,
    Map<String, String>? query,
    PageKind kind = PageKind.material,
    bool requiresAuth = false,
    Map<String, dynamic>? state,
    bool allowNoop = false,
  }) {
    final PageModel page = PageModel(
      name: name,
      segments: (segments == null || segments.isEmpty)
          ? <String>[name]
          : List<String>.from(segments),
      query: query ?? const <String, String>{},
      kind: kind,
      requiresAuth: requiresAuth,
      state: <String, dynamic>{...?state, if (title != null) 'title': title},
    );
    replaceTop(page, allowNoop: allowNoop);
  }

  /// Reinicia el stack a una sola página construida a partir del [name].
  void goNamed(
    String name, {
    String? title,
    List<String>? segments,
    Map<String, String>? query,
    PageKind kind = PageKind.material,
    bool requiresAuth = false,
    Map<String, dynamic>? state,
  }) {
    final PageModel root = PageModel(
      name: name,
      segments: (segments == null || segments.isEmpty)
          ? <String>[name]
          : List<String>.from(segments),
      query: query ?? const <String, String>{},
      kind: kind,
      requiresAuth: requiresAuth,
      state: <String, dynamic>{...?state, if (title != null) 'title': title},
    );
    resetTo(root);
  }

  /// Navega por una **location** (p. ej. `"/foo/bar?x=1"`).
  ///
  /// Por defecto hace `push` para conservar el historial. Usa
  /// [mustReplaceTop] para realizar `replaceTop` (p. ej. redirects).
  void navigateToLocation(
    String location, {
    String? name,
    PageKind kind = PageKind.material,
    bool mustReplaceTop = false,
    bool allowDuplicate = false,
  }) {
    final PageModel page =
        PageModel.fromUri(Uri.parse(location), name: name, kind: kind);

    if (mustReplaceTop) {
      replaceTop(page, allowNoop: true);
    } else {
      push(page, allowDuplicate: allowDuplicate);
    }
  }

  /// Cambia “duro” de contexto reemplazando el stack con la [location] dada.
  ///
  /// Útil para deep-links iniciales.
  void goToLocation(
    String location, {
    String? name,
    PageKind kind = PageKind.material,
  }) {
    final PageModel root =
        PageModel.fromUri(Uri.parse(location), name: name, kind: kind);
    resetTo(root);
  }

  /// Establece el stack decodificando una **chain** serializada.
  void setFromRouteChain(String chain) =>
      setStack(NavStackModel.decodeRouteChain(chain));

  /// Devuelve la **chain** canónica del stack actual.
  String get routeChain => stack.encodeAsRouteChain();

  /// Helper de depuración: lista inmutable de nombres de página en el historial.
  List<String> get historyNames =>
      stack.pages.map((PageModel p) => p.name).toList(growable: false);

  /// Libera recursos del BLoC interno y aplica la política post-dispose.
  @override
  FutureOr<void> dispose() {
    if (_isDisposed) {
      return null;
    }
    _isDisposed = true;
    _stack.dispose();
  }

  /// Normaliza a `String` no vacío; en otro caso devuelve `''`.
  String _asNonEmptyString(dynamic v) {
    return (v is String && v.trim().isNotEmpty) ? v : '';
  }

  /// Obtiene un título “humano” para la página:
  /// 1) `state['title']` explícito, 2) `query['title']`, 3) último segmento
  /// o `name` humanizado.
  String _titleOf(PageModel p) {
    final String fromState = _asNonEmptyString(p.state['title']);
    if (fromState.isNotEmpty) {
      return fromState;
    }

    final String fromQuery = _asNonEmptyString(p.query['title']);
    if (fromQuery.isNotEmpty) {
      return fromQuery;
    }

    if (p.segments.isNotEmpty) {
      return _humanize(p.segments.last);
    }
    return _humanize(p.name);
  }

  /// Humaniza una cadena básica: separa guiones/underscores y capitaliza.
  String _humanize(String s) {
    // muy simple: separa guiones/underscores y capitaliza la primera
    final String spaced = s.replaceAll(RegExp(r'[_\-]+'), ' ');
    return spaced.isEmpty
        ? s
        : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }

  /// Título actual derivado del top del stack.
  String get currentTitle => _titleOf(stack.top);

  /// Stream de títulos; emite el título del top cuando cambie el stack.
  Stream<String> get currentTitleStream =>
      stackStream.map((NavStackModel s) => _titleOf(s.top)).distinct();

  /// Compara si dos [PageModel] apuntan al **mismo destino lógico**.
  bool _sameTarget(PageModel a, PageModel b) {
    return a.name == b.name &&
        listEquals(a.segments, b.segments) &&
        mapEquals(a.query, b.query) &&
        a.kind == b.kind &&
        a.requiresAuth == b.requiresAuth;
  }

  /// Remueve **duplicados consecutivos** de destino dentro del stack.
  ///
  /// Reconstruye el stack preservando orden y dejando un solo elemento
  /// por cada corrida consecutiva de páginas equivalentes.
  NavStackModel _dedupConsecutive(NavStackModel s) {
    final List<PageModel> out = <PageModel>[];
    for (final PageModel p in s.pages) {
      if (out.isEmpty || !_sameTarget(out.last, p)) {
        out.add(p);
      }
    }
    return NavStackModel(out);
  }

  /// `push` evitando duplicado **consecutivo** (no-op si el top es igual).
  void pushDistinctTop(PageModel page, {PageEquals equals = routeEquals}) {
    setStack(stack.pushDistinctTop(page, equals: equals));
  }

  /// `push` garantizando **unicidad global** en el stack
  /// (remueve iguales previamente).
  void pushOnce(PageModel page, {PageEquals equals = routeEquals}) {
    setStack(stack.pushOnce(page, equals: equals));
  }

  /// Versión *named* de [pushDistinctTop].
  void pushDistinctTopNamed(
    String name, {
    String? title,
    List<String>? segments,
    Map<String, String>? query,
    PageKind kind = PageKind.material,
    bool requiresAuth = false,
    Map<String, dynamic>? state,
    PageEquals equals = routeEquals, // o _nameEquals si prefieres
  }) {
    final PageModel page = PageModel(
      name: name,
      segments: (segments == null || segments.isEmpty)
          ? <String>[name]
          : List<String>.from(segments),
      query: query ?? const <String, String>{},
      kind: kind,
      requiresAuth: requiresAuth,
      state: <String, dynamic>{...?state, if (title != null) 'title': title},
    );
    pushDistinctTop(page, equals: equals);
  }

  /// Versión *named* de [pushOnce].
  void pushOnceNamed(
    String name, {
    String? title,
    List<String>? segments,
    Map<String, String>? query,
    PageKind kind = PageKind.material,
    bool requiresAuth = false,
    Map<String, dynamic>? state,
    PageEquals equals = routeEquals,
  }) {
    final PageModel page = PageModel(
      name: name,
      segments: (segments == null || segments.isEmpty)
          ? <String>[name]
          : List<String>.from(segments),
      query: query ?? const <String, String>{},
      kind: kind,
      requiresAuth: requiresAuth,
      state: <String, dynamic>{...?state, if (title != null) 'title': title},
    );
    pushOnce(page, equals: equals);
  }
}
