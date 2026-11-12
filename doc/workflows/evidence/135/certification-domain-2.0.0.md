# Certificación de integración con domain 2.0.0 publicado

Fecha: 2026-11-12 (America/Bogota).

**Resultado: PASS para la integración de la dependencia oficial en
JocaaguraArchetype 5.0.0.**

Se sustituyó el pin Git por `jocaagura_domain: ^2.0.0` y se retiró
`publish_to: none` del paquete raíz. El ejemplo mantiene esa restricción.
Se conservan Flutter >=3.50.0 y Dart >=3.14.0 <4.0.0.

## Dependencias verificadas

Ambos lockfiles locales resuelven domain desde `https://pub.dev` con
`source: hosted`, versión `2.0.0` y SHA-256 de archivo:

```text
aad1a8ff8ae7125a9ba589e7e17573ab03540e0b73e45007b92325dbb966da79
```

Este hash coincide con el archivo declarado por la API pública de
[domain 2.0.0](https://pub.dev/packages/jocaagura_domain/versions/2.0.0).
Core resuelve a `1.3.0`, hosted y transitivo en la raíz y en el ejemplo.
No se usan dependencias Git ni overrides para domain. Ya no existe un
`resolved-ref` Git de domain en los lockfiles de esta integración.

## Validación local

Entorno: Windows, Flutter 3.50.0 estable y Dart 3.14.0.

| Directorio | Comando | Resultado |
| --- | --- | --- |
| Raíz | `flutter pub get` | PASS |
| Raíz | `dart format --output=none --set-exit-if-changed .` | PASS; 314 archivos sin cambios |
| Raíz | `flutter analyze` | PASS; sin observaciones |
| Raíz | `flutter test --reporter expanded` | PASS; **1022 pruebas** |
| `example` | `flutter pub get` | PASS |
| `example` | `flutter analyze` | PASS; sin observaciones |
| `example` | `flutter build web --release` | PASS; comprobación preliminar Wasm y compilación web exitosas |

Una primera ejecución detectó la prueba antigua `testMe`, que exigía más de
2000 ms reales para una espera de dos segundos. Se sustituyó por tiempo virtual,
comprobando que la tarea sigue pendiente a los 1999 ms y termina a los 2000 ms.
La suite completa volvió a ejecutarse y pasó. No se cambió la implementación
de la espera ni se omitieron pruebas.

## Evidencia y alcance

El [manifiesto](validation-domain-2.0.0.json) registra la base de trabajo,
las versiones resueltas y las huellas de pubspecs, lockfiles, prueba corregida
y logs locales. El commit que contiene este certificado identifica la
integración pública. Los certificados anteriores de los candidatos Git son
evidencia histórica y no reemplazan esta nueva validación hosted.

Esta certificación cubre los contratos y componentes consumidos por el
arquetipo y la compilación web de su ejemplo. No equivale a una matriz nativa
completa ni a una publicación del arquetipo. El PR #136 sigue dirigido a
`develop`; el release debe seguir el flujo hacia `master` y su comprobación
final `flutter pub publish --dry-run` desde un estado Git limpio.
