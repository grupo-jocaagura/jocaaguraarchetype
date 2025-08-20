part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class PageManager extends BlocModule {
  PageManager({required NavStackModel initial})
      : _stack = BlocGeneral<NavStackModel>(initial);

  /// Consistencia con el resto de módulos: minúsculas.
  static const String name = 'pageManager';

  final BlocGeneral<NavStackModel> _stack;

  /// True when there is at least one page to pop (stack length > 1).
  bool get canPop => !stack.isRoot;

  /// Reactive version for UI bindings.
  Stream<bool> get canPopStream => stackStream
      .map((NavStackModel navStackModel) => !navStackModel.isRoot)
      .distinct();

  Stream<NavStackModel> get stackStream => _stack.stream;
  NavStackModel get stack => _stack.value;
  bool get isClosed => _stack.isClosed;

  void setStack(NavStackModel next) {
    final NavStackModel sanitized = _dedupConsecutive(next);
    if (identical(sanitized, _stack.value) || sanitized == _stack.value) {
      return;
    }
    _stack.value = sanitized;
  }

  // ---- Mutations base ----
  void push(PageModel page, {bool allowDuplicate = false}) {
    if (!allowDuplicate && _sameTarget(stack.top, page)) {
      return;
    }
    setStack(stack.push(page));
  }

  void goHome() {
    if (stack.isRoot) {
      return;
    }
    setStack(stack.resetTo(stack.pages.first));
  }

  void replaceTop(PageModel page, {bool allowNoop = false}) {
    if (!allowNoop && _sameTarget(stack.top, page)) {
      return;
    }
    setStack(stack.replaceTop(page));
  }

  bool pop() {
    if (stack.isRoot) {
      return false;
    }
    setStack(stack.pop());
    return true;
  }

  void resetTo(PageModel root) => setStack(stack.resetTo(root));

  // ---- Ergonomía: named helpers (reemplazan al adaptador viejo) ----

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

  bool _isDisposed = false;

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
