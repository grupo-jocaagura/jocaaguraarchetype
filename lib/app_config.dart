part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class AppConfig {
  const AppConfig({
    required this.blocTheme,
    required this.blocUserNotifications,
    required this.blocLoading,
    required this.blocMainMenuDrawer,
    required this.blocSecondaryMenuDrawer,
    required this.blocResponsive,
    required this.blocOnboarding,
    required this.pageManager,
    this.blocModuleList = const <String, BlocModule>{},
  });

  /// Flavors de ejemplo (opcional)
  factory AppConfig.dev({
    required PageRegistry registry,
  }) {
    // root simple: /home
    final PageManager pm = PageManager(
      initial: NavStackModel.single(
        const PageModel(
          name: 'home',
          segments: <String>['home'],
        ),
      ),
    );
    return AppConfig(
      blocTheme: BlocTheme(
        themeUsecases: ThemeUsecases.fromRepo(
          RepositoryThemeImpl(
            gateway: GatewayThemeImpl(),
          ),
        ),
      ),
      blocUserNotifications: BlocUserNotifications(),
      blocLoading: BlocLoading(),
      blocMainMenuDrawer: BlocMainMenuDrawer(),
      blocSecondaryMenuDrawer: BlocSecondaryMenuDrawer(),
      blocResponsive: BlocResponsive(),
      blocOnboarding: BlocOnboarding(),
      pageManager: pm,
    );
  }

  final BlocTheme blocTheme;
  final BlocUserNotifications blocUserNotifications;
  final BlocLoading blocLoading;
  final BlocMainMenuDrawer blocMainMenuDrawer;
  final BlocSecondaryMenuDrawer blocSecondaryMenuDrawer;
  final BlocResponsive blocResponsive;
  final BlocOnboarding blocOnboarding;

  /// New: navigation stack
  final PageManager pageManager;

  final Map<String, BlocModule> blocModuleList;

  BlocCore<dynamic> blocCore() {
    return BlocCore<dynamic>(<String, BlocModule>{
      BlocTheme.name: blocTheme,
      BlocOnboarding.name: blocOnboarding,
      BlocResponsive.name: blocResponsive,
      BlocMainMenuDrawer.name: blocMainMenuDrawer,
      BlocSecondaryMenuDrawer.name: blocSecondaryMenuDrawer,
      BlocLoading.name: blocLoading,
      BlocUserNotifications.name: blocUserNotifications,
      PageManager.name: pageManager,
      ...blocModuleList,
    });
  }
}
