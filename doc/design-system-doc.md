# Design System (jocaaguraarchetype)

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
- La UI evita estilos inline por pantalla (salvo casos justificados).
- Los modelos soportan **persistencia** (JSON round-trip).

### Regla rápida de uso

- UI / acciones / navegación → `ColorScheme` (primary/secondary/error/etc.)
- Estados de dominio → `ModelSemanticColors` (success/warning/info)
- Datos / gráficas → `ModelDataVizPalette` (categorical/sequential)

---

## 1) Tokens extendidos (foundations)

### 1.1 ¿Qué es `ModelDsExtendedTokens`?

`ModelDsExtendedTokens` define tokens base reutilizables para decisiones visuales repetibles:

- Espaciados (`spacing*`)
- Radios (`borderRadius*`)
- Elevaciones (`elevation*`)
- Intensidad de overlays (`withAlpha*`, rango 0..1)
- Duraciones de animación (`animationDuration*`)

> Importante: `_validate()` asegura rangos válidos y progresión ascendente.

### 1.2 Defaults actuales (coherentes para Material 3)

- spacing: `4, 8, 16, 24, 32, 64`
- radius: `2, 4, 8, 12, 16, 24`
- elevation: `0, 1, 3, 6, 9, 12`
- withAlpha: `0.04, 0.12, 0.16, 0.24, 0.32, 0.40`
- durations: `100ms / 300ms / 800ms`

### 1.3 Uso recomendado de `withAlpha*`

`withAlpha*` está pensado para overlays y estados (hover/focus/pressed/disabled).

- Preferible: `color.withValues(alpha: x)` (si tu Flutter lo soporta)
- Alternativa: `color.withOpacity(x)` (si tu versión aún no tiene `withValues`)

Ejemplo:

```dart
final Color overlay = Theme.of(context).colorScheme.primary.withValues(
  alpha: context.dsTokens.withAlphaSm,
);
```

---

## 2) Modelo de tema: `ModelThemeData`

### 2.1 ¿Qué resuelve?

`ModelThemeData` encapsula lo esencial para construir `ThemeData` de forma determinística:

* `ColorScheme` (light / dark)
* `TextTheme` (light / dark)
* `useMaterial3`

✅ Incluye JSON round-trip estricto (keys + parsing + validación).

### 2.2 Construcción de ThemeData

```dart
final ThemeData theme = modelThemeData.toThemeData(
  brightness: Brightness.light,
);
```

### 2.3 Crear `ModelThemeData` desde `ThemeData`

Útil para capturar un theme existente y persistirlo:

```dart
final ModelThemeData model = ModelThemeData.fromThemeData(
  lightTheme: myLightTheme,
  darkTheme: myDarkTheme,
);
```

---

## 3) Tipografía “Google Fonts” sin complicaciones (recomendado self-host)

Para un DS estable y reproducible, la recomendación es **self-host** (sin paquetes).

### 3.1 Self-host (offline, determinístico)

1. Descarga `.ttf/.otf` (ej: Inter, Roboto Flex, Poppins).
2. Declárala en `pubspec.yaml`.
3. Aplica `fontFamily` en el `TextTheme`.

Helper sugerido:

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

* No dependes de red
* Reproducible en CI/CD
* Serializable: `ModelThemeData.toJson()` conserva `fontFamily` y `fontFamilyFallback`

---

## 4) Component Themes (Material 3)

### 4.1 Meta

Construir un `ThemeData` completo por componente para evitar re-estilizar pantalla a pantalla.

Esto incluye:

* Inputs: `InputDecorationTheme`
* Buttons: `FilledButtonThemeData`, `OutlinedButtonThemeData`, `TextButtonThemeData`
* Surfaces: `CardThemeData`, `DialogThemeData`, `BottomSheetThemeData`
* Feedback: `SnackBarThemeData`, `TooltipThemeData`
* Navegación: `NavigationBarThemeData` / `NavigationRailThemeData`
* Desktop: soporte de focus/outline

### 4.2 Builder central (composer)

Se recomienda un builder:

* Input: `ModelDesignSystem` + `Brightness`
* Output: `ThemeData`

✅ Reglas:

* shapes, paddings, estados (disabled/hover/focus) salen de tokens
* no styles inline en pantallas demo

### 4.3 Validación de cierre (demo)

La demo debe renderizar sin estilos inline:

* TextField: normal / error / disabled
* Buttons: filled / outlined / text + disabled
* Card + ListTile
* SnackBar + Tooltip
* Navigation (bar/rail)

Checklist:

* `flutter analyze` sin errores
* demo sin excepciones
* decisiones solo en `ThemeData`

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
final materialApp = MaterialApp(
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

Uso recomendado de tokens:

* `Padding` / `SizedBox`
* `BorderRadius`
* `elevation`
* durations de animación
* overlay alpha (hover/focus/pressed/disabled)

---

## 6) Issue 3 — Colores semánticos + DataViz (estado)

Meta: completar semántica de dominio que no cubre `ColorScheme`.

### 6.1 `ModelSemanticColors` (success / warning / info)

Debe incluir:

* success / onSuccess / successContainer / onSuccessContainer
* warning / onWarning / warningContainer / onWarningContainer
* info / onInfo / infoContainer / onInfoContainer

### 6.2 `ModelDataVizPalette` (categorical / sequential)

`ModelDataVizPalette` es la **paleta oficial para datos**: colores pensados para gráficas, dashboards, tablas y series.
No reemplaza `ColorScheme`; lo complementa.

¿Por qué es clave?

* Mantiene consistencia: “la serie A siempre es este color”.
* Evita confusiones entre series (colores demasiado parecidos).
* Funciona bien en claro/oscuro y en superficies típicas.
* Aporta “identidad de marca” también en visualización de datos.

Dos familias:

* **categorical**: series discretas (barras por categoría, múltiples líneas, donut/pie, leyendas)
* **sequential**: gradientes (heatmaps, escalas 0..100, intensidades)

### 6.3 Validaciones mínimas

* contraste razonable manual en claro/oscuro
* demo con chips/banners para semánticos en ambos temas
* JSON round-trip + tests

### 6.4 Guía rápida de uso

* primary: acciones principales y navegación
* success: confirmación de operación (backend ok, guardado, listo)
* warning: precaución (no bloqueante, requiere atención)
* info: contextual (banners suaves, estado informativo)
* error: se mantiene en `ColorScheme.error`

---

## 7) Arquitectura de modelos (visión general)

La arquitectura del Design System se organiza en **modelos serializables** (JSON round-trip) y un **compositor** que construye `ThemeData` sin sorpresas.

### Capas (de base a experiencia)

1) **Foundations / Tokens**
   - **`ModelDsExtendedTokens`**
     - Define escalas repetibles (spacing, radius, elevation, withAlpha, durations).
     - Objetivo: que el producto tenga **proporción y consistencia** sin “magic numbers”.

2) **Tema base (Material)**
   - **`ModelThemeData`**
     - Encapsula `ColorScheme` (light/dark), `TextTheme` (light/dark) y `useMaterial3`.
     - Objetivo: que el look & feel Material sea **determinístico** y persistible.

3) **Semántica de dominio**
   - **`ModelSemanticColors`**
     - success / warning / info (+ sus on* y container*).
     - Objetivo: cubrir estados que `ColorScheme` no define “por negocio”.
     - Regla: semánticos se usan para **mensajes del dominio**, no para navegación.

4) **Data Visualization**
   - **`ModelDataVizPalette`**
     - categorical (series) / sequential (gradientes).
     - Objetivo: dashboards consistentes y “de marca” sin inventar colores por pantalla.

5) **Agregador / Entry-point del DS**
   - **`ModelDesignSystem`**
     - Agrupa los modelos anteriores y expone:
       - `toThemeData(brightness: ...)` → `ThemeData` completo
       - `toJson()` / `fromJson()` → export/import estable

### Flujo de construcción (compositor)

Cuando se llama:

```dart
final ThemeData t = ds.toThemeData(brightness: Brightness.light);
```

El DS construye el tema así:

1. **Base ThemeData**

    * `ModelThemeData.toThemeData(brightness)`
2. **Extensiones (Tokens + futuros modelos)**

    * Adjunta tokens como `ThemeExtension` para acceso vía `BuildContext`.
3. **Component Themes**

    * Aplica temas por componente (`InputDecorationTheme`, buttons, cards, dialogs, etc.)
    * Las decisiones (radius/padding/estados) salen de tokens.

### Acceso desde UI (idea objetivo)

* UI no “adivina” valores.
* UI consume el DS por `context`:

```dart
final ModelDsExtendedTokens tokens = context.dsTokens;
// (futuro) final ModelSemanticColors s = context.dsSemantic;
// (futuro) final ModelDataVizPalette p = context.dsDataViz;
```

> Nota: los tokens vía `ThemeExtension` son el “canal” recomendado para que todo se mantenga centralizado sin acoplar pantallas.



---

## 8) Glosario

## Glosario (términos del DS)

**Design System (DS)**  
Conjunto de reglas, tokens y componentes que garantizan consistencia visual y funcional en todo el producto.

**Foundation tokens**  
Valores base reutilizables (spacing, radius, elevation, opacidades, duraciones).  
Ej: `spacingSm`, `borderRadius`, `withAlphaSm`.

**ThemeData (Flutter)**  
Objeto global que define estilos por defecto del árbol de widgets (Material).  
Incluye colores, tipografía, componentes, estados, etc.

**ColorScheme (Material)**  
Mapa de colores “UI general” (primary, secondary, surface, error, outline…).  
Sirve para navegación y acciones principales. No cubre semántica de dominio.

**TextTheme (Material)**  
Conjunto de estilos tipográficos por rol (display, headline, title, body, label).  
En DS se espera que sea estable y serializable.

**Component Themes**  
Configuración global por componente (buttons, inputs, cards, dialogs…).  
Su objetivo es evitar estilos inline y mantener consistencia.

**Semánticos (Semantic Colors)**  
Colores “por significado” de dominio: success/warning/info.  
Se usan en banners, badges, toasts, estados de backend, confirmaciones, etc.

**DataViz Palette**  
Paleta especializada para visualización de datos.  
- *Categorical*: series discretas (A/B/C…).
- *Sequential*: gradiente para magnitudes (0..100).

**ThemeExtension**  
Mecanismo de Flutter para “colgar” datos extra del `ThemeData` y accederlos por `BuildContext`.  
Ideal para tokens, semánticos y DataViz sin contaminar widgets.

**Round-trip JSON**  
Garantía de que:  
`model -> toJson() -> fromJson() -> model`  
produce el mismo contenido (idealmente `==`).

**Determinístico**  
Con los mismos inputs (modelos), el DS genera el mismo `ThemeData` siempre.  
Clave para CI/CD, QA visual y consistencia entre plataformas.
---