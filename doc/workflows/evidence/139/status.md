# Issue #139: checkpoints de 5.1.0

Referencia domain: `675abfc904775b2e02dbeebd3890dbad1cd1f480`.

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
y 66479976 (PR temporal). Retirar esta última al terminar la certificación.

La regla `Immutable release tags` (ID 27136487) está activa y bloquea actualización
y borrado de `refs/tags/v*`, sin bypass.

La [sonda real](https://github.com/grupo-jocaagura/jocaaguraarchetype/actions/runs/43260989494)
pasó en su intento 2. El artifact `oidc-readiness-43260989494-2` registra
`signed_claims_verified` y `pub_dev_upload: not_executed`, para la ref
`refs/pull/140/merge`, SHA `266050ed145f21ecfcaae16ebbb9cebabd2d622e`.
Los claims públicos se incorporaron a `.github/evidence/cp0-5.1.0.json` y
fueron aceptados por `require_cp0`. No se guardó el JWT ni se ejecutó un upload.
La aceptación de credenciales por pub.dev se certificará en CP-2, no en esta sonda.

## CP-2: publicación y certificación — PENDIENTE

Requiere un release aprobado de 5.1.0 desde master, workflow/tag/SHA verificables,
versión visible en pub.dev y atribución real en el activity log. Las pruebas
locales no certifican por sí solas autenticación ni publicación automática.
