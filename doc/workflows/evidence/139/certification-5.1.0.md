# Certificación final de publicación automática: 5.1.0

Fecha: 2026-11-12 (America/Bogota). **Resultado: PASS.**

JocaaguraArchetype 5.1.0 fue publicada por GitHub Actions con autenticación
OIDC temporal. El resultado se verificó en el servidor y el mantenedor confirmó
la atribución en el activity log autenticado de pub.dev.

## Identidad y evidencia

| Elemento | Valor |
| --- | --- |
| Issue | [#139, completado](https://github.com/grupo-jocaagura/jocaaguraarchetype/issues/139) |
| Release PR | [#141](https://github.com/grupo-jocaagura/jocaaguraarchetype/pull/141) |
| Commit publicado | `9403fb9618affadd6c9b8ccf3fcac58f17c29f8a` |
| Tag conservado | `v5.1.0`, apuntando al mismo commit durante ambos intentos |
| Orquestación | [43267158581: SUCCESS](https://github.com/grupo-jocaagura/jocaaguraarchetype/actions/runs/43267158581) |
| Publisher | [43268012683: SUCCESS, intento 2](https://github.com/grupo-jocaagura/jocaaguraarchetype/actions/runs/43268012683) |
| Evento del publisher | `workflow_dispatch` sobre `refs/tags/v5.1.0` |
| Publicación | [pub.dev, versión 5.1.0](https://pub.dev/packages/jocaaguraarchetype/versions/5.1.0) |
| Fecha del servidor | `2026-11-12T17:39:03.66334Z` |
| Release GitHub | [v5.1.0](https://github.com/grupo-jocaagura/jocaaguraarchetype/releases/tag/v5.1.0) |
| Artifact de identidad | `publication-identity-43268012683-2` |

SHA-256 del archivo, obtenido de la
[API pública de pub.dev](https://pub.dev/api/packages/jocaaguraarchetype/versions/5.1.0):

```text
3ad05a07e5e3008d74716ec6bb87f82a49658b333e88ea1afd8aa5b2a20cacbd
```

Dependencias publicadas: `jocaagura_domain: ^2.0.0`, `material_ui: ^1.11.0`,
`cupertino_ui: ^1.1.6` y Flutter SDK. Domain 2.0.0 declara core `^1.3.0`
transitivamente. Requisitos: Flutter `>=3.50.0`, Dart `>=3.14.0 <4.0.0`.

## Checkpoints completados

- **CP-0:** firma JWT e identidad OIDC verificadas con evidencia real; configuración
  de pub.dev confirmada por el mantenedor. No se almacenaron JWT ni credenciales.
- **CP-1:** widget y painter públicos incorporados; análisis limpio, 1035 pruebas
  Flutter y 11 pruebas Python aprobadas; formato y build web del ejemplo aprobados.
- **CP-2:** merge oficial a master, CI y dry-run, creación del tag inmutable,
  despacho del publisher, credenciales OIDC, upload, lectura de la versión hosted
  y creación del release GitHub completados.
- **Atribución:** el mantenedor confirmó que el activity log identifica al
  publisher `jocaagura.com`, el run `43268012683` y el commit publicado indicado.
  Ese registro requiere autenticación; su contenido fue suministrado por el
  mantenedor, no obtenido mediante una consulta pública anónima.

El mensaje del servidor fue `Successfully uploaded` y el paso posterior informó
`Verified hosted publication: jocaaguraarchetype 5.1.0`. Los claims del artifact
corresponden a la comprobación de identidad previa al upload; el indicador
`pub_dev_upload: not_executed` describe esa comprobación, no el resultado del job
completo. La prueba de publicación es el upload exitoso y la respuesta hosted.

## Incidencia resuelta y configuración requerida

El primer intento pasó CI, identidad OIDC y dry-run, pero el servidor rechazó
el upload porque **este paquete no permitía eventos `workflow_dispatch`**.
No era una prohibición general de pub.dev. El mantenedor habilitó ese evento y
se reejecutaron los jobs fallidos del mismo run; el segundo intento publicó 5.1.0.

En **pub.dev → Admin → Automated publishing** conservar:

- Repositorio: `grupo-jocaagura/jocaaguraarchetype`.
- Patrón de tag: `v{{version}}`.
- **Enable publishing from `push` events: activado.**
- **Enable publishing from `workflow_dispatch` events: activado.**
- **Require GitHub Actions environment: activado**, con valor **`pub.dev`**.

En GitHub, el entorno `pub.dev` conserva las políticas de despliegue para
`master` y tags `v*`. La excepción temporal `refs/pull/140/merge` (política
66479976) fue retirada después de la certificación. La protección de tags contra
actualización/borrado permanece activa, sin bypass.

No se añadieron GitHub App ni PAT, no se movió/borró/recreó el tag y no hubo
un upload manual alternativo. La orquestación utiliza `GITHUB_TOKEN` para crear
el tag y despachar explícitamente el publisher; el upload usa credenciales OIDC.

Esta evidencia describe el release ya publicado. Los cambios de documentación
posteriores no modifican el commit, el tag ni el archivo inmutable de 5.1.0.
