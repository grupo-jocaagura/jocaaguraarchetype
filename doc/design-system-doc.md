Sí, **se puede**, pero depende de *cómo* quieras “Google Fonts”:

## Opción A (recomendada para un Design System estable): **self-host** la fuente (sin paquetes)

1. Descargas los `.ttf/.otf` (por ejemplo *Inter*, *Roboto Flex*, *Poppins*).
2. Los agregas a `pubspec.yaml` (assets fonts).
3. Construyes el `TextTheme` apuntando a `fontFamily`.

Ejemplo (dentro de tu builder de `ModelThemeData`):

```dart
TextTheme _withFontFamily(TextTheme base, String fontFamily) {
  TextStyle? s(TextStyle? t) => t?.copyWith(fontFamily: fontFamily);

  return base.copyWith(
    displayLarge: s(base.displayLarge),
    displayMedium: s(base.displayMedium),
    displaySmall: s(base.displaySmall),
    headlineLarge: s(base.headlineLarge),
    headlineMedium: s(base.headlineMedium),
    headlineSmall: s(base.headlineSmall),
    titleLarge: s(base.titleLarge),
    titleMedium: s(base.titleMedium),
    titleSmall: s(base.titleSmall),
    bodyLarge: s(base.bodyLarge),
    bodyMedium: s(base.bodyMedium),
    bodySmall: s(base.bodySmall),
    labelLarge: s(base.labelLarge),
    labelMedium: s(base.labelMedium),
    labelSmall: s(base.labelSmall),
  );
}
```

✅ Ventaja: **100% determinístico**, offline, y tu `ModelThemeData.toJson()` lo soporta bien porque guarda `fontFamily` / `fontFamilyFallback`.
