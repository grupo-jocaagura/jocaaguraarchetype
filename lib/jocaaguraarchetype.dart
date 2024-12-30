export 'app_config.dart';
export 'blocs/app_manager.dart';
export 'blocs/bloc_connectivity.dart';
export 'blocs/bloc_loading.dart';
export 'blocs/bloc_main_menu_drawer.dart';
export 'blocs/bloc_navigator.dart';
export 'blocs/bloc_onboarding.dart';
export 'blocs/bloc_responsive.dart';
export 'blocs/bloc_secondary_menu_drawer.dart';
export 'blocs/bloc_session.dart';
export 'blocs/bloc_theme.dart';
export 'blocs/bloc_user_notifications.dart';
export 'consts/app_constants.dart';
export 'fake_providers/fake_connectivity_provider.dart';
export 'fake_providers/fake_internet_provider.dart';
export 'fake_providers/fake_session_provider.dart';
export 'navigator/page_manager.dart';
export 'providers/app_manager_provider.dart';
export 'providers/provider_session.dart';
export 'providers/provider_theme.dart';
export 'services/service_session.dart';
export 'services/service_theme.dart';
export 'ui/jocaagura_app.dart';
export 'ui/pages/my_demo_home_page.dart';
export 'ui/pages/onboarding_page.dart';
export 'ui/pages/test_page_builder_page.dart';
export 'ui/widgets/forms/custom_autocomplete_input_widget.dart';
export 'ui/widgets/main_menu_option_widget.dart';
export 'ui/widgets/main_menu_widget.dart';
export 'ui/widgets/page_with_secondary_menu_widget.dart';
export 'ui/widgets/responsive_1x1_widget.dart';
export 'ui/widgets/responsive_1x2_widget.dart';
export 'ui/widgets/responsive_1x3_widget.dart';
export 'ui/widgets/responsive_generator_widget.dart';
export 'ui/widgets/responsive_size_widget.dart';

/// A foundational class for the Jocaagura Archetype package.
///
/// The `JocaaguraArchetype` class provides utility methods and serves as an
/// entry point to various functionalities of the package. This includes
/// mathematical operations and asynchronous tasks.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
///
/// void main() {
///   final archetype = JocaaguraArchetype();
///
///   // Using the addOne method
///   final result = archetype.addOne(5);
///   print('Result: $result'); // Output: Result: 6
///
///   // Using the testMe method
///   archetype.testMe().then((_) {
///     print('Test completed!');
///   });
/// }
/// ```
class JocaaguraArchetype {
  /// Adds 1 to the provided [value] and returns the result.
  ///
  /// This method is a simple utility function that increments the given integer.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final archetype = JocaaguraArchetype();
  /// final result = archetype.addOne(3);
  /// print('Result: $result'); // Output: Result: 4
  /// ```
  int addOne(int value) => value + 1;

  /// Simulates an asynchronous task by delaying execution for 2 seconds.
  ///
  /// This method demonstrates an example of asynchronous operation using `Future`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final archetype = JocaaguraArchetype();
  /// archetype.testMe().then((_) {
  ///   print('Async task completed!');
  /// });
  /// ```
  Future<void> testMe() async {
    await Future<void>.delayed(
      const Duration(seconds: 2),
    );
  }
}
