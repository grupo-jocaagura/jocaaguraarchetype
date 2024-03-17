import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'mocks/mock_blocs.dart';
import 'mocks/pagemanager_mock.dart';
import 'mocks/provider_theme_mock.dart';

void main() {
  group('AppConfig', () {
    test('should initialize all BLoCs correctly', () {
      final AppConfig appConfig = AppConfig(
        blocTheme: MockBlocTheme(ProviderThemeMock()),
        blocUserNotifications: MockBlocUserNotifications(),
        blocLoading: MockBlocLoading(),
        blocMainMenuDrawer: MockBlocMainMenuDrawer(),
        blocSecondaryMenuDrawer: MockBlocSecondaryMenuDrawer(),
        blocResponsive: MockBlocResponsive(),
        blocOnboarding: MockBlocOnboarding(<FutureOr<void> Function()>[]),
        blocNavigator: MockBlocNavigator(MockPageManager()),
      );

      final BlocCore<dynamic> blocCore = appConfig.blocCore();

      expect(
        blocCore.getBlocModule<MockBlocTheme>(MockBlocTheme.name),
        isA<MockBlocTheme>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocUserNotifications.name),
        isA<MockBlocUserNotifications>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocLoading.name),
        isA<MockBlocLoading>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocMainMenuDrawer.name),
        isA<MockBlocMainMenuDrawer>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocSecondaryMenuDrawer.name),
        isA<MockBlocSecondaryMenuDrawer>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocResponsive.name),
        isA<MockBlocResponsive>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocOnboarding.name),
        isA<MockBlocOnboarding>(),
      );
      expect(
        blocCore.getBlocModule(MockBlocNavigator.name),
        isA<MockBlocNavigator>(),
      );
    });
  });
}
