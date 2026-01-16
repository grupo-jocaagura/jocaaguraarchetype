# Sistema de diseño guía rápida de inicio

Este documento resume el avance del Design System basado en `jocaaguraarchetype`, con foco en:

* **Tokens**: spacing, radius, elevation, alpha, animaciones.
* **Theme model**: ColorScheme + TextTheme con JSON round-trip.
* **Component themes**: botones, inputs, cards, dialogs, etc. (Material 3).
* **Semánticos + DataViz**: colores de dominio y paletas para visualización.

---

## 0) Objetivo y reglas de oro

Queremos un **Design System centralizado**, donde:

* El diseño se decide **una sola vez** (en el builder/composer).
* `ThemeData` y tokens se aplican **globalmente**.
* La UI **no define estilos inline** por pantalla.
* Los modelos soportan **persistencia** (JSON round-trip).

### Reglas rápidas de uso

* **UI / navegación / acciones** → `ColorScheme` (primary/secondary/error/etc).
* **Estados de dominio** → `SemanticColors` (success/warning/info).
* **Datos y gráficas** → `DataVizPalette` (categorical/sequential).

---

## 1) Cómo adoptar el DS en una app

### 1.1 Instanciar el DS

```dart
final ModelDesignSystem ds = ModelDesignSystem(
  theme: yourModelThemeData,
  tokens: const ModelDsExtendedTokens(),
  // semantic: const ModelSemanticColors(...),
  // dataViz: const ModelDataVizPalette(...),
);
```

> Nota: si `semantic` y `dataViz` ya viven dentro del DS en tu versión, mantenlos ahí; si no, agrégalos en el constructor según tu implementación.

### 1.2 Aplicar en `MaterialApp`

```dart
final materialApp = MaterialApp(
  theme: ds.toThemeData(brightness: Brightness.light),
  darkTheme: ds.toThemeData(brightness: Brightness.dark),
  themeMode: ThemeMode.system,
  home: const HomePage(),
);
```

### 1.3 Usar tokens en widgets (sin hardcode)

```dart
final double gap = context.dsTokens.spacingSm;
```

---

## 2) Tokens extendidos (Foundations)

### 2.1 ¿Qué es `ModelDsExtendedTokens`?

Tokens “base” (foundation) usados para decisiones visuales repetibles:

* Espaciados: `spacing*`
* Radios: `borderRadius*`
* Elevaciones: `elevation*`
* Intensidades de overlay: `withAlpha*` (0..1)
* Duraciones: `animationDuration*`

### 2.2 Defaults actuales (coherentes con Material 3)

* spacing: `4, 8, 16, 24, 32, 64`
* radius: `2, 4, 8, 12, 16, 24`
* elevation: `0, 1, 3, 6, 9, 12`
* withAlpha: `0.04, 0.12, 0.16, 0.24, 0.32, 0.40`
* durations: `100ms / 300ms / 800ms`

✅ `_validate()` asegura:

* no negativos (spacing/radius/elevation)
* `withAlpha` dentro de 0..1
* progresión ascendente

### 2.3 Cómo aplicar `withAlpha` (sin deprecations)

* Preferible: `color.withValues(alpha: x)` (si tu Flutter lo soporta)
* Alternativa: `color.withOpacity(x)` (si tu versión aún no tiene `withValues`)

```dart
final Color overlay = Theme.of(context).colorScheme.primary.withValues(
  alpha: context.dsTokens.withAlphaSm,
);
```

---

## 3) Modelo de tema: `ModelThemeData`

### 3.1 ¿Qué resuelve?

`ModelThemeData` guarda lo esencial para construir `ThemeData`:

* `ColorScheme` (light / dark)
* `TextTheme` (light / dark)
* `useMaterial3`

✅ Incluye JSON round-trip estricto (keys, validaciones y parsing).

### 3.2 Construcción de ThemeData

```dart
final ThemeData theme = modelThemeData.toThemeData(
  brightness: Brightness.light,
);
```

### 3.3 Capturar `ThemeData` → `ModelThemeData`

Útil para importar un theme externo y volverlo exportable como JSON:

```dart
final ModelThemeData model = ModelThemeData.fromThemeData(
  lightTheme: myLightTheme,
  darkTheme: myDarkTheme,
);
```

---

## 4) Tipografía (Google Fonts sin complicaciones)

Para un Design System estable, la recomendación es **self-host** (sin paquetes):

1. Descarga `.ttf/.otf` (Inter, Roboto Flex, Poppins, etc.)
2. Declárala en `pubspec.yaml`
3. Aplica `fontFamily` al `TextTheme`

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

* offline / determinístico
* reproducible en CI/CD
* serializable por `ModelThemeData` (fontFamily/fallback)

---

## 5) Component Themes (Material 3)

### 5.1 Meta

Construir un `ThemeData` completo por componente para que:

* TextField, Buttons, Cards, Dialogs, etc. se vean consistentes
* no haya que re-estilizar pantalla a pantalla
* las decisiones dependan de tokens

### 5.2 Componentes mínimo-indispensables (lo que la demo debe cubrir)

**Inputs**

* TextField / InputDecoration (normal, focused, error, disabled)
* DropdownMenu / MenuStyle (si aplica)

**Actions**

* FilledButton / OutlinedButton / TextButton / ElevatedButton
* IconButton
* FloatingActionButton (si tu producto lo usa)

**Surfaces**

* Card + ListTile (con shape consistente)
* Dialog / BottomSheet
* Divider

**Feedback**

* SnackBar
* Tooltip
* ProgressIndicator (al menos guideline de uso)

**Navigation**

* AppBar
* NavigationBar / NavigationRail (según plataforma)
* Drawer (si aplica)

> Regla: si el producto “vive” en desktop/web, incluye también focus/hover.

### 5.3 Validación de “no estilos inline”

✅ La demo debe mostrar:

* TextField: normal / error / disabled
* Buttons: filled / outlined / text + disabled
* Card + ListTile
* SnackBar + Tooltip
* Navigation (bar/rail)

✅ Cierre técnico:

* `flutter analyze` sin errores
* demo sin excepciones
* componentes estilizados únicamente por `ThemeData`

---

## 6) Semánticos + DataViz (ya incluidos en el DS)

### 6.1 Qué problema resuelven

`ColorScheme` cubre roles Material (primary, surface, error…), pero producto necesita:

* **Semántica de dominio**: success / warning / info (y sus “on” y containers)
* **Paletas de datos**: colores para gráficas y dashboards

La idea es que la UI no “invente colores” por pantalla.

### 6.2 `ModelSemanticColors`

Debe incluir:

* success / onSuccess / successContainer / onSuccessContainer
* warning / onWarning / warningContainer / onWarningContainer
* info / onInfo / infoContainer / onInfoContainer

**Reglas simples**

* `primary`: acciones principales y navegación
* `success`: confirmación (guardado ok, backend ok, “listo”)
* `warning`: atención/precaución (no bloqueante, requiere acción)
* `info`: contexto/ayuda/banners suaves
* `error`: se mantiene en `ColorScheme.error`

### 6.3 `ModelDataVizPalette`

`ModelDataVizPalette` es la “paleta oficial para datos”:

* **categorical**: series discretas (barras por categoría, múltiples líneas, leyendas)
* **sequential**: gradientes (heatmaps, intensidades, escalas 0..100)

**Por qué importa**

* coherencia visual (dashboards consistentes)
* lectura clara (colores distinguibles)
* construcción de marca (así “se ven” nuestras métricas)

### 6.4 Validaciones mínimas

* contraste razonable manual en claro/oscuro
* demo con chips/banners para success/warning/info en ambos temas
* JSON round-trip + tests

### 6.5 Ejemplo de uso (implementadores)

```dart
Widget build(BuildContext context) {
  final ModelSemanticColors s = context.dsSemantic;
  final ModelDsExtendedTokens t = context.dsTokens;

  Widget chip(Color bg, Color fg, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: t.spacing, vertical: t.spacingSm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(t.borderRadius),
      ),
      child: Text(label, style: TextStyle(color: fg)),
    );
  }

  return Wrap(
    spacing: t.spacingSm,
    runSpacing: t.spacingSm,
    children: <Widget>[
      chip(s.success, s.onSuccess, 'Success'),
      chip(s.successContainer, s.onSuccessContainer, 'Success Container'),
      chip(s.warning, s.onWarning, 'Warning'),
      chip(s.warningContainer, s.onWarningContainer, 'Warning Container'),
      chip(s.info, s.onInfo, 'Info'),
      chip(s.infoContainer, s.onInfoContainer, 'Info Container'),
    ],
  );
}
```

---

## 7) Checklist de adopción (implementadores)

Antes de decir “ya usamos el DS”, valida:

* [ ] App usa `MaterialApp(theme/darkTheme)` construidos desde `ModelDesignSystem`
* [ ] Tokens se consultan desde `context.dsTokens` (no hardcode)
* [ ] Semánticos se consultan desde `context.dsSemantic`
* [ ] DataViz se consulta desde `context.dsDataViz`
* [ ] Demo/catálogo no usa estilos inline en componentes base
* [ ] Export/import JSON funciona (round-trip) para theme/tokens/semantics/dataviz

---

## 8) “Do / Don’t” rápidos

✅ Do

* usar `ThemeData` para estilos globales
* usar tokens para spacing/radius/elevation/durations
* usar semánticos para estados de backend y UI de estado
* usar DataViz para gráficas/tablas

❌ Don’t

* definir `TextStyle`, `BorderRadius`, `elevation` inline por pantalla
* usar `primary` para “success” solo porque se ve bonito
* inventar colores de charts en cada módulo

---
