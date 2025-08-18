library jocaaguraarchetype;

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

export 'jocaaguraarchetype_domain.dart';

part 'app_config.dart';
part 'consts/app_constants.dart';
part 'domain/blocs/app_manager.dart';
part 'domain/blocs/bloc_main_menu_drawer.dart';
part 'domain/blocs/bloc_navigator.dart';
part 'domain/blocs/bloc_secondary_menu_drawer.dart';
part 'domain/blocs/bloc_theme.dart';
part 'domain/blocs/bloc_user_notifications.dart';
part 'navigator/custom_page.dart';
part 'navigator/my_app_route_delegate.dart';
part 'navigator/page_manager.dart';
part 'navigator/route_information_parser.dart';
part 'providers/app_manager_provider.dart';
part 'providers/provider_theme.dart';
part 'services/service_theme.dart';
part 'ui/jocaagura_app.dart';
part 'ui/page_builder.dart';
part 'ui/pages/loading_page.dart';
part 'ui/pages/my_demo_home_page.dart';
part 'ui/pages/onboarding_page.dart';
part 'ui/pages/page_404_widget.dart';
part 'ui/pages/test_page_builder_page.dart';
part 'ui/widgets/column_blueprint_widget.dart';
part 'ui/widgets/columns_blueprint_widget.dart';
part 'ui/widgets/drawer_option_widget.dart';
part 'ui/widgets/forms/custom_autocomplete_input_widget.dart';
part 'ui/widgets/gutter_blueprint_widget.dart';
part 'ui/widgets/list_tile_exit_drawer_widget.dart';
part 'ui/widgets/main_menu_option_widget.dart';
part 'ui/widgets/main_menu_widget.dart';
part 'ui/widgets/margin_blueprint_widget.dart';
part 'ui/widgets/mobile_secondary_menu_widget.dart';
part 'ui/widgets/mobile_secondary_option_widget.dart';
part 'ui/widgets/my_app_button_widget.dart';
part 'ui/widgets/my_snack_bar_widget.dart';
part 'ui/widgets/page_with_secondary_menu_widget.dart';
part 'ui/widgets/responsive_1x1_widget.dart';
part 'ui/widgets/responsive_1x2_widget.dart';
part 'ui/widgets/responsive_1x3_widget.dart';
part 'ui/widgets/responsive_generator_widget.dart';
part 'ui/widgets/responsive_size_widget.dart';
part 'ui/widgets/secondary_option_widget.dart';
part 'ui/widgets/work_area_widget.dart';
part 'utils/lab_color.dart';

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
