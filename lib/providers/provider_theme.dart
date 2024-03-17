import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../services/service_theme.dart';

class ProviderTheme extends EntityProvider {
  const ProviderTheme(this.serviceTheme);

  final ServiceTheme serviceTheme;
  MaterialColor materialColorFromRGB(int r, int g, int b) {
    return serviceTheme.materialColorFromRGB(r, g, b);
  }

  Color getDarker(Color color, {double amount = .1}) {
    return serviceTheme.getDarker(color, amount: amount);
  }

  Color getLighter(Color color, {double amount = .1}) {
    return serviceTheme.getLighter(color, amount: amount);
  }

  ThemeData customThemeFromColorScheme(
    ColorScheme colorScheme,
    TextTheme textTheme, [
    bool isDark = false,
  ]) {
    return serviceTheme.customThemeFromColorScheme(
      colorScheme,
      textTheme,
      isDark,
    );
  }

  Color colorRandom() {
    return serviceTheme.colorRandom();
  }
}
