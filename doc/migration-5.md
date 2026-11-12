# Migración a JocaaguraArchetype 5.0.0

Esta migración corresponde al issue #135. La versión 5.0.0 incorpora también
la corrección de temporizadores de notificaciones #133 mediante el PR #134.

## SDK y dependencias

Usa Flutter >=3.50.0 con Dart >=3.14.0 y <4.0.0. El paquete declara
`material_ui: ^1.11.0` y `cupertino_ui: ^1.1.6`.

La integración usa la versión oficial publicada en pub.dev:

```yaml
dependencies:
  jocaagura_domain: ^2.0.0
```

Core `^1.3.0` se resuelve transitivamente. No agregues
`dependency_overrides`: cambiarían la implementación que estamos validando.
El barrel de domain del arquetipo conserva sus reexports y permite seguir
consumiendo modelos, contratos y BLoCs desde el arquetipo.

La homologación inicial del candidato Git se conserva como evidencia histórica.
La validación final con domain 2.0.0 publicado está documentada en la
[certificación de la dependencia oficial](workflows/evidence/135/certification-domain-2.0.0.md).

## Imports y tipos de diseño

Declara `material_ui` en las aplicaciones que lo importan. Declara también
`cupertino_ui` si lo importas directamente. Sustituye los imports antiguos por:

```dart
import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
```

Usa los mismos paquetes en tests, mocks y ejemplos. Actualiza también imports
con `show`, `hide` o alias. Flutter conserva `widgets.dart`, `foundation.dart`
y `services.dart`: esos imports no cambian.

Las clases de diseño conservan sus nombres pero tienen una identidad de tipo
diferente. Esto afecta a `ThemeData`, `TextTheme`, `ColorScheme`, `MaterialPage`
y `CupertinoPage`, entre otras. Por eso la migración es un cambio major.
Los parámetros públicos del arquetipo conservan sus nombres.
El mínimo de Dart activa el formateador moderno; los cambios de formato se
aplican también a los archivos cuyo comportamiento no cambia.

El ejemplo declara `cupertino_icons` para incluir la fuente usada por los
controles Cupertino y carga la web con `flutter_bootstrap.js`.

Si una aplicación necesita convivir con widgets de terceros que aún usan las
bibliotecas antiguas, revisa `MaterialUiCompatibilityBridge` y
`CupertinoUiCompatibilityBridge` en la guía oficial. El arquetipo no agrega
puentes automáticamente. Si utilizas `GlobalMaterialLocalizations` o
`GlobalCupertinoLocalizations`, impórtalos desde los nuevos paquetes.

Guía oficial:
[Material/Cupertino independientes del SDK](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui).

## Validación

Desde la raíz:

```sh
flutter --version
flutter pub get
flutter analyze
dart analyze --fatal-infos --fatal-warnings .
flutter test
dart format --output=none --set-exit-if-changed .
cd example
flutter analyze
flutter build web --release
```

Comprueba en ambos `pubspec.lock` que domain use `source: hosted`, versión
`2.0.0`, su hash de archivo publicado y core `1.3.0` como dependencia transitiva.
Ya no hay `resolved-ref` de Git. Los lockfiles son locales y están ignorados
por el repositorio.
El ejemplo no tiene suite de tests propia; sus fuentes se analizan y su entrada
principal se compila para web. La suite de la raíz cubre componentes, themes,
navegación Material/Cupertino y los contratos de dominio consumidos.

## Versión y publicación

El PR se dirige a `develop` con etiqueta `major`. El workflow ya incrementó
`pubspec.yaml` desde 4.x a 5.0.0. El changelog contiene la sección prevista para
5.0.0. El workflow calcula el incremento desde la versión base del PR y omite
el commit si la versión ya coincide con la esperada. Así, los siguientes pushes
de homologación y evidencias conservan 5.0.0.

Se sustituyó el pin Git por `jocaagura_domain: ^2.0.0` y se retiró
`publish_to: none` del paquete raíz. El ejemplo sigue siendo no publicable.
Antes del release:

1. Verifica la coincidencia de versiones del changelog y `pubspec.yaml`, y
   ejecuta `flutter pub publish --dry-run`.
2. Sigue el flujo `develop` -> `master` y confirma el mecanismo de publicación.
   Los workflows actuales validan y versionan, pero no publican en pub.dev.
