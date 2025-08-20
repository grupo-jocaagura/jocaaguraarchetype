# JocaaguraArchetype
> 👋 ¡Hola! Antes de que sigas, te contamos que estamos migrando las responsabilidades principales de este paquete a [`jocaagura_domain`](https://pub.dev/packages/jocaagura_domain).  
> Este arquetipo seguirá disponible por ahora, pero puede ser deprecado más adelante.  
> Te invitamos a construir directamente desde `jocaagura_domain`, donde ahora están los blocs, contratos y herramientas compartidas.


> 👋 Hey there! Just a heads-up — most of the functionality from this archetype has been moved to [`jocaagura_domain`](https://pub.dev/packages/jocaagura_domain).  
> This package may be deprecated in the near future.  
> For a cleaner setup and fewer dependencies, we recommend building directly with `jocaagura_domain`, which now includes the base blocs, services, and UI contracts.

> ⚠️ **Important Notice:**  
> This package is no longer maintained as a standalone solution.  
> We strongly recommend migrating to [`jocaagura_domain`](https://pub.dev/packages/jocaagura_domain),  
> which now includes all shared infrastructure contracts and cross-cutting logic.
>
> Centralizing the effort in `jocaagura_domain` helps reduce duplication, simplifies maintenance, and avoids future package conflicts.



This package is designed to ensure that the cross-functional features of applications developed by Jocaagura are addressed at the start of each project. It provides a uniform and robust foundation for development teams, facilitating the integration and scaling of new features and functionalities.
![Coverage](https://img.shields.io/badge/coverage-86%25-brightgreen)
![Author](https://img.shields.io/badge/Author-@albertjjimenezp-brightgreen) 🐱‍👤

## Important
- Waiting for flutter to fix deprecated value, red, green and blue in Color class.

## Documentation Index

- [JocaaguraArchetype](#jocaaguraarchetype)
- [Documentation Index](#documentation-index)
  - [LabColor](#labcolor)
  - [ProviderTheme](#providertheme)
  - [ServiceTheme](#servicetheme)
  - [BlocTheme](#bloctheme)
  - [BlocLoading](#blocloading)
  - [BlocResponsive](#blocresponsive)
  - [Sistema de navegacion](#Navigation-System)
    - [Guía de Implementación de Navegación (JocaaguraArchetype)](#guía-de-implementación-de-navegación-jocaaguraarchetype)
      - [0) Conceptos](#0-conceptos)
      - [1) Wiring mínimo](#1-wiring-mínimo)
      - [2) Navegación programática (API del `PageManager`)](#2-navegación-programática-api-del-pagemanager)
      - [3) URL → PageModel (parser)](#3-url--pagemodel-parser)
      - [4) PageRegistry (404 y redirecciones)](#4-pageregistry-404-y-redirecciones)
      - [5) Projector Mode vs Stack Mode](#5-projector-mode-vs-stack-mode)
      - [6) Back button (helpers)](#6-back-button-helpers)
      - [7) Buenas prácticas](#7-buenas-prácticas)
      - [8) Anti-patrones](#8-anti-patrones)
      - [9) Checklist de integración](#9-checklist-de-integración)
      - [10) Snippets de referencia](#10-snippets-de-referencia)
  - 


## LabColor

### Description
`LabColor` is a utility class that provides methods to convert colors between different color spaces, specifically RGB and Lab (CIELAB). These methods are useful for precise color manipulations needed in custom themes, data visualization, and more.

### Parameters
- `lightness`: The brightness of the color.
- `a`: Component a in the CIELAB color space.
- `b`: Component b in the CIELAB color space.

### Example in Dart Code
```dart
Color colorRGB = Color.fromARGB(255, 255, 0, 0); // Red color
List<double> labColor = LabColor.colorToLab(colorRGB);
LabColor lab = LabColor(labColor[0], labColor[1], labColor[2]);
LabColor adjustedLab = lab.withLightness(50.0);
```

## ProviderTheme

### Description
`ProviderTheme` acts as an intermediary between theme services and UI interfaces that consume these themes. It simplifies the application of custom themes and color manipulations at the app level, ensuring a seamless and consistent visual design.

### Example in Dart Code
```dart
ColorScheme colorScheme = ColorScheme.light(primary: Color(0xFF00FF00));
TextTheme textTheme = TextTheme(bodyText1: TextStyle(color: Color(0xFF000000)));
ProviderTheme providerTheme = ProviderTheme(ServiceTheme());
ThemeData customTheme = providerTheme.customThemeFromColorScheme(colorScheme, textTheme);
```

## ServiceTheme

### Description
`ServiceTheme` provides a range of methods for creating and manipulating themes and colors. It includes functions to convert RGB colors to `MaterialColor`, darken and lighten colors, and generate custom themes from color schemes. This is fundamental for managing the visual appearance of applications.

### Example in Dart Code
```dart
ServiceTheme serviceTheme = ServiceTheme();
MaterialColor materialColor = serviceTheme.materialColorFromRGB(255, 0, 0); // Red color
```

## BlocTheme

### Description
`BlocTheme` is a BLoC (Business Logic Component) module that manages the theme state within the application. It enables dynamic theme updates, allowing the UI to adapt to user preferences or specific conditions, such as switching between light and dark modes.

### Example in Dart Code
```dart
void main() {
  ColorScheme lightScheme = ColorScheme.light();
  ColorScheme darkScheme = ColorScheme.dark();
  TextTheme textTheme = TextTheme(bodyText1: TextStyle(color: Colors.white));

  bool isDarkMode = true; // User preference
  ThemeData themeToUpdate = isDarkMode
      ? blocTheme.providerTheme.serviceTheme.customThemeFromColorScheme(darkScheme, textTheme, true)
      : blocTheme.providerTheme.serviceTheme.customThemeFromColorScheme(lightScheme, textTheme, false);

  blocTheme._themeDataController.value = themeToUpdate;
}
```

## BlocLoading

### Description
`BlocLoading` is a BLoC component that manages loading messages within the application. It provides a centralized way to display and update loading status messages, which is useful for informing users about ongoing operations.

### Example in Dart Code
```dart
void main() async {
  await blocLoading.loadingMsgWithFuture(
      "Loading data...",
      () async {
        await Future.delayed(Duration(seconds: 2)); // Simulated data loading operation
      });
}
```

## BlocResponsive

### Description
`BlocResponsive` is a crucial component for managing adaptive UI in an application. This BLoC facilitates handling screen sizes and component visibility, ensuring the app adjusts optimally to different resolutions and devices.

### Example in Dart Code
```dart
Widget responsiveWidget = AspectRatio(
  aspectRatio: 16 / 9,
  child: Container(
    width: blocResponsive.widthByColumns(4),
    decoration: BoxDecoration(color: Colors.blue),
  ),
);
```

---

This README has been restructured and translated to provide a comprehensive yet concise guide to the **JocaaguraArchetype** package for its audience on **pub.dev**.
If additional sections or examples are required, they can be added based on specific needs. 🐱‍👤
# Navigation System
## Guía de Implementación de Navegación (JocaaguraArchetype)

> **Recomendación clave**: para la mayoría de apps usa **`projectorMode: true`** en el `MyAppRouterDelegate`.
> Renderiza **solo la página del tope** del stack → menos árbol de widgets, menos reprocesamiento, mejor rendimiento.
> (Igual mantienes un **back-stack lógico** en el `PageManager`).

---

## 0) Conceptos

* **PageModel**: representación **lógica** de una vista/página (ocupa toda la pantalla).

  * `name`, `segments`, `query`, `kind`, `requiresAuth`, `state`.
* **NavStackModel**: **estado inmutable** del back-stack (`List<PageModel> pages`).
* **PageManager**: BLoC de navegación. Expone `stackStream`, `push/pop/replace/reset`, helpers named y serialización.
* **PageWidgetBuilder**: `(BuildContext, PageModel) => Widget`.
* **PageRegistry**: diccionario `name → builder` + políticas para *unknown routes* (404/redirect).
* **Router 2.0**:

  * `MyAppRouterDelegate`: escucha al `PageManager` y materializa `Page`s (Navigator).
  * `MyRouteInformationParser`: parsea una `Uri` → `NavStackModel`.

---

## 1) Wiring mínimo

```dart
import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// 1) PageRegistry (const si es posible)
final PageRegistry registry = PageRegistry(
  <String, PageWidgetBuilder>{
    HomePage.pageModel.name: (ctx, page) => const HomePage(),
    DetailsPage.pageModel.name: (ctx, page) => DetailsPage(id: page.segments.elementAtOrNull(0)),
  },
  // Opcional: comportamiento por defecto si no existe la ruta
  defaultPage: HomePage.pageModel, // o defaultStack: NavStackModel(...)
);

// 2) PageManager (estado inicial)
final PageManager page = PageManager(
  initial: NavStackModel.single(HomePage.pageModel),
);

// 3) RouterDelegate + Parser
final MyAppRouterDelegate routerDelegate = MyAppRouterDelegate(
  registry: registry,
  pageManager: page,
  projectorMode: true, // ✅ recomendado
);

final MyRouteInformationParser routeParser = MyRouteInformationParser(
  defaultRouteName: HomePage.pageModel.name,
  // Opcional: convierte slug -> name (kebab-case → camelCase)
  slugToName: (s) => s.replaceAllMapped(RegExp(r'-(\w)'), (m) => m[1]!.toUpperCase()),
);

// 4) MaterialApp.router
void main() {
  runApp(MaterialApp.router(
    title: 'Demo',
    theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
    routerDelegate: routerDelegate,
    routeInformationParser: routeParser,
  ));
}
```

### Ejemplo de páginas (recomendado: `PageModel` dentro de cada pantalla)

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const PageModel pageModel = PageModel(name: 'home', segments: <String>['/']);
  @override
  Widget build(BuildContext context) {
    final page = context.appManager.page;
    return Scaffold(
      appBar: AppBar(title: StreamBuilder<String>(
        stream: page.currentTitleStream,
        initialData: page.currentTitle,
        builder: (_, s) => Text(s.data ?? 'Home'),
      )),
      body: Center(
        child: ElevatedButton(
          onPressed: () => page.pushNamed(DetailsPage.pageModel.name, segments: const ['42']),
          child: const Text('Ir a detalles (id=42)'),
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key, this.id});
  final String? id;
  static const PageModel pageModel = PageModel(name: 'details', segments: <String>['details']);
  @override
  Widget build(BuildContext context) {
    final page = context.appManager.page;
    return Scaffold(
      appBar: AppBar(
        leading: const NavBackButton(), // helper listo (abajo)
        title: StreamBuilder<String>(
          stream: page.currentTitleStream,
          initialData: page.currentTitle,
          builder: (_, s) => Text(s.data ?? 'Detalles'),
        ),
      ),
      body: Center(child: Text('Detalle id: $id')),
    );
  }
}
```

---

## 2) Navegación programática (API del `PageManager`)

* **Push/replace/reset (by name)**

```dart
final pm = context.appManager.page;

pm.pushNamed('details', segments: ['42']);   // push
pm.replaceTopNamed('details', segments: ['99']);
pm.goNamed('home');                           // reset a 1 página
```

* **Evitar duplicados**

  * `pushDistinctTop(...)`: evita **duplicado consecutivo** (no-op si el top ya es igual).
  * `pushOnce(...)`: **único en todo el stack** (si existe, lo mueve al top).

```dart
pm.pushDistinctTopNamed('details', segments: ['42']);
pm.pushOnceNamed('details', segments: ['42']); // by route (name+segments+query+kind+auth)
pm.pushOnceNamed('details', equals: _nameEquals); // único por name
```

* **Pop / estado del back**

```dart
final canPop = pm.canPop;              // bool inmediato
pm.canPopStream.listen((v) { ... });   // reactivo
pm.pop();                              // retorna false si ya estás en root
```

* **URI / deep-links**

```dart
// Reemplaza el top a partir de la URL (también puedes setear todo el stack con una chain)
pm.navigateToLocation('/details/42?q=hola');

final chain = pm.routeChain;           // "/home;/details/42?q=hola"
pm.setFromRouteChain(chain);
```

---

## 3) URL → PageModel (parser)

Regla por defecto:

* **Primer segmento** → `name` (tras `slugToName` si lo defines).
* **Resto de segmentos** → `segments`.
* **QueryString** → `query` (`Map<String,String>`).

Ejemplos:

* `/#/primeApp/query/1` →
  `PageModel(name: 'primeApp', segments: ['query','1'], query: {})`

* `/#/primeApp/search?q=hola` →
  `PageModel(name: 'primeApp', segments: ['search'], query: {'q':'hola'})`

> Si usas `url_strategy` sin hash, las URLs serían `/primeApp/...`

---

## 4) PageRegistry (404 y redirecciones)

Puedes inyectar un comportamiento cuando no se encuentra el `name`:

```dart
final registry = PageRegistry(
  {
    HomePage.pageModel.name: (ctx, p) => const HomePage(),
    DetailsPage.pageModel.name: (ctx, p) => DetailsPage(id: p.segments.elementAtOrNull(0)),
  },
  // Opción A: UI 404 custom
  // notFoundBuilder: (ctx, req) => const My404(),

  // Opción B: redirigir solo el top
  // defaultPage: HomePage.pageModel,

  // Opción C: redirigir TODO el stack (prioridad sobre defaultPage)
  // defaultStack: NavStackModel(<PageModel>[HomePage.pageModel, DetailsPage.pageModel]),
);
```

> Si no defines nada, el registro muestra una **404 por defecto** y loguea:
> `[PageRegistry] 404 for name="...", segments=[...], known=[...]`

---

## 5) Projector Mode vs Stack Mode

* **`projectorMode: true` (recomendado)**
  El `RouterDelegate` construye **solo la `Page` del tope** del `NavStackModel`.

  * Menos widgets materializados.
  * El `back` sigue funcionando (lógico por `PageManager.pop()`).

* **`projectorMode: false`**
  Materializa todas las `Page`s del stack.

  * Debes garantizar **keys únicas** por entrada (el `PageRegistry` las genera con `position`).
  * Úsalo si necesitas transiciones/gestos entre páginas del stack real.

---

## 6) Back button (helpers)

Para no repetir `canPop` en cada pantalla:

```dart
/// Botón back reactivo
class NavBackButton extends StatelessWidget {
  const NavBackButton({super.key});
  @override
  Widget build(BuildContext context) {
    final page = context.appManager.page;
    return StreamBuilder<bool>(
      stream: page.canPopStream,
      initialData: page.canPop,
      builder: (_, snap) => snap.data == true
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: page.pop)
          : const SizedBox.shrink(),
    );
  }
}

/// AppBar listo (título reactivo al PageManager)
PreferredSizeWidget buildNavAppBar(BuildContext context, {String? fixedTitle}) {
  final page = context.appManager.page;
  return AppBar(
    leading: const NavBackButton(),
    title: StreamBuilder<String>(
      stream: page.currentTitleStream,
      initialData: page.currentTitle,
      builder: (_, s) => Text(fixedTitle ?? (s.data ?? '')),
    ),
  );
}

/// Intercepta back físico (Android/web)
class NavPopScope extends StatelessWidget {
  const NavPopScope({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final page = context.appManager.page;
    return PopScope(
      canPop: page.canPop,
      onPopInvoked: (didPop) async {
        if (!didPop) page.pop();
      },
      child: child,
    );
  }
}
```

Uso:

```dart
return NavPopScope(
  child: Scaffold(
    appBar: buildNavAppBar(context),
    body: ...
  ),
);
```

---

## 7) Buenas prácticas

* Define un **`PageModel` estático en cada pantalla** (`static const PageModel pageModel = ...`).
* El `PageRegistry` debe ser **constante** y vivir en el wiring de la app.
* Prefiere **`pushOnce`/`pushDistinctTop`** para evitar duplicados indeseados.
* Para rendimiento, usa `projectorMode: true`.
* Título de AppBar: lee **`PageManager.currentTitleStream`** (derivado de `state['title']`, `query['title']`, último segmento o `name`).
* Para deep-links, implementa `slugToName` si usas slugs kebab-case.
* Si tu app no usa back-stack visual, `projectorMode` + back manual es lo más simple.

---

## 8) Anti-patrones

* Construir Widgets en el registro que **no dependan del `PageModel`** (pierdes trazabilidad).
* Dejar keys de `Page` **no determinísticas** o duplicadas (si usas stack mode).
* Manejar navegación directamente con `Navigator.of(context)` en lugar de `PageManager` (rompe el flujo Clean).

---

## 9) Checklist de integración

1. Crear `PageRegistry` (builders + 404/redirect opcional).
2. Crear `PageManager` con `NavStackModel.single(...)`.
3. Instanciar `MyAppRouterDelegate(projectorMode: true)` y `MyRouteInformationParser`.
4. Usar `MaterialApp.router`.
5. Navegar con `context.appManager.page.*`.
6. AppBar/Back: `NavBackButton`, `NavPopScope`, `buildNavAppBar`.

---

## 10) Snippets de referencia

* Push con título:

```dart
page.pushNamed('details', title: 'Detalle del producto', segments: ['42']);
```

* Reemplazar top por URI:

```dart
page.navigateToLocation('/details/42?ref=home');
```

* Route chain:

```dart
final chain = page.routeChain; // "/home;/details/42?ref=home"
page.setFromRouteChain(chain);
```

---

Con esto tienes un **sistema de navegación declarativo, testable y performante**, alineado a Clean Architecture, con API ergonómica y soporte de deep-links, 404 y redirecciones.
