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

## CP-0: preparación OIDC — PENDIENTE

El mantenedor confirmó la configuración de publicación automática de pub.dev.
El entorno GitHub `pub.dev` existe pero solo permite `master`: debe autorizarse
explícitamente añadir los tags `v*` y la ref exacta del PR para ejecutar la sonda.
La revisión automática rechazó el cambio del entorno sin autorización específica.
No se modificó esa frontera de despliegue.

La regla `Immutable release tags` (ID 27136487) está activa y bloquea actualización
y borrado de `refs/tags/v*`, sin bypass. La evidencia CP-0 permanece en `pending`:
no se inventaron claims ni una ejecución firmada de Actions.

## CP-2: publicación y certificación — PENDIENTE

Requiere un release aprobado de 5.1.0 desde master, workflow/tag/SHA verificables,
versión visible en pub.dev y atribución real en el activity log. Las pruebas
locales no certifican por sí solas autenticación ni publicación automática.
