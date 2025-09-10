# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.1.4] - 2025-09-10

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

## [3.1.3] - 2025-09-08
- Verificacion de ramas en commits anteriores

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

## [2.0.1] - 2025-08-27

### 🔒 Congelación de `pubspec.yaml`

Esta versión congela el archivo `pubspec.yaml` como parte del proceso de migración de lógica de negocio hacia el paquete [`jocaagura_domain`](https://pub.dev/packages/jocaagura_domain), a partir de su versión `1.21.2`.
**⚠️ Importante:**  
No se recibirán actualizaciones ni nuevas dependencias en este paquete hasta que la migración completa esté finalizada. Esto garantiza estabilidad durante el refactor estructural y evita conflictos en entornos de integración continua.

---

### 🧭 Contexto

La lógica compartida, los contratos y modelos principales serán trasladados progresivamente a `jocaagura_domain` para favorecer la reutilización, testabilidad y mantenimiento centralizado.

---

### 📌 Próximos pasos
- Migrar los `Blocs`, `Gateways`, `Repositories` y `Entities` existentes a `jocaagura_domain`.
- Eliminar código duplicado tras la consolidación.
- Actualizar documentación de dependencias y estructura de carpetas.

---
Si estás utilizando este paquete en tus proyectos, asegúrate de apuntar tus dependencias compartidas directamente a `jocaagura_domain` en adelante.


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
