part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

@immutable
class ModelThemeData {
  const ModelThemeData({
    required this.lightScheme,
    required this.darkScheme,
    required this.lightTextTheme,
    required this.darkTextTheme,
    required this.useMaterial3,
  });

  final ColorScheme lightScheme;
  final ColorScheme darkScheme;

  final TextTheme lightTextTheme;
  final TextTheme darkTextTheme;

  final bool useMaterial3;

  ModelThemeData copyWith({
    ColorScheme? lightScheme,
    ColorScheme? darkScheme,
    TextTheme? lightTextTheme,
    TextTheme? darkTextTheme,
    bool? useMaterial3,
  }) {
    return ModelThemeData(
      lightScheme: lightScheme ?? this.lightScheme,
      darkScheme: darkScheme ?? this.darkScheme,
      lightTextTheme: lightTextTheme ?? this.lightTextTheme,
      darkTextTheme: darkTextTheme ?? this.darkTextTheme,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
    );
  }

  ThemeData toThemeData({required Brightness brightness}) {
    final bool isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: useMaterial3,
      colorScheme: isDark ? darkScheme : lightScheme,
      textTheme: isDark ? darkTextTheme : lightTextTheme,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelThemeDataKeys.useMaterial3: useMaterial3,
        ModelThemeDataKeys.lightScheme: _schemeToMap(lightScheme),
        ModelThemeDataKeys.darkScheme: _schemeToMap(darkScheme),
        ModelThemeDataKeys.lightTextTheme: _textThemeToMap(lightTextTheme),
        ModelThemeDataKeys.darkTextTheme: _textThemeToMap(darkTextTheme),
      };

  static ModelThemeData fromJson(Map<String, dynamic> json) {
    final bool useMaterial3 =
        _expectBool(json, ModelThemeDataKeys.useMaterial3);

    final Map<String, dynamic> lightSchemeMap =
        _expectMap(json, ModelThemeDataKeys.lightScheme);
    final Map<String, dynamic> darkSchemeMap =
        _expectMap(json, ModelThemeDataKeys.darkScheme);

    final Map<String, dynamic> lightTextMap =
        _expectMap(json, ModelThemeDataKeys.lightTextTheme);
    final Map<String, dynamic> darkTextMap =
        _expectMap(json, ModelThemeDataKeys.darkTextTheme);

    return ModelThemeData(
      useMaterial3: useMaterial3,
      lightScheme: _mapToScheme(lightSchemeMap, path: 'lightScheme'),
      darkScheme: _mapToScheme(darkSchemeMap, path: 'darkScheme'),
      lightTextTheme: _mapToTextTheme(lightTextMap, path: 'lightTextTheme'),
      darkTextTheme: _mapToTextTheme(darkTextMap, path: 'darkTextTheme'),
    );
  }

  // ---------------------------------------------------------------------------
  // ColorScheme (Material 3 snapshot)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _schemeToMap(ColorScheme s) => <String, dynamic>{
        ColorSchemeKeys.brightness: s.brightness.name,

        ColorSchemeKeys.primary: UtilsForTheme.colorToHex(s.primary),
        ColorSchemeKeys.onPrimary: UtilsForTheme.colorToHex(s.onPrimary),
        ColorSchemeKeys.primaryContainer:
            UtilsForTheme.colorToHex(s.primaryContainer),
        ColorSchemeKeys.onPrimaryContainer:
            UtilsForTheme.colorToHex(s.onPrimaryContainer),
        ColorSchemeKeys.primaryFixed: UtilsForTheme.colorToHex(s.primaryFixed),
        ColorSchemeKeys.primaryFixedDim:
            UtilsForTheme.colorToHex(s.primaryFixedDim),
        ColorSchemeKeys.onPrimaryFixed:
            UtilsForTheme.colorToHex(s.onPrimaryFixed),
        ColorSchemeKeys.onPrimaryFixedVariant:
            UtilsForTheme.colorToHex(s.onPrimaryFixedVariant),

        ColorSchemeKeys.secondary: UtilsForTheme.colorToHex(s.secondary),
        ColorSchemeKeys.onSecondary: UtilsForTheme.colorToHex(s.onSecondary),
        ColorSchemeKeys.secondaryContainer:
            UtilsForTheme.colorToHex(s.secondaryContainer),
        ColorSchemeKeys.onSecondaryContainer:
            UtilsForTheme.colorToHex(s.onSecondaryContainer),
        ColorSchemeKeys.secondaryFixed:
            UtilsForTheme.colorToHex(s.secondaryFixed),
        ColorSchemeKeys.secondaryFixedDim:
            UtilsForTheme.colorToHex(s.secondaryFixedDim),
        ColorSchemeKeys.onSecondaryFixed:
            UtilsForTheme.colorToHex(s.onSecondaryFixed),
        ColorSchemeKeys.onSecondaryFixedVariant:
            UtilsForTheme.colorToHex(s.onSecondaryFixedVariant),

        ColorSchemeKeys.tertiary: UtilsForTheme.colorToHex(s.tertiary),
        ColorSchemeKeys.onTertiary: UtilsForTheme.colorToHex(s.onTertiary),
        ColorSchemeKeys.tertiaryContainer:
            UtilsForTheme.colorToHex(s.tertiaryContainer),
        ColorSchemeKeys.onTertiaryContainer:
            UtilsForTheme.colorToHex(s.onTertiaryContainer),
        ColorSchemeKeys.tertiaryFixed:
            UtilsForTheme.colorToHex(s.tertiaryFixed),
        ColorSchemeKeys.tertiaryFixedDim:
            UtilsForTheme.colorToHex(s.tertiaryFixedDim),
        ColorSchemeKeys.onTertiaryFixed:
            UtilsForTheme.colorToHex(s.onTertiaryFixed),
        ColorSchemeKeys.onTertiaryFixedVariant:
            UtilsForTheme.colorToHex(s.onTertiaryFixedVariant),

        ColorSchemeKeys.error: UtilsForTheme.colorToHex(s.error),
        ColorSchemeKeys.onError: UtilsForTheme.colorToHex(s.onError),
        ColorSchemeKeys.errorContainer:
            UtilsForTheme.colorToHex(s.errorContainer),
        ColorSchemeKeys.onErrorContainer:
            UtilsForTheme.colorToHex(s.onErrorContainer),

        ColorSchemeKeys.surface: UtilsForTheme.colorToHex(s.surface),
        ColorSchemeKeys.onSurface: UtilsForTheme.colorToHex(s.onSurface),
        ColorSchemeKeys.surfaceDim: UtilsForTheme.colorToHex(s.surfaceDim),
        ColorSchemeKeys.surfaceBright:
            UtilsForTheme.colorToHex(s.surfaceBright),
        ColorSchemeKeys.surfaceContainerLowest:
            UtilsForTheme.colorToHex(s.surfaceContainerLowest),
        ColorSchemeKeys.surfaceContainerLow:
            UtilsForTheme.colorToHex(s.surfaceContainerLow),
        ColorSchemeKeys.surfaceContainer:
            UtilsForTheme.colorToHex(s.surfaceContainer),
        ColorSchemeKeys.surfaceContainerHigh:
            UtilsForTheme.colorToHex(s.surfaceContainerHigh),
        ColorSchemeKeys.surfaceContainerHighest:
            UtilsForTheme.colorToHex(s.surfaceContainerHighest),

        ColorSchemeKeys.onSurfaceVariant:
            UtilsForTheme.colorToHex(s.onSurfaceVariant),

        ColorSchemeKeys.outline: UtilsForTheme.colorToHex(s.outline),
        ColorSchemeKeys.outlineVariant:
            UtilsForTheme.colorToHex(s.outlineVariant),
        ColorSchemeKeys.shadow: UtilsForTheme.colorToHex(s.shadow),
        ColorSchemeKeys.scrim: UtilsForTheme.colorToHex(s.scrim),

        ColorSchemeKeys.inverseSurface:
            UtilsForTheme.colorToHex(s.inverseSurface),
        ColorSchemeKeys.onInverseSurface:
            UtilsForTheme.colorToHex(s.onInverseSurface),
        ColorSchemeKeys.inversePrimary:
            UtilsForTheme.colorToHex(s.inversePrimary),

        ColorSchemeKeys.surfaceTint: UtilsForTheme.colorToHex(s.surfaceTint),

        // Si quieres snapshot 100% API (incluye legacy), descomenta:
        // ColorSchemeKeys.background: UtilsForTheme.colorToHex(s.background),
        // ColorSchemeKeys.onBackground: UtilsForTheme.colorToHex(s.onBackground),
        // ColorSchemeKeys.surfaceVariant: UtilsForTheme.colorToHex(s.surfaceVariant),
      };

  static ColorScheme _mapToScheme(
    Map<String, dynamic> m, {
    required String path,
  }) {
    final String bStr =
        _expectString(m, ColorSchemeKeys.brightness, path: path);
    final Brightness brightness =
        (bStr == 'dark') ? Brightness.dark : Brightness.light;

    Color c(String k) => UtilsForTheme.parseColorCanonical(
          _expectString(m, k, path: path),
          path: '$path.$k',
        );

    return ColorScheme(
      brightness: brightness,

      primary: c(ColorSchemeKeys.primary),
      onPrimary: c(ColorSchemeKeys.onPrimary),
      primaryContainer: c(ColorSchemeKeys.primaryContainer),
      onPrimaryContainer: c(ColorSchemeKeys.onPrimaryContainer),
      primaryFixed: c(ColorSchemeKeys.primaryFixed),
      primaryFixedDim: c(ColorSchemeKeys.primaryFixedDim),
      onPrimaryFixed: c(ColorSchemeKeys.onPrimaryFixed),
      onPrimaryFixedVariant: c(ColorSchemeKeys.onPrimaryFixedVariant),

      secondary: c(ColorSchemeKeys.secondary),
      onSecondary: c(ColorSchemeKeys.onSecondary),
      secondaryContainer: c(ColorSchemeKeys.secondaryContainer),
      onSecondaryContainer: c(ColorSchemeKeys.onSecondaryContainer),
      secondaryFixed: c(ColorSchemeKeys.secondaryFixed),
      secondaryFixedDim: c(ColorSchemeKeys.secondaryFixedDim),
      onSecondaryFixed: c(ColorSchemeKeys.onSecondaryFixed),
      onSecondaryFixedVariant: c(ColorSchemeKeys.onSecondaryFixedVariant),

      tertiary: c(ColorSchemeKeys.tertiary),
      onTertiary: c(ColorSchemeKeys.onTertiary),
      tertiaryContainer: c(ColorSchemeKeys.tertiaryContainer),
      onTertiaryContainer: c(ColorSchemeKeys.onTertiaryContainer),
      tertiaryFixed: c(ColorSchemeKeys.tertiaryFixed),
      tertiaryFixedDim: c(ColorSchemeKeys.tertiaryFixedDim),
      onTertiaryFixed: c(ColorSchemeKeys.onTertiaryFixed),
      onTertiaryFixedVariant: c(ColorSchemeKeys.onTertiaryFixedVariant),

      error: c(ColorSchemeKeys.error),
      onError: c(ColorSchemeKeys.onError),
      errorContainer: c(ColorSchemeKeys.errorContainer),
      onErrorContainer: c(ColorSchemeKeys.onErrorContainer),

      surface: c(ColorSchemeKeys.surface),
      onSurface: c(ColorSchemeKeys.onSurface),
      surfaceDim: c(ColorSchemeKeys.surfaceDim),
      surfaceBright: c(ColorSchemeKeys.surfaceBright),
      surfaceContainerLowest: c(ColorSchemeKeys.surfaceContainerLowest),
      surfaceContainerLow: c(ColorSchemeKeys.surfaceContainerLow),
      surfaceContainer: c(ColorSchemeKeys.surfaceContainer),
      surfaceContainerHigh: c(ColorSchemeKeys.surfaceContainerHigh),
      surfaceContainerHighest: c(ColorSchemeKeys.surfaceContainerHighest),

      onSurfaceVariant: c(ColorSchemeKeys.onSurfaceVariant),

      outline: c(ColorSchemeKeys.outline),
      outlineVariant: c(ColorSchemeKeys.outlineVariant),
      shadow: c(ColorSchemeKeys.shadow),
      scrim: c(ColorSchemeKeys.scrim),

      inverseSurface: c(ColorSchemeKeys.inverseSurface),
      onInverseSurface: c(ColorSchemeKeys.onInverseSurface),
      inversePrimary: c(ColorSchemeKeys.inversePrimary),

      surfaceTint: c(ColorSchemeKeys.surfaceTint),

      // Si incluyes legacy en JSON, también debes incluirlos aquí:
      // background: c(ColorSchemeKeys.background),
      // onBackground: c(ColorSchemeKeys.onBackground),
      // surfaceVariant: c(ColorSchemeKeys.surfaceVariant),
    );
  }

  // ---------------------------------------------------------------------------
  // TextTheme + TextStyle (strict, JSON-safe)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _textThemeToMap(TextTheme t) => <String, dynamic>{
        TextThemeKeys.displayLarge: _textStyleToMapOrNull(t.displayLarge),
        TextThemeKeys.displayMedium: _textStyleToMapOrNull(t.displayMedium),
        TextThemeKeys.displaySmall: _textStyleToMapOrNull(t.displaySmall),
        TextThemeKeys.headlineLarge: _textStyleToMapOrNull(t.headlineLarge),
        TextThemeKeys.headlineMedium: _textStyleToMapOrNull(t.headlineMedium),
        TextThemeKeys.headlineSmall: _textStyleToMapOrNull(t.headlineSmall),
        TextThemeKeys.titleLarge: _textStyleToMapOrNull(t.titleLarge),
        TextThemeKeys.titleMedium: _textStyleToMapOrNull(t.titleMedium),
        TextThemeKeys.titleSmall: _textStyleToMapOrNull(t.titleSmall),
        TextThemeKeys.bodyLarge: _textStyleToMapOrNull(t.bodyLarge),
        TextThemeKeys.bodyMedium: _textStyleToMapOrNull(t.bodyMedium),
        TextThemeKeys.bodySmall: _textStyleToMapOrNull(t.bodySmall),
        TextThemeKeys.labelLarge: _textStyleToMapOrNull(t.labelLarge),
        TextThemeKeys.labelMedium: _textStyleToMapOrNull(t.labelMedium),
        TextThemeKeys.labelSmall: _textStyleToMapOrNull(t.labelSmall),
      };

  static TextTheme _mapToTextTheme(
    Map<String, dynamic> m, {
    required String path,
  }) {
    Map<String, dynamic>? styleMapOrNull(String k) {
      final Object? v = m[k];
      if (v == null) {
        return null;
      }
      if (v is Map<String, dynamic>) {
        return v;
      }
      throw FormatException('Expected map for $path.$k, got ${v.runtimeType}');
    }

    TextStyle? style(String k) {
      final Map<String, dynamic>? mm = styleMapOrNull(k);
      if (mm == null) {
        return null;
      }
      return _mapToTextStyle(mm, path: '$path.$k');
    }

    for (final String key in TextThemeKeys.all) {
      if (!m.containsKey(key)) {
        throw FormatException('Missing key $path.$key');
      }
    }

    return TextTheme(
      displayLarge: style(TextThemeKeys.displayLarge),
      displayMedium: style(TextThemeKeys.displayMedium),
      displaySmall: style(TextThemeKeys.displaySmall),
      headlineLarge: style(TextThemeKeys.headlineLarge),
      headlineMedium: style(TextThemeKeys.headlineMedium),
      headlineSmall: style(TextThemeKeys.headlineSmall),
      titleLarge: style(TextThemeKeys.titleLarge),
      titleMedium: style(TextThemeKeys.titleMedium),
      titleSmall: style(TextThemeKeys.titleSmall),
      bodyLarge: style(TextThemeKeys.bodyLarge),
      bodyMedium: style(TextThemeKeys.bodyMedium),
      bodySmall: style(TextThemeKeys.bodySmall),
      labelLarge: style(TextThemeKeys.labelLarge),
      labelMedium: style(TextThemeKeys.labelMedium),
      labelSmall: style(TextThemeKeys.labelSmall),
    );
  }

  static Map<String, dynamic>? _textStyleToMapOrNull(TextStyle? s) {
    if (s == null) {
      return null;
    }

    if (s.foreground != null || s.background != null) {
      throw StateError(
        'TextStyle.foreground/background (Paint) are not supported for JSON round-trip.',
      );
    }

    return <String, dynamic>{
      TextStyleKeys.inherit: s.inherit,
      TextStyleKeys.color:
          s.color == null ? null : UtilsForTheme.colorToHex(s.color!),
      TextStyleKeys.backgroundColor: s.backgroundColor == null
          ? null
          : UtilsForTheme.colorToHex(s.backgroundColor!),
      TextStyleKeys.fontSize: s.fontSize,
      TextStyleKeys.fontWeight: s.fontWeight?.value,
      TextStyleKeys.fontStyle: s.fontStyle?.name,
      TextStyleKeys.letterSpacing: s.letterSpacing,
      TextStyleKeys.wordSpacing: s.wordSpacing,
      TextStyleKeys.textBaseline: s.textBaseline?.name,
      TextStyleKeys.height: s.height,
      TextStyleKeys.leadingDistribution: s.leadingDistribution?.name,
      TextStyleKeys.locale: s.locale?.toLanguageTag(),
      TextStyleKeys.decoration: _decorationToListOrEmpty(s.decoration),
      TextStyleKeys.decorationColor: s.decorationColor == null
          ? null
          : UtilsForTheme.colorToHex(s.decorationColor!),
      TextStyleKeys.decorationStyle: s.decorationStyle?.name,
      TextStyleKeys.decorationThickness: s.decorationThickness,
      TextStyleKeys.fontFamily: s.fontFamily,
      TextStyleKeys.fontFamilyFallback: s.fontFamilyFallback,
      TextStyleKeys.overflow: s.overflow?.name,
      TextStyleKeys.shadows: _shadowsToListOrNull(s.shadows),

      // ✅ Added
      TextStyleKeys.fontFeatures: _fontFeaturesToListOrNull(s.fontFeatures),
      TextStyleKeys.fontVariations:
          _fontVariationsToListOrNull(s.fontVariations),
      TextStyleKeys.debugLabel: s.debugLabel,
    };
  }

  static TextStyle _mapToTextStyle(
    Map<String, dynamic> m, {
    required String path,
  }) {
    for (final String key in TextStyleKeys.all) {
      if (!m.containsKey(key)) {
        throw FormatException('Missing key $path.$key');
      }
    }

    Color? parseColorOrNull(String k) {
      final Object? v = m[k];
      if (v == null) {
        return null;
      }
      return UtilsForTheme.parseColorCanonical('$v', path: '$path.$k');
    }

    FontWeight? parseFontWeightOrNull(Object? v) {
      if (v == null) {
        return null;
      }
      final int w = (v is int) ? v : int.tryParse('$v') ?? -1;
      switch (w) {
        case 100:
          return FontWeight.w100;
        case 200:
          return FontWeight.w200;
        case 300:
          return FontWeight.w300;
        case 400:
          return FontWeight.w400;
        case 500:
          return FontWeight.w500;
        case 600:
          return FontWeight.w600;
        case 700:
          return FontWeight.w700;
        case 800:
          return FontWeight.w800;
        case 900:
          return FontWeight.w900;
      }
      throw FormatException(
        'Invalid fontWeight at $path.${TextStyleKeys.fontWeight}: $v',
      );
    }

    FontStyle? parseFontStyleOrNull(Object? v) {
      if (v == null) {
        return null;
      }
      final String s = '$v';
      if (s == 'italic') {
        return FontStyle.italic;
      }
      if (s == 'normal') {
        return FontStyle.normal;
      }
      throw FormatException(
        'Invalid fontStyle at $path.${TextStyleKeys.fontStyle}: $v',
      );
    }

    TextBaseline? parseBaselineOrNull(Object? v) {
      if (v == null) {
        return null;
      }
      final String s = '$v';
      if (s == 'alphabetic') {
        return TextBaseline.alphabetic;
      }
      if (s == 'ideographic') {
        return TextBaseline.ideographic;
      }
      throw FormatException(
        'Invalid textBaseline at $path.${TextStyleKeys.textBaseline}: $v',
      );
    }

    TextLeadingDistribution? parseLeadingOrNull(Object? v) {
      if (v == null) {
        return null;
      }
      final String s = '$v';
      if (s == 'proportional') {
        return TextLeadingDistribution.proportional;
      }
      if (s == 'even') {
        return TextLeadingDistribution.even;
      }
      throw FormatException(
        'Invalid leadingDistribution at $path.${TextStyleKeys.leadingDistribution}: $v',
      );
    }

    TextOverflow? parseOverflowOrNull(Object? v) {
      if (v == null) {
        return null;
      }
      final String s = '$v';
      for (final TextOverflow e in TextOverflow.values) {
        if (e.name == s) {
          return e;
        }
      }
      throw FormatException(
        'Invalid overflow at $path.${TextStyleKeys.overflow}: $v',
      );
    }

    Locale? parseLocaleOrNull(Object? v) {
      if (v == null) {
        return null;
      }
      final String tag = '$v'.trim();
      if (tag.isEmpty) {
        return null;
      }

      final List<String> parts = tag.replaceAll('_', '-').split('-');
      final String languageCode = parts.isNotEmpty ? parts[0] : 'en';

      String? scriptCode;
      String? countryCode;

      if (parts.length == 2) {
        if (parts[1].length == 4) {
          scriptCode = parts[1];
        } else {
          countryCode = parts[1];
        }
      } else if (parts.length >= 3) {
        scriptCode = parts[1].length == 4 ? parts[1] : null;
        countryCode = parts[2];
      }

      return Locale.fromSubtags(
        languageCode: languageCode,
        scriptCode: scriptCode,
        countryCode: countryCode,
      );
    }

    TextDecoration? parseDecorationOrNull(Object? v) {
      if (v == null) {
        return null;
      }
      if (v is! List) {
        throw FormatException(
          'Invalid decoration list at $path.${TextStyleKeys.decoration}',
        );
      }
      final List<TextDecoration> parts = <TextDecoration>[];
      for (final Object? e in v) {
        final String s = '$e';
        if (s == 'underline') {
          parts.add(TextDecoration.underline);
        }
        if (s == 'overline') {
          parts.add(TextDecoration.overline);
        }
        if (s == 'lineThrough') {
          parts.add(TextDecoration.lineThrough);
        }
      }
      if (parts.isEmpty) {
        return null;
      }
      return TextDecoration.combine(parts);
    }

    TextDecorationStyle? parseDecorationStyleOrNull(Object? v) {
      if (v == null) {
        return null;
      }
      final String s = '$v';
      for (final TextDecorationStyle e in TextDecorationStyle.values) {
        if (e.name == s) {
          return e;
        }
      }
      throw FormatException(
        'Invalid decorationStyle at $path.${TextStyleKeys.decorationStyle}: $v',
      );
    }

    List<String>? parseStringListOrNull(Object? v) {
      if (v == null) {
        return null;
      }
      if (v is! List) {
        throw FormatException('Expected list at $path, got ${v.runtimeType}');
      }
      return v.map((Object? e) => '$e').toList(growable: false);
    }

    List<Shadow>? parseShadowsOrNull(Object? v) {
      if (v == null) {
        return null;
      }
      if (v is! List) {
        throw FormatException(
          'Invalid shadows at $path.${TextStyleKeys.shadows}',
        );
      }
      final List<Shadow> out = <Shadow>[];
      for (final Object? e in v) {
        if (e is! Map) {
          throw FormatException(
            'Invalid shadow item at $path.${TextStyleKeys.shadows}',
          );
        }
        final Map<String, dynamic> sm = e.cast<String, dynamic>();
        final Color color = UtilsForTheme.parseColorCanonical(
          _expectString(sm, 'color', path: '$path.shadows'),
          path: '$path.shadows.color',
        );
        final double dx = _expectDouble(sm, 'dx', path: '$path.shadows');
        final double dy = _expectDouble(sm, 'dy', path: '$path.shadows');
        final double blur = _expectDouble(sm, 'blur', path: '$path.shadows');

        out.add(
          Shadow(
            color: color,
            offset: Offset(dx, dy),
            blurRadius: blur,
          ),
        );
      }
      return out;
    }

    final List<FontFeature>? fontFeatures =
        _parseFontFeaturesOrNull(m[TextStyleKeys.fontFeatures], path: path);
    final List<FontVariation>? fontVariations =
        _parseFontVariationsOrNull(m[TextStyleKeys.fontVariations], path: path);

    return TextStyle(
      inherit: _expectBool(m, TextStyleKeys.inherit),
      color: parseColorOrNull(TextStyleKeys.color),
      backgroundColor: parseColorOrNull(TextStyleKeys.backgroundColor),
      fontSize: _expectDoubleOrNull(m, TextStyleKeys.fontSize),
      fontWeight: parseFontWeightOrNull(m[TextStyleKeys.fontWeight]),
      fontStyle: parseFontStyleOrNull(m[TextStyleKeys.fontStyle]),
      letterSpacing: _expectDoubleOrNull(m, TextStyleKeys.letterSpacing),
      wordSpacing: _expectDoubleOrNull(m, TextStyleKeys.wordSpacing),
      textBaseline: parseBaselineOrNull(m[TextStyleKeys.textBaseline]),
      height: _expectDoubleOrNull(m, TextStyleKeys.height),
      leadingDistribution:
          parseLeadingOrNull(m[TextStyleKeys.leadingDistribution]),
      locale: parseLocaleOrNull(m[TextStyleKeys.locale]),
      decoration: parseDecorationOrNull(m[TextStyleKeys.decoration]),
      decorationColor: parseColorOrNull(TextStyleKeys.decorationColor),
      decorationStyle:
          parseDecorationStyleOrNull(m[TextStyleKeys.decorationStyle]),
      decorationThickness:
          _expectDoubleOrNull(m, TextStyleKeys.decorationThickness),
      fontFamily: _expectStringOrNull(m, TextStyleKeys.fontFamily),
      fontFamilyFallback:
          parseStringListOrNull(m[TextStyleKeys.fontFamilyFallback]),
      overflow: parseOverflowOrNull(m[TextStyleKeys.overflow]),
      shadows: parseShadowsOrNull(m[TextStyleKeys.shadows]),
      fontFeatures: fontFeatures,
      fontVariations: fontVariations,
      debugLabel: _expectStringOrNull(m, TextStyleKeys.debugLabel),
    );
  }

  static List<String> _decorationToListOrEmpty(TextDecoration? d) {
    if (d == null) {
      return <String>[];
    }
    final List<String> out = <String>[];
    if (d.contains(TextDecoration.underline)) {
      out.add('underline');
    }
    if (d.contains(TextDecoration.overline)) {
      out.add('overline');
    }
    if (d.contains(TextDecoration.lineThrough)) {
      out.add('lineThrough');
    }
    return out;
  }

  static List<Map<String, dynamic>>? _shadowsToListOrNull(List<Shadow>? s) {
    if (s == null) {
      return null;
    }
    return s
        .map(
          (Shadow sh) => <String, dynamic>{
            'color': UtilsForTheme.colorToHex(sh.color),
            'dx': sh.offset.dx,
            'dy': sh.offset.dy,
            'blur': sh.blurRadius,
          },
        )
        .toList(growable: false);
  }

  static List<Map<String, dynamic>>? _fontFeaturesToListOrNull(
    List<FontFeature>? features,
  ) {
    if (features == null) {
      return null;
    }
    return features
        .map(
          (FontFeature f) => <String, dynamic>{
            'feature': f.feature,
            'value': f.value,
          },
        )
        .toList(growable: false);
  }

  static List<Map<String, dynamic>>? _fontVariationsToListOrNull(
    List<FontVariation>? variations,
  ) {
    if (variations == null) {
      return null;
    }
    return variations
        .map(
          (FontVariation v) => <String, dynamic>{
            'axis': v.axis,
            'value': v.value,
          },
        )
        .toList(growable: false);
  }

  static List<FontFeature>? _parseFontFeaturesOrNull(
    Object? v, {
    required String path,
  }) {
    if (v == null) {
      return null;
    }
    if (v is! List) {
      throw FormatException(
        'Invalid fontFeatures at $path.${TextStyleKeys.fontFeatures}',
      );
    }
    final List<FontFeature> out = <FontFeature>[];
    for (final Object? e in v) {
      if (e is! Map) {
        throw FormatException(
          'Invalid fontFeature item at $path.${TextStyleKeys.fontFeatures}',
        );
      }
      final Map<String, dynamic> m = e.cast<String, dynamic>();
      final String feature =
          _expectString(m, 'feature', path: '$path.fontFeatures');
      final int value = _expectInt(m, 'value', path: '$path.fontFeatures');
      out.add(FontFeature(feature, value));
    }
    return out;
  }

  static List<FontVariation>? _parseFontVariationsOrNull(
    Object? v, {
    required String path,
  }) {
    if (v == null) {
      return null;
    }
    if (v is! List) {
      throw FormatException(
        'Invalid fontVariations at $path.${TextStyleKeys.fontVariations}',
      );
    }
    final List<FontVariation> out = <FontVariation>[];
    for (final Object? e in v) {
      if (e is! Map) {
        throw FormatException(
          'Invalid fontVariation item at $path.${TextStyleKeys.fontVariations}',
        );
      }
      final Map<String, dynamic> m = e.cast<String, dynamic>();
      final String axis =
          _expectString(m, 'axis', path: '$path.fontVariations');
      final double value =
          _expectDouble(m, 'value', path: '$path.fontVariations');
      out.add(FontVariation(axis, value));
    }
    return out;
  }

  // ---------------------------------------------------------------------------
  // Equality & Hashing
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    if (other is! ModelThemeData) {
      return false;
    }

    return useMaterial3 == other.useMaterial3 &&
        Utils.deepEqualsMap(
          _schemeToMap(lightScheme),
          _schemeToMap(other.lightScheme),
        ) &&
        Utils.deepEqualsMap(
          _schemeToMap(darkScheme),
          _schemeToMap(other.darkScheme),
        ) &&
        Utils.deepEqualsMap(
          _textThemeToMap(lightTextTheme),
          _textThemeToMap(other.lightTextTheme),
        ) &&
        Utils.deepEqualsMap(
          _textThemeToMap(darkTextTheme),
          _textThemeToMap(other.darkTextTheme),
        );
  }

  @override
  int get hashCode =>
      useMaterial3.hashCode ^
      (Utils.deepHash(_schemeToMap(lightScheme)) * 31) ^
      (Utils.deepHash(_schemeToMap(darkScheme)) * 37) ^
      (Utils.deepHash(_textThemeToMap(lightTextTheme)) * 41) ^
      (Utils.deepHash(_textThemeToMap(darkTextTheme)) * 43);

  // ---------------------------------------------------------------------------
  // Strict JSON helpers
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _expectMap(
    Map<String, dynamic> json,
    String key,
  ) {
    final Object? v = json[key];
    if (v is Map<String, dynamic>) {
      return v;
    }
    throw FormatException('Expected map for $key, got ${v.runtimeType}');
  }

  static String _expectString(
    Map<String, dynamic> json,
    String key, {
    required String path,
  }) {
    if (!json.containsKey(key)) {
      throw FormatException('Missing key $path.$key');
    }
    final Object? v = json[key];
    if (v == null) {
      throw FormatException('Null value at $path.$key');
    }
    final String s = Utils.getStringFromDynamic(v).trim();
    if (s.isEmpty) {
      throw FormatException('Empty string at $path.$key');
    }
    return s;
  }

  static String? _expectStringOrNull(Map<String, dynamic> json, String key) {
    final Object? v = json[key];
    if (v == null) {
      return null;
    }
    final String s = Utils.getStringFromDynamic(v).trim();
    return s.isEmpty ? null : s;
  }

  static bool _expectBool(Map<String, dynamic> json, String key) {
    if (!json.containsKey(key)) {
      throw FormatException('Missing key $key');
    }
    final Object? v = json[key];
    if (v is bool) {
      return v;
    }
    if (v is String) {
      return v.toLowerCase() == 'true';
    }
    throw FormatException('Expected bool for $key, got ${v.runtimeType}');
  }

  static int _expectInt(
    Map<String, dynamic> json,
    String key, {
    required String path,
  }) {
    if (!json.containsKey(key)) {
      throw FormatException('Missing key $path.$key');
    }
    final Object? v = json[key];
    if (v is int) {
      return v;
    }
    final int? parsed = int.tryParse('$v');
    if (parsed == null) {
      throw FormatException('Expected int at $path.$key, got $v');
    }
    return parsed;
  }

  static double _expectDouble(
    Map<String, dynamic> json,
    String key, {
    required String path,
  }) {
    if (!json.containsKey(key)) {
      throw FormatException('Missing key $path.$key');
    }
    final Object? v = json[key];
    if (v is num) {
      return v.toDouble();
    }
    final double? parsed = double.tryParse('$v');
    if (parsed == null) {
      throw FormatException('Expected double at $path.$key, got $v');
    }
    return parsed;
  }

  static double? _expectDoubleOrNull(Map<String, dynamic> json, String key) {
    final Object? v = json[key];
    if (v == null) {
      return null;
    }
    if (v is num) {
      return v.toDouble();
    }
    return double.tryParse('$v');
  }
}

// -----------------------------------------------------------------------------
// ✅ Public key classes (usable externally)
// -----------------------------------------------------------------------------

abstract final class ModelThemeDataKeys {
  static const String useMaterial3 = 'useMaterial3';
  static const String lightScheme = 'lightScheme';
  static const String darkScheme = 'darkScheme';
  static const String lightTextTheme = 'lightTextTheme';
  static const String darkTextTheme = 'darkTextTheme';
}

abstract final class ColorSchemeKeys {
  static const String brightness = 'brightness';

  static const String primary = 'primary';
  static const String onPrimary = 'onPrimary';
  static const String primaryContainer = 'primaryContainer';
  static const String onPrimaryContainer = 'onPrimaryContainer';
  static const String primaryFixed = 'primaryFixed';
  static const String primaryFixedDim = 'primaryFixedDim';
  static const String onPrimaryFixed = 'onPrimaryFixed';
  static const String onPrimaryFixedVariant = 'onPrimaryFixedVariant';

  static const String secondary = 'secondary';
  static const String onSecondary = 'onSecondary';
  static const String secondaryContainer = 'secondaryContainer';
  static const String onSecondaryContainer = 'onSecondaryContainer';
  static const String secondaryFixed = 'secondaryFixed';
  static const String secondaryFixedDim = 'secondaryFixedDim';
  static const String onSecondaryFixed = 'onSecondaryFixed';
  static const String onSecondaryFixedVariant = 'onSecondaryFixedVariant';

  static const String tertiary = 'tertiary';
  static const String onTertiary = 'onTertiary';
  static const String tertiaryContainer = 'tertiaryContainer';
  static const String onTertiaryContainer = 'onTertiaryContainer';
  static const String tertiaryFixed = 'tertiaryFixed';
  static const String tertiaryFixedDim = 'tertiaryFixedDim';
  static const String onTertiaryFixed = 'onTertiaryFixed';
  static const String onTertiaryFixedVariant = 'onTertiaryFixedVariant';

  static const String error = 'error';
  static const String onError = 'onError';
  static const String errorContainer = 'errorContainer';
  static const String onErrorContainer = 'onErrorContainer';

  static const String surface = 'surface';
  static const String onSurface = 'onSurface';
  static const String surfaceDim = 'surfaceDim';
  static const String surfaceBright = 'surfaceBright';
  static const String surfaceContainerLowest = 'surfaceContainerLowest';
  static const String surfaceContainerLow = 'surfaceContainerLow';
  static const String surfaceContainer = 'surfaceContainer';
  static const String surfaceContainerHigh = 'surfaceContainerHigh';
  static const String surfaceContainerHighest = 'surfaceContainerHighest';

  static const String onSurfaceVariant = 'onSurfaceVariant';

  static const String outline = 'outline';
  static const String outlineVariant = 'outlineVariant';
  static const String shadow = 'shadow';
  static const String scrim = 'scrim';

  static const String inverseSurface = 'inverseSurface';
  static const String onInverseSurface = 'onInverseSurface';
  static const String inversePrimary = 'inversePrimary';

  static const String surfaceTint = 'surfaceTint';

// Opcional (legacy snapshot):
// static const String background = 'background';
// static const String onBackground = 'onBackground';
// static const String surfaceVariant = 'surfaceVariant';
}

abstract final class TextThemeKeys {
  static const String displayLarge = 'displayLarge';
  static const String displayMedium = 'displayMedium';
  static const String displaySmall = 'displaySmall';
  static const String headlineLarge = 'headlineLarge';
  static const String headlineMedium = 'headlineMedium';
  static const String headlineSmall = 'headlineSmall';
  static const String titleLarge = 'titleLarge';
  static const String titleMedium = 'titleMedium';
  static const String titleSmall = 'titleSmall';
  static const String bodyLarge = 'bodyLarge';
  static const String bodyMedium = 'bodyMedium';
  static const String bodySmall = 'bodySmall';
  static const String labelLarge = 'labelLarge';
  static const String labelMedium = 'labelMedium';
  static const String labelSmall = 'labelSmall';

  static const List<String> all = <String>[
    displayLarge,
    displayMedium,
    displaySmall,
    headlineLarge,
    headlineMedium,
    headlineSmall,
    titleLarge,
    titleMedium,
    titleSmall,
    bodyLarge,
    bodyMedium,
    bodySmall,
    labelLarge,
    labelMedium,
    labelSmall,
  ];
}

abstract final class TextStyleKeys {
  static const String inherit = 'inherit';
  static const String color = 'color';
  static const String backgroundColor = 'backgroundColor';
  static const String fontSize = 'fontSize';
  static const String fontWeight = 'fontWeight';
  static const String fontStyle = 'fontStyle';
  static const String letterSpacing = 'letterSpacing';
  static const String wordSpacing = 'wordSpacing';
  static const String textBaseline = 'textBaseline';
  static const String height = 'height';
  static const String leadingDistribution = 'leadingDistribution';
  static const String locale = 'locale';
  static const String decoration = 'decoration';
  static const String decorationColor = 'decorationColor';
  static const String decorationStyle = 'decorationStyle';
  static const String decorationThickness = 'decorationThickness';
  static const String fontFamily = 'fontFamily';
  static const String fontFamilyFallback = 'fontFamilyFallback';
  static const String overflow = 'overflow';
  static const String shadows = 'shadows';

  // ✅ Added
  static const String fontFeatures = 'fontFeatures';
  static const String fontVariations = 'fontVariations';
  static const String debugLabel = 'debugLabel';

  static const List<String> all = <String>[
    inherit,
    color,
    backgroundColor,
    fontSize,
    fontWeight,
    fontStyle,
    letterSpacing,
    wordSpacing,
    textBaseline,
    height,
    leadingDistribution,
    locale,
    decoration,
    decorationColor,
    decorationStyle,
    decorationThickness,
    fontFamily,
    fontFamilyFallback,
    overflow,
    shadows,
    fontFeatures,
    fontVariations,
    debugLabel,
  ];
}
