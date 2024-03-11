import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/app_config.dart';
import 'package:jocaaguraarchetype/blocs/app_manager.dart';

import '../mocks/mock_blocs.dart';
import '../mocks/pagemanager_mock.dart';
import '../mocks/provider_theme_mock.dart';

void main() {
  group('AppManager', () {
    late AppConfig appConfig;
    late AppManager appManager;

    setUp(() {
      appConfig = AppConfig(
        blocTheme: MockBlocTheme(ProviderThemeMock()),
        blocUserNotifications: MockBlocUserNotifications(),
        blocLoading: MockBlocLoading(),
        blocMainMenuDrawer: MockBlocMainMenuDrawer(),
        blocSecondaryMenuDrawer: MockBlocSecondaryMenuDrawer(),
        blocResponsive: MockBlocResponsive(),
        blocOnboarding: MockBlocOnboarding(<Future<void> Function()>[]),
        blocNavigator: MockBlocNavigator(MockPageManager()),
      );
      appManager = AppManager(appConfig);
    });

    test('should provide access to BLoCs', () {
      expect(appManager.theme, isA<MockBlocTheme>());
      expect(
          appManager.blocUserNotifications, isA<MockBlocUserNotifications>());
      expect(appManager.loading, isA<MockBlocLoading>());
      expect(appManager.mainMenu, isA<MockBlocMainMenuDrawer>());
      expect(appManager.secondaryMenu, isA<MockBlocSecondaryMenuDrawer>());
      expect(appManager.responsive, isA<MockBlocResponsive>());
      expect(appManager.onboarding, isA<MockBlocOnboarding>());
      expect(appManager.navigator, isA<MockBlocNavigator>());
    });

    test('dispose should properly dispose all BLoCs', () {
      appManager.dispose();
      expect(appManager.blocUserNotifications.msg, '');
      expect(appManager.mainMenu.isClosed, true);
    });
  });
}
