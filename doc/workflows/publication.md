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

En pub.dev: repositorio `grupo-jocaagura/jocaaguraarchetype`, patrón
`v{{version}}`, entorno requerido `pub.dev`. En GitHub: permitir tags `v*`
en ese entorno y activar protección de tags contra actualización y borrado,
sin bypass. La sonda inicial del PR requiere permitir su ref exacto de PR
en el entorno durante la certificación; no habilitar acceso general para forks.

Los workflows nuevos deben existir en la rama predeterminada antes de poder
despacharlos manualmente. El primer PR hacia develop los incorpora y verifica
CP-0 antes de preparar el PR de release a master. Usar etiqueta `minor` para
que el versionador actual pase de 5.0.0 a 5.1.0, sin incremento manual duplicado.

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
