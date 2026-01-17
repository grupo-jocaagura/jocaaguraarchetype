part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// JSON keys for [ModelDesignSystem].
///
/// Notes:
/// - Keys are intentionally stable to support export/import.
/// - The JSON payload is strict: each entry is expected to be a map.
abstract final class ModelDesignSystemKeys {
  static const String theme = 'theme';
  static const String tokens = 'tokens';
  static const String semanticLight = 'semanticLight';
  static const String semanticDark = 'semanticDark';
  static const String dataViz = 'dataViz';
}

/// Represents a serializable Design System and provides a single entry-point
/// to build a complete [ThemeData].
///
/// This model combines:
/// - [theme]: base theming (ColorScheme/TextTheme/useMaterial3, JSON-safe)
/// - [tokens]: extra scales (spacing/radius/elevation/opacity/durations, JSON-safe)
///
/// The final [ThemeData] is built in a deterministic way:
/// 1) Builds a base ThemeData from [theme] for the given [Brightness].
/// 2) Attaches [tokens] as a [ThemeExtension] (see [DsExtendedTokensExtension]).
/// 3) Applies component-level themes in one place.
///
/// Functional example:
/// ```dart
/// import 'package:flutter/material.dart';
///
/// void main() {
///   final ModelDesignSystem ds = ModelDesignSystem(
///     theme: ModelThemeData(/* ... */),
///     tokens: const ModelDsExtendedTokens(),
///   );
///
///   final ThemeData light = ds.toThemeData(brightness: Brightness.light);
///   runApp(MaterialApp(theme: light, home: const SizedBox()));
/// }
/// ```
///
/// Throws:
/// - [FormatException] from [fromJson] when the payload shape is invalid.
/// - Any exception thrown by [ModelThemeData.fromJson] or [ModelDsExtendedTokens.fromJson].
@immutable
class ModelDesignSystem {
  const ModelDesignSystem({
    required this.theme,
    required this.tokens,
    required this.semanticLight,
    required this.semanticDark,
    required this.dataViz,
  });

  /// Builds an instance from a strict JSON map.
  ///
  /// The `theme` and `tokens` entries must be maps, otherwise a [FormatException]
  /// is thrown.
  factory ModelDesignSystem.fromJson(Map<String, dynamic> json) {
    final Object? themeRaw = json[ModelDesignSystemKeys.theme];
    final Object? tokensRaw = json[ModelDesignSystemKeys.tokens];

    if (themeRaw is! Map<String, dynamic>) {
      throw const FormatException(
        'Expected map for ${ModelDesignSystemKeys.theme}',
      );
    }
    if (tokensRaw is! Map<String, dynamic>) {
      throw const FormatException(
        'Expected map for ${ModelDesignSystemKeys.tokens}',
      );
    }

    final Object? semanticLightRaw = json[ModelDesignSystemKeys.semanticLight];
    final Object? semanticDarkRaw = json[ModelDesignSystemKeys.semanticDark];
    final Object? dataVizRaw = json[ModelDesignSystemKeys.dataViz];

    // ✅ Retrocompatible: si faltan, usamos fallbacks
    final ModelSemanticColors semanticLight =
        (semanticLightRaw is Map<String, dynamic>)
            ? ModelSemanticColors.fromJson(semanticLightRaw)
            : ModelSemanticColors.fallbackLight();

    final ModelSemanticColors semanticDark =
        (semanticDarkRaw is Map<String, dynamic>)
            ? ModelSemanticColors.fromJson(semanticDarkRaw)
            : ModelSemanticColors.fallbackDark();

    final ModelDataVizPalette dataViz = (dataVizRaw is Map<String, dynamic>)
        ? ModelDataVizPalette.fromJson(dataVizRaw)
        : ModelDataVizPalette.fallback();

    return ModelDesignSystem(
      theme: ModelThemeData.fromJson(themeRaw),
      tokens: ModelDsExtendedTokens.fromJson(tokensRaw),
      semanticLight: semanticLight,
      semanticDark: semanticDark,
      dataViz: dataViz,
    );
  }

  /// Base: ColorScheme + TextTheme + useMaterial3 (JSON-safe).
  final ModelThemeData theme;

  /// Extra tokens: spacing/radius/elevation/durations, etc (JSON-safe).
  final ModelDsExtendedTokens tokens;

  /// Domain semantic colors (success/warning/info) for light surfaces.
  final ModelSemanticColors semanticLight;

  /// Domain semantic colors (success/warning/info) for dark surfaces.
  final ModelSemanticColors semanticDark;

  /// Data visualization palette (categorical + sequential).
  final ModelDataVizPalette dataViz;

  /// Returns a new instance with the provided overrides.
  ///
  /// Optimization: if no values are provided, returns `this`.
  ModelDesignSystem copyWith({
    ModelThemeData? theme,
    ModelDsExtendedTokens? tokens,
    ModelSemanticColors? semanticLight,
    ModelSemanticColors? semanticDark,
    ModelDataVizPalette? dataViz,
  }) {
    if (theme == null &&
        tokens == null &&
        semanticLight == null &&
        semanticDark == null &&
        dataViz == null) {
      return this;
    }

    return ModelDesignSystem(
      theme: theme ?? this.theme,
      tokens: tokens ?? this.tokens,
      semanticLight: semanticLight ?? this.semanticLight,
      semanticDark: semanticDark ?? this.semanticDark,
      dataViz: dataViz ?? this.dataViz,
    );
  }

  /// Serializes this instance into a JSON map compatible with [fromJson].
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelDesignSystemKeys.theme: theme.toJson(),
        ModelDesignSystemKeys.tokens: tokens.toJson(),
        ModelDesignSystemKeys.semanticLight: semanticLight.toJson(),
        ModelDesignSystemKeys.semanticDark: semanticDark.toJson(),
        ModelDesignSystemKeys.dataViz: dataViz.toJson(),
      };

  /// Builds a complete [ThemeData] for the given [brightness].
  ///
  /// This method:
  /// 1) Builds the base ThemeData using [ModelThemeData.toThemeData].
  /// 2) Attaches [tokens] as a [ThemeExtension].
  /// 3) Applies component themes (buttons, inputs, cards, dialogs, snackbars, etc).
  ///
  /// Notes:
  /// - The extensions list is currently set explicitly; if the base theme contains
  ///   other extensions, they may be replaced.
  ThemeData toThemeData({
    required Brightness brightness,
  }) {
    final ThemeData base = theme.toThemeData(brightness: brightness);

    final ModelSemanticColors semantic =
        (brightness == Brightness.dark) ? semanticDark : semanticLight;

    final ThemeData withExtensions = base.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        DsExtendedTokensExtension(tokens: tokens),
        DsSemanticColorsExtension(semantic: semantic),
        DsDataVizPaletteExtension(palette: dataViz),
      ],
    );

    return _applyComponentThemes(withExtensions, brightness: brightness);
  }

  ThemeData _applyComponentThemes(
    ThemeData t, {
    required Brightness brightness,
  }) {
    final ColorScheme cs = t.colorScheme;

    final BorderRadius radiusSm = BorderRadius.circular(tokens.borderRadiusSm);
    final BorderRadius radius = BorderRadius.circular(tokens.borderRadius);
    final BorderRadius radiusLg = BorderRadius.circular(tokens.borderRadiusLg);

    final double disabledAlpha = tokens.withAlphaSm; // 0..1

    final ButtonStyle elevatedBase = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: radius),
      minimumSize: Size(tokens.spacingXXl, tokens.spacingXl),
    );

    final ButtonStyle filledBase = FilledButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: radius),
      minimumSize: Size(tokens.spacingXXl, tokens.spacingXl),
    );

    final ButtonStyle outlinedBase = OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: radius),
      minimumSize: Size(tokens.spacingXXl, tokens.spacingXl),
    );

    final ButtonStyle textBase = TextButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: radiusSm),
      minimumSize: Size(tokens.spacingXXl, tokens.spacingXl),
    );

    return t.copyWith(
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: elevatedBase.copyWith(
          animationDuration:
              tokens.animationDuration, // ✅ Duration, no StateProperty
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: filledBase.copyWith(
          animationDuration: tokens.animationDuration, // ✅ Duration
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedBase),
      textButtonTheme: TextButtonThemeData(style: textBase),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacing,
          vertical: tokens.spacingSm,
        ),
      ),

      // Cards (✅ CardThemeData en tu SDK)
      cardTheme: CardThemeData(
        elevation: tokens.elevation,
        shape: RoundedRectangleBorder(borderRadius: radiusLg),
        clipBehavior: Clip.antiAlias,
        color: cs.surfaceContainerLow,
      ),

      // Dialogs (✅ DialogThemeData en tu SDK)
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: radiusLg),
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        thickness: 1,
        space: tokens.spacingLg,
        color: cs.outlineVariant,
      ),

      // ListTiles
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: radius),
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
      ),

      // Disabled color (✅ no withOpacity)
      disabledColor: cs.onSurface.withValues(alpha: disabledAlpha),

      // Snackbars
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radius),
        backgroundColor: cs.inverseSurface,
        contentTextStyle: t.textTheme.bodyMedium?.copyWith(
          color: cs.onInverseSurface,
        ),
      ),

      // Tooltips (✅ no withOpacity)
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cs.inverseSurface,
          borderRadius: radiusSm,
        ),
        textStyle: t.textTheme.bodySmall?.copyWith(
          color: cs.onInverseSurface,
        ),
        waitDuration: tokens.animationDurationShort,
        showDuration: tokens.animationDurationLong,
      ),
    );
  }

  /// Creates a [ModelThemeData] from existing [ThemeData] references.
  ///
  /// This is intended for scenarios like:
  /// - Importing a theme from an external builder and then persisting it as JSON
  ///   using [ModelThemeData.toJson].
  /// - Capturing a runtime theme (light/dark) and converting it into the
  ///   Jocaagura-friendly model.
  ///
  /// Notes:
  /// - This method requires both light and dark [ThemeData] to preserve the full
  ///   round-trip capabilities of [ModelThemeData] (schemes + text themes).
  /// - It will fallback safely to `ThemeData.light()/dark()` defaults if a field
  ///   is missing.
  ///
  /// ```dart
  /// final ThemeData light = ThemeData(
  ///   useMaterial3: true,
  ///   colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  /// );
  /// final ThemeData dark = ThemeData(
  ///   useMaterial3: true,
  ///   colorScheme: ColorScheme.fromSeed(
  ///     seedColor: Colors.teal,
  ///     brightness: Brightness.dark,
  ///   ),
  /// );
  ///
  /// final ModelThemeData model = ModelThemeData.fromThemeData(
  ///   lightTheme: light,
  ///   darkTheme: dark,
  /// );
  ///
  /// final Map<String, dynamic> json = model.toJson();
  /// final ModelThemeData roundTrip = ModelThemeData.fromJson(json);
  /// assert(model == roundTrip);
  /// ```
  static ModelThemeData fromThemeData({
    required ThemeData lightTheme,
    required ThemeData darkTheme,
  }) {
    final ThemeData fallbackLight = ThemeData.light(useMaterial3: true);
    final ThemeData fallbackDark = ThemeData.dark(useMaterial3: true);

    final bool useMaterial3 = lightTheme.useMaterial3;

    final ColorScheme lightScheme = lightTheme.colorScheme;
    final ColorScheme darkScheme = darkTheme.colorScheme;

    final TextTheme lightTextTheme = lightTheme.textTheme;
    final TextTheme darkTextTheme = darkTheme.textTheme;

    // Defensive: ensure TextThemes are not "empty-ish" (very rare but can happen
    // if someone passes ThemeData(textTheme: const TextTheme()).
    TextTheme safeTextTheme(TextTheme candidate, TextTheme fallback) {
      final TextStyle? probe =
          candidate.bodyMedium ?? candidate.bodyLarge ?? candidate.titleMedium;
      if (probe == null) {
        return fallback;
      }
      return candidate;
    }

    return ModelThemeData(
      useMaterial3: useMaterial3,
      lightScheme: lightScheme,
      darkScheme: darkScheme,
      lightTextTheme: safeTextTheme(lightTextTheme, fallbackLight.textTheme),
      darkTextTheme: safeTextTheme(darkTextTheme, fallbackDark.textTheme),
    );
  }
}
