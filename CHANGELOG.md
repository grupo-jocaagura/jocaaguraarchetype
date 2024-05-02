# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2024-05-01
### Added
- Ninguna.

### Changed
- Eliminación del export de `jocaagura_domain` desde la raíz del paquete para limpiar la estructura de importación.
- Eliminación de la invocación interna del paquete `jocaagura_archetype` para evitar referencias circulares y mejorar la modularidad.

### Fixed
- Aumento de la cobertura de tests en `FakeProvider` para asegurar una mejor validación y fiabilidad de las funcionalidades simuladas.

## [1.2.1] - 2024-04-25 (fix)
- Actualizaciones en la documentación para reflejar los cambios y mejoras en los módulos.
- Correcciones de varios issues menores detectados por `dart fix`.

## [1.2.0] - 2024-04-20
### Added
- Módulo `BlocConnectivity` con `ConnectivityProvider` e `InternetProvider` para gestionar el estado de la conectividad.

## [1.1.0] - 2024-04-15
### Added
- `bloc_session`, `service_session` y `provider_session` para el manejo de sesiones.
- `fake_session_provider` para simular el inicio de sesiones, facilitando las pruebas y desarrollo.

### Fixed
- Corrección de warnings e información en `bloc_counter` y `second_app_counter` detectados por análisis estático de código.

## [0.0.1] - 2024-04-10
- Inicio del Changelog con la versión actual de módulos.

