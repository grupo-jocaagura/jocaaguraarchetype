import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

final JocaaguraArchetype jocaaguraArchetype = JocaaguraArchetype();

/// Zona de configuración inicial
final BlocTheme blocTheme = BlocTheme(
  const ProviderTheme(
    ServiceTheme(),
  ),
);
final BlocUserNotifications blocUserNotifications = BlocUserNotifications();
final BlocLoading blocLoading = BlocLoading();
final BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
final BlocSecondaryMenuDrawer blocSecondaryMenuDrawer =
    BlocSecondaryMenuDrawer();
final BlocResponsive blocResponsive = BlocResponsive();
final BlocOnboarding blocOnboarding = BlocOnboarding();
final BlocNavigator blocNavigator = BlocNavigator(
  PageManager(),
  OnBoardingPage(
    blocOnboarding: blocOnboarding,
  ),
);

class TestPageForJocaaguraAppTest extends StatelessWidget {
  const TestPageForJocaaguraAppTest({
    super.key,
  });

  static const ValueKey<String> valueKey = ValueKey<String>('testThemeKey');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          key: TestPageForJocaaguraAppTest.valueKey,
          onPressed: () => AppManagerProvider.of(context).theme.randomTheme(),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}

void main() {
  group('JocaaguraApp Widget Tests', () {
    testWidgets('JocaaguraApp initializes theme subscription in initState',
        (WidgetTester tester) async {
      final AppManager appManager = AppManager(
        AppConfig(
          blocTheme: blocTheme,
          blocUserNotifications: blocUserNotifications,
          blocLoading: blocLoading,
          blocMainMenuDrawer: blocMainMenuDrawer,
          blocSecondaryMenuDrawer: blocSecondaryMenuDrawer,
          blocResponsive: blocResponsive,
          blocOnboarding: blocOnboarding,
          blocNavigator: blocNavigator,
        ),
      );
      await tester.pumpWidget(JocaaguraApp(appManager: appManager));
      await tester.pumpAndSettle();
      final int testThemeValue =
          LabColor.colorValueFromColor(appManager.theme.themeData.primaryColor);
      appManager.theme.randomTheme();
      final int testThemeValueResult =
          LabColor.colorValueFromColor(appManager.theme.themeData.primaryColor);
      expect(testThemeValue != testThemeValueResult, true);
    });

    testWidgets('JocaaguraApp disposes theme subscription on dispose',
        (WidgetTester tester) async {
      // Similar al test anterior, pero enfocado en verificar que la suscripción se cancela.
      // Esto puede requerir un mock más sofisticado o una inspección del estado después de dispose.
    });
  });
}
