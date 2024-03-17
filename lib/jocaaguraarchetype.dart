export 'package:jocaagura_domain/jocaagura_domain.dart';

export 'app_config.dart';
export 'blocs/app_manager.dart';
export 'blocs/bloc_loading.dart';
export 'blocs/bloc_main_menu.dart';
export 'blocs/bloc_navigator.dart';
export 'blocs/bloc_onboarding.dart';
export 'blocs/bloc_responsive.dart';
export 'blocs/bloc_secondary_menu.dart';
export 'blocs/bloc_theme.dart';
export 'blocs/bloc_user_notifications.dart';
export 'navigator/page_manager.dart';
export 'providers/app_manager_provider.dart';
export 'providers/provider_theme.dart';
export 'services/service_theme.dart';
export 'ui/jocaagura_app.dart';
export 'ui/pages/my_demo_home_page.dart';
export 'ui/pages/onboarding_page.dart';
export 'ui/pages/test_page_builder_page.dart';
export 'ui/widgets/forms/custom_autocomplete_input_widget.dart';
export 'ui/widgets/responsive_generator_widget.dart';

const double kAppBarHeight = 60.0;

class JocaaguraArchetype {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;

  Future<void> testMe() async {
    await Future<void>.delayed(
      const Duration(seconds: 2),
    );
  }
}
