library jocaaguraarchetype;

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'jocaaguraarchetype.dart';

export 'jocaaguraarchetype_domain.dart';

part 'app_config.dart';
part 'consts/app_constants.dart';
part 'domain/blocs/app_manager.dart';
part 'domain/blocs/bloc_app_config.dart';
part 'domain/blocs/bloc_main_menu_drawer.dart';
part 'domain/blocs/bloc_menu_base.dart';
part 'domain/blocs/bloc_model_version.dart';
part 'domain/blocs/bloc_secondary_menu_drawer.dart';
part 'domain/blocs/bloc_theme.dart';
part 'domain/blocs/bloc_theme_react.dart';
part 'domain/blocs/bloc_user_notifications.dart';
part 'domain/entities/abstract_app_manager.dart';
part 'domain/gateways/gateway_theme.dart';
part 'domain/gateways/gateway_theme_react.dart';
part 'domain/models/model_data_viz_palette.dart';
part 'domain/models/model_design_system.dart';
part 'domain/models/model_ds_extended_tokens.dart';
part 'domain/models/model_field_state.dart';
part 'domain/models/model_semantic_colors.dart';
part 'domain/models/model_theme_data.dart';
part 'domain/models/nav_stack_model.dart';
part 'domain/models/page_model.dart';
part 'domain/models/session_pages.dart';
part 'domain/models/toast_message.dart';
part 'domain/repositories/repository_theme.dart';
part 'domain/repositories/repository_theme_react.dart';
part 'domain/services/service_theme.dart';
part 'domain/services/service_theme_react.dart';
part 'domain/states/theme_patch.dart';
part 'domain/states/theme_state.dart';
part 'domain/usecases/theme/theme_usecases.dart';
part 'env/app_config_builder.dart';
part 'env/app_mode.dart';
part 'env/deferred_steps.dart';
part 'env/env.dart';
part 'src/fake_services/fake_service_jocaagura_archetype_theme.dart';
part 'src/fake_services/fake_service_theme_react.dart';
part 'src/gateways/gateway_theme_impl.dart';
part 'src/gateways/gateway_theme_react_impl.dart';
part 'src/repositories/repository_theme_impl.dart';
part 'src/repositories/repository_theme_react_impl.dart';
part 'src/services/service_jocaagura_archetype_theme.dart';
part 'ui/builders/expando_model_main_menu_model.dart';
part 'ui/builders/main_drawer.dart';
part 'ui/builders/main_drawer_builder.dart';
part 'ui/builders/page_app_bar.dart';
part 'ui/builders/page_app_bar_builder.dart';
part 'ui/builders/page_builder.dart';
part 'ui/builders/page_loading_boundary.dart';
part 'ui/builders/page_loading_boundary_builder.dart';
part 'ui/builders/page_scaffold_shell.dart';
part 'ui/builders/page_scaffold_shell_builder.dart';
part 'ui/builders/page_with_secondary_menu_builder.dart';
part 'ui/builders/secondary_menu_mobile_layout.dart';
part 'ui/builders/secondary_menu_mobile_layout_builder.dart';
part 'ui/builders/secondary_menu_side_panel_layout.dart';
part 'ui/builders/secondary_menu_side_panel_layout_builder.dart';
part 'ui/builders/secondary_menu_square_button.dart';
part 'ui/jocaagura_app.dart';
part 'ui/jocaagura_app_with_sesion.dart';
part 'ui/navigation/my_app_router_delegate.dart';
part 'ui/navigation/my_route_information_parser.dart';
part 'ui/navigation/page_def.dart';
part 'ui/navigation/page_manager.dart';
part 'ui/navigation/page_registry.dart';
part 'ui/navigation/session_app_manager.dart';
part 'ui/navigation/session_nav_coordinator.dart';
part 'ui/pages/loading_page.dart';
part 'ui/pages/my_demo_home_page.dart';
part 'ui/pages/onboarding_page.dart';
part 'ui/pages/page_404_widget.dart';
part 'ui/pages/test_page_builder_page.dart';
part 'ui/providers/app_manager_provider.dart';
part 'ui/theme/ds_data_viz_palette_extension.dart';
part 'ui/theme/ds_extended_tokens_extension.dart';
part 'ui/theme/ds_semantic_color_extension.dart';
part 'ui/theme/text_theme_overrides.dart';
part 'ui/theme/theme_overrides.dart';
part 'ui/theme/utils_for_theme.dart';
part 'ui/widgets/aspect_layout_router.dart';
part 'ui/widgets/column_blueprint_widget.dart';
part 'ui/widgets/columns_blueprint_widget.dart';
part 'ui/widgets/drawer_option_widget.dart';
part 'ui/widgets/forms/custom_autocomplete_input_widget.dart';
part 'ui/widgets/forms/jocaagura_autocomplete_input_widget.dart';
part 'ui/widgets/gutter_blueprint_widget.dart';
part 'ui/widgets/jocaagura_app_shell.dart';
part 'ui/widgets/jocaagura_app_shell_controller.dart';
part 'ui/widgets/jocaagura_splash_overlay.dart';
part 'ui/widgets/jocaagura_theme_router_app.dart';
part 'ui/widgets/list_tile_exit_drawer_widget.dart';
part 'ui/widgets/main_menu_option_widget.dart';
part 'ui/widgets/main_menu_widget.dart';
part 'ui/widgets/margin_blueprint_widget.dart';
part 'ui/widgets/mobile_secondary_menu_widget.dart';
part 'ui/widgets/mobile_secondary_option_widget.dart';
part 'ui/widgets/my_app_button_widget.dart';
part 'ui/widgets/my_snack_bar_widget.dart';
part 'ui/widgets/page_with_secondary_menu_widget.dart';
part 'ui/widgets/projector_widget.dart';
part 'ui/widgets/responsive_1x1_widget.dart';
part 'ui/widgets/responsive_1x2_widget.dart';
part 'ui/widgets/responsive_1x3_widget.dart';
part 'ui/widgets/responsive_generator_widget.dart';
part 'ui/widgets/responsive_nx_base.dart';
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
