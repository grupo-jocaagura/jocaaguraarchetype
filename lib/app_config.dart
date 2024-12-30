import 'package:jocaagura_domain/jocaagura_domain.dart';

import 'jocaaguraarchetype.dart';

/// A configuration class for managing application-wide BLoC instances.
///
/// The `AppConfig` class serves as a central point for initializing and managing
/// all the required BLoC modules in an application. It facilitates the organization
/// of application state and provides a `BlocCore` for accessing all registered BLoCs.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/app_config.dart';
///
/// void main() {
///   final appConfig = AppConfig(
///     blocTheme: BlocTheme(ProviderTheme(ServiceTheme())),
///     blocUserNotifications: BlocUserNotifications(),
///     blocLoading: BlocLoading(),
///     blocMainMenuDrawer: BlocMainMenuDrawer(),
///     blocSecondaryMenuDrawer: BlocSecondaryMenuDrawer(),
///     blocResponsive: BlocResponsive(),
///     blocOnboarding: BlocOnboarding([]),
///     blocNavigator: BlocNavigator(PageManager()),
///   );
///
///   final blocCore = appConfig.blocCore();
///   print('Registered BLoCs: ${blocCore.modules.keys}');
/// }
/// ```
class AppConfig {
  /// Creates an instance of `AppConfig`.
  ///
  /// The constructor requires all necessary BLoC instances to be provided, ensuring
  /// that the application's state management is fully configured. Optionally, additional
  /// custom BLoC modules can be included via [blocModuleList].
  const AppConfig({
    required this.blocTheme,
    required this.blocUserNotifications,
    required this.blocLoading,
    required this.blocMainMenuDrawer,
    required this.blocSecondaryMenuDrawer,
    required this.blocResponsive,
    required this.blocOnboarding,
    required this.blocNavigator,
    this.blocModuleList = const <String, BlocModule>{},
  });

  /// The BLoC responsible for managing the application's theme.
  final BlocTheme blocTheme;

  /// The BLoC responsible for managing user notifications.
  final BlocUserNotifications blocUserNotifications;

  /// The BLoC responsible for managing loading states.
  final BlocLoading blocLoading;

  /// The BLoC responsible for managing the main menu drawer.
  final BlocMainMenuDrawer blocMainMenuDrawer;

  /// The BLoC responsible for managing the secondary menu drawer.
  final BlocSecondaryMenuDrawer blocSecondaryMenuDrawer;

  /// The BLoC responsible for managing responsive layouts.
  final BlocResponsive blocResponsive;

  /// The BLoC responsible for managing the onboarding process.
  final BlocOnboarding blocOnboarding;

  /// The BLoC responsible for managing navigation.
  final BlocNavigator blocNavigator;

  /// A map of additional custom BLoC modules to include in the configuration.
  ///
  /// The key represents the module name, and the value is the corresponding BLoC instance.
  final Map<String, BlocModule> blocModuleList;

  /// Combines all registered BLoC modules into a `BlocCore` instance.
  ///
  /// This method returns a `BlocCore` containing all required and custom BLoC modules.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final blocCore = appConfig.blocCore();
  /// print('Registered BLoCs: ${blocCore.modules.keys}');
  /// ```
  BlocCore<dynamic> blocCore() {
    return BlocCore<dynamic>(<String, BlocModule>{
      BlocTheme.name: blocTheme,
      BlocNavigator.name: blocNavigator,
      BlocOnboarding.name: blocOnboarding,
      BlocResponsive.name: blocResponsive,
      BlocMainMenuDrawer.name: blocMainMenuDrawer,
      BlocSecondaryMenuDrawer.name: blocSecondaryMenuDrawer,
      BlocLoading.name: blocLoading,
      BlocUserNotifications.name: blocUserNotifications,
      ...blocModuleList,
    });
  }
}
