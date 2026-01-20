// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ---------------------------------------------------------------------------
/// DESIGN SYSTEM JSON (placeholder)
/// ---------------------------------------------------------------------------
const String kDsJson = r'''
{
  "theme": {
    "useMaterial3": true,
    "lightScheme": {
      "brightness": "light",
      "primary": "#FF6750A4",
      "onPrimary": "#FFFFFFFF",
      "primaryContainer": "#FFEADDFF",
      "onPrimaryContainer": "#FF4F378B",
      "primaryFixed": "#FFEADDFF",
      "primaryFixedDim": "#FFD0BCFF",
      "onPrimaryFixed": "#FF21005D",
      "onPrimaryFixedVariant": "#FF4F378B",
      "secondary": "#FF625B71",
      "onSecondary": "#FFFFFFFF",
      "secondaryContainer": "#FFE8DEF8",
      "onSecondaryContainer": "#FF4A4458",
      "secondaryFixed": "#FFE8DEF8",
      "secondaryFixedDim": "#FFCCC2DC",
      "onSecondaryFixed": "#FF1D192B",
      "onSecondaryFixedVariant": "#FF4A4458",
      "tertiary": "#FF7D5260",
      "onTertiary": "#FFFFFFFF",
      "tertiaryContainer": "#FFFFD8E4",
      "onTertiaryContainer": "#FF633B48",
      "tertiaryFixed": "#FFFFD8E4",
      "tertiaryFixedDim": "#FFEFB8C8",
      "onTertiaryFixed": "#FF31111D",
      "onTertiaryFixedVariant": "#FF633B48",
      "error": "#FFB3261E",
      "onError": "#FFFFFFFF",
      "errorContainer": "#FFF9DEDC",
      "onErrorContainer": "#FF8C1D18",
      "surface": "#FFFEF7FF",
      "onSurface": "#FF1D1B20",
      "surfaceDim": "#FFDED8E1",
      "surfaceBright": "#FFFEF7FF",
      "surfaceContainerLowest": "#FFFFFFFF",
      "surfaceContainerLow": "#FFF7F2FA",
      "surfaceContainer": "#FFF3EDF7",
      "surfaceContainerHigh": "#FFECE6F0",
      "surfaceContainerHighest": "#FFE6E0E9",
      "onSurfaceVariant": "#FF49454F",
      "outline": "#FF79747E",
      "outlineVariant": "#FFCAC4D0",
      "shadow": "#FF000000",
      "scrim": "#FF000000",
      "inverseSurface": "#FF322F35",
      "onInverseSurface": "#FFF5EFF7",
      "inversePrimary": "#FFD0BCFF",
      "surfaceTint": "#FF6750A4"
    },
    "darkScheme": {
      "brightness": "dark",
      "primary": "#FFD0BCFF",
      "onPrimary": "#FF381E72",
      "primaryContainer": "#FF4F378B",
      "onPrimaryContainer": "#FFEADDFF",
      "primaryFixed": "#FFEADDFF",
      "primaryFixedDim": "#FFD0BCFF",
      "onPrimaryFixed": "#FF21005D",
      "onPrimaryFixedVariant": "#FF4F378B",
      "secondary": "#FFCCC2DC",
      "onSecondary": "#FF332D41",
      "secondaryContainer": "#FF4A4458",
      "onSecondaryContainer": "#FFE8DEF8",
      "secondaryFixed": "#FFE8DEF8",
      "secondaryFixedDim": "#FFCCC2DC",
      "onSecondaryFixed": "#FF1D192B",
      "onSecondaryFixedVariant": "#FF4A4458",
      "tertiary": "#FFEFB8C8",
      "onTertiary": "#FF492532",
      "tertiaryContainer": "#FF633B48",
      "onTertiaryContainer": "#FFFFD8E4",
      "tertiaryFixed": "#FFFFD8E4",
      "tertiaryFixedDim": "#FFEFB8C8",
      "onTertiaryFixed": "#FF31111D",
      "onTertiaryFixedVariant": "#FF633B48",
      "error": "#FFF2B8B5",
      "onError": "#FF601410",
      "errorContainer": "#FF8C1D18",
      "onErrorContainer": "#FFF9DEDC",
      "surface": "#FF141218",
      "onSurface": "#FFE6E0E9",
      "surfaceDim": "#FF141218",
      "surfaceBright": "#FF3B383E",
      "surfaceContainerLowest": "#FF0F0D13",
      "surfaceContainerLow": "#FF1D1B20",
      "surfaceContainer": "#FF211F26",
      "surfaceContainerHigh": "#FF2B2930",
      "surfaceContainerHighest": "#FF36343B",
      "onSurfaceVariant": "#FFCAC4D0",
      "outline": "#FF938F99",
      "outlineVariant": "#FF49454F",
      "shadow": "#FF000000",
      "scrim": "#FF000000",
      "inverseSurface": "#FFE6E0E9",
      "onInverseSurface": "#FF322F35",
      "inversePrimary": "#FF6750A4",
      "surfaceTint": "#FFD0BCFF"
    },
    "lightTextTheme": {
      "displayLarge": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": 40.0,
        "fontWeight": null,
        "fontStyle": "normal",
        "letterSpacing": -0.35,
        "wordSpacing": null,
        "textBaseline": null,
        "height": 1.15,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(((((((((((blackRedmond displayLarge).apply).copyWith).copyWith).copyWith).copyWith).copyWith).copyWith).copyWith).copyWith).copyWith).copyWith"
      },
      "displayMedium": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(blackRedmond displayMedium).apply"
      },
      "displaySmall": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(blackRedmond displaySmall).apply"
      },
      "headlineLarge": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(blackRedmond headlineLarge).apply"
      },
      "headlineMedium": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(blackRedmond headlineMedium).apply"
      },
      "headlineSmall": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(blackRedmond headlineSmall).apply"
      },
      "titleLarge": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(blackRedmond titleLarge).apply"
      },
      "titleMedium": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(blackRedmond titleMedium).apply"
      },
      "titleSmall": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(blackRedmond titleSmall).apply"
      },
      "bodyLarge": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(blackRedmond bodyLarge).apply"
      },
      "bodyMedium": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": 12.0,
        "fontWeight": null,
        "fontStyle": "normal",
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": 1.3,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(((((blackRedmond bodyMedium).apply).copyWith).copyWith).copyWith).copyWith"
      },
      "bodySmall": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(blackRedmond bodySmall).apply"
      },
      "labelLarge": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(blackRedmond labelLarge).apply"
      },
      "labelMedium": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(blackRedmond labelMedium).apply"
      },
      "labelSmall": {
        "inherit": true,
        "color": "#FF1D1B20",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FF1D1B20",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(blackRedmond labelSmall).apply"
      }
    },
    "darkTextTheme": {
      "displayLarge": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": 40.0,
        "fontWeight": null,
        "fontStyle": "normal",
        "letterSpacing": -0.35,
        "wordSpacing": null,
        "textBaseline": null,
        "height": 1.15,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(((((((((((whiteRedmond displayLarge).apply).copyWith).copyWith).copyWith).copyWith).copyWith).copyWith).copyWith).copyWith).copyWith).copyWith"
      },
      "displayMedium": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(whiteRedmond displayMedium).apply"
      },
      "displaySmall": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(whiteRedmond displaySmall).apply"
      },
      "headlineLarge": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(whiteRedmond headlineLarge).apply"
      },
      "headlineMedium": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(whiteRedmond headlineMedium).apply"
      },
      "headlineSmall": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(whiteRedmond headlineSmall).apply"
      },
      "titleLarge": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(whiteRedmond titleLarge).apply"
      },
      "titleMedium": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(whiteRedmond titleMedium).apply"
      },
      "titleSmall": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(whiteRedmond titleSmall).apply"
      },
      "bodyLarge": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(whiteRedmond bodyLarge).apply"
      },
      "bodyMedium": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": 12.0,
        "fontWeight": null,
        "fontStyle": "normal",
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": 1.3,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(((((whiteRedmond bodyMedium).apply).copyWith).copyWith).copyWith).copyWith"
      },
      "bodySmall": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(whiteRedmond bodySmall).apply"
      },
      "labelLarge": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(whiteRedmond labelLarge).apply"
      },
      "labelMedium": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(whiteRedmond labelMedium).apply"
      },
      "labelSmall": {
        "inherit": true,
        "color": "#FFE6E0E9",
        "backgroundColor": null,
        "fontSize": null,
        "fontWeight": null,
        "fontStyle": null,
        "letterSpacing": null,
        "wordSpacing": null,
        "textBaseline": null,
        "height": null,
        "leadingDistribution": null,
        "locale": null,
        "decoration": [],
        "decorationColor": "#FFE6E0E9",
        "decorationStyle": null,
        "decorationThickness": null,
        "fontFamily": "Segoe UI",
        "fontFamilyFallback": null,
        "overflow": null,
        "shadows": null,
        "fontFeatures": null,
        "fontVariations": null,
        "debugLabel": "(whiteRedmond labelSmall).apply"
      }
    }
  },
  "tokens": {
    "spacingXs": 4.0,
    "spacingSm": 8.0,
    "spacing": 16.0,
    "spacingLg": 24.0,
    "spacingXl": 32.0,
    "spacingXXl": 64.0,
    "borderRadiusXs": 2.0,
    "borderRadiusSm": 4.0,
    "borderRadius": 8.0,
    "borderRadiusLg": 12.0,
    "borderRadiusXl": 16.0,
    "borderRadiusXXl": 24.0,
    "elevationXs": 0.0,
    "elevationSm": 1.0,
    "elevation": 3.0,
    "elevationLg": 6.0,
    "elevationXl": 9.0,
    "elevationXXl": 12.0,
    "withAlphaXs": 0.04,
    "withAlphaSm": 0.12,
    "withAlpha": 0.16,
    "withAlphaLg": 0.24,
    "withAlphaXl": 0.32,
    "withAlphaXXl": 0.4,
    "animationDurationShort": 100,
    "animationDuration": 300,
    "animationDurationLong": 800
  },
  "semanticLight": {
    "success": 4281236786,
    "onSuccess": 4294967295,
    "successContainer": 4290377418,
    "onSuccessContainer": 4278922771,
    "warning": 4293749762,
    "onWarning": 4294967295,
    "warningContainer": 4294959282,
    "onWarningContainer": 4281999104,
    "info": 4278356177,
    "onInfo": 4294967295,
    "infoContainer": 4289979900,
    "onInfoContainer": 4278197804
  },
  "semanticDark": {
    "success": 4284922730,
    "onSuccess": 4278592011,
    "successContainer": 4279983648,
    "onSuccessContainer": 4293326826,
    "warning": 4294948685,
    "onWarning": 4280947968,
    "warningContainer": 4283312896,
    "onWarningContainer": 4294961617,
    "info": 4283417591,
    "onInfo": 4278198059,
    "infoContainer": 4278209395,
    "onInfoContainer": 4292998399
  },
  "dataViz": {
    "categorical": [
      4280252340,
      4294934286,
      4281114668,
      4292224808,
      4287915965,
      4287387211,
      4293097410,
      4286545791,
      4290559266,
      4279746255
    ],
    "sequential": [
      4293128957,
      4287679225,
      4282557941,
      4280191205,
      4279592384,
      4279060385
    ]
  }
}
''';

ModelDesignSystem? parseDsJsonOrNull(String raw) {
  try {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    return ModelDesignSystem.fromJson(decoded);
  } catch (_) {
    return null;
  }
}

/// ---------------------------------------------------------------------------
/// ACL DEMO (quemado)
/// ---------------------------------------------------------------------------

enum DemoRole { viewer, editor, admin }

DemoRole _roleOfEmail(String email) {
  if (email == 'admin@jocaaguraarchetype.com') {
    return DemoRole.admin;
  }
  if (email == 'editor@jocaaguraarchetype.com') {
    return DemoRole.editor;
  }
  return DemoRole.viewer;
}

bool _roleAtLeast(DemoRole actual, DemoRole min) => actual.index >= min.index;

abstract final class DemoPolicies {
  static const String viewer = 'demo.policy.viewer';
  static const String editor = 'demo.policy.editor';
  static const String admin = 'demo.policy.admin';
}

const Map<String, DemoRole> kPolicyMinRoles = <String, DemoRole>{
  DemoPolicies.viewer: DemoRole.viewer,
  DemoPolicies.editor: DemoRole.editor,
  DemoPolicies.admin: DemoRole.admin,
};

class BlocAclDemo extends BlocModule {
  BlocAclDemo({required String initialEmail})
      : _actingEmail = BlocGeneral<String>(initialEmail);

  static const String name = 'BlocAclDemo';

  final BlocGeneral<String> _actingEmail;

  Stream<String> get email$ => _actingEmail.stream;
  String get email => _actingEmail.value;

  void setEmail(String email) {
    if (email == _actingEmail.value) {
      return;
    }
    _actingEmail.value = email;
  }

  DemoRole get role => _roleOfEmail(email);

  bool canRenderWithAcl(String policyId) {
    final DemoRole? minRole = kPolicyMinRoles[policyId];
    if (minRole == null) {
      return false; // deny-by-default
    }
    return _roleAtLeast(role, minRole);
  }

  Future<void> refreshIfNeeded() async {
    if (role == DemoRole.editor || role == DemoRole.admin) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
  }

  Future<bool> canNavigateWithAcl(String policyId) async {
    await refreshIfNeeded();
    return canRenderWithAcl(policyId);
  }

  Future<Either<ErrorItem, T>> executeWithAcl<T>({
    required String policyId,
    required Future<Either<ErrorItem, T>> Function() action,
    required ErrorItem Function() unauthorizedErrorBuilder,
  }) async {
    await refreshIfNeeded();
    final bool allowed = canRenderWithAcl(policyId);
    if (!allowed) {
      return Left<ErrorItem, T>(unauthorizedErrorBuilder());
    }
    return action();
  }

  @override
  void dispose() {
    _actingEmail.dispose();
  }
}

/// ---------------------------------------------------------------------------
/// SESSION FAKE (RepositoryAuth) para BlocSession.fromRepository(...).
/// ---------------------------------------------------------------------------

class _FakeRepositoryAuth implements RepositoryAuth {
  _FakeRepositoryAuth()
      : _ctrl = StreamController<Either<ErrorItem, UserModel?>>.broadcast();

  final StreamController<Either<ErrorItem, UserModel?>> _ctrl;
  UserModel? _current;

  static const List<String> allowed = <String>[
    'admin@jocaaguraarchetype.com',
    'editor@jocaaguraarchetype.com',
    'viewer@jocaaguraarchetype.com',
  ];

  ErrorItem _err(
    String title,
    String description, {
    String code = 'AUTH_ERROR',
  }) {
    return ErrorItem(
      title: title,
      code: code,
      description: description,
      errorLevel: ErrorLevelEnum.severe,
    );
  }

  UserModel _mkUser(String email) {
    return UserModel(
      id: email,
      displayName: email.split('@').first,
      photoUrl: '',
      email: email,
      jwt: const <String, dynamic>{},
    );
  }

  void dispose() {
    _ctrl.close();
  }

  void _emit(UserModel? user) {
    _ctrl.add(Right<ErrorItem, UserModel?>(user));
  }

  @override
  Stream<Either<ErrorItem, UserModel?>> authStateChanges() => _ctrl.stream;

  @override
  Future<Either<ErrorItem, UserModel>> logInUserAndPassword(
    String email,
    String password,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!allowed.contains(email)) {
      final ErrorItem e = _err(
        'LOGIN_FAILED',
        'Email no permitido en el demo',
        code: 'LOGIN_FAILED',
      );
      _ctrl.add(Left<ErrorItem, UserModel?>(e));
      return Left<ErrorItem, UserModel>(e);
    }
    _current = _mkUser(email);
    _emit(_current);
    return Right<ErrorItem, UserModel>(_current!);
  }

  @override
  Future<Either<ErrorItem, UserModel>> signInUserAndPassword(
    String email,
    String password,
  ) async {
    return logInUserAndPassword(email, password);
  }

  @override
  Future<Either<ErrorItem, void>> logOutUser(UserModel user) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _current = null;
    _emit(null);
    return Right<ErrorItem, void>(null);
  }

  @override
  Future<Either<ErrorItem, UserModel>> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (_current == null) {
      return Left<ErrorItem, UserModel>(
        _err('NO_SESSION', 'No hay sesión activa', code: 'NO_SESSION'),
      );
    }
    return Right<ErrorItem, UserModel>(_current!);
  }

  @override
  Future<Either<ErrorItem, bool>> isSignedIn() async {
    return Right<ErrorItem, bool>(_current != null);
  }

  // ---- no usados en el ejemplo (pero requeridos por el contrato) -------------

  @override
  Future<Either<ErrorItem, UserModel>> logInWithGoogle() async {
    return Left<ErrorItem, UserModel>(
      _err('NOT_IMPLEMENTED', 'Demo no implementa Google', code: 'NOT_IMPL'),
    );
  }

  @override
  Future<Either<ErrorItem, UserModel>> logInSilently(
    UserModel currentUser,
  ) async {
    return Left<ErrorItem, UserModel>(
      _err(
        'NOT_IMPLEMENTED',
        'Demo no implementa silent login',
        code: 'NOT_IMPL',
      ),
    );
  }

  @override
  Future<Either<ErrorItem, UserModel>> refreshSession(
    UserModel currentUser,
  ) async {
    return Left<ErrorItem, UserModel>(
      _err('NOT_IMPLEMENTED', 'Demo no implementa refresh', code: 'NOT_IMPL'),
    );
  }

  @override
  Future<Either<ErrorItem, void>> recoverPassword(String email) async {
    return Left<ErrorItem, void>(
      _err('NOT_IMPLEMENTED', 'Demo no implementa recover', code: 'NOT_IMPL'),
    );
  }
}

/// ---------------------------------------------------------------------------
/// APP MANAGER (con helpers ACL + acceso a módulos).
/// ---------------------------------------------------------------------------

class JdsAppManager extends AppManager {
  JdsAppManager(
    super.config, {
    required this.unauthorizedErrorBuilder,
    super.onAppLifecycleChanged,
    super.env = defaultEnv,
  });

  final ErrorItem Function() unauthorizedErrorBuilder;

  BlocDesignSystem get blocDesignSystem =>
      requireModuleOfType<BlocDesignSystem>();
  BlocSession get blocSession => requireModuleOfType<BlocSession>();
  BlocAclDemo get blocAcl => requireModuleOfType<BlocAclDemo>();

  Future<void> pushWithAcl(
    PageModel page, {
    required String policyId,
    bool allowDuplicate = true,
    PageModel? forbiddenPage,
  }) async {
    final bool allowed = await blocAcl.canNavigateWithAcl(policyId);
    if (!allowed) {
      if (forbiddenPage != null) {
        pageManager.resetTo(forbiddenPage);
      }
      return;
    }
    pageManager.push(page, allowDuplicate: allowDuplicate);
  }

  Future<Either<ErrorItem, T>> executeWithAcl<T>({
    required String policyId,
    required Future<Either<ErrorItem, T>> Function() action,
  }) {
    return blocAcl.executeWithAcl<T>(
      policyId: policyId,
      action: action,
      unauthorizedErrorBuilder: unauthorizedErrorBuilder,
    );
  }

  @override
  void handleLifecycle(AppLifecycleState state) {
    super.handleLifecycle(state);
    if (state == AppLifecycleState.resumed) {
      blocAcl.refreshIfNeeded();
    }
  }
}

/// ---------------------------------------------------------------------------
/// RepositoryTheme mínimo (requerido por BlocTheme).
/// ---------------------------------------------------------------------------

class RepositoryThemeForExample implements RepositoryTheme {
  @override
  Future<Either<ErrorItem, ThemeState>> read() {
    return Future<Either<ErrorItem, ThemeState>>.value(
      Right<ErrorItem, ThemeState>(ThemeState.defaults),
    );
  }

  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState next) {
    return Future<Either<ErrorItem, ThemeState>>.value(
      Right<ErrorItem, ThemeState>(next),
    );
  }
}

/// ---------------------------------------------------------------------------
/// PAGES (todas con segments => evita 404 "/" y 404 "/login").
/// ---------------------------------------------------------------------------

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  static const String name = 'splash';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    final BlocOnboarding ob = context.appManager.onboarding;
    return OnBoardingPage(blocOnboarding: ob);
  }
}

class HomePublicPage extends StatelessWidget {
  const HomePublicPage({super.key});
  static const String name = 'homePublic';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    final AbstractAppManager app = context.appManager;
    return PageBuilder(
      page: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'HOME PUBLIC',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => app.pushModel(LoginPage.pageModel),
              child: const Text('Ir a Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String name = 'login';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = 'viewer@jocaaguraarchetype.com';
  final TextEditingController _pass = TextEditingController(text: 'demo');

  @override
  void dispose() {
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AbstractAppManager app = context.appManager;
    final JdsAppManager jds = app as JdsAppManager;
    final BlocSession bloc = jds.blocSession;

    return PageBuilder(
      page: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<SessionState>(
          stream: bloc.stream,
          initialData: bloc.state,
          builder: (_, __) {
            final SessionState s = bloc.stateOrDefault;
            final bool authenticating = s is Authenticating;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Login (demo)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  value: _email,
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'admin@jocaaguraarchetype.com',
                      child: Text('admin@jocaaguraarchetype.com'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'editor@jocaaguraarchetype.com',
                      child: Text('editor@jocaaguraarchetype.com'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'viewer@jocaaguraarchetype.com',
                      child: Text('viewer@jocaaguraarchetype.com'),
                    ),
                  ],
                  onChanged: authenticating
                      ? null
                      : (String? v) => setState(() => _email = v ?? _email),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _pass,
                  enabled: !authenticating,
                  decoration:
                      const InputDecoration(labelText: 'Password (demo)'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: authenticating
                      ? null
                      : () async {
                          final Either<ErrorItem, UserModel> r = await bloc
                              .logIn(email: _email, password: _pass.text);

                          r.fold(
                            (ErrorItem e) =>
                                jds.notifications.showToast(e.title),
                            (UserModel u) {
                              // ACL “usuario activo” sigue a la sesión en este demo
                              jds.blocAcl.setEmail(u.email);
                              // Normalmente SessionAppManager te llevará a homeAuthenticated.
                              // Igual lo hacemos explícito para que sea determinístico.
                              jds.pageManager
                                  .resetTo(HomeAuthenticatedPage.pageModel);
                            },
                          );
                        },
                  child: authenticating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign in'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Estado sesión: ${s.runtimeType}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class HomeAuthenticatedPage extends StatelessWidget {
  const HomeAuthenticatedPage({super.key});
  static const String name = 'homeAuthenticated';
  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>[name],
    requiresAuth: true,
  );

  @override
  Widget build(BuildContext context) {
    final JdsAppManager app = context.appManager as JdsAppManager;
    final ModelDsExtendedTokens tok = _safeTokens(context);

    return PageBuilder(
      page: Padding(
        padding: EdgeInsets.all(tok.spacing),
        child: ListView(
          children: <Widget>[
            _SessionCard(appManager: app),
            SizedBox(height: tok.spacingLg),
            _DsCard(appManager: app),
            SizedBox(height: tok.spacingLg),
            _AclCard(appManager: app),
          ],
        ),
      ),
    );
  }
}

class SessionClosedPage extends StatelessWidget {
  const SessionClosedPage({super.key});
  static const String name = 'sessionClosed';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    final AbstractAppManager app = context.appManager;
    return PageBuilder(
      page: InkWell(
        onTap: () => app.pageManager.resetTo(HomePublicPage.pageModel),
        child: const Center(
          child: Text('Session Closed · tap para ir a Home Public'),
        ),
      ),
    );
  }
}

class AuthenticatingPage extends StatelessWidget {
  const AuthenticatingPage({super.key});
  static const String name = 'authenticating';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    return const PageBuilder(
      showAppBar: false,
      page: Center(child: CircularProgressIndicator()),
    );
  }
}

class SessionErrorPage extends StatelessWidget {
  const SessionErrorPage({super.key});
  static const String name = 'sessionError';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    final AbstractAppManager app = context.appManager;
    final BlocSession bloc =
        app.requireModuleByKey<BlocSession>(BlocSession.name);

    return PageBuilder(
      page: InkWell(
        onTap: () => app.pageManager.resetTo(HomePublicPage.pageModel),
        child: Center(
          child: Text('Session Error · ${bloc.state}'),
        ),
      ),
    );
  }
}

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});
  static const String name = 'forbidden';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    final AbstractAppManager app = context.appManager;
    return PageBuilder(
      page: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('403 · Forbidden (ACL)'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  app.pageManager.resetTo(HomeAuthenticatedPage.pageModel),
              child: const Text('Volver a Home Auth'),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewerPage extends StatelessWidget {
  const ViewerPage({super.key});
  static const String name = 'viewer';
  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>[name],
    requiresAuth: true,
  );

  @override
  Widget build(BuildContext context) {
    return const PageBuilder(
      page: _ProtectedPage(
        title: 'Viewer page (minRole: viewer)',
        policyId: DemoPolicies.viewer,
      ),
    );
  }
}

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});
  static const String name = 'editor';
  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>[name],
    requiresAuth: true,
  );

  @override
  Widget build(BuildContext context) {
    return const PageBuilder(
      page: _ProtectedPage(
        title: 'Editor page (minRole: editor)',
        policyId: DemoPolicies.editor,
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});
  static const String name = 'admin';
  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>[name],
    requiresAuth: true,
  );

  @override
  Widget build(BuildContext context) {
    return const PageBuilder(
      page: _ProtectedPage(
        title: 'Admin page (minRole: admin)',
        policyId: DemoPolicies.admin,
      ),
    );
  }
}

class _ProtectedPage extends StatelessWidget {
  const _ProtectedPage({
    required this.title,
    required this.policyId,
  });

  final String title;
  final String policyId;

  @override
  Widget build(BuildContext context) {
    final JdsAppManager app = context.appManager as JdsAppManager;
    final ModelDsExtendedTokens tok = _safeTokens(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: EdgeInsets.all(tok.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Policy: $policyId'),
            Text(
              'Usuario ACL: ${app.blocAcl.email} (${app.blocAcl.role.name})',
            ),
            SizedBox(height: tok.spacingLg),
            ElevatedButton(
              onPressed: () =>
                  app.pageManager.resetTo(HomeAuthenticatedPage.pageModel),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// HOME AUTH: Cards de Session / DS / ACL
/// ---------------------------------------------------------------------------

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.appManager});
  final JdsAppManager appManager;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tok = _safeTokens(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tok.spacing),
        child: StreamBuilder<SessionState>(
          stream: appManager.blocSession.stream,
          initialData: appManager.blocSession.state,
          builder: (_, __) {
            final SessionState s = appManager.blocSession.stateOrDefault;
            final bool authed = s is Authenticated;
            final String email = authed ? s.user.email : '(no session)';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Session', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: tok.spacingSm),
                Text('Estado: ${s.runtimeType}'),
                Text('Usuario: $email'),
                SizedBox(height: tok.spacing),
                Wrap(
                  spacing: tok.spacingSm,
                  runSpacing: tok.spacingSm,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: authed
                          ? () async {
                              final Either<ErrorItem, void>? r =
                                  await appManager.blocSession.logOut();
                              if (r == null) {
                                appManager.pageManager
                                    .resetTo(HomePublicPage.pageModel);
                                return;
                              }
                              r.fold(
                                (ErrorItem e) =>
                                    appManager.notifications.showToast(e.title),
                                (_) => appManager.pageManager
                                    .resetTo(SessionClosedPage.pageModel),
                              );
                            }
                          : null,
                      child: const Text('Log out'),
                    ),
                    Text('ACL rol: ${appManager.blocAcl.role.name}'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DsCard extends StatelessWidget {
  const _DsCard({required this.appManager});
  final JdsAppManager appManager;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tok = _safeTokens(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tok.spacing),
        child: StreamBuilder<Either<ErrorItem, ModelDesignSystem>>(
          stream: appManager.blocDesignSystem.dsStream,
          initialData: appManager.blocDesignSystem.currentEither,
          builder: (_, __) {
            final ModelDesignSystem ds =
                appManager.blocDesignSystem.requireDs();
            final ModelDsExtendedTokens t = ds.tokens;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Design System',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: tok.spacingSm),
                Text('borderRadius: ${t.borderRadius}'),
                Text('spacing: ${t.spacing}'),
                SizedBox(height: tok.spacing),
                Wrap(
                  spacing: tok.spacingSm,
                  runSpacing: tok.spacingSm,
                  children: <Widget>[
                    FilledButton(
                      onPressed: () {
                        appManager.blocDesignSystem.patchTokens(
                          borderRadius: t.borderRadius + 2,
                        );
                        appManager.notifications
                            .showToast('Token patch (borderRadius +2)');
                      },
                      child: const Text('Patch radius +2'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        final Object? decoded = jsonDecode(kDsJson);
                        if (decoded is! Map<String, dynamic>) {
                          appManager.notifications.showToast('JSON inválido');
                          return;
                        }
                        appManager.blocDesignSystem.importFromJson(decoded);
                        appManager.notifications
                            .showToast('importFromJson() ejecutado');
                      },
                      child: const Text('Import DS JSON'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        appManager.notifications.showToast('Dark Theme Mode');
                        appManager.theme.setMode(ThemeMode.light);
                      },
                      child: const Text('Light Theme Mode'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        appManager.notifications.showToast('Dark Theme Mode');
                        appManager.theme.setMode(ThemeMode.dark);
                      },
                      child: const Text('Dark Theme Mode'),
                    ),
                    TextButton(
                      onPressed: () {
                        final Map<String, dynamic> json =
                            appManager.blocDesignSystem.exportToJson();
                        appManager.notifications.showToast(
                          'Export DS JSON keys: ${json.keys.join(', ')}',
                        );
                      },
                      child: const Text('Export DS JSON (keys)'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AclCard extends StatelessWidget {
  const _AclCard({required this.appManager});
  final JdsAppManager appManager;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tok = _safeTokens(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tok.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('ACL', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: tok.spacingSm),
            const Text('Policies: viewer / editor / admin (deny-by-default)'),
            SizedBox(height: tok.spacing),
            Wrap(
              spacing: tok.spacingSm,
              runSpacing: tok.spacingSm,
              children: <Widget>[
                FilledButton(
                  onPressed: () => appManager.pushWithAcl(
                    ViewerPage.pageModel,
                    policyId: DemoPolicies.viewer,
                    forbiddenPage: ForbiddenPage.pageModel,
                  ),
                  child: const Text('Go Viewer'),
                ),
                FilledButton(
                  onPressed: () => appManager.pushWithAcl(
                    EditorPage.pageModel,
                    policyId: DemoPolicies.editor,
                    forbiddenPage: ForbiddenPage.pageModel,
                  ),
                  child: const Text('Go Editor'),
                ),
                FilledButton(
                  onPressed: () => appManager.pushWithAcl(
                    AdminPage.pageModel,
                    policyId: DemoPolicies.admin,
                    forbiddenPage: ForbiddenPage.pageModel,
                  ),
                  child: const Text('Go Admin'),
                ),
              ],
            ),
            SizedBox(height: tok.spacingLg),
            Text('UI gating', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: tok.spacingSm),
            _AclGate(
              appManager: appManager,
              policyId: DemoPolicies.admin,
              child: FilledButton(
                onPressed: () => appManager.notifications
                    .showToast('Botón SOLO admin visible'),
                child: const Text('Admin-only button'),
              ),
            ),
            SizedBox(height: tok.spacingLg),
            Text(
              'executeWithAcl',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tok.spacingSm),
            OutlinedButton(
              onPressed: () async {
                final Either<ErrorItem, Unit> r =
                    await appManager.executeWithAcl<Unit>(
                  policyId: DemoPolicies.editor,
                  action: () async {
                    await Future<void>.delayed(
                      const Duration(milliseconds: 120),
                    );
                    return Right<ErrorItem, Unit>(unit);
                  },
                );

                r.when(
                  (ErrorItem e) =>
                      appManager.notifications.showToast('DENIED: ${e.title}'),
                  (_) => appManager.notifications
                      .showToast('OK: operación ejecutada'),
                );
              },
              child: const Text('Execute (editor+)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AclGate extends StatelessWidget {
  const _AclGate({
    required this.appManager,
    required this.policyId,
    required this.child,
  });

  final JdsAppManager appManager;
  final String policyId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool allowed = appManager.blocAcl.canRenderWithAcl(policyId);
    return allowed ? child : const SizedBox.shrink();
  }
}

/// ---------------------------------------------------------------------------
/// SAFE TOKENS helper
/// ---------------------------------------------------------------------------

ModelDsExtendedTokens _safeTokens(BuildContext context) {
  try {
    return context.dsTokens;
  } catch (_) {
    return const ModelDsExtendedTokens();
  }
}

/// ---------------------------------------------------------------------------
/// MENUS (para SessionAppManager)
/// ---------------------------------------------------------------------------

void _setupMenusForLoggedOut(AbstractAppManager app) {
  app.secondaryMenu.clearSecondaryDrawer();
  app.mainMenu.clearMainDrawer();

  app.mainMenu.addMainMenuOption(
    label: 'Home Public',
    iconData: Icons.home_outlined,
    onPressed: () => app.pageManager.resetTo(HomePublicPage.pageModel),
  );
  app.mainMenu.addMainMenuOption(
    label: 'Login',
    iconData: Icons.login,
    onPressed: () => app.pushModel(LoginPage.pageModel),
  );
}

void _setupMenusForLoggedIn(AbstractAppManager app) {
  final JdsAppManager jds = app as JdsAppManager;

  app.secondaryMenu.clearSecondaryDrawer();
  app.mainMenu.clearMainDrawer();

  app.mainMenu.addMainMenuOption(
    label: 'Home Auth',
    iconData: Icons.home,
    onPressed: () => app.pageManager.resetTo(HomeAuthenticatedPage.pageModel),
  );
  app.mainMenu.addMainMenuOption(
    label: 'Viewer',
    iconData: Icons.remove_red_eye_outlined,
    onPressed: () => jds.pushWithAcl(
      ViewerPage.pageModel,
      policyId: DemoPolicies.viewer,
      forbiddenPage: ForbiddenPage.pageModel,
    ),
  );
  app.mainMenu.addMainMenuOption(
    label: 'Editor',
    iconData: Icons.edit_outlined,
    onPressed: () => jds.pushWithAcl(
      EditorPage.pageModel,
      policyId: DemoPolicies.editor,
      forbiddenPage: ForbiddenPage.pageModel,
    ),
  );
  app.mainMenu.addMainMenuOption(
    label: 'Admin',
    iconData: Icons.admin_panel_settings_outlined,
    onPressed: () => jds.pushWithAcl(
      AdminPage.pageModel,
      policyId: DemoPolicies.admin,
      forbiddenPage: ForbiddenPage.pageModel,
    ),
  );
  app.mainMenu.addMainMenuOption(
    label: 'Sign out',
    iconData: Icons.logout,
    onPressed: () async {
      final Either<ErrorItem, void>? r = await jds.blocSession.logOut();
      if (r == null) {
        jds.pageManager.resetTo(SessionClosedPage.pageModel);
        _setupMenusForLoggedOut(jds);
        return;
      }
      r.fold(
        (ErrorItem e) => jds.notifications.showToast(e.title),
        (_) {
          _setupMenusForLoggedOut(jds);
          jds.pageManager.resetTo(SessionClosedPage.pageModel);
        },
      );
    },
  );
}

/// ---------------------------------------------------------------------------
/// APP BOOTSTRAP (registry + manager + onboarding + runApp)
/// ---------------------------------------------------------------------------

const SessionPages sessionPages = SessionPages(
  splash: SplashPage.pageModel,
  homePublic: HomePublicPage.pageModel,
  login: LoginPage.pageModel,
  homeAuthenticated: HomeAuthenticatedPage.pageModel,
  sessionClosed: SessionClosedPage.pageModel,
  authenticating: AuthenticatingPage.pageModel,
  sessionError: SessionErrorPage.pageModel,
);

JdsAppManager buildAppManager(PageManager pageManager, PageRegistry registry) {
  // Theme mínimo requerido por AppConfig.
  final RepositoryTheme repositoryTheme = RepositoryThemeForExample();
  final BlocTheme blocTheme =
      BlocTheme(themeUsecases: ThemeUsecases.fromRepo(repositoryTheme));

  // Design System inicial (fallback).
  final ModelDesignSystem initialDs = ModelDesignSystem(
    theme: ModelDesignSystem.fromThemeData(
      lightTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
    ),
    tokens: const ModelDsExtendedTokens(),
    semanticLight: ModelSemanticColors.fallbackLight(),
    semanticDark: ModelSemanticColors.fallbackDark(),
    dataViz: ModelDataVizPalette.fallback(),
  );

  final BlocDesignSystem blocDs = BlocDesignSystem(initialDs);
  final BlocAclDemo blocAcl =
      BlocAclDemo(initialEmail: 'viewer@jocaaguraarchetype.com');

  final _FakeRepositoryAuth repoAuth = _FakeRepositoryAuth();
  final BlocSession blocSession =
      BlocSession.fromRepository(repository: repoAuth);

  // Onboarding (Splash manda: mientras top==Splash, SessionAppManager no toca).
  final BlocOnboarding onboarding = BlocOnboarding()
    ..configure(<OnboardingStep>[
      const OnboardingStep(
        title: 'Boot',
        description: 'Inicializando…',
        autoAdvanceAfter: Duration(milliseconds: 200),
      ),
      OnboardingStep(
        title: 'Import DS',
        description: 'Cargando Design System…',
        onEnter: () async {
          final ModelDesignSystem? parsed = parseDsJsonOrNull(kDsJson);
          if (parsed != null) {
            blocDs.setNewDs(parsed);
          }
          return Right<ErrorItem, Unit>(unit);
        },
        autoAdvanceAfter: const Duration(milliseconds: 200),
      ),
      OnboardingStep(
        title: 'Session',
        description: 'Verificando sesión…',
        onEnter: () async {
          await blocSession.boot();
          return Right<ErrorItem, Unit>(unit);
        },
        autoAdvanceAfter: const Duration(milliseconds: 200),
      ),
      OnboardingStep(
        title: 'Finish',
        description: 'Entrando…',
        onEnter: () {
          pageManager.replaceTop(HomePublicPage.pageModel);
          return Right<ErrorItem, Unit>(unit);
        },
      ),
    ]);

  final AppConfig cfg = AppConfig(
    pageManager: pageManager,
    blocTheme: blocTheme,
    blocResponsive: BlocResponsive(),
    blocLoading: BlocLoading(),
    blocUserNotifications: BlocUserNotifications(),
    blocOnboarding: onboarding,
    blocMainMenuDrawer: BlocMainMenuDrawer(),
    blocSecondaryMenuDrawer: BlocSecondaryMenuDrawer(),
    blocModuleList: <String, BlocModule>{
      BlocDesignSystem.name: blocDs,
      BlocAclDemo.name: blocAcl,
      BlocSession.name: blocSession,
    },
  );

  return JdsAppManager(
    cfg,
    unauthorizedErrorBuilder: () => const ErrorItem(
      title: 'UNAUTHORIZED',
      code: '401',
      description: 'No tienes permisos para esta acción (ACL).',
    ),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Registry (desde PageDef => evita lios de rutas).
  final List<PageDef> defs = <PageDef>[
    PageDef(
      model: SplashPage.pageModel,
      builder: (_, __) => const SplashPage(),
    ),
    PageDef(
      model: HomePublicPage.pageModel,
      builder: (_, __) => const HomePublicPage(),
    ),
    PageDef(model: LoginPage.pageModel, builder: (_, __) => const LoginPage()),
    PageDef(
      model: HomeAuthenticatedPage.pageModel,
      builder: (_, __) => const HomeAuthenticatedPage(),
    ),
    PageDef(
      model: SessionClosedPage.pageModel,
      builder: (_, __) => const SessionClosedPage(),
    ),
    PageDef(
      model: AuthenticatingPage.pageModel,
      builder: (_, __) => const AuthenticatingPage(),
    ),
    PageDef(
      model: SessionErrorPage.pageModel,
      builder: (_, __) => const SessionErrorPage(),
    ),
    PageDef(
      model: ForbiddenPage.pageModel,
      builder: (_, __) => const ForbiddenPage(),
    ),
    PageDef(
      model: ViewerPage.pageModel,
      builder: (_, __) => const ViewerPage(),
    ),
    PageDef(
      model: EditorPage.pageModel,
      builder: (_, __) => const EditorPage(),
    ),
    PageDef(model: AdminPage.pageModel, builder: (_, __) => const AdminPage()),
  ];

  final PageRegistry registry =
      PageRegistry.fromDefs(defs, defaultPage: HomePublicPage.pageModel);

  final PageManager pageManager =
      PageManager(initial: NavStackModel.single(SplashPage.pageModel));

  final JdsAppManager appManager = buildAppManager(pageManager, registry);

  // Start onboarding si top == splash (como en el ejemplo oficial).
  if (pageManager.stack.top == SplashPage.pageModel) {
    appManager.onboarding.start();
  }

  final BlocSession sessionBloc =
      appManager.requireModuleByKey<BlocSession>(BlocSession.name);

  runApp(
    JocaaguraAppWithSession(
      appManager: appManager,
      registry: registry,
      sessionBloc: sessionBloc,
      sessionPages: sessionPages,
      seedInitialFromPageManager: true,
      initialLocation: SplashPage.pageModel.toUriString(),
      configureMenusForLoggedIn: _setupMenusForLoggedIn,
      configureMenusForLoggedOut: _setupMenusForLoggedOut,
    ),
  );
}
