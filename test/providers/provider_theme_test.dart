import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/providers/provider_theme.dart';

import '../mocks/service_theme_mock.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  test('Test ProviderTheme', () {
    // Crea una instancia de ServiceThemeMock para utilizarla en ProviderTheme
    final ServiceThemeMock serviceThemeMock = ServiceThemeMock();

    // Crea una instancia de ProviderTheme utilizando el ServiceThemeMock
    final ProviderTheme providerTheme = ProviderTheme(serviceThemeMock);

    // Realiza las pruebas para cada método en ProviderTheme
    // Asegúrate de cubrir todos los escenarios posibles

    // Prueba materialColorFromRGB
    final MaterialColor materialColor =
        providerTheme.materialColorFromRGB(255, 0, 0);
    expect(materialColor, equals(Colors.red));

    // Prueba getDarker
    final Color darkerColor = providerTheme.getDarker(Colors.blue);
    expect(darkerColor, equals(Colors.blue));

    // Prueba getLighter
    final Color lighterColor = providerTheme.getLighter(Colors.green);
    expect(lighterColor, equals(Colors.green));

    // Prueba customThemeFromColorScheme
    final ThemeData themeData = providerTheme.customThemeFromColorScheme(
      const ColorScheme.light(),
      const TextTheme(),
    );
    expect(
      themeData.primaryColor,
      equals(ThemeData(colorScheme: const ColorScheme.light()).primaryColor),
    );

    // Prueba colorRandom
    final Color randomColor = providerTheme.colorRandom();
    expect(randomColor, equals(Colors.purple));
  });
}
