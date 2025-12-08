part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Single façade for navigation, UI wiring, and cross-cutting concerns.
///
/// Aligned with the current archetype:
/// - Navigation source of truth: [PageManager].
/// - Theme source of truth: [BlocTheme] (ThemeUsecases → Repository → Gateway).
/// - Onboarding: [BlocOnboarding] from jocaagura_domain.
/// - Loading: [BlocLoading] (loadingWhile / queueLoadingWhile).
/// - Notifications: [BlocUserNotifications] (showToast).
/// - Menus: [BlocMainMenuDrawer] and [BlocSecondaryMenuDrawer] (acciones canalizadas aquí).
///
/// ### Navigation policy
/// - `pushOnce` is encouraged to avoid duplicates.
/// - `home` behaves as singleTop via [clearAndGoHome].
/// - Pages may set `requiresAuth`; coordinator redirects to `/login`.
class AppManager {
  AppManager(
    this._config, {
    this.onAppLifecycleChanged,
    this.env = defaultEnv,
  });
  AppConfig _config;
  bool _disposed = false;

  final Env env;
  final void Function(AppLifecycleState state)? onAppLifecycleChanged;
  // ---- Read-only accessors to core blocs ----
  BlocTheme get theme => _config.blocTheme;
  BlocUserNotifications get notifications => _config.blocUserNotifications;
  BlocLoading get loading => _config.blocLoading;
  BlocResponsive get responsive => _config.blocResponsive;
  BlocOnboarding get onboarding => _config.blocOnboarding;
  PageManager get pageManager => _config.pageManager;

  /// Menús (drawers)
  BlocMainMenuDrawer get mainMenu => _config.blocMainMenuDrawer;
  BlocSecondaryMenuDrawer get secondaryMenu => _config.blocSecondaryMenuDrawer;

  bool get isDisposed => _disposed;

  /// Applies a new [AppConfig]. Keeps the navigation stack by default.
  void applyConfig(AppConfig next, {bool resetStack = false}) {
    _config = next;
    if (resetStack) {
      clearAndGoHome();
    }
  }

  /// Called by UI layer to propagate lifecycle events.
  void handleLifecycle(AppLifecycleState state) {
    onAppLifecycleChanged?.call(state);
  }

  BlocModelVersion? get appVersionBloc => _config.blocModelVersion;

  ModelAppVersion get currentAppVersion =>
      _config.blocModelVersion?.value ?? ModelAppVersion.defaultModelAppVersion;

  // --------------------------------------------------------------------------
  // Enviroment -
  // --------------------------------------------------------------------------
  AppMode get appMode => env.mode;
  bool get isQa => env.isQa;
  bool get isProd => env.isProd;

  // --------------------------------------------------------------------------
  // Navigation API (String-based; internamente PageModel.fromUri)
  // --------------------------------------------------------------------------
  void goTo(String location) {
    final PageModel root = PageModel.fromUri(Uri.parse(location));
    pageManager.resetTo(root);
  }

  void push(String location, {bool allowDuplicate = true}) {
    final PageModel page = PageModel.fromUri(Uri.parse(location));
    pageManager.push(page, allowDuplicate: allowDuplicate);
  }

  void pushOnce(String location) {
    final PageModel page = PageModel.fromUri(Uri.parse(location));
    pageManager.pushOnce(page);
  }

  void replaceTop(String location, {bool allowNoop = false}) {
    final PageModel page = PageModel.fromUri(Uri.parse(location));
    pageManager.replaceTop(page, allowNoop: allowNoop);
  }

  /// Snapshot del stack pendiente cuando se redirige a /login.
  String? _pendingRouteChain;

  /// Limpia cualquier intención pendiente previamente almacenada.
  void clearPendingIntent() => _pendingRouteChain = null;
  bool pop() => pageManager.pop();

  void clearAndGoHome() => pageManager.goHome();

  // --------------------------------------------------------------------------
  // Menu actions → navegación centralizada en AppManager
  // --------------------------------------------------------------------------

  /// Dispara una acción desde el **Main Menu** (por convención, pushOnce).
  void selectFromMainMenu(String location) => pushOnce(location);

  /// Dispara una acción desde el **Secondary Menu** (por convención, pushOnce).
  void selectFromSecondaryMenu(String location) => pushOnce(location);

  // Si luego tenemos un tipo MenuItem, agregamos handlers tipeados:
  // void handleMainMenuItem(MenuItem item) { ... }
  // En AppManager
  void replaceTopNamed(
    String name, {
    List<String>? segments,
    Map<String, String>? query,
    PageKind kind = PageKind.material,
    bool requiresAuth = false,
    Map<String, dynamic>? state,
    bool allowNoop = false,
  }) {
    final PageModel page = PageModel(
      name: name,
      segments: segments ?? <String>[name],
      query: query ?? const <String, String>{},
      kind: kind,
      requiresAuth: requiresAuth,
      state: state ?? const <String, dynamic>{},
    );
    pageManager.replaceTop(page, allowNoop: allowNoop);
  }

  // --------------------------------------------------------------------------
  // Session coordination
  // --------------------------------------------------------------------------
  void onRequiresAuthAtTop() => goTo('/login');

  void onAuthenticatedRestorePendingStack() {
    if (_pendingRouteChain != null && _pendingRouteChain!.isNotEmpty) {
      pageManager.setFromRouteChain(_pendingRouteChain!);
      _pendingRouteChain = null;
    } else {
      clearAndGoHome();
    }
  }

  // --------------------------------------------------------------------------
  // UI helpers (loading / notifications)
  // --------------------------------------------------------------------------
  void notify(String message) => notifications.showToast(message);

  Future<T> runWithLoading<T>(
    Future<T> future, {
    String label = 'Loading…',
    Duration minShow = Duration.zero,
  }) {
    return loading.loadingWhile<T>(
      label,
      () async => future,
      minShow: minShow,
    );
  }

  Future<T> queueRunWithLoading<T>(
    Future<T> Function() task, {
    String label = 'Loading…',
    Duration minShow = Duration.zero,
  }) {
    return loading.queueLoadingWhile<T>(
      label,
      task,
      minShow: minShow,
    );
  }

  // --------------------------------------------------------------------------
  // Telemetry hooks (no-op by default)
  // --------------------------------------------------------------------------
  void trackPageView(
    String name, {
    Map<String, Object?> params = const <String, Object?>{},
  }) {}
  void trackEvent(
    String id, {
    Map<String, Object?> params = const <String, Object?>{},
  }) {}

  // --------------------------------------------------------------------------
  FutureOr<void> dispose() {
    if (_disposed) {
      return null;
    }
    _disposed = true;
    _config.dispose();
  }

  // Dentro de AppManager

  /// Returns the **first** registered module in [AppConfig.blocModuleList]
  /// that matches type [T]. Intended for development-time wiring.
  /// Throws [UnimplementedError] if not found.
  ///
  /// ### Example
  /// ```dart
  /// final MyFeatureModule mod = appManager.requireModuleOfType<MyFeatureModule>();
  /// ```
  T requireModuleOfType<T extends BlocModule>() {
    return _config.requireModuleOfType<T>();
  }

  /// Returns the module registered under [key] and **checks** it matches [T].
  /// Lookup is **case-insensitive**. Throws [UnimplementedError] if:
  ///  - no module is registered under [key], or
  ///  - the registered module does not match type [T].
  ///
  /// ### Example
  /// ```dart
  /// final CanvasModule canvas =
  ///   appManager.requireModuleByKey<CanvasModule>('Canvas'); // case-insensitive
  /// ```
  T requireModuleByKey<T extends BlocModule>(String key) {
    return _config.requireModuleByKey<T>(key);
  }

  /// Navigation by PageModel
  void goToModel(PageModel model) => pageManager.resetTo(model);
  void pushModel(PageModel model, {bool allowDuplicate = true}) =>
      pageManager.push(model, allowDuplicate: allowDuplicate);
  void pushOnceModel(PageModel model) => pageManager.pushOnce(model);
  void replaceTopModel(PageModel model, {bool allowNoop = false}) =>
      pageManager.replaceTop(model, allowNoop: allowNoop);

  @visibleForTesting
  void debugSetPendingRouteChain(String? chain) {
    if (_pendingRouteChain != chain) {
      _pendingRouteChain = chain;
    }
  }
}
