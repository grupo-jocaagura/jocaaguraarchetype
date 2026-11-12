# Publicación automática desde master (#139)

Referencia: pipeline de `grupo-jocaagura/jocaagura_domain` fijado al commit
`675abfc904775b2e02dbeebd3890dbad1cd1f480`. Se adaptan la identidad del paquete,
repositorio e ID de OIDC, la dependencia domain ^2.0.0 y el checkpoint inicial.

## Flujo

1. Un PR oficial `develop` -> `master` produce el commit exacto de release.
2. `release_after_merge.yaml` verifica la identidad, changelog, versión nueva,
   preparación OIDC y procedencia del merge. Repite CI y dry-run.
3. Crea `v<version>` solo si no existe o coincide exactamente con ese commit.
   Despacha `publish.yaml` explícitamente: los tags creados con GITHUB_TOKEN
   no disparan por sí solos otro workflow de push.
4. El publisher exige un tag protegido del master actual, firma GitHub válida,
   merge oficial, CI y dry-run. Usa credenciales OIDC de corta duración mediante
   `dart-lang/setup-dart`, sin almacenar tokens ni secretos de pub.dev.
5. Reconsulta pub.dev antes de subir, verifica la versión después del upload
   y crea/actualiza el release GitHub. Una versión publicada no se vuelve a subir.

Las versiones estables de release son minor/major (patch cero), como en domain.
Las versiones de desarrollo patch no se promueven directamente. Los errores
de red o identidad bloquean la publicación; no equivalen a versión inexistente.
No se mueven ni se borran tags existentes. Los jobs de publicación se serializan.

## Checkpoints de 5.1.0

- **CP-0: identidad y configuración.** El mantenedor confirmó la configuración
  de pub.dev. La sonda `oidc_probe.yaml` verifica la firma JWT y guarda solo
  claims no secretos. Descargar su artifact y registrar los claims reales,
  URL de ejecución y estado `passed` en `.github/evidence/cp0-5.1.0.json`.
  Mientras permanezca `pending`, el publisher queda bloqueado deliberadamente.
- **CP-1: implementación y regresión.** `DsLayeredSurfaceWidget` y su painter
  son públicos desde el barrel principal, adaptados de Bienvenido a Material UI.
  Probar tokens, gradientes vacíos/unicolor/multicolor, opacidad y repintado.
  Ejecutar tests Python de políticas, Flutter analyze/test y build web del ejemplo.
- **CP-2: certificación real.** Tras aprobar y fusionar el release 5.1.0,
  conservar URL/run ID del publisher, tag/SHA y la respuesta de pub.dev. Confirmar
  la atribución a Actions en el activity log del paquete. No certificar CP-2
  por haber pasado solo una sonda o haber enviado un dispatch.

## Configuración externa

En **pub.dev → Admin → Automated publishing**, configurar:

- Repositorio `grupo-jocaagura/jocaaguraarchetype`.
- Patrón `v{{version}}`.
- **Enable publishing from `push` events: activado.**
- **Enable publishing from `workflow_dispatch` events: activado.**
- **Require GitHub Actions environment: activado**, con nombre **`pub.dev`**.

Este flujo necesita ambos tipos de evento: la orquestación crea el tag con
`GITHUB_TOKEN` y despacha explícitamente el publisher sobre ese tag. Si pub.dev
no permite `workflow_dispatch`, el upload se rechaza aunque pasen OIDC, CI y
dry-run. Habilitar el evento no requiere quitar la restricción del entorno.

En GitHub: permitir `master` y tags `v*`
en ese entorno y activar protección de tags contra actualización y borrado,
sin bypass. La sonda inicial del PR requiere permitir su ref exacto de PR
en el entorno durante la certificación; no habilitar acceso general para forks.
Retirar la excepción temporal del PR tras la certificación. La sonda queda
disponible mediante ejecución manual después del bootstrap.

El flujo completo quedó certificado con la publicación de **5.1.0**:
[certificación final y resolución del rechazo inicial](evidence/139/certification-5.1.0.md).

Los workflows nuevos deben existir en la rama predeterminada antes de poder
despacharlos manualmente. El primer PR hacia develop los incorpora y verifica
CP-0 antes de preparar el PR de release a master. Usar etiqueta `minor` para
que el versionador actual pase de 5.0.0 a 5.1.0, sin incremento manual duplicado.

## Sincronización del historial después del release

Después de cada merge por squash de `develop` a `master`, incorporar `master`
de nuevo a `develop` mediante un PR de sincronización. Un squash puede dejar
árboles de archivos idénticos con historiales divergentes; conservar solo los
archivos no incorpora el commit de master y puede repetir conflictos en el
siguiente release.

El workflow `Sync master to develop` escucha la finalización satisfactoria de
`Release after master merge` y `Publish package`. Solo propone el PR cuando la
versión de master ya está publicada en pub.dev. También funciona para promociones
documentales de una versión publicada. Si el upload aún no ocurrió, espera al
publisher; si master ya es ancestro de develop, termina sin cambios. Un evento
de un commit anterior al master vigente se omite.

Antes de reconciliar el historial comprueba la firma del commit de master, el
PR oficial fusionado de develop a master y la igualdad completa entre el árbol
de master y el head de ese PR. Ese head debe ser ancestro del develop actual.
Solo entonces usa un merge de dos padres con estrategia `ours`: el contenido
del release ya está incorporado y se conserva cualquier trabajo posterior de
develop. Si no puede demostrarlo, falla y requiere reconciliación manual.

La rama `automation/sync-master-<SHA completo>` contiene un merge firmado con
la identidad existente del bot (`SSH_SIGNING_KEY`, `BOT_NAME`, `BOT_EMAIL`).
El setup deriva el archivo `.pub` mediante `ssh-keygen -y` antes de firmar;
Git lo necesita para cargar claves privadas PEM. Ambos archivos temporales se
eliminan al finalizar. Una prueba con clave RSA PEM sintética reproduce el fallo
sin `.pub` y verifica criptográficamente el merge firmado tras generarlo.
El único cambio de contenido es un comentario generado en `CHANGELOG.md`, para
satisfacer la validación de contribución. El PR lleva `skip-version-bump` y
conserva la versión vigente de develop, incluso si ya avanzó respecto al release.
Las reejecuciones reutilizan el PR abierto y verifican cualquier rama existente;
no hacen force-push ni recrean tags. Un PR cerrado sin incorporar la ascendencia
o una versión que cambie mientras está abierto requieren intervención.

En **Settings → Actions → General → Workflow permissions**, habilitar
**Allow GitHub Actions to create and approve pull requests**, necesario para
crear el PR con `GITHUB_TOKEN`. Aunque GitHub agrupa ambas capacidades en esa
opción, estos workflows nunca aprueban ni fusionan PRs. Se mantienen las reglas
de firma y revisión externa de develop.

El creador despacha explícitamente `Validate automatic master sync` desde
master. El validador ejecuta únicamente código de master y publica el estado
`Master synchronization validation` sobre el SHA exacto del PR, tras comprobar
firma, procedencia, padres, ascendencia y diff restringido al comentario.
Las pruebas de política se ejecutan antes de emitir éxito. Los workflows
ordinarios del PR creado con `GITHUB_TOKEN` pueden necesitar autorización humana
con **Approve workflows to run**; este despacho no depende de ese disparador.
Los dos workflows deben estar incorporados a master antes de su primera ejecución.

Para reintentar, ejecutar `Sync master to develop` con **Run workflow → master**.
Revisar y aprobar el PR y fusionarlo con **Create a merge commit**, nunca squash
ni rebase: la relación de ascendencia es el resultado que se quiere conservar.
La automatización no modifica la versión ni inicia una nueva publicación.

Si las comprobaciones de procedencia fallan, crear una rama desde develop,
reconciliar master mediante un merge normal revisado, conservar la versión y
tramitar el PR con `skip-version-bump` y una nota al changelog.

Tras aprobar y fusionar ese PR, verificar:

```sh
git fetch origin
git merge-base --is-ancestor origin/master origin/develop
```

El comando debe terminar con código 0. Si falla, no considerar completada la
sincronización aunque los archivos parezcan iguales.

## Widget

```dart
DsLayeredSurfaceWidget(
  gradientColors: const [Colors.indigo, Colors.teal],
  borderRadius: BorderRadius.circular(20),
  padding: const EdgeInsets.all(16),
  child: const Text('Superficie con textura'),
)
```

Sin radio explícito se requiere `DsExtendedTokensExtension` en el tema.
La lista vacía usa primary del tema; un solo color se duplica para formar
un gradiente válido. El widget no incorpora gestos ni lógica de negocio.

Documentación oficial: https://dart.dev/tools/pub/automated-publishing
