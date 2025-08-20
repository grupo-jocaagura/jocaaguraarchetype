part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class AppManager {
  AppManager(this.appConfig) : _blocCore = appConfig.blocCore();

  final AppConfig appConfig;
  final BlocCore<dynamic> _blocCore;

  BlocCore<dynamic> get blocCore => _blocCore;

  // BLoCs
  BlocResponsive get responsive =>
      blocCore.getBlocModule<BlocResponsive>(BlocResponsive.name);
  BlocLoading get loading =>
      blocCore.getBlocModule<BlocLoading>(BlocLoading.name);
  BlocMainMenuDrawer get mainMenu =>
      blocCore.getBlocModule<BlocMainMenuDrawer>(BlocMainMenuDrawer.name);
  BlocSecondaryMenuDrawer get secondaryMenu => blocCore
      .getBlocModule<BlocSecondaryMenuDrawer>(BlocSecondaryMenuDrawer.name);
  BlocTheme get theme => blocCore.getBlocModule<BlocTheme>(BlocTheme.name);
  BlocOnboarding get onboarding =>
      blocCore.getBlocModule<BlocOnboarding>(BlocOnboarding.name);
  BlocUserNotifications get blocUserNotifications =>
      blocCore.getBlocModule(BlocUserNotifications.name);

  /// Navegación (única fuente de verdad)
  PageManager get page => blocCore.getBlocModule<PageManager>(PageManager.name);

  // Proxies ergonómicos para el UI
  void push(PageModel pageModel) => page.push(pageModel);
  void pushNamed(
    String name, {
    String? title,
    List<String>? segments,
    Map<String, String>? query,
    PageKind kind = PageKind.material,
    bool requiresAuth = false,
    Map<String, dynamic>? state,
  }) =>
      page.pushNamed(
        name,
        title: title,
        segments: segments,
        query: query,
        kind: kind,
        requiresAuth: requiresAuth,
        state: state,
      );
  bool pop() => page.pop();
  List<String> get historyPageNames => page.historyNames;

  FutureOr<void> dispose() {
    if (isDisposed) {
      return null;
    }
    isDisposed = true;
    blocCore.dispose();
  }

  bool isDisposed = false;
}
