import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../providers/provider_theme.dart';

class BlocTheme extends BlocModule {
  BlocTheme(this.providerTheme);
  static const String name = 'blocTheme';

  final ProviderTheme providerTheme;
  final BlocGeneral<ThemeData> _themeDataController =
      BlocGeneral<ThemeData>(ThemeData());

  ThemeData get themeData => _themeDataController.value;

  Stream<ThemeData> get themeDataStream => _themeDataController.stream;

  @override
  void dispose() {
    _themeDataController.dispose();
  }

  void customThemeFromColorScheme(
    ColorScheme colorScheme,
    TextTheme textTheme, [
    bool isDark = false,
  ]) {
    _themeDataController.value = providerTheme.customThemeFromColorScheme(
      colorScheme,
      textTheme,
      isDark,
    );
  }

  void customThemeFromColor(Color primaryColor) {
    _themeDataController.value =
        providerTheme.serviceTheme.customThemeFromColorScheme(
      ColorScheme.fromSeed(seedColor: primaryColor),
      themeData.textTheme,
    );
  }

  void randomTheme() {
    customThemeFromColor(providerTheme.colorRandom());
  }
}
