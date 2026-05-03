# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.3.0] - 2026-05-02

### Added

- Se agregó `ModelInteractiveState` como modelo inmutable reutilizable para representar estados interactivos controlados en componentes de UI.
  - Soporta estados habilitado, cargando, visible, seleccionado, razón, error e intención semántica.
  - Incluye serialización/deserialización JSON.
  - Incluye getters derivados como `canInteract`, `hasError`, `hasReason`, `isBlocked` y helpers de feedback.
  - Incluye pruebas round-trip para estados default, loading, error, selected, disabled y fallback semántico.

- Se agregó `DsInteractiveBuilder`.
  - Permite interpretar visualmente un `ModelInteractiveState`.
  - Soporta builders específicos para estados hidden, loading, error, selected, disabled y enabled.
  - Define prioridad de render determinística:
    `hidden → loading → error → selected → disabled → enabled`.
  - Incluye widget tests para prioridad de render y comportamiento fallback.

- Se agregó la base funcional de la galería del Design System.
  - Se agregó `GalleryPreviewBuilder`.
  - Se agregó `SideBySideWidget` para comparar un mismo preview en tema claro y oscuro.
  - Se agregó `DesignSystemGalleryCoverPage`.
  - Se agregó `DesignSystemGalleryPage`.
  - Se agregó `DsGalleryPage` como shell principal de la galería.
  - Se agregó `BlocGallery` para administrar estado, página actual, páginas por defecto y navegación interna sin depender de `Navigator`.
  - Se agregó `ModelDsGalleryState` y `ModelDsGalleryPageEntry`.
  - Se agregó `DsGalleryNavigationControls`.
  - Se agregó `DsGalleryIndexPage`.

- Se agregaron páginas de previsualización para modelos del Design System.
  - `ModelThemeDataPage`.
  - `TextThemePage`.
  - `ModelDsExtendedTokensPage`.
  - `ModelSemanticColorsPage`.
  - `ModelDataVizPalettePage`.

- Se agregó `defaultModelDesignSystem()` para examples, pruebas y uso fallback de la galería.

- Se agregó ejemplo de uso de la galería.
  - Muestra cómo montar `DsGalleryPage`.
  - Muestra cómo extender la galería con entradas personalizadas usando `ModelDsGalleryPageEntry`.
  - Muestra previews de widgets mediante `DesignSystemGalleryPage`.
  - Muestra el uso de `SideBySideWidget` como herramienta de comparación light/dark.
  - Incluye páginas de ejemplo para botones DS, tipografía DS y `DsInteractiveBuilder`.

### Changed

- Dependencia `jocaagura_domain` actualizada y alineada a `1.40.0`.

- Se mejoró la implementación de `SideBySideWidget` para funcionar correctamente dentro de páginas scrollables de la galería.
  - Se reemplazaron árboles anidados de `MaterialApp` por paneles aislados con `Theme`.
  - Se agregó altura explícita para el preview.
  - Se hizo más seguro su uso dentro de `SingleChildScrollView`, `Column` y layouts de galería.

- Se refinó el enfoque de la galería DS para usar `ModelDsComponentAnatomy` como contrato principal de metadata para portada, páginas de widgets y documentación visual.

### Fixed

- Se corrigió el comportamiento de preview de `SideBySideWidget` al renderizarse dentro de una página scrollable del example.
  - Ahora el preview muestra de forma confiable los paneles light y dark.
  - Se evita que el preview desaparezca por constraints verticales no acotadas.

### Tests

- Se agregaron pruebas round-trip para `ModelInteractiveState`.
- Se agregaron widget tests para `DsInteractiveBuilder`.
- Se agregaron pruebas de `BlocGallery` para `next`, `previous`, `goTo`, `reset` y navegación al índice.
- Se agregaron widget tests para `DsGalleryPage`, `DsGalleryIndexPage` y `SideBySideWidget`.
- Se agregaron widget tests tipo smoke para las páginas de previsualización de modelos DS.

### Notes

- La galería DS se enfoca en esta versión en estructura, contratos y comportamiento funcional de previsualización.
- El refinamiento visual, composición responsive y pulido final de la galería quedan diferidos a un issue dedicado.

## [4.2.0] - 2026-03-24

### Changed
- Dependencia `jocaagura_domain` actualizada y alineada a `1.39.0`.
- Validada la retrocompatibilidad del arquetipo con `jocaagura_domain 1.39.0` en compilación, análisis y pruebas.

### Docs
- README general reestructurado para reflejar el estado actual del arquetipo.
- Se documentó explícitamente la compatibilidad con `jocaagura_domain 1.39.0`.
- Se añadió un bloque destacado para enfatizar el soporte nativo del paquete a Design System:
  - `ModelDesignSystem`
  - `ModelThemeData`
  - `ModelDsExtendedTokens`
  - `ModelSemanticColors`
  - `ModelDataVizPalette`
  - `BlocDesignSystem`
  - widgets de edición e import/export

### Compatibility
- Upgrade considerado retrocompatible para `jocaaguraarchetype`.
- No se requirieron ajustes funcionales obligatorios en widgets, flujos, formularios ni bootstrap transversal.

## [4.1.0] - 2026-01-21

> **Release acumulada** que integra **4.0.1 → 4.0.6**. Enfoque: Sistema de Diseño serializable, utilidades de ACL, y toolchain para análisis/simulación de flujos.

### Added
- **Design System (4.0.1–4.0.4)**
    - `ModelThemeData`: representación serializable de **ThemeData** (colores, tipografías, text scaling).
    - `ModelDsExtendedTokens`: **tokens extendidos** (spacing, border radius, elevation, animation durations) + validación y documentación.
    - `ModelDesignSystem`: contenedor integral que **orquesta** `ModelThemeData` y `ModelDsExtendedTokens`.
    - `ModelDataVizPalette` y `ModelSemanticColors`: paletas para **visualización** y **colores semánticos** (éxito/advertencia/error/info).
    - `ModelDsComponentAnatomy`: anatomía de componentes (botón, tarjeta, modal, etc.).
    - **Showcase** `ModelSystemExamples`: ejemplo de composición DS + DataViz + Semantic.
    - **Widgets DS**:
        - `DsTextThemeEditorWidget`: edición y previsualización de tipografías.
        - `DsImportExportWidget`: import/export JSON de configuraciones completas.

- **ACL (4.0.5)**
    - `ModelAclSnapshot`: snapshot serializable de permisos por **recurso/acción**.
    - `AclBridge`: mapeo entre `ModelAclSnapshot` y estructuras internas.
    - `HelperAclErrors`: utilidades para errores comunes (denegado, no encontrado).
    - `BlocAcl`: BLoC para **cargar/actualizar/verificar** permisos.
    - **Documentación** detallada del flujo de ACL y su integración con el DS.

- **Flow Analysis & Simulation (4.0.6)**
    - **Análisis**: `FlowAnalyzer`, `FlowAnalysisReport`, `FlowValidationIssue`, `FlowValidator`, `FlowValidatorReport`.
    - **Simulación**: `FlowSimulationPlan`, `FlowSimulator`, `FlowTraceEntry`, `FlowAuditSnapshot`.
    - **Soporte `Either`**: validación, auditoría y trazas **reproducibles** de flujos.

### Changed
- **ModelDesignSystem** amplía alcance: integra **DataViz** y **Semantic Colors**.
- **ModelFieldState**: soporte `errorTextToInput` (interoperabilidad con inputs que esperan `null` en lugar de `''`).
- **Dependencias**: `jocaagura_domain` actualizado a **1.38.0** para soportar `ModelAclSnapshot` y casos de uso asociados.

### Docs
- Guías y ejemplos:
    - **DS**: definición de tokens, composición de `ModelDesignSystem`, showcase.
    - **ACL**: ejemplo de implementación end-to-end.
    - **Flujos**: pipeline de **análisis/validación** y **simulación** con reportes reproducibles.

### Migration notes
- **Adopción DS**: migra temas y tokens existentes a `ModelDesignSystem`. Usa `DsImportExportWidget` para intercambio JSON.
- **ACL**: si tenías permisos dispersos, centraliza en `ModelAclSnapshot` y usa `AclBridge` para el mapeo.
- **Flujos**: para diagnosticar decisiones en pipelines `Either`, define **planes de simulación** con `FlowSimulationPlan` y genera auditorías con `FlowAuditSnapshot`.

> **Compatibilidad:** Cambios no rompientes dentro del rango **4.0.x → 4.1.0**. Requiere `jocaagura_domain >= 1.38.1` para las funciones de ACL.


## [4.0.6] - 2026-01-20
### Added
- FlowAnalysisReport: modelo serializable para resultados de análisis de flujos.
- FlowAnalyzer: servicio/contrato para analizar flujos Either y generar reportes.
- FlowAuditSnapshot: snapshot auditable del estado del flujo y sus decisiones.
- FlowSimulationPlan: plan de simulación parametrizable para flujos Either.
- FlowSimulator: ejecutor de simulaciones de flujos con trazas reproducibles.
- FlowTraceEntry: entrada granular del rastro de ejecución de un flujo.
- FlowValidationIssue: representación estandarizada de hallazgos/errores en validación.
- FlowValidator: contrato para validar flujos y producir issues.
- FlowValidatorReport: reporte agregado de validaciones de flujos.

## [4.0.5] - 2026-01-20

### Added
- ModelAclSnapshot: modelo serializable para representar snapshots de listas de control de acceso (ACL) con permisos detallados por recurso y acción.
- AclBridge: clase puente para mapear entre ModelAclSnapshot y estructuras de permisos internas del sistema.
- HelperAclErrors: utilidades para manejar errores comunes relacionados con ACL (permiso denegado, recurso no encontrado).
- BlocAcl: BLoC para gestionar el estado de ACL, incluyendo carga, actualización y verificación de permisos.
- Doocumentacion detallada del ejemplo de impleemntacion del flujo de ACl y Design system.

### Changed
- jocaagura_domain actualizado a la versión 1.38.0 para soportar ModelAclSnapshot y sus casos de uso asociados.

## [4.0.4] - 2026-01-15

### Added
- ModelDataVizPalette: modelo serializable para representar paletas de visualización de datos (colores primarios, secundarios, de acento y de fondo).
- ModelSemanticColors: modelo serializable para representar colores semánticos adicionales (éxito, advertencia, error, información).
- ModelDsComponentAnatomy: modelo serializable para representar la anatomía de componentes del sistema de diseño (botones, tarjetas, modales).
- ModelSystemExamples: ejemplo tipo showcase que ilustra cómo combinar ModelDesignSystem, ModelDataVizPalette y ModelSemanticColors en una configuración completa del sistema de diseño.
- DsTextThemeEditorWidget: widget interactivo para editar y previsualizar ModelTextTheme dentro de ModelDesignSystem.
- DsImportExportWidget: widget para importar y exportar configuraciones completas de ModelDesignSystem en formato JSON.

### Changed
- ModelDesignSystem ahora incluye ModelDataVizPalette y ModelSemanticColors para una gestión más completa del sistema de diseño.
- ModelFieldState actualizado para soportar errorTextToInput con el fin de ayudar a los input de flutter que reciben null en vez de empty.
## [4.0.3] - 2026-01-15
### Added
- Introducimos ModelDesignSystem: un modelo serializable que encapsula ModelThemeData y ModelDsExtendedTokens para una gestión integral del sistema de diseño.

## [4.0.2] - 2026-01-15
### Added
- ModelDsExtendedTokens: modelo serializable para representar tokens extendidos de espaciado, border radius, elevación y duraciones de animación.
- add comprehensive documentation and validation for ModelDsExtendedTokens and its keys

## [4.0.1] - 2026-01-15
### Added
- ModelThemeData: modelo serializable para representar ThemeData completo (colores, tipografías, text scaling).
- Extended tokens model for spacing, border radius, elevation, and animation durations

## [4.0.0] - 2025-12-14

### ⚠️ Breaking Changes
- Public APIs now depend on `AbstractAppManager` instead of the concrete `AppManager`.
  This affects (at least):
  - `JocaaguraAppShellController`
  - `JocaaguraThemedRouterApp`
  - `JocaaguraAppShell`

### ✅ Why
- **Lower coupling:** UI wiring no longer depends on the concrete archetype implementation.
- **Better testability:** enables minimal fakes/stubs for unit tests without heavy app wiring or real stream extensions.
- **Safer evolution:** internal changes in `AppManager` are less likely to ripple into consumers.

### 🔁 Migration
- Replace explicit `AppManager` types with `AbstractAppManager` where required.
- You can still keep a concrete instance, typed as the abstraction:
### Rationale
This reduces coupling in the UI layer and makes unit tests simpler and more deterministic by allowing precise fakes without requiring full app wiring.

## [3.5.3] - 2025-12-14

### Added
- **ModelFieldState:** modelo inmutable para formularios controlados con `BlocGeneral<ModelFieldState>`, con `copyWith`, banderas `isDirty/isValid` y roundtrip JSON para persistir borradores.
- **Forms Example:** `example/lib/forms_example.dart` ahora incluye el flujo multi‑paso (Email → Password → Login OK) que replica el patrón de OKANE y prueba navegación con FieldState.
- **Docs:** guía `doc/forms-flow.md` detallando el ciclo FieldState ↔ BLoC ↔ UI, mejores prácticas y casos (login, búsqueda con sugerencias).

### Changed
- **Example navigation:** el demo de formularios se divide en dos pantallas (email y password) y solo avanza si cada FieldState es válido; se reutiliza `DemoLoginFormBloc` entre pasos y se añade una pantalla de confirmación.


## [3.5.2] - 2025-12-13

### Changed
- **Responsive Flow:** el llamado a `BlocResponsive.setSizeFromContext` ahora sucede únicamente en el `builder` de `MaterialApp.router` dentro de `JocaaguraApp`, eliminando las invocaciones redundantes en widgets y mejorando la consistencia de métricas.
- **UI Widgets:** `PageBuilder`, `WorkAreaWidget`, `PageWithSecondaryMenuWidget`, menús y componentes reutilizables ahora sólo consumen métricas de `BlocResponsive`; se actualizaron tests para reflejar el flujo centralizado.
- **MySnackBarWidget:** se corrige el cálculo de `maxWidth` para evitar constraints negativas en pantallas pequeñas (side‑effect del refactor responsivo).

### Docs
- **`doc/responsive-flow.md`:** nueva guía oficial que documenta el patrón centralizado de responsividad, buenas prácticas, migración y estrategias de prueba con `setSizeForTesting`.
- **Page Builder / README:** se enlaza la guía y se documenta que `PageBuilder` ya no llama `setSizeFromContext`, orientando a los implementadores sobre el nuevo flujo.


## [3.5.1] - 2025-12-08

### Chore
- **Dependencies:** actualiza `jocaagura_domain` a **1.33.0**.

### Added
- **App Version – Gestión reactiva:**
    - Integración de **`BlocModelVersion`** para centralizar el estado de versión de la app.
- **HTTP – Obtención de versión remota:**
    - Manejo de solicitudes HTTP para **consultar la versión de la app** desde backend (flujo GET con normalización de respuesta y manejo de errores).

### Changed
- **App Version – Lógica de comparación:**
    - Refactor de la comparación de versiones (semver/build number) para decidir *update available* / *force update* usando `ModelAppVersion`.
- **HTTP – Robustez & encapsulamiento:**
    - Mejoras en el **pipeline HTTP** para la consulta de versión (normalización de payload, preparación para timeouts/offline, reutilización de helpers).

### Docs
- Guías y comentarios ampliados para:
    - Flujo de **obtención de versión** via HTTP.
    - Contratos y uso de **`ModelAppVersion`** (semántica de campos, comparación, ejemplos).

### Notes
- Cambios **no rompientes**. Asegúrate de configurar el **endpoint de versión** y, si corresponde, mapear correctamente los campos de `ModelAppVersion` (e.g., `version`, `buildNumber`, `forceUpdate`).


## [3.5.0] - 2025-11-16

### Added
- **Session – `SessionPages` (modelo único)**
    - Nueva clase que **agrega** las 7 páginas requeridas por `JocaaguraAppWithSession`:
      `splash`, `homePublic`, `login`, `homeAuthenticated`, `sessionClosed`,
      `authenticating`, `sessionError`.
- **UI – Arquitectura extensible de Page Builder (`ui/builders/`)**
    - Punto de entrada: `PageBuilder`.
    - Componentes: `PageLoadingBoundary`, `PageScaffoldShell`, `MainDrawer`, `PageAppBar`.
    - Contratos (overrides): `PageLoadingBoundaryBuilder`, `PageScaffoldShellBuilder`,
      `MainDrawerBuilder`, `PageAppBarBuilder`.
    - Extensiones UI: `ModelMainMenuModelX` (vía `Expando`).
    - Documento: `page-builder-doc.md` (guía completa y patrones de personalización).
- **UI – Secondary Menu Builder (responsive)**
    - `PageWithSecondaryMenuBuilder` con *wiring* automático a `AppManager.secondaryMenu.itemsStream`.
    - Layouts:
        - `SecondaryMenuMobileLayout` (fila flotante de acciones cuadradas; *tooltips*; animaciones).
        - `SecondaryMenuSidePanelLayout` (panel lateral para pantallas grandes; *overflow-safe*).
    - *Overrides*: `menuItemsOverride`, `mobileBuilder`, `sidePanelBuilder`.
    - Documento: `secondary-menu-builder-doc.md`.

### Changed
- **`JocaaguraAppWithSession`**
    - El constructor ahora recibe **un único** parámetro `sessionPages: SessionPages`
      (en lugar de 7 `PageModel`s). La `factory dev()` fue actualizada.
- **Alineación con Material 3 (colores y layouts)**
    - Fondos por defecto en `WorkAreaWidget`, `PageWithSecondaryMenuWidget` y
      `PageWithSecondaryMenuBuilder`: `scheme.surfaceContainerLowest` (antes `scheme.surface`).
    - `DrawerOptionWidget`: roles de color M3 para estados habilitado/inhabilitado/seleccionado/hover.
    - `SecondaryMenuSidePanelLayout`: cálculo de ancho basado en `responsive.size.width` para evitar *overflow* en pantallas pequeñas.
    - `PageAppBar`: separador después del botón Back para padding consistente; `iconSize` del botón Back ahora **responsivo** (proporcional al margen).

### Docs
- `jocaagura-app-with-session.md` actualizado para el nuevo API con `SessionPages`.
- Guías nuevas/extendidas: `page-builder-doc.md`, `secondary-menu-builder-doc.md`.

### Backwards compatibility
- **`PageBuilder`** mantiene el **mismo API público y comportamiento por defecto**; la nueva arquitectura es **opt-in** mediante *builders*.
- El cambio de colores a M3 puede ajustar ligeramente el contraste percibido en algunos temas.

### BREAKING CHANGES
- **Constructor de `JocaaguraAppWithSession`**:
    - Ahora requiere `sessionPages: SessionPages`.
    - **Migración rápida**:
      ```dart
      // Antes
      final Widget app = JocaaguraAppWithSession(
        splash: splashPage,
        homePublic: homePublic,
        login: loginPage,
        homeAuthenticated: homeAuth,
        sessionClosed: sessionClosed,
        authenticating: authenticating,
        sessionError: sessionError,
      );
  
      // Ahora
      final Widget app = JocaaguraAppWithSession(
        sessionPages: SessionPages(
          splash: splashPage,
          homePublic: homePublic,
          login: loginPage,
          homeAuthenticated: homeAuth,
          sessionClosed: sessionClosed,
          authenticating: authenticating,
          sessionError: sessionError,
        ),
      );
      ```

### Notes
- La nueva arquitectura de **Page/Secondary Menu Builders** mejora **modularidad, pruebas** y **personalización** sin obligar a copiar código del arquetipo.
- Los ajustes M3 corrigen desbordes y alineaciones sutiles en pantallas pequeñas y grandes.


## [3.4.1] - 2025-11-04

### Fixed
- **Lints / Docs:**
    - Corrige advertencia _“Angle brackets will be interpreted as HTML”_ en DartDoc (`theme_usecases.dart`) escapando o envolviendo con código para tipos genéricos (`Either<ErrorItem, ThemeState>`).
- **UI (deprecations):**
    - Reemplazo de `toastStream` **deprecated** en `page_builder.dart`:
        - Ahora se usa `textStream` (solo texto) **o** `stream<ToastMessage>` según el caso, eliminando la dependencia de la API obsoleta.

### Changed
- **env (DI/testability)** — `hotfix(env): refactor Env for improved DI and testability`
    - `Env` pasa de diseño estático a **modelo basado en instancias**:
        - Convertido a `abstract class`; `isQa`, `isProd`, `mode` ahora son **getters de instancia**.
        - La variable de compilación `_mode` continúa siendo `static`, pero se **encapsula** detrás de la instancia.
    - **`DefaultEnv`**: implementación estándar por defecto.
    - **Testing:** se añade `modeTest` opcional para **forzar modo** en pruebas.
- **AppManager**
    - Ahora **recibe un `Env`** en el constructor (por defecto, `DefaultEnv`).
    - `appMode`, `isQa`, `isProd` delegan al `Env` **inyectado** (no más accesores estáticos).

### Docs
- Actualizada la documentación de `Env` y ejemplo práctico de uso con DI.
- Notas en `page_builder.dart` sobre el uso de `textStream`/`ToastMessage` en lugar de `toastStream`.

### Migration notes
- **Casi sin rompimientos**:
    - Si no pasas `Env`, **no debes cambiar nada** (usa `DefaultEnv`).
    - Para pruebas o entornos custom, inyecta tu instancia:
      ```dart
      final Env env = DefaultEnv(modeTest: AppMode.qa); // o tu implementación
      final AppManager am = AppManager(env: env);
      ```
    - Si tu UI usaba `toastStream` directamente, migra a:
        - `textStream` (cuando solo necesitas texto), o
        - un `Stream<ToastMessage>` si manejas tipos enriquecidos.

## [3.4.0] - 2025-11-03

> Versión **acumulada** que integra las entregas **3.3.2** (flavors lógicos por `--dart-define`) y **3.3.1** (página y web de Política de Privacidad, y estructura legal unificada). No introduce cambios adicionales fuera de lo ya incluido.

### Added
- **Flavors lógicos por `--dart-define`:**
    - `lib/env/app_mode.dart`: `enum AppMode { dev, qa, prod }` + `parseAppMode(String)`.
    - `lib/env/env.dart`: `Env` base (extensible) con `mode`, `isQa`, `isProd`.
    - `lib/env/app_config_builder.dart`: `AppConfigBuilder.byMode(...)` para despachar `AppConfig` por entorno.
    - `lib/env/deferred_steps.dart`: `deferredStep(...)` para cargas diferidas en Onboarding (timeouts, manejo de error y *retry* con `Left/Right`).
    - **Exports** en `lib/jocaaguraarchetype.dart`.
    - **Doc:** `doc/env-doc.md` con:
        - Ejemplo Flutter de un solo archivo (contador + `AnyService` simulado).
        - Guía de ejecución por modo `--dart-define=APP_MODE=dev|qa|prod`.
        - Estrategia Android sugerida para ID/label por modo sin `productFlavors`.

### Changed
- **Env/Onboarding:** centralización de lectura de modo y mejoras para integrar Onboarding con imports diferidos.
- **Legal:** refactor a **estructura unificada** para centralizar contenidos y componentes.

### Removed
- `TermsAndConditionsProdPage` (reemplazada por la estructura legal unificada).

### Migration notes
- **No hay breaking changes.**
- En apps que usan el arquetipo:
    1. Extiende `Env` para tus variables (`class MyEnv extends Env { ... }`).
    2. Construye `AppConfig` con `AppConfigBuilder.byMode(mode: Env.mode, ...)`.
    3. Mueve inicializaciones pesadas al Onboarding con `deferredStep(...)`.
    4. Ejecuta por modo:
       ```bash
       flutter run --dart-define=APP_MODE=dev|qa|prod
       ```


## [3.3.2] - 2025-11-03
### Added
* **Flavors (logical-only) por `--dart-define`:**
    * `lib/env/app_mode.dart`: `enum AppMode { dev, qa, prod }` y `parseAppMode(String)`.
    * `lib/env/env.dart`: `Env` base mínima (extensible por proyecto) con `mode`, `isQa`, `isProd`.
    * `lib/env/app_config_builder.dart`: `AppConfigBuilder.byMode(...)` para despachar `AppConfig` por entorno.
    * `lib/env/deferred_steps.dart`: helper `deferredStep(...)` para **cargas diferidas** durante Onboarding (timeouts, manejo de error y retry vía `Left/Right`).
* **Exports** en `lib/jocaaguraarchetype.dart` para exponer las nuevas utilidades.
* **Documentación**: `doc/env-doc.md` con:
    * Ejemplo Flutter de un solo archivo (contador + `AnyService` simulado).
    * Guía de ejecución por modo `--dart-define=APP_MODE=dev|qa|prod`.
    * Sugerencia de estrategia Android para **ID/label** por modo sin productFlavors.

### Changed
* Estructura interna del paquete para centralizar lectura de modo y facilitar integración de Onboarding con imports diferidos.
### Notes (migración rápida)
* No hay breaking changes.
* En proyectos que usen el arquetipo:
    1. Extiende `Env` en la app para tus propias variables (`class MyEnv extends Env { ... }`).
    2. Construye `AppConfig` con `AppConfigBuilder.byMode(mode: Env.mode, ...)`.
    3. Mueve inicializaciones pesadas al Onboarding usando `deferredStep(...)`.
    4. Ejecuta por modo:
       ```bash
       flutter run --dart-define=APP_MODE=dev|qa|prod
       ```

## [3.3.1] - 2025-11-03

### Added
- **Privacy Policy (in-app):** `PrivacyPolicyPage.dart` para visualizar la política dentro de la app.
- **Web:** `web/privacy.html` como versión estática pública (mejora de cumplimiento, SEO y descubribilidad).
- **UI reutilizable (legal):** `SectionWidget`, `SubSectionWidget`, `PolicyTableWidget`, `InfoGridWidget` para maquetación clara y consistente.
- **Routing & Navegación:** registro de `PrivacyPolicyPage` en `legal_pages.dart` y entrada “Política de Privacidad” en el menú de usuario (`TermsMenuTileWidget`).

### Changed
- **Estructura legal unificada:** refactor de la sección legal para centralizar contenidos y componentes.

### Removed
- **`TermsAndConditionsProdPage`:** eliminada por redundante frente a la nueva estructura legal unificada.

### Notes
- Cambios **no rompientes**. Si tu app enlazaba a `TermsAndConditionsProdPage`, actualiza rutas/menús para apuntar a `PrivacyPolicyPage` o a `web/privacy.html` según corresponda.


## [3.3.0] - 2025-10-15

### Added
- **Typography – `TextThemeOverrides`:**
  - Clase **serializable** para definir/persistir overrides tipográficos (light/dark).
  - Serializa un subconjunto curado de `TextStyle`: `fontFamily`, `fontSize`, `fontWeight`, `letterSpacing`, `height`.
  - Igualdad/`hashCode` robustos e `immutability` vía `copyWith`.
  - Exportada desde `jocaaguraarchetype.dart`.
- **ThemeState:**
  - Nuevo campo `textOverrides` para personalizar `TextTheme` de forma **independiente** a colores (light/dark).
  - Soporte completo en `fromJson`, `toJson`, `copyWith`, `==`, `hashCode`.
- **Arquitectura reactiva de tema:**
  - **Contratos:** `ServiceThemeReact` (stream de JSON canónico), `GatewayThemeReact` (normaliza/valida), `RepositoryThemeReact` (mapea a `Stream<Either<ErrorItem, ThemeState>>`), y **use case** `WatchTheme`.
  - **Implementaciones:** `FakeServiceThemeReact` (auto-toggle configurable), `GatewayThemeReactImpl`, `RepositoryThemeReactImpl`.
  - **BLoC:** `BlocThemeReact` suscrito a `WatchTheme` para actualizaciones automáticas.
  - **Demo:** `main_reactive_demo.dart` mostrando service → gateway → repository → bloc → UI.
- **Docs & utilidades:**
  - Documentación y pruebas para `BuildThemeData` (derivación de `ColorScheme`, overrides, `TextTheme`, text scaling).

### Changed
- **BlocTheme / BlocThemeReact:**
  - `BlocThemeReact` ahora **hereda** de `BlocTheme` (el API imperativo se mantiene; el estado se alimenta desde el stream del repositorio).
  - `app_config.dart`: configuración por defecto actualizada a `BlocThemeReact` con `RepositoryThemeReactImpl` y servicio *fake*.
  - `jocaagura_app.dart`: `StreamBuilder` simplificado usando `am.theme.stateOrDefault`.
- **Separación de responsabilidades:**
  - `TextThemeOverrides` **excluye colores** (responsabilidad de `ThemeOverrides`/`ColorScheme`).

### Docs
- **ThemeState:** secciones nuevas (“Behavior”, “Contracts”, “Caveats”, “Functional example”), aclaraciones sobre formato HEX `#AARRGGBB`, compatibilidad ARGB int y exclusión de `createdAt` en igualdad.
- **ThemeOverrides / TextThemeOverrides:** DartDoc ampliado (serialización, `copyWith` con *clear flags*, *clamping* de `fontWeight`, ejemplos más completos).
- **Capa reactiva:** DartDocs detallados en todos los componentes; guía `docs/theme-doc.md` con arquitectura, cableado, uso y estrategia de pruebas.

### Tests
- **TextThemeOverrides:** *round-trip* JSON, igualdad, casos borde e integración con `ThemeOverrides`.
- **ThemeState:** casos para `textOverrides` (light+dark, solo light, nulo); convivencia con `ThemeOverrides`.
- **Capa reactiva:** `reactive_theme_watch_test.dart` valida `watch()` extremo a extremo (auto-toggle, normalización, manejo de errores, `TextThemeOverrides`).

### Dependencies
- **`jocaagura_domain` → `^1.31.0`** para soportar la arquitectura reactiva de temas.

### Migration notes
- Si persistes tema en JSON:
  - Añade/acepta el nuevo nodo `textOverrides` (opcional; *backward compatible*).
  - Mantén colores en `ThemeOverrides` y tipografías en `TextThemeOverrides` (sin mezclar responsabilidades).
- Para adoptar el flujo reactivo:
  - Usa `BlocThemeReact` + `WatchTheme` y un repositorio reactivo (`RepositoryThemeReactImpl`).
  - En UI, lee el estado con `am.theme.stateOrDefault` o suscríbete al BLoC.

> **Notas:** Cambio **no rompiente**. La arquitectura reactiva y `TextThemeOverrides` son opt-in y conviven con la configuración imperativa existente.

## [3.2.0] - 2025-09-10

### Added
- **JocaaguraApp:** widget de alto nivel con `AppManagerProvider` y factory `JocaaguraApp.dev()` para arranque rápido.
- **UtilsForTheme:** utilidades para parseo/formateo de colores y acceso JSON estricto.
- **Testing:** `FakeServiceTheme` para pruebas determinísticas de implementaciones de tema.

### Changed
- **PageRegistry / PageManager:** utilidades de rutas, políticas post-dispose, navegación nombrada y mayor estabilidad en hot reload.
- **Navegación:** `MyAppRouterDelegate` mejora la conciliación de removals y refuerza la inmutabilidad en los modelos de navegación.
- **Tema:**
  - `GatewayThemeImpl.normalize()` acepta semilla como `int` (ARGB32), `String` (HEX `#AARRGGBB`) o `Color` (persistencia interna como `int`).
  - JSON canónico en `ThemeState` y `ThemeOverrides`: colores en HEX mayúsculas `#AARRGGBB`; `fromJson` admite ARGB `int` legado pero normaliza en `toJson`.
  - `createdAt` (`DateTime?`) serializado en ISO8601 UTC cuando existe y excluido de `==`/`hashCode`.

### Docs
- DartDoc ampliado en **ServiceTheme**, **PageRegistry** y **PageManager**, con ejemplos autocontenidos.

### Tests
- Casos adicionales para `GatewayThemeImpl`, `ThemeUsecases` y `RepositoryThemeImpl` (incluye verificación de normalización HEX y propagación de errores).

### CI/CD
- Workflows actualizados para **commits firmados**, análisis estático y **publicación en pub.dev**.

> **Notas:** No hay cambios incompatibles. Si usas snapshots de JSON de tema en tests, podrían requerir actualización al formato HEX en mayúsculas.


## [3.1.4] - 2025-09-10

### Added
- **Testing:** `FakeServiceTheme` para pruebas determinísticas de `ServiceTheme` (usado en `service_theme_test.dart`).

### Changed
- **GatewayThemeImpl:** `normalize()` ahora acepta semilla como `int` (ARGB32), `String` (HEX `#AARRGGBB`) o `Color`. Se persiste internamente como `int`.
- **Serialización de tema:** `ThemeState`/`ThemeOverrides` emiten JSON canónico:
  - Colores en HEX `#AARRGGBB` (mayúsculas).
  - `fromJson` acepta ints ARGB legados, pero `toJson` normaliza a HEX.
  - `createdAt` es `DateTime?` y se serializa en ISO8601 UTC si existe; se ignora en `==`/`hashCode`.
- **Estructura:** `ThemeOverrides` y `ThemePatch` movidos a archivos propios (`theme_overrides.dart`, `theme_patch.dart`).
- **Utilidades:** `UtilsForTheme` para parseo/formateo de color y acceso JSON estricto.

### Fixed
- **ThemePatch.applyOn:** maneja `textScale` no finito y cae de forma segura al valor base.

### Docs
- **ServiceTheme:** DartDoc ampliado (contratos de pureza, idempotencia, pre/post-condiciones).

### Tests
- **GatewayThemeImpl:** casos para entradas en HEX y `Color`.
- **ThemeUsecases:** pruebas de propagación de errores (read/write), verificación de HEX canónico en `ThemeState.toJson()` y fallback a defaults en `ERR_NOT_FOUND`.
- **RepositoryThemeImpl:** corrección de nombre de archivo de pruebas  
  `repository_teme_impl_test.dart` → `repository_theme_impl_test.dart`.

### CI
- **Workflow:** `validate_commits_and_lints.yaml` ignora pushes a `master` y `develop` (ramas protegidas con merge controlado).

> **Notas:** No hay cambios incompatibles. La salida JSON ahora es canónica; si tienes snapshots de tests sobre JSON de tema, puede que requieran actualizarse al formato HEX en mayúsculas.

## [3.1.3] - 2025-09-10

### Added
- **JocaaguraApp** (nuevo widget de alto nivel)
  - API pública *stateless* con *shell* interno stateful para estabilidad del router.
  - `JocaaguraApp.dev()` para bootstrapping rápido (propiedad del `AppManager` por defecto).
  - `AppManagerProvider` en la raíz y *wiring* de `MaterialApp.router`.
  - Ejemplo mínimo de navegación (3 páginas) y documentación integrada.
- **PageRegistry**
  - Documentación exhaustiva y utilidades de 404/redirect.
  - `toPage()` con claves canónicas estables y soporte de `DialogPage`.
- **PageManager**
  - **ModulePostDisposePolicy** para controlar el comportamiento *post-dispose*:
    - `throwStateError` (estricto).
    - `returnLastSnapshotNoop` (tolerante).
  - Nuevos helpers y métodos de navegación nombrada (`pushDistinctTopNamed`, `pushOnceNamed`, etc.).
- **CI**
  - Workflow `validate_commits_and_lints.yaml` (commits firmados, lints, format, doctor).
- **Example**
  - Consolidación en `example/lib/main.dart` y simplificación del arquetipo de demo.

### Changed
- **MyAppRouterDelegate**
  - Lógica de `pop` y conciliación de removals refinada para distinguir cambios del modelo vs. gestos del `Navigator`.
  - `update()` para *hot reload* / cambios dinámicos de `PageManager`/`PageRegistry` sin recrear el delegate.
  - Sincronización inicial protegida con `_navigatorSyncedOnce` para evitar reacciones prematuras.
- **JocaaguraApp / Lifecycle**
  - El *ownership* del `AppManager` se respeta mediante `ownsManager`.
  - **Importante:** el `dispose()` del `AppManager` se **difiere** al cierre real de la app (p. ej. `AppLifecycleState.detached`) para evitar matar BLoCs en desmontajes no definitivos (hot reload, reparents, tests).
- **PageModel / NavStackModel**
  - Inmutabilidad reforzada (listas/mapas envueltos como unmodifiable).
  - Hash/igualdad más estables y documentación modernizada.

### Fixed
- Cadena de rutas: se preserva correctamente `PageModel.name` en múltiples iteraciones (v1/v2/v3).
- `setNewRoutePath`: limpieza correcta de historial al establecer una nueva ruta.
- Eliminados *pops* fantasma durante el primer *build* del `Navigator` gracias a la sincronización diferida.

### Docs & Tests
- DartDoc ampliado para `MyAppRouterDelegate`, `PageRegistry` y `PageManager`, con ejemplos autocontenidos.
- Cobertura de pruebas ampliada (post-dispose policy, títulos, historial, conciliación de removals, hooks de delegate).

### Deprecations
- **projectorMode**: el modo “proyector/top-only” queda **desaconsejado** y no se expone desde `JocaaguraApp` (el delegate trabaja con **stack completo**). Para flujos de “pantalla única”, usar navegación por `replaceTop*`.

---

**Notas de migración**
- Si dependías de “proyector”, migra a **stack completo** y usa `replaceTop*` para transiciones tipo shell.
- En tests que reconstruyen el árbol varias veces, si administras el `AppManager` externamente, dispónlo explícitamente en `tearDown()`.

**Autores**
- @Albert J. Jiménez P. (commits y refactors principales).


## [3.1.2] - 2025-09-08

### Refactor
- **SessionNavCoordinator**: improved robustness and testability.
    - Added `_prevTopFromStackEvent` tracking to better handle user navigation intents.
    - Introduced `canApplyGoHome` predicate to centralize the conditions for (C) → *authed on login → go home*.
    - Strengthened idempotency checks for login/home redirections.
    - More resilient fallbacks when `BlocSession` or `PageManager` are already disposed.

### Tests
- Expanded coverage for session-aware navigation flows (unauth → login, auth → restore, refreshing, logout, etc.).
- Verified compatibility with alternative `pageEquals` strategies (by name, by route).
- Documented and temporarily disabled two failing tests related to **intention handling** (`prevTop` / `canApplyGoHome`).  
  These are not in use yet and will be fully debugged in a future iteration.  
  → See TODOs in test file and upcoming issue *“Depurar manejo de intenciones en SessionNavCoordinator”*.

### Notes
- Session management is confirmed to work as expected across supported flows.
- The **intention management** code path is scaffolded but not yet active in production use.


## [3.1.1] - 2025-09-07

### Refactor
- Consolidated all example files into a single `example/lib/main.dart` for a minimal, self-contained demo.
- Simplified `RepositoryThemeImpl` and `GatewayThemeImpl` to use `const DefaultErrorMapper()`.

### CI
- Added GitHub Actions workflow `validate_commits_and_lints.yaml`:
    - Verifies signed commits.
    - Sets up Flutter and runs `flutter doctor`.
    - Runs `flutter pub get` for all pubspecs.
    - Disallows `dependency_overrides` in pubspec.yaml.
    - Enforces formatting with `dart format`.
    - Runs static analysis with `dart analyze --fatal-infos --fatal-warnings`.

### Chore
- Bumped `jocaagura_domain` dependency to `^1.26.0`.
- Updated package description in `pubspec.yaml` to comply with pub.dev scoring guidelines.

---

✅ This patch release simplifies the example app structure, strengthens CI with commit and lint validations, and ensures alignment with the latest `jocaagura_domain` release.


## [3.1.0] - 2025-09-03
### Added
- **AppConfig**
    - Nuevo método `T requireFirstModule<T>()` que expone el primer `BlocModule` encontrado en `blocModuleList`.
    - Nuevo método `T requireModuleByKey<T>(String key)` que devuelve el `BlocModule` correspondiente a la `key` establecida, validando tipo.
    - Ambos métodos lanzan error si no encuentran el módulo, asegurando integridad en fase de desarrollo.

- **AppManager**
    - Exposición de los métodos `requireFirstModule<T>()` y `requireModuleByKey<T>(String key)` para centralizar el acceso a módulos desde el manager.

- **Tests**
    - Se añadieron pruebas unitarias para validar el comportamiento de los nuevos métodos tanto en `AppConfig` como en `AppManager`.
- **AppManager**
    - Nuevos métodos de navegación basados en `PageModel`:
        - `goToModel(PageModel model)`
        - `pushModel(PageModel model, {bool allowDuplicate = true})`
        - `pushOnceModel(PageModel model)`
        - `replaceTopModel(PageModel model, {bool allowNoop = false})`
    - Estos métodos complementan la navegación existente por `String`, permitiendo aprovechar directamente los `PageModel` definidos por cada página.

### Changed
- Ajuste de la suite de pruebas para incluir validaciones de errores al no encontrar módulos en `blocModuleList`.
- Suite de pruebas ampliada para validar la nueva API de navegación en `AppManager`.
- Documentación (`DartDoc`) actualizada con ejemplos de uso de los nuevos métodos.

## [3.0.0] - 2025-08-28
### ⚠️ Breaking Changes
- Se eliminó la dependencia de `jocaagura_domain` y se ha vuelto a implementar la lógica de negocio dentro del paquete.
- Se ha eliminado el `BlocSession` y `BlocConnectivity`, ya que ahora se manejan directamente desde `AppManager`.
- Se ha eliminado el `ServiceSession` y `ServiceConnectivity`, ya que ahora se manejan directamente desde `AppManager`.
- Se ha eliminado el `ServiceSessionPlus`, ya que ahora se maneja directamente desde `AppManager`.
- Se ha eliminado el `ServiceConnectivityPlus`, ya que ahora se maneja directamente desde `AppManager`.
- Se ha eliminado el `FakeSessionProvider`, ya que ahora se maneja directamente desde `AppManager`.
- Se ha eliminado el `FakeConnectivityProvider`, ya que ahora se maneja directamente desde `AppManager`.
- Se ha eliminado el `FakeProvider`, ya que ahora se maneja directamente desde `AppManager`.
- Se ha eliminado el `BlocUserNotifications`, ya que ahora se maneja directamente desde `AppManager`.
- Se ha eliminado el `BlocCounter`, ya que ahora se maneja directamente desde `AppManager`.
- Se ha eliminado el `BlocCounterPlus`, ya que ahora se maneja directamente desde `AppManager`.
- Se ha eliminado el `BlocCounterProvider`, ya que ahora se maneja directamente desde `AppManager`.
- Se ha eliminado el `BlocCounterPlusProvider`, ya que ahora se maneja directamente desde `AppManager`.
- Ahora la libreria se puede utilizar como jocaaguraarchetype.
- Se expone la sublibreria `jocaaguraarchetiped_domain` para facilitar la integración con jocaagura_domain.
- Ahora los archivos cumplen con el formato part of `jocaaguraarchetype` para una mejor organización y claridad.

#### Added

* **README (Quick start):** ejemplo mínimo con `JocaaguraApp.dev`, `PageRegistry` y `OnboardingPage`.
* **DartDoc con ejemplos** para 13 módulos clave (Theme Gateway/Repo/Service, páginas base, utils de color, blueprint widgets, etc.).
* **Plantilla de issues** inicial (`plantilla de issues.txt`) para estandarizar reportes y tareas.
* **Guía inicial de tema** (docs): “Configuración de Tema con JocaaguraArchetype” (cómo seed, M3, textScale, presets).

#### Changed

* **Alcance aclarado:** el arquetipo se centra en *UI Shell* y *navegación*; lo transversal vive en `jocaagura_domain` (aviso en README).
* **Ejemplos y descripciones** de componentes responsive y `PageBuilder` (intención y uso típico).

#### Deprecated

* *N/A* (si en este ciclo anotamos alias/contratos antiguos del menú como `@Deprecated`, documentar aquí y planificar remoción para `1.28.0`).

#### CI/CD

* **Documentadas** las rutas de workflows recomendados para PRs a `develop` y `master` (validate PR).
* **Rama `master`:** consolidado el flujo de automatización/documentación de publicación.
* **Commits firmados:** guía para configurar firma del bot/miembros del repo.
* **CodeQL:** lineamientos para ejecución en `develop` y `master`.

## [2.0.2] - 2025-07-27

### 🔒 Resolved master conflicts

## [2.0.1] - 2025-07-27

### 🔒 Congelación de `pubspec.yaml`

Esta versión congela el archivo `pubspec.yaml` como parte del proceso de migración de lógica de negocio hacia el paquete [`jocaagura_domain`](https://pub.dev/packages/jocaagura_domain), a partir de su versión `1.21.2`.
**⚠️ Importante:**  
No se recibirán actualizaciones ni nuevas dependencias en este paquete hasta que la migración completa esté finalizada. Esto garantiza estabilidad durante el refactor estructural y evita conflictos en entornos de integración continua.

---

## [2.0.0] - 2025-07-27

### ⚠️ Breaking Changes

- Se removió la implementación interna de `ServiceSession` y `ServiceConnectivity`.
- Se introdujo `service_session_plus.dart`, que ahora debe ser implementado desde la app o inyectado desde `jocaagura_domain`.
- `bloc_session.dart` y `bloc_connectivity.dart` fueron actualizados para depender de las nuevas abstracciones definidas en `jocaagura_domain`.
- El paquete deja de funcionar de forma independiente. Ahora **requiere tener configurado `jocaagura_domain`** para su correcto funcionamiento.

### 💡 Razonamiento del cambio

Este cambio mayor responde a una estrategia de consolidación de herramientas transversales dentro del paquete [`jocaagura_domain`](https://pub.dev/packages/jocaagura_domain). Centralizar los servicios compartidos y sus contratos:

- Simplifica el mantenimiento y evolución de la arquitectura.
- Evita colisiones con paquetes externos o implementaciones personalizadas.
- Permite que cada app tenga control sobre la forma en que maneja sesiones, conectividad y navegación.

### 📌 Migración necesaria

1. Agrega `jocaagura_domain` como dependencia en tu `pubspec.yaml`.
2. Implementa tu propia versión de `ServiceSession` y `ServiceConnectivity` acorde a tus necesidades.
3. Asegúrate de configurar correctamente los blocs desde `AppManager`, inyectando las implementaciones deseadas.

### 📁 Otros cambios

- Se reorganizó el código para reflejar mejor la separación entre `blocs`, `services`, `ui` y `utils`.
- Mejora de documentación interna para los nuevos servicios.

---

> ⚠️ Este paquete podría ser deprecado en el futuro. Se recomienda utilizar directamente `jocaagura_domain` como punto de entrada para la configuración de servicios compartidos y lógica transversal.



## [1.5.2] - 2025-01-16

### Improved
- Enhanced the `publish.yml` workflow to accommodate the Google environment and GitHub Actions, ensuring seamless package publishing.

## [1.5.1] - 2024-01-16

### Updated
- Updated `codeql.yml` to version 3 due to the deprecation of version 2 announced by GitHub, ensuring proper execution of the scheduled code analysis cron jobs.

### Added
- Extracted the list of languages used by the CodeQL workflow into a GitHub secret (`secrets.CODEQL_LANGUAGES`) for a more dynamic and efficient configuration.

## [1.5.0] - 2025-01-16

### Added
- CI/CD configuration for the `develop` branch.
- Integration of CodeQL for code quality analysis.
- Automation of commit signing using a bot.
- Fixed dates in the changelog.


## [1.4.5] - 2024-01-15

### Added
- Integrated `validate_pr` configuration to include the `master` branch, ensuring compliance with PR validation rules.
- Added `publish.yml` to the `.github/workflows` directory, enabling automatic publishing to `pub.dev` upon merging into `master`.

### Updated
- Extracted bot credentials (`name` and `email`) into GitHub Secrets (`secrets.BOT_NAME` and `secrets.BOT_EMAIL`) to enhance security and prevent exposure.


## [1.4.4] - 2025-01-10

### Updated
- Updated `codeql.yaml` to enforce GitHub for making Code quality analysis.
### Added
- Improved workflow traceability with Code Quality analysis support using CodeQl from github.

## [1.4.3] - 2025-01-08

### Updated
- Updated `validate_pr.yaml` to enforce GitHub bot signatures for new protection rules in PR merging.
### Added
- Improved workflow traceability with snapshot support for key date-specific workflows.

## [1.4.2] - 2024-12-30
### Updated
- Changed deprecated values into 


## [1.4.1] - 2024-12-30
### Updated
- Changelog Translation: The changelog has been translated into English for publication on pub.dev.
- Pubspec.yaml: Adjusted to align with the latest version of the jocaagura_domain package, ensuring compatibility and consistency.
### Added
- Dartdoc Documentation: Comprehensive documentation has been added for all classes using the Dartdoc format, providing detailed explanations and examples for developers.
### Improved
- Test Coverage: Expanded the unit test coverage across the package to enhance reliability and ensure higher quality of the codebase.

## [1.4.0] - 2024-05-19
### Added
- Implemented a `Debouncer` in `BlocUserNotifications` to manage how and when the toast messages are displayed uniformly.
- Added `ShowToastPage` in the example to demonstrate the changes on-screen.

### Changed
- Updated `showToast` to use the `Debouncer`, ensuring the message updates properly and stays visible for the defined duration.
- Updated `IndexApp` to allow access or visualization of the `ShowToastPage`.

### Fixed
- Adjusted unit tests to reflect the new scope of `BlocUserNotifications` with the debouncer.
- Corrected capitalization consistency in change sections to maintain uniformity in the document.

## [1.3.1] - 2024-05-13
### Fixed
- Fixed the conditional logic to display the button only when the value is greater than 1.

## [1.3.0] - 2024-05-01
### Changed
- Removed the export of `jocaagura_domain` from the root of the package to clean up the import structure.
- Removed internal invocation of the `jocaagura_archetype` package to avoid circular references and improve modularity.

### Fixed
- Increased test coverage in `FakeProvider` to ensure better validation and reliability of simulated functionalities.

## [1.2.1] - 2024-04-25 (fix)
- Documentation updates to reflect changes and improvements in the modules.
- Fixed various minor issues detected by `dart fix`.

## [1.2.0] - 2024-04-20
### Added
- Added `BlocConnectivity` module with `ConnectivityProvider` and `InternetProvider` to manage connectivity state.

## [1.1.0] - 2024-04-15
### Added
- Added `bloc_session`, `service_session`, and `provider_session` for session management.
- Added `fake_session_provider` to simulate session initiation, facilitating testing and development.

### Fixed
- Fixed warnings and information in `bloc_counter` and `second_app_counter` detected by static code analysis.

## [0.0.1] - 2024-04-10
- Initial Changelog with the current version of modules.
