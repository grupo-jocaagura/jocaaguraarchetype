part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Public contract for [AppManager].
///
/// Intentionally mirrors the current [AppManager] API to allow consumers to
/// depend on this type without code changes.
abstract interface class AbstractAppManager {
  // --------------------------------------------------------------------------
  // Core identity / lifecycle
  // --------------------------------------------------------------------------
  Env get env;
  bool get isDisposed;

  void handleLifecycle(AppLifecycleState state);
  FutureOr<void> dispose();

  // --------------------------------------------------------------------------
  // Read-only accessors to core blocs
  // --------------------------------------------------------------------------
  BlocTheme get theme;
  BlocUserNotifications get notifications;
  BlocLoading get loading;
  BlocResponsive get responsive;
  BlocOnboarding get onboarding;
  PageManager get pageManager;

  BlocMainMenuDrawer get mainMenu;
  BlocSecondaryMenuDrawer get secondaryMenu;

  BlocModelVersion? get appVersionBloc;
  ModelAppVersion get currentAppVersion;

  // --------------------------------------------------------------------------
  // Environment helpers
  // --------------------------------------------------------------------------
  AppMode get appMode;
  bool get isQa;
  bool get isProd;

  // --------------------------------------------------------------------------
  // Config
  // --------------------------------------------------------------------------
  void applyConfig(AppConfig next, {bool resetStack = false});

  // --------------------------------------------------------------------------
  // Navigation API (String-based)
  // --------------------------------------------------------------------------
  void goTo(String location);
  void push(String location, {bool allowDuplicate = true});
  void pushOnce(String location);
  void replaceTop(String location, {bool allowNoop = false});
  bool pop();
  void clearAndGoHome();

  void replaceTopNamed(
    String name, {
    List<String>? segments,
    Map<String, String>? query,
    PageKind kind = PageKind.material,
    bool requiresAuth = false,
    Map<String, dynamic>? state,
    bool allowNoop = false,
  });

  // Navigation by PageModel
  void goToModel(PageModel model);
  void pushModel(PageModel model, {bool allowDuplicate = true});
  void pushOnceModel(PageModel model);
  void replaceTopModel(PageModel model, {bool allowNoop = false});

  // --------------------------------------------------------------------------
  // Menu actions
  // --------------------------------------------------------------------------
  void selectFromMainMenu(String location);
  void selectFromSecondaryMenu(String location);

  // --------------------------------------------------------------------------
  // Session coordination
  // --------------------------------------------------------------------------
  void onRequiresAuthAtTop();
  void onAuthenticatedRestorePendingStack();
  void clearPendingIntent();

  // --------------------------------------------------------------------------
  // UI helpers
  // --------------------------------------------------------------------------
  void notify(String message);

  Future<T> runWithLoading<T>(
    Future<T> future, {
    String label = 'Loading…',
    Duration minShow = Duration.zero,
  });

  Future<T> queueRunWithLoading<T>(
    Future<T> Function() task, {
    String label = 'Loading…',
    Duration minShow = Duration.zero,
  });

  // --------------------------------------------------------------------------
  // Telemetry hooks
  // --------------------------------------------------------------------------
  void trackPageView(
    String name, {
    Map<String, Object?> params = const <String, Object?>{},
  });

  void trackEvent(
    String id, {
    Map<String, Object?> params = const <String, Object?>{},
  });

  // --------------------------------------------------------------------------
  // Modules
  // --------------------------------------------------------------------------
  T requireModuleOfType<T extends BlocModule>();
  T requireModuleByKey<T extends BlocModule>(String key);

  // --------------------------------------------------------------------------
  // Testing helpers
  // --------------------------------------------------------------------------
  @visibleForTesting
  void debugSetPendingRouteChain(String? chain);
}
