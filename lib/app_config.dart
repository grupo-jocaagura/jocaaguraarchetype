part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Holds the source-of-truth blocs for the app shell, aligned with the
/// current archetype flow. Uses ThemeUsecases → RepositoryThemeImpl →
/// GatewayThemeImpl for theming, and the jocaagura_domain BlocOnboarding.
///
/// Example
/// ```dart
/// final PageRegistry registry = buildExampleRegistry();
/// final AppConfig cfg = AppConfig.dev(registry: registry);
/// final AppManager manager = AppManager(cfg);
/// runApp(JocaaguraApp(appManager: manager, registry: registry));
/// ```
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

  /// DEV factory using the archetype defaults and in‑memory theme gateway.
  /// The PageRegistry is required by the app shell (JocaaguraApp), while the
  /// initial stack here starts at `/home`.
  factory AppConfig.dev({
    required PageRegistry registry,
    List<OnboardingStep> onboardingSteps = const <OnboardingStep>[],
  }) {
    // Minimal initial stack → /home
    final PageManager pm = PageManager(
      initial: NavStackModel.single(
        const PageModel(name: 'home', segments: <String>['home']),
      ),
    );

    // BlocTheme wired to ThemeUsecases → RepositoryThemeImpl → GatewayThemeImpl
    final BlocTheme themeBloc = BlocTheme(
      themeUsecases: ThemeUsecases.fromRepo(
        RepositoryThemeImpl(gateway: GatewayThemeImpl()),
      ),
    );

    // jocaagura_domain BlocOnboarding with optional configured steps
    final BlocOnboarding onboardingBloc = BlocOnboarding();
    if (onboardingSteps.isNotEmpty) {
      onboardingBloc.configure(onboardingSteps);
    }

    return AppConfig(
      blocTheme: themeBloc,
      blocUserNotifications: BlocUserNotifications(),
      blocLoading: BlocLoading(),
      blocMainMenuDrawer: BlocMainMenuDrawer(),
      blocSecondaryMenuDrawer: BlocSecondaryMenuDrawer(),
      blocResponsive: BlocResponsive(),
      blocOnboarding: onboardingBloc,
      pageManager: pm,
    );
  }

  // Core blocs (frozen)
  final BlocTheme blocTheme; // archetype BlocTheme (ThemeUsecases-based)
  final BlocUserNotifications blocUserNotifications;
  final BlocLoading blocLoading;
  final BlocMainMenuDrawer blocMainMenuDrawer;
  final BlocSecondaryMenuDrawer blocSecondaryMenuDrawer;
  final BlocResponsive blocResponsive;
  final BlocOnboarding blocOnboarding; // from jocaagura_domain
  final PageManager pageManager; // navigation source of truth

  /// Extendable modules (non-core). Keys must be unique.
  final Map<String, BlocModule> blocModuleList;

  /// Builds the BlocCore with frozen core modules plus extendable extras.
  BlocCore<dynamic> blocCore() {
    return BlocCore<dynamic>(<String, BlocModule>{
      BlocTheme.name: blocTheme, // 'BlocTheme'
      BlocOnboarding.name: blocOnboarding, // 'blocOnboarding'
      BlocResponsive.name: blocResponsive,
      BlocMainMenuDrawer.name: blocMainMenuDrawer,
      BlocSecondaryMenuDrawer.name: blocSecondaryMenuDrawer,
      BlocLoading.name: blocLoading,
      BlocUserNotifications.name: blocUserNotifications,
      PageManager.name: pageManager, // 'pageManager'
      ...blocModuleList,
    });
  }

  FutureOr<void> dispose() {
    blocTheme.dispose();
    blocUserNotifications.dispose();
    blocLoading.dispose();
    blocMainMenuDrawer.dispose();
    blocSecondaryMenuDrawer.dispose();
    blocResponsive.dispose();
    blocOnboarding.dispose();
    pageManager.dispose();

    // Dispose any extra modules
    for (final BlocModule module in blocModuleList.values) {
      module.dispose();
    }
  }

  /// Returns the **first** registered module in [blocModuleList] that matches type [T].
  ///
  /// Intended for **development-time** wiring to ensure configuration integrity.
  /// Throws [UnimplementedError] if no module of type [T] is found.
  ///
  /// ### Example
  /// ```dart
  /// final MyFeatureModule mod = appConfig.requireModuleOfType<MyFeatureModule>();
  /// ```
  T requireModuleOfType<T extends BlocModule>() {
    for (final BlocModule module in blocModuleList.values) {
      if (module is T) {
        return module;
      }
    }
    throw UnimplementedError(
      'No BlocModule of type $T was registered in blocModuleList. '
      'This helper is intended for development-only configuration checks.',
    );
  }

  /// Returns the module registered under [key] and **checks** it matches type [T].
  ///
  /// Lookup is **case-insensitive**. Throws [UnimplementedError] if:
  /// - No module is registered under [key], or
  /// - The registered module does not match the requested type [T].
  ///
  /// This is meant for **development-time** configuration checks and should not
  /// be used as a dynamic service locator in production flows.
  ///
  /// ### Example
  /// ```dart
  /// final CanvasModule canvas =
  ///     appConfig.requireModuleByKey<CanvasModule>('Canvas'); // case-insensitive
  /// ```
  T requireModuleByKey<T extends BlocModule>(String key) {
    final String target = key.toLowerCase();
    for (final MapEntry<String, BlocModule> entry in blocModuleList.entries) {
      if (entry.key.toLowerCase() == target) {
        final BlocModule mod = entry.value;
        if (mod is T) {
          return mod;
        }
        throw UnimplementedError(
          'BlocModule registered under key "$key" is ${mod.runtimeType}, '
          'but $T was requested. Check your development wiring.',
        );
      }
    }
    throw UnimplementedError(
      'No BlocModule was registered under key "$key" in blocModuleList. '
      'This helper is intended for development-only configuration checks.',
    );
  }
}
