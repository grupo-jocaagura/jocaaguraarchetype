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
    if (identical(next, _stack.value) || next == _stack.value) {
      return;
    }
    _stack.value = next;
  }

  // ---- Mutations base ----
  void push(PageModel page) => setStack(stack.push(page));
  void replaceTop(PageModel page) => setStack(stack.replaceTop(page));
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
    push(page);
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
    replaceTop(page);
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
}
