# Certificación de integración: JocaaguraArchetype / domain-core

> Evidencia histórica del commit `87ee1b8…`. Para el candidato homologado
> `ec8d831…` con Flutter 3.50.0/Dart 3.14.0, consulta
> [la nueva certificación](certification-ec8d831.md).

Fecha: 2026-11-11 (America/Bogota).

**Resultado: PASS. GO para continuar el proceso de publicación de
`jocaagura_domain 2.0.0` desde la validación de este consumidor.**

No se detectaron bloqueos de integración del commit de domain evaluado en
JocaaguraArchetype. La certificación cubre este consumidor y este snapshot;
la publicación de domain debe conservar sus propias validaciones de release.

## Identidad de lo evaluado

| Elemento | Referencia |
| --- | --- |
| Issue consumidor | [JocaaguraArchetype #135](https://github.com/grupo-jocaagura/jocaaguraarchetype/issues/135) |
| PR consumidor | [JocaaguraArchetype #136](https://github.com/grupo-jocaagura/jocaaguraarchetype/pull/136), abierto hacia `develop` |
| Rama | `feature/135-feat-migrate-archetype-to-material-ui-and-domaincore-for-500` |
| Commit de implementación probado | `509edcd9096f3991c5481af0affcb0136f4f7f99` |
| Commit posterior de versión | `7e23620c3714ee97ee9e37e70f273e490d805d67` |
| Commit exacto de domain | [`87ee1b879d089e6a05a2b3ec485f979529a16bf9`](https://github.com/grupo-jocaagura/jocaagura_domain/commit/87ee1b879d089e6a05a2b3ec485f979529a16bf9) |
| Versión declarada por ese commit de domain | `1.43.2`; no se presenta como una versión `2.0.0` ya publicada |
| Core resuelto | `jocaagura_domain_core 1.3.0`, transitivo, desde pub.dev |
| Material / Cupertino resueltos | `material_ui 1.11.0` / `cupertino_ui 1.1.6` |
| Overrides | Ninguno |

El workflow generó el segundo commit para cambiar únicamente la versión del
arquetipo de `4.6.0` a `5.0.0`. Se verificó ese diff: no contiene cambios de
código ni de dependencias. Las ejecuciones CI enlazadas corresponden al commit
de implementación `509edcd…`, no a una ejecución adicional sobre el commit del bot.
GitHub verifica como válidas las firmas de ambos commits.

## Evidencias

| Validación | Entorno | Resultado |
| --- | --- | --- |
| `flutter pub get` | Windows, Flutter 3.47.4 / Dart 3.13.3 | PASS; `resolved-ref` coincide con los 40 caracteres del commit de domain |
| `flutter analyze` | Local | PASS, sin observaciones |
| `dart analyze --fatal-infos --fatal-warnings .` | Local | PASS, sin observaciones |
| `flutter test` | Local | PASS, **1022 pruebas** |
| `dart format --output=none --set-exit-if-changed .` | Local | PASS, 314 archivos sin cambios |
| `flutter analyze` desde `example` | Local | PASS, sin observaciones |
| `flutter build web --release` desde `example` | Local | PASS; fuentes Material/Cupertino incluidas |
| `git diff --check` | Local, antes del commit | PASS |
| Firmas, dependencias, formato y análisis estricto | Ubuntu, Flutter 3.50.0 / Dart 3.14.0 | [Workflow de commits: SUCCESS](https://github.com/grupo-jocaagura/jocaaguraarchetype/actions/runs/43121226985) |
| Changelog, dependencias, formato, análisis, tests e incremento major | Ubuntu, Flutter stable del workflow | [Workflow de PR: SUCCESS](https://github.com/grupo-jocaagura/jocaaguraarchetype/actions/runs/43121235306) |

Las pruebas existentes cubren las APIs de dominio consumidas por el arquetipo,
bootstrap, BLoCs, formularios, temas, serialización y navegación Material/Cupertino.
El ejemplo no tiene una suite propia: se validó mediante análisis y compilación web.
No se ejecutó una matriz de aplicaciones nativas Android/iOS/macOS/Windows/Linux.

Huellas SHA-256 de los logs locales usados como evidencia:

```text
migration-tests.log
38B80951C87D3B27286925C4488DD4C1ED804153DDFC42F9DA626724BFB52EFA

example/migration-web-build.log
227B005946E4D333356ED0FB6EC6F2ED27BC05BDD71BA5174FBC6C7FCEFCE322
```

## Conclusión para el equipo de domain

JocaaguraArchetype puede consumir el commit exacto evaluado de domain, con core
1.3.0 transitivo, y utilizar Material/Cupertino independientes sin errores en
el análisis ni fallos en su suite de pruebas. También compila su ejemplo para web.
Esta evidencia permite continuar el proceso de publicación de domain 2.0.0 sin
un bloqueo identificado por este consumidor.

La certificación no implica que domain 2.0.0 ya esté publicado, que el PR del
arquetipo esté fusionado, ni que se hayan validado otros consumidores. Si el
código candidato de domain cambia respecto a `87ee1b8…`, debe repetirse la
validación de integración sobre el nuevo commit.

Una vez publicada la versión acordada de domain, el arquetipo debe sustituir
el pin Git por la dependencia hosted y repetir resolución, análisis y pruebas.
El `publish_to: none` actual del arquetipo corresponde a su snapshot Git y no
es un bloqueo para publicar domain. Se retirará antes de publicar el arquetipo.

La corrección de notificaciones del issue #133 permanece en el PR #134 y no
se incluye en el alcance de esta certificación.
