part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Default design system for examples, tests and gallery fallback.
///
/// This instance should be deterministic and safe for local previews.
ModelDesignSystem defaultModelDesignSystem() {
  return ModelDesignSystem(
    theme: ModelThemeData(
      lightScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
      ),
      darkScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.dark,
      ),
      lightTextTheme: Typography.material2021().black,
      darkTextTheme: Typography.material2021().white,
      useMaterial3: true,
    ),
    tokens: const ModelDsExtendedTokens(),
    semanticLight: ModelSemanticColors.fallbackLight(),
    semanticDark: ModelSemanticColors.fallbackDark(),
    dataViz: ModelDataVizPalette.fallback(),
  );
}
