part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

enum ModulePostDisposePolicy {
  /// Estricto: cualquier acceso tras `dispose()` lanza StateError.
  throwStateError,

  /// Tolerante: getters devuelven último snapshot; mutadores son no-op.
  returnLastSnapshotNoop,
}

class PageManager extends BlocModule {
  PageManager({
    required NavStackModel initial,
    this.postDisposePolicy = ModulePostDisposePolicy.throwStateError,
  }) : _stack = BlocGeneral<NavStackModel>(initial);

  static const String name = 'pageManager';

  final BlocGeneral<NavStackModel> _stack;
  final ModulePostDisposePolicy postDisposePolicy;

  bool _isDisposed = false;

  // ---- Guard genérico (similar a BlocSession._guard) ------------------------
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

  // ---- Lecturas seguras -----------------------------------------------------
  bool get isClosed => _stack.isClosed;

  bool get canPop => _guard<bool>(
        body: () => !stack.isRoot,
        lastSnapshot: () {
          // Si ya está cerrado, seguimos respondiendo con el último valor.
          return !_stack.value.isRoot;
        },
      );

  Stream<bool> get canPopStream =>
      stackStream.map((NavStackModel s) => !s.isRoot).distinct();

  Stream<NavStackModel> get stackStream => _guard<Stream<NavStackModel>>(
        body: () => _stack.stream,
        lastSnapshot: () =>
            _stack.stream, // stream ya cerrado, re-emite y completa
      );

  NavStackModel get stack => _guard<NavStackModel>(
        body: () => _stack.value,
        lastSnapshot: () => _stack.value,
      );

  // ---- Mutaciones con no-op en leniente ------------------------------------
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
    setStack(stack.push(page), allowDuplicate: allowDuplicate);
  }

  void goHome() {
    if (_isDisposed || _stack.isClosed) {
      if (postDisposePolicy == ModulePostDisposePolicy.returnLastSnapshotNoop) {
        return;
      }
      throw StateError('PageManager has been disposed');
    }
    if (stack.isRoot) {
      return;
    }
    setStack(stack.resetTo(stack.pages.first));
  }

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

  bool pop() {
    if (_isDisposed || _stack.isClosed) {
      if (postDisposePolicy == ModulePostDisposePolicy.returnLastSnapshotNoop) {
        return false; // comportamiento seguro
      }
      throw StateError('PageManager has been disposed');
    }
    if (stack.isRoot) {
      return false;
    }
    setStack(stack.pop());
    return true;
  }

  void resetTo(PageModel root) {
    if (_isDisposed || _stack.isClosed) {
      if (postDisposePolicy == ModulePostDisposePolicy.returnLastSnapshotNoop) {
        return;
      }
      throw StateError('PageManager has been disposed');
    }
    setStack(stack.resetTo(root));
  }

  /// Push by name. Optional [title] stored in `state['title']`.
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

  /// Replace top using a name.
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

  /// Reset stack to a single named page.
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

  // ---- Helpers (URI/chain) ----
  void navigateToLocation(
    String location, {
    String? name,
    PageKind kind = PageKind.material,
  }) {
    replaceTop(PageModel.fromUri(Uri.parse(location), name: name, kind: kind));
  }

  void setFromRouteChain(String chain) =>
      setStack(NavStackModel.decodeRouteChain(chain));
  String get routeChain => stack.encodeAsRouteChain();

  /// Debug helper: list of page names in back stack.
  List<String> get historyNames =>
      stack.pages.map((PageModel p) => p.name).toList(growable: false);

  @override
  FutureOr<void> dispose() {
    if (_isDisposed) {
      return null;
    }
    _isDisposed = true;
    _stack.dispose();
  }

  String _titleOf(PageModel p) {
    // 1) explícito en state['title']
    final String? fromState = p.state['title'] as String?;
    if (fromState != null && fromState.isNotEmpty) {
      return fromState;
    }

    // 2) fallback por query (útil para deep-links)
    final String? fromQuery = p.query['title'];
    if (fromQuery != null && fromQuery.isNotEmpty) {
      return fromQuery;
    }

    // 3) último segmento o el name
    if (p.segments.isNotEmpty) {
      return _humanize(p.segments.last);
    }
    return _humanize(p.name);
  }

  String _humanize(String s) {
    // muy simple: separa guiones/underscores y capitaliza la primera
    final String spaced = s.replaceAll(RegExp(r'[_\-]+'), ' ');
    return spaced.isEmpty
        ? s
        : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }

  String get currentTitle => _titleOf(stack.top);
  Stream<String> get currentTitleStream =>
      stackStream.map((NavStackModel s) => _titleOf(s.top)).distinct();

  // ---- helpers ----
  bool _sameTarget(PageModel a, PageModel b) {
    return a.name == b.name &&
        listEquals(a.segments, b.segments) &&
        mapEquals(a.query, b.query) &&
        a.kind == b.kind &&
        a.requiresAuth == b.requiresAuth;
  }

  NavStackModel _dedupConsecutive(NavStackModel s) {
    final List<PageModel> out = <PageModel>[];
    for (final PageModel p in s.pages) {
      if (out.isEmpty || !_sameTarget(out.last, p)) {
        out.add(p);
      }
    }
    // reconstruye el stack con `out`
    return NavStackModel(out); // o copyWith(pages: out) si lo tienes
  }

  /// Push evitando duplicado consecutivo (no-op si el top es igual).
  void pushDistinctTop(PageModel page, {PageEquals equals = _routeEquals}) {
    setStack(stack.pushDistinctTop(page, equals: equals));
  }

  /// Push garantizando unicidad en el stack completo (remueve iguales antes).
  void pushOnce(PageModel page, {PageEquals equals = _routeEquals}) {
    setStack(stack.pushOnce(page, equals: equals));
  }

  // --- helpers "named" coherentes ---

  void pushDistinctTopNamed(
    String name, {
    String? title,
    List<String>? segments,
    Map<String, String>? query,
    PageKind kind = PageKind.material,
    bool requiresAuth = false,
    Map<String, dynamic>? state,
    PageEquals equals = _routeEquals, // o _nameEquals si prefieres
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

  void pushOnceNamed(
    String name, {
    String? title,
    List<String>? segments,
    Map<String, String>? query,
    PageKind kind = PageKind.material,
    bool requiresAuth = false,
    Map<String, dynamic>? state,
    PageEquals equals =
        _routeEquals, // cambia a _nameEquals si tu clave es el name
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
