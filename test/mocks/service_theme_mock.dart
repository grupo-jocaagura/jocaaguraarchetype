import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 author: @albertjjimenezp
class ServiceThemeMock extends ServiceTheme {
  @override
  MaterialColor materialColorFromRGB(int r, int g, int b) {
    // Implementa la lógica de prueba para materialColorFromRGB
    // según el escenario que desees probar
    // y devuelve un MaterialColor simulado
    return Colors.red;
  }

  @override
  Color getDarker(Color color, {double amount = .1}) {
    // Implementa la lógica de prueba para getDarker
    // según el escenario que desees probar
    // y devuelve un Color simulado
    return Colors.blue;
  }

  @override
  Color getLighter(Color color, {double amount = .1}) {
    // Implementa la lógica de prueba para getLighter
    // según el escenario que desees probar
    // y devuelve un Color simulado
    return Colors.green;
  }

  @override
  ThemeData customThemeFromColorScheme(
    ColorScheme colorScheme,
    TextTheme textTheme, [
    bool isDark = false,
  ]) {
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
  }

  @override
  Color colorRandom() {
    // Implementa la lógica de prueba para colorRandom
    // según el escenario que desees probar
    // y devuelve un Color simulado
    return Colors.purple;
  }
}
