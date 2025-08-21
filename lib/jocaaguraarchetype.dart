library jocaaguraarchetype;

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'jocaaguraarchetype_domain.dart';

export 'jocaaguraarchetype_domain.dart';

part 'app_config.dart';
part 'consts/app_constants.dart';
part 'domain/blocs/app_manager.dart';
part 'domain/blocs/bloc_main_menu_drawer.dart';
part 'domain/blocs/bloc_menu_base.dart';
part 'domain/blocs/bloc_secondary_menu_drawer.dart';
part 'domain/blocs/bloc_theme.dart';
part 'domain/blocs/bloc_user_notifications.dart';
part 'domain/gateways/gateway_theme.dart';
part 'domain/models/nav_stack_model.dart';
part 'domain/models/page_model.dart';
part 'domain/models/toast_message.dart';
part 'domain/repositories/repository_theme.dart';
part 'domain/services/service_theme.dart';
part 'domain/states/theme_state.dart';
part 'domain/usecases/theme/theme_usecases.dart';
part 'navigator/custom_page.dart';
part 'src/fake_services/fake_service_jocaagura_archetype_theme.dart';
part 'src/gateways/gateway_theme_impl.dart';
part 'src/repositories/repository_theme_impl.dart';
part 'src/services/service_jocaagura_archetype_theme.dart';
part 'ui/jocaagura_app.dart';
part 'ui/navigation/my_app_router_delegate.dart';
part 'ui/navigation/my_route_information_parser.dart';
part 'ui/navigation/page_def.dart';
part 'ui/navigation/page_manager.dart';
part 'ui/navigation/page_registry.dart';
part 'ui/navigation/session_nav_coordinator.dart';
part 'ui/page_builder.dart';
part 'ui/pages/loading_page.dart';
part 'ui/pages/my_demo_home_page.dart';
part 'ui/pages/onboarding_page.dart';
part 'ui/pages/page_404_widget.dart';
part 'ui/pages/test_page_builder_page.dart';
part 'ui/providers/app_manager_provider.dart';
part 'ui/widgets/column_blueprint_widget.dart';
part 'ui/widgets/columns_blueprint_widget.dart';
part 'ui/widgets/drawer_option_widget.dart';
part 'ui/widgets/forms/custom_autocomplete_input_widget.dart';
part 'ui/widgets/forms/jocaagura_autocomplete_input_widget.dart';
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
part 'utils/theme_color_utils.dart';
part 'utils/theme_data_utils.dart';

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
