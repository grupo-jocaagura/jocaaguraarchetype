# Certificación de integración homologada: domain/core

> Evidencia histórica del candidato Git. La dependencia oficial de pub.dev
> está validada en la [certificación de domain 2.0.0](certification-domain-2.0.0.md).

Fecha: 2026-11-11 (America/Bogota).

**Resultado: PASS. GO para continuar la publicación de `jocaagura_domain 2.0.0`
desde la validación de JocaaguraArchetype.**

Se repitieron las siete comprobaciones solicitadas sobre el nuevo commit de
domain, utilizando Flutter 3.50.0 estable y Dart 3.14.0. No se detectaron
bloqueos de integración desde este consumidor.

## Snapshot certificado

| Elemento | Valor |
| --- | --- |
| Issue / PR | [#135](https://github.com/grupo-jocaagura/jocaaguraarchetype/issues/135) / [#136](https://github.com/grupo-jocaagura/jocaaguraarchetype/pull/136) |
| Rama de trabajo | `feature/135-feat-migrate-archetype-to-material-ui-and-domaincore-for-500` |
| Base del consumidor | `7e23620c3714ee97ee9e37e70f273e490d805d67`, más los cambios locales identificados en el manifiesto adjunto |
| Versión del consumidor | `5.0.0` |
| Domain certificado | [`ec8d831db3305b7e036f1e403aee7727e0a95e2d`](https://github.com/grupo-jocaagura/jocaagura_domain/commit/ec8d831db3305b7e036f1e403aee7727e0a95e2d) |
| Versión declarada por ese commit | `1.43.2`; candidato a la publicación de domain 2.0.0 |
| Core resuelto | `jocaagura_domain_core 1.3.0`, transitivo desde pub.dev |
| SDK mínimo del paquete y del ejemplo | Flutter `>=3.50.0`; Dart `>=3.14.0 <4.0.0` |
| SDK ejecutado | Flutter `3.50.0`, revisión `ab2912035e`; Dart `3.14.0` |
| Overrides de domain | Ninguno; no hay `dependency_overrides` en los pubspecs del proyecto |

## Resultados nuevos

Todos los comandos terminaron con código de salida **0**.

| Directorio | Comando | Resultado |
| --- | --- | --- |
| Raíz | `flutter pub get` | PASS; resolución del SHA exacto y core transitivo |
| Raíz | `dart format --output=none --set-exit-if-changed .` | PASS; 314 archivos, 0 cambios |
| Raíz | `flutter analyze` | PASS; sin observaciones |
| Raíz | `flutter test --reporter expanded` | PASS; **1022 pruebas** |
| `example` | `flutter pub get` | PASS |
| `example` | `flutter analyze` | PASS; sin observaciones |
| `example` | `flutter build web --release` | PASS; compilación y comprobación preliminar Wasm exitosas; fuentes Material/Cupertino incluidas |

La suite cubre los contratos de domain consumidos por el arquetipo, BLoCs,
bootstrap, formularios, temas y navegación Material/Cupertino. El ejemplo se
analizó y compiló para web; no tiene suite propia. No se ejecutó una matriz
de aplicaciones nativas ni la suite interna de domain.

## Resolución comprobada en ambos lockfiles

Se verificaron `pubspec.lock` y `example/pubspec.lock`. Ambos contienen:

```yaml
jocaagura_domain:
  description:
    ref: ec8d831db3305b7e036f1e403aee7727e0a95e2d
    resolved-ref: ec8d831db3305b7e036f1e403aee7727e0a95e2d
  source: git
  version: "1.43.2"

jocaagura_domain_core:
  dependency: transitive
  source: hosted
  version: "1.3.0"
```

El fragmento muestra los campos comprobados, no el contenido completo de los
lockfiles. Domain es dependencia directa en la raíz y transitiva en el ejemplo.
Core es transitivo en ambos. Los lockfiles permanecen locales conforme al
`.gitignore` del repositorio.

## Trazabilidad y límites

El [manifiesto de validación](validation-ec8d831.json) registra los resultados,
las versiones y las huellas SHA-256 de los dos pubspecs, ambos lockfiles y los
siete logs. El [diff del snapshot](snapshot-ec8d831.diff) permite reconstruir
los cambios versionados sobre la base indicada mediante `git apply --unidiff-zero`.
Los logs `domain-ec8d831-*.log`
se conservan localmente en la raíz y en `example`.

Esta es una certificación **local nueva**, publicada junto con los cambios de
homologación. Los workflows verdes anteriores del PR para `87ee1b8…` son
evidencia histórica y no se presentan como una ejecución CI del candidato
`ec8d831…`. El manifiesto conserva la base exacta de la validación local;
el commit que contiene este documento identifica su publicación.

El dictamen permite continuar el proceso de publicación de domain 2.0.0 sin
un bloqueo detectado por el arquetipo. No sustituye los controles de publicación
propios de domain ni certifica otros consumidores. Si cambia el código candidato
respecto al SHA indicado, se debe repetir esta validación.

Una vez disponible la versión publicada de domain, habrá que sustituir el pin
Git por la dependencia hosted y repetir las comprobaciones. El arquetipo mantiene
`publish_to: none` mientras depende de Git, sin bloquear la publicación de domain.
La versión del arquetipo se conserva en 5.0.0. El workflow calcula el incremento
desde la versión base del PR y omite el commit si ya coincide con la esperada,
para evitar incrementos major duplicados al publicar esta evidencia.
