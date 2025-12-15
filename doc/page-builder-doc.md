# Page Builder – Guía de uso y personalización

Este documento describe cómo usar el **Page Builder** del arquetipo Jocaagura, su flujo interno y las formas recomendadas de personalizarlo sin romper la arquitectura ni duplicar lógica.

---

## 1. Objetivo del Page Builder

El `PageBuilder` es la **cáscara estándar de página** del arquetipo. Su rol es:

* Conectar la UI con el `AppManager`.
* Centralizar:

    * Loading global.
    * Layout responsivo (métricas provistas por BlocResponsive desde el punto único documentado en `doc/responsive-flow.md`).
    * AppBar y Drawer principal.
    * Área de trabajo (`WorkAreaWidget`).
    * Notificaciones (`MySnackBarWidget`).
* Permitir **personalización controlada** por proyecto sin copiar/pegar el shell.

Diagrama de flujo simplificado:

```text
UI Page → PageBuilder
          └─ PageLoadingBoundary
              └─ PageScaffoldShell
                  ├─ MainDrawer (opcional)
                  ├─ PageAppBar (opcional)
                  ├─ WorkAreaWidget (page)
                  └─ MySnackBarWidget (notificaciones)
```

---

## 2. Clases y contratos principales

Los componentes viven en `lib/ui/builders/`:

* `page_builder.dart`

    * `PageBuilder`
* `page_loading_boundary.dart`

    * `PageLoadingBoundary`
* `page_scaffold_shell.dart`

    * `PageScaffoldShell`
* `main_drawer.dart`

    * `MainDrawer`
* `page_app_bar.dart`

    * `PageAppBar`
* `*_builder.dart`

    * `PageLoadingBoundaryBuilder`
    * `PageScaffoldShellBuilder`
    * `MainDrawerBuilder`
    * `PageAppBarBuilder`
* `expando_model_main_menu_model.dart`

    * `ModelMainMenuModelX` (Extensiones UI con `Expando`)

### 2.1. `PageBuilder`

Entry point recomendado para todas las páginas:

```dart
class PageBuilder extends StatelessWidget {
  const PageBuilder({
    super.key,
    this.page,
    this.showAppBar = true,
    this.loadingBoundaryBuilder,
    this.scaffoldShellBuilder,
    this.drawerBuilder,
    this.appBarBuilder,
  });

  final Widget? page;
  final bool showAppBar;
  final PageLoadingBoundaryBuilder? loadingBoundaryBuilder;
  final PageScaffoldShellBuilder? scaffoldShellBuilder;
  final MainDrawerBuilder? drawerBuilder;
  final PageAppBarBuilder? appBarBuilder;
}
```

Responsabilidades:

* Obtiene `AppManager` desde `context.appManager`.
* Inicializa `BlocResponsive` (`showAppbar`).
* Crea el **loading boundary** (por defecto `PageLoadingBoundary`).

> Desde la versión 2025.12, `PageBuilder` **ya no** llama `setSizeFromContext`; esa responsabilidad está en `JocaaguraApp`. Consulta `doc/responsive-flow.md` para más contexto y guías de migración.

### 2.2. `PageLoadingBoundary`

Capa que decide entre:

* Mostrar `LoadingPage` si `app.loading.loadingMsg` ≠ `''`.
* Delegar al shell (`PageScaffoldShell` u otro).

### 2.3. `PageScaffoldShell`

Compone el `Scaffold`:

* Escucha:

    * `responsive.appScreenSizeStream`
    * `app.mainMenu.listMenuOptionsStream`
    * `responsive.showAppbarStream`
* Construye:

    * Drawer (usando `MainDrawerBuilder`).
    * AppBar (usando `PageAppBarBuilder`).
    * Body: `WorkAreaWidget` + `MySnackBarWidget`.

### 2.4. `MainDrawer`

Drawer por defecto:

* Header con el título actual (`pageManager.currentTitleStream`).
* Lista de opciones usando `ModelMainMenuModel` + `DrawerOptionWidget`.

### 2.5. `PageAppBar`

AppBar por defecto:

* Título ligado a `pageManager.currentTitleStream`.
* Botón Back según `pageManager.canPopStream`.
* `ValueKey('appbar_hasDrawer_$hasDrawer')` para recomputar el leading cuando aparece/desaparece el drawer.

---

## 3. Uso básico

### 3.1. Página estándar

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageBuilder(
      page: HomeView(),
    );
  }
}
```

Comportamiento:

* Usa loading global del `AppManager`.
* Usa `MainDrawer` si existen opciones en `app.mainMenu.listMenuOptions`.
* Usa `PageAppBar` con el título y botón back.
* Renderiza `HomeView` dentro de `WorkAreaWidget`.

### 3.2. Página sin AppBar

```dart
class FullscreenPage extends StatelessWidget {
  const FullscreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageBuilder(
      page: FullscreenView(),
      showAppBar: false,
    );
  }
}
```

Se desactiva el AppBar inicial vía `BlocResponsive.showAppbar`.

---

## 4. Personalizaciones soportadas

El diseño del builder permite **inyección por capas**.
Puedes reemplazar:

* Sólo el Drawer.
* Sólo el AppBar.
* Todo el shell (`Scaffold`).
* Incluso el loading boundary completo.

### 4.1. Reemplazar sólo el Drawer (MainDrawerBuilder)

Ejemplo: Drawer con branding de proyecto.

```dart
class OkaneDrawer extends StatelessWidget {
  const OkaneDrawer({
    super.key,
    required this.app,
    required this.responsive,
    required this.items,
  });

  final AppManager app;
  final BlocResponsive responsive;
  final List<ModelMainMenuModel> items;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 32),
          const Text('Okane', style: TextStyle(fontSize: 20)),
          Expanded(
            child: ListView(
              children: <Widget>[
                for (final ModelMainMenuModel it in items)
                  ListTile(
                    title: Text(it.label),
                    onTap: () {
                      it.onPressed();
                      Navigator.of(context).maybePop();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

Uso con `PageBuilder`:

```dart
class OkaneHomePage extends StatelessWidget {
  const OkaneHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBuilder(
      page: const HomeView(),
      drawerBuilder: (
        BuildContext context,
        AppManager app,
        BlocResponsive r,
        List<ModelMainMenuModel> items,
      ) {
        if (items.isEmpty) {
          return null;
        }
        return OkaneDrawer(
          app: app,
          responsive: r,
          items: items,
        );
      },
    );
  }
}
```

### 4.2. Reemplazar sólo el AppBar (PageAppBarBuilder)

Ejemplo: AppBar con actions custom.

```dart
PreferredSizeWidget? okaneAppBarBuilder(
  BuildContext context,
  AppManager app,
  BlocResponsive responsive,
  bool hasDrawer,
) {
  return AppBar(
    title: const Text('Okane'),
    toolbarHeight: responsive.appBarHeight,
    actions: <Widget>[
      IconButton(
        icon: const Icon(Icons.account_balance_wallet),
        onPressed: () => app.pushNamed('/wallet'),
      ),
    ],
  );
}
```

Uso:

```dart
class OkaneHomePage extends StatelessWidget {
  const OkaneHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBuilder(
      page: const HomeView(),
      appBarBuilder: okaneAppBarBuilder,
    );
  }
}
```

### 4.3. Reemplazar todo el shell (PageScaffoldShellBuilder)

Ejemplo: layout con `NavigationRail` en desktop.

```dart
Widget okaneShellBuilder(
  BuildContext context,
  AppManager app,
  BlocResponsive r,
  Widget? page,
) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final bool useRail = constraints.maxWidth >= 900;

      if (!useRail) {
        // Fallback: usa el shell estándar
        return PageScaffoldShell(
          app: app,
          responsive: r,
          page: page,
        );
      }

      return Scaffold(
        body: Row(
          children: <Widget>[
            NavigationRail(
              destinations: <NavigationRailDestination>[
                const NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
              selectedIndex: 0,
              onDestinationSelected: (int index) {
                // Navegación via AppManager / PageManager
              },
            ),
            Expanded(
              child: WorkAreaWidget(
                responsive: r,
                content: page ?? const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      );
    },
  );
}
```

Uso:

```dart
class OkaneHomePage extends StatelessWidget {
  const OkaneHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBuilder(
      page: const HomeView(),
      scaffoldShellBuilder: okaneShellBuilder,
    );
  }
}
```

### 4.4. Reemplazar el loading boundary completo (PageLoadingBoundaryBuilder)

Ejemplo: pantalla de loading con animación propia.

```dart
Widget okaneLoadingBoundary(
  BuildContext context,
  AppManager app,
  BlocResponsive r,
  Widget? page,
) {
  return StreamBuilder<String>(
    stream: app.loading.loadingMsgStream,
    initialData: app.loading.loadingMsg,
    builder: (BuildContext context, AsyncSnapshot<String> snap) {
      final String msg = snap.data ?? '';
      if (msg.isNotEmpty) {
        return OkaneSplashLoading(message: msg);
      }
      return PageScaffoldShell(
        app: app,
        responsive: r,
        page: page,
      );
    },
  );
}
```

Uso:

```dart
class OkaneHomePage extends StatelessWidget {
  const OkaneHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageBuilder(
      page: const HomeView(),
      loadingBoundaryBuilder: okaneLoadingBoundary,
    );
  }
}
```

---

## 5. Extensiones UI sobre `ModelMainMenuModel`

En `expando_model_main_menu_model.dart` se definen extensiones UI para `ModelMainMenuModel` usando `Expando`:

```dart
extension ModelMainMenuModelX on ModelMainMenuModel {
  bool get selected;
  set selected(bool value);

  bool get enabled;
  set enabled(bool value);

  int? get badgeCount;
  set badgeCount(int? value);

  String? get tooltip;
  set tooltip(String? value);

  ModelMainMenuModel ui({
    bool? selected,
    bool? enabled,
    int? badgeCount,
    String? tooltip,
  });
}
```

Estas propiedades:

* **No** forman parte del dominio (`jocaagura_domain`).
* Son **estado efímero de UI**.
* Deben usarse sólo en la capa UI (drawers, menús, etc.).

Ejemplo:

```dart
final ModelMainMenuModel item = ModelMainMenuModel(
  label: 'Dashboard',
  onPressed: goDashboard,
).ui(
  selected: true,
  badgeCount: 5,
  tooltip: 'You have 5 pending items',
);
```

---

## 6. Recomendaciones de arquitectura

1. **Usa siempre `PageBuilder` como entry point**
   Sólo omite `PageBuilder` si estás construyendo un prototipo o test muy específico.

2. **Personaliza por builders, no por copy/paste**

    * Prefiere `drawerBuilder`, `appBarBuilder`, `scaffoldShellBuilder`, `loadingBoundaryBuilder`.
    * Evita duplicar `PageScaffoldShell` salvo casos excepcionales.

3. **No lleves widgets al dominio**

    * Los typedef y builders viven en `ui/builders`.
    * El dominio sólo conoce modelos (como `ModelMainMenuModel`).

4. **Testea componentes en aislamiento**

    * Puedes montar `MainDrawer`, `PageAppBar`, `PageScaffoldShell` directamente en tests.
    * Usa `FakeAppManager` / mocks para streams.

---

## 7. Checklist de implementación

Antes de dar por listo el uso de Page Builder en un proyecto:

* [ ] Todas las páginas principales usan `PageBuilder`.
* [ ] Los menús usan `ModelMainMenuModel` + `ModelMainMenuModelX` sólo en UI.
* [ ] Cualquier personalización se hace vía builders:

    * [ ] `drawerBuilder` (si aplica).
    * [ ] `appBarBuilder` (si aplica).
    * [ ] `scaffoldShellBuilder` (layouts avanzados).
    * [ ] `loadingBoundaryBuilder` (loading custom).
* [ ] No se han movido typedef ni widgets a la capa dominio.
* [ ] Existen tests básicos para al menos:

    * [ ] Shell por defecto (`PageScaffoldShell`).
    * [ ] Drawer personalizado (si existe).
    * [ ] AppBar personalizado (si existe).
