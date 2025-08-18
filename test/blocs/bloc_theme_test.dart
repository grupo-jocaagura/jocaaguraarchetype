import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../mocks/provider_theme_mock.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  late BlocTheme blocTheme;
  late ProviderThemeMock providerThemeMock;
  // Prepara el entorno antes de cada prueba.
  setUp(() {
    providerThemeMock = ProviderThemeMock();
    blocTheme = BlocTheme(providerThemeMock);
  });

  tearDown(() {
    blocTheme.dispose();
  });
  test('Test BlocTheme', () {
    // Prueba que el getter themeData devuelve el último valor del Stream
    final ThemeData themeData1 =
        ThemeData.from(colorScheme: const ColorScheme.light());
    final ThemeData themeData2 =
        ThemeData.dark().copyWith(brightness: Brightness.dark);
    final ThemeData themeData3 = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );
    blocTheme.customThemeFromColorScheme(
      const ColorScheme.light(),
      const TextTheme(),
    );
    expect(blocTheme.themeData.primaryColor, equals(themeData1.primaryColor));

    blocTheme.customThemeFromColorScheme(
      const ColorScheme.dark(),
      const TextTheme(),
      true,
    );
    expect(
      LabColor.colorValueFromColor(themeData2.primaryColor) !=
          LabColor.colorValueFromColor(blocTheme.themeData.primaryColor),
      true,
    );
    blocTheme.customThemeFromColor(themeData3.primaryColor);
    expect(
      LabColor.colorValueFromColor(blocTheme.themeData.primaryColor),
      equals(LabColor.colorValueFromColor(themeData3.primaryColor)),
    );

    // Prueba que el getter themeDataStream devuelve el Stream de ThemeData
    final Stream<ThemeData> themeDataStream = blocTheme.themeDataStream;
    expect(themeDataStream, isA<Stream<ThemeData>>());

    // Prueba customThemeFromColorScheme
    const ColorScheme colorScheme = ColorScheme.light();
    const TextTheme textTheme = TextTheme();
    blocTheme.customThemeFromColorScheme(colorScheme, textTheme);
    expect(
      blocTheme.themeData,
      equals(
        providerThemeMock.customThemeFromColorScheme(
          colorScheme,
          textTheme,
        ),
      ),
    );

    // Prueba customThemeFromColor
    const MaterialColor color = Colors.red;
    blocTheme.customThemeFromColor(color);
    final ThemeData tmp = blocTheme.themeData
        .copyWith(colorScheme: ColorScheme.fromSeed(seedColor: color));
    expect(
      LabColor.colorValueFromColor(blocTheme.themeData.primaryColor),
      equals(
        LabColor.colorValueFromColor(tmp.primaryColor),
      ),
    );

    // Prueba randomTheme
    blocTheme.randomTheme();
    expect(blocTheme.themeData, isNotNull);

    // Prueba dispose
    blocTheme.dispose();
    // Asegúrate de comprobar que el Stream se cierra y se libera correctamente
    expect(themeDataStream.isBroadcast, isFalse);
  });
}
