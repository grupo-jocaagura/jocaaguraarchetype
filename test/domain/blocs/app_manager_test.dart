import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../mocks/mock_blocs.dart';

void main() {
  group('AppManager', () {
    late AppConfig appConfig;
    late AppManager appManager;

    setUp(() {
      appConfig = AppConfig(
        blocTheme: MockBlocTheme(
          themeUsecases: ThemeUsecases.fromRepo(
            RepositoryThemeImpl(
              gateway: GatewayThemeImpl(
                themeService: const ServiceJocaaguraArchetypeTheme(),
              ),
            ),
          ),
        ),
        blocUserNotifications: MockBlocUserNotifications(),
        blocLoading: MockBlocLoading(),
        blocMainMenuDrawer: MockBlocMainMenuDrawer(),
        blocSecondaryMenuDrawer: MockBlocSecondaryMenuDrawer(),
        blocResponsive: MockBlocResponsive(),
        blocOnboarding: MockBlocOnboarding(),
        pageManager: MockBlocNavigator(
          initial: NavStackModel(
            const <PageModel>[
              PageModel(name: '/', segments: <String>['home']),
            ],
          ),
        ),
      );
      appManager = AppManager(appConfig);
    });

    test('should provide access to BLoCs', () {
      expect(appManager.theme, isA<MockBlocTheme>());
      expect(
        appManager.notifications,
        isA<MockBlocUserNotifications>(),
      );
      expect(appManager.loading, isA<MockBlocLoading>());
      expect(appManager.mainMenu, isA<MockBlocMainMenuDrawer>());
      expect(appManager.secondaryMenu, isA<MockBlocSecondaryMenuDrawer>());
      expect(appManager.responsive, isA<MockBlocResponsive>());
      expect(appManager.onboarding, isA<MockBlocOnboarding>());
      expect(appManager.pageManager, isA<MockBlocNavigator>());
    });

    test('dispose should properly dispose all BLoCs', () {
      appManager.dispose();
      expect(appManager.notifications.msg, '');
      expect(appManager.mainMenu.isClosed, true);
    });
  });
}
