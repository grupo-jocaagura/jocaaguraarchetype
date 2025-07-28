# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
