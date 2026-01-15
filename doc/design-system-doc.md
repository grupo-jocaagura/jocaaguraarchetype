
# Design System

Este documento resume el avance del Design System basado en `jocaaguraarchetype`, con foco en:
- **Tokens** (spacing, radius, elevation, alpha, animaciones)
- **Theme model** (ColorScheme + TextTheme con JSON round-trip)
- **Component themes** (botones, inputs, cards, dialogs, etc.)
- Preparación para **colores semánticos** y **DataViz** (Issue 3)

---

## 0) Objetivo

Tener un **Design System centralizado**, donde:
- El diseño se decide **una sola vez** en un builder.
- `ThemeData` y tokens se aplican globalmente.
- La UI **no** define estilos inline por pantalla.
- Los modelos soportan **persistencia** (JSON round-trip).

---

## 1) Tokens extendidos (fundations)

### 1.1 ¿Qué es `ModelDsExtendedTokens`?

Un conjunto de tokens “base” (foundation) que se usan para decisiones visuales repetibles:
- Espaciados (`spacing*`)
- Radios (`borderRadius*`)
- Elevaciones (`elevation*`)
- Intensidades de transparencia (`withAlpha*`)
- Duraciones de animación (`animationDuration*`)

### 1.2 Valores por defecto recomendados

Los defaults actuales son coherentes para Material 3:
- spacing: 4, 8, 16, 24, 32, 64
- radius: 2, 4, 8, 12, 16, 24
- elevation: 0, 1, 3, 6, 9, 12
- alpha (para opacidad): 0.04, 0.12, 0.16, 0.24, 0.32, 0.40
- durations: 100ms / 300ms / 800ms

✅ Lo importante: `_validate()` asegura rangos y progresión ascendente.

### 1.3 Uso recomendado de `withAlpha*` (sin deprecations)

En Flutter moderno, evita `withOpacity` si te marca deprecation:
- Preferible: `color.withValues(alpha: x)` (si tu versión lo soporta)
- Alternativa: `color.withOpacity(x)` (si tu Flutter aún no tiene `withValues`)

Ejemplo:
```dart
final Color overlay = theme.colorScheme.primary.withValues(
  alpha: context.dsTokens.withAlphaSm,
);
```

---

## 2) Modelo de tema: `ModelThemeData`

### 2.1 ¿Qué resuelve?

`ModelThemeData` guarda lo esencial para construir `ThemeData`:

* `ColorScheme` (light / dark)
* `TextTheme` (light / dark)
* `useMaterial3`

✅ Incluye JSON round-trip estricto (keys, validaciones y parsing).

### 2.2 Construcción de ThemeData

Uso típico:

```dart
final ThemeData theme = modelThemeData.toThemeData(
  brightness: Brightness.light,
);
```

### 2.3 Crear `ModelThemeData` desde `ThemeData`

Útil para “capturar” un theme existente y persistirlo en JSON:

```dart
final ModelThemeData model = ModelThemeData.fromThemeData(
  lightTheme: myLightTheme,
  darkTheme: myDarkTheme,
);
```

---

## 3) Tipografía Google Fonts (sin complicaciones)

Sí, se puede. La recomendación para un Design System estable es **self-host** de la fuente (sin paquetes).

### 3.1 Opción recomendada: self-host (offline, determinístico)

1. Descarga `.ttf/.otf` (ej: Inter, Roboto Flex, Poppins).
2. Declárala en `pubspec.yaml`.
3. Aplica `fontFamily` al `TextTheme`.

Helper recomendado:

```dart
TextTheme withFontFamily(TextTheme base, String fontFamily) {
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

✅ Ventajas:

* No dependes de red.
* Reproducible en CI/CD.
* `ModelThemeData.toJson()` lo soporta: `fontFamily` y `fontFamilyFallback` son serializables.

---

## 4) Component Themes (Material 3)

### 4.1 Meta

Construir un `ThemeData` completo por componente, para que:

* TextField, Buttons, Cards, Dialogs, etc. se vean consistentes.
* No sea necesario re-estilizar pantalla a pantalla.
* Las decisiones dependan de tokens.

### 4.2 Builder central (composer)

Se recomienda un builder tipo:

* Input: `ModelDesignSystem` + `Brightness`
* Output: `ThemeData`

Incluye al menos:

* `InputDecorationTheme`
* `FilledButtonThemeData`, `OutlinedButtonThemeData`, `TextButtonThemeData`
* `CardThemeData`, `DialogThemeData`, `BottomSheetThemeData`
* `SnackBarThemeData`, `TooltipThemeData`
* `NavigationBarThemeData` / `NavigationRailThemeData` según plataforma
* Soporte de focus/outline (desktop)

### 4.3 “No estilos inline” en demo

La demo debe mostrar:

* TextField: normal/error/disabled
* Buttons: filled/outlined/text + disabled
* Card + ListTile
* SnackBar + Tooltip
* Navigation (bar/rail)

✅ Validación de cierre:

* `flutter analyze` sin errores
* Demo sin excepciones
* Componentes estilizados únicamente por ThemeData

---

## 5) Uso en app (guía para implementadores)

### 5.1 Instanciar el DS

```dart
final ModelDesignSystem ds = ModelDesignSystem(
  theme: yourModelThemeData,
  tokens: const ModelDsExtendedTokens(),
);
```

### 5.2 Aplicar en MaterialApp

```dart
final materialApp =
  MaterialApp(
    theme: ds.toThemeData(brightness: Brightness.light),
    darkTheme: ds.toThemeData(brightness: Brightness.dark),
    themeMode: ThemeMode.system,
    home: const HomePage(),
  );


```

### 5.3 Usar tokens en widgets (sin hardcode)

```dart
final double gap = context.dsTokens.spacingSm;
```

Recomendación: usar tokens para:

* `Padding` / `SizedBox`
* `BorderRadius`
* `elevation`
* `durations` de animación
* overlay alpha (hover/focus/pressed)

---

## 6) Colores semánticos + DataViz (estado)

**Meta:** completar semántica de dominio que no cubre `ColorScheme`.

### 6.1 ModelSemanticColors (success / warning / info)

Debe incluir:

* success / onSuccess / successContainer / onSuccessContainer
* warning / onWarning / warningContainer / onWarningContainer
* info / onInfo / infoContainer / onInfoContainer

### 6.2 ModelDataVizPalette

Paletas:

* categorical (series discretas)
* sequential (gradientes)

### 6.3 Validaciones mínimas

* Contraste razonable manual en claro/oscuro
* Demo con chips/banners para cada semántico en ambos temas
* JSON round-trip + tests

### 6.4 Guía rápida de uso (reglas simples)

* **primary**: acciones principales y navegación.
* **success**: confirmación de operación (backend ok, guardado, “listo”).
* **warning**: atención/precaución (no bloqueante, pero requiere acción).
* **info**: contextual (estado informativo, ayuda, banners suaves).
* **error**: se mantiene en `ColorScheme.error` (Material).

### 6.5 Ejemplo para implementadores

```dart
Widget build(BuildContext context) {
  final ModelSemanticColors s = context.dsSemantic;

  Widget chip(Color bg, Color fg, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(context.dsTokens.borderRadius),
      ),
      child: Text(label, style: TextStyle(color: fg)),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Wrap(
        spacing: context.dsTokens.spacingSm,
        runSpacing: context.dsTokens.spacingSm,
        children: <Widget>[
          chip(s.success, s.onSuccess, 'Success'),
          chip(s.successContainer, s.onSuccessContainer, 'Success Container'),
          chip(s.warning, s.onWarning, 'Warning'),
          chip(s.warningContainer, s.onWarningContainer, 'Warning Container'),
          chip(s.info, s.onInfo, 'Info'),
          chip(s.infoContainer, s.onInfoContainer, 'Info Container'),
        ],
      ),
    ],
  );
}
```


`ModelDataVizPalette` es, dentro del sistema de diseño, **la “paleta oficial para datos”**: un conjunto de colores pensado específicamente para **gráficas, dashboards, tablas, heatmaps y series**. No reemplaza al `ColorScheme`; lo complementa.

## Por qué `ColorScheme` no alcanza para DataViz

`ColorScheme` está hecho para UI general: fondo, texto, primary, error, etc.
Pero en DataViz necesitas otras reglas:

* **Diferenciar muchas series** (10, 12, 20…) sin que se confundan.
* Mantener **legibilidad sobre fondos claros y oscuros**.
* Garantizar **consistencia**: “la serie A siempre es este color”.
* Evitar colores que se vean bien en botones pero se vean mal en una gráfica (por ejemplo, saturaciones o contrastes incorrectos).

Ahí entra `ModelDataVizPalette`.

## Qué contiene típicamente `ModelDataVizPalette`

Normalmente tiene dos familias:

### 1) Categorical (series discretas)

Para gráficas donde cada serie es un “grupo” distinto:

* barras por categoría
* líneas por región
* pastel/donut
* leyendas con varios ítems

Ejemplo mental: “Ventas por ciudad” → cada ciudad necesita un color distinto.

👉 Importante: aquí necesitas una lista de colores **equidistantes visualmente**, para que no parezcan “casi iguales”.

### 2) Sequential (gradientes)

Para valores continuos o intensidades:

* heatmaps
* mapas de calor
* barras de progreso por rango
* métricas “de menor a mayor”

Ejemplo mental: “nivel de riesgo 0..100” → del más suave al más intenso.

👉 Importante: debe funcionar como escala perceptual: que “más” se sienta realmente más.

## Por qué es importante para construir marca

Una marca no es solo el logo o el primary. También es:

* **Cómo se ve un dashboard**
* Cómo se distingue “lo importante”
* Cómo se percibe el producto cuando hay datos

Si cada equipo elige colores distintos para gráficas, pasa esto:

* un mismo KPI se ve diferente en cada pantalla
* la lectura cambia según el color elegido
* se pierde “coherencia visual” y se ve “hecho por partes”

Con `ModelDataVizPalette` logras:

* **consistencia** entre módulos y equipos
* **reconocimiento**: “así se ven nuestras métricas”
* **confianza**: dashboards más limpios y profesionales
* **accesibilidad práctica** (menos confusión entre colores)

## Cómo se usa en UI (idea simple)

Con el approach de DS:

* `context.dsDataViz.categoricalAt(i)` → color i de series
* `context.dsDataViz.sequentialAt(t)` → color para un valor normalizado 0..1

Entonces el implementador no “inventa” colores:
solo pide el color que corresponde.


---

## 7) Qué sigue (Issue 4 — sugerido)

Una vez listo Issue 3, lo natural es:

* `ModelDesignSystem` como agregador final:

    * theme + tokens + semantic + dataviz
* Helpers de acceso desde `BuildContext`
* Página “catalog” tipo preview (componente → decisiones)
* Documentación de “Componente → decisiones (shape/padding/typography/states)”
