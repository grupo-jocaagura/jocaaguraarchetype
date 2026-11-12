# Issue #139: checkpoints de 5.1.0

Referencia domain: `675abfc904775b2e02dbeebd3890dbad1cd1f480`.

**Estado final: CP-0, CP-1 y CP-2 completados.** Consultar la
[certificación de publicación de 5.1.0](certification-5.1.0.md) con runs,
commit, hash del paquete, atribución y configuración necesaria de pub.dev.

## CP-1: implementación local — PASS

- Flutter 3.50.0 / Dart 3.14.0.
- Flutter analyze: sin observaciones.
- Flutter test: 1035 pruebas aprobadas, incluidas cinco del widget público.
- Formato: 317 archivos sin cambios.
- Python unittest: 11 pruebas de políticas aprobadas.
- YAML: ocho workflows parseados correctamente.
- Ejemplo: build web release aprobado.
- Radio DS, opacidad, gradientes vacío/unicolor/multicolor y repintado cubiertos.

## CP-0: preparación OIDC — PASS

El mantenedor confirmó la configuración de publicación automática de pub.dev y
autorizó explícitamente añadir los tags `v*` y la ref exacta del PR #140 al entorno
GitHub `pub.dev`, conservando master. Se aplicaron las políticas 66479973 (tags)
y 66479976 (PR temporal). Esta última fue retirada al terminar la certificación;
se conservan master y tags `v*`.

La regla `Immutable release tags` (ID 27136487) está activa y bloquea actualización
y borrado de `refs/tags/v*`, sin bypass.

La [sonda real](https://github.com/grupo-jocaagura/jocaaguraarchetype/actions/runs/43260989494)
pasó en su intento 2. El artifact `oidc-readiness-43260989494-2` registra
`signed_claims_verified` y `pub_dev_upload: not_executed`, para la ref
`refs/pull/140/merge`, SHA `266050ed145f21ecfcaae16ebbb9cebabd2d622e`.
Los claims públicos se incorporaron a `.github/evidence/cp0-5.1.0.json` y
fueron aceptados por `require_cp0`. No se guardó el JWT ni se ejecutó un upload.
La aceptación de credenciales por pub.dev quedó verificada en CP-2; esta sonda
por sí sola no ejecutó un upload.

## CP-2: publicación y certificación — PASS

El [publisher 43268012683](https://github.com/grupo-jocaagura/jocaaguraarchetype/actions/runs/43268012683)
publicó 5.1.0 en su intento 2. La versión es visible en pub.dev y el mantenedor
confirmó la atribución al mismo run y commit en el activity log. El primer
intento había sido rechazado por tener deshabilitado `workflow_dispatch` en
pub.dev; al habilitarlo se completó la publicación sin cambiar tag ni credencial.
