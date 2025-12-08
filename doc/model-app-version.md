# ModelAppVersion

## Objetivo

`ModelAppVersion` concentra la **fuente de verdad** acerca de la versión que la app considera instalada o disponible.  

Normaliza campos clave (versión semántica, `buildNumber`, canal, `minSupportedVersion`, `forceUpdate`, metadata opcional) para que cualquier módulo pueda consultar o reaccionar **sin conocer detalles del origen del dato**.

Es el contrato que `BlocModelVersion` y `AppManager` consumen para coordinar flujos de actualización, recordatorios y decisiones de compatibilidad.

> 🔎 Importante: aunque muchos ejemplos usen HTTP como fuente de datos, `ModelAppVersion` **no está acoplado al transporte**. La versión puede venir de:
> - Configuración local (env/flavors, archivos, assets).
> - Servicios remotos (HTTP, gRPC, sockets, etc.).
> - Deep links o parámetros de arranque.
> - Feature flags, remoto o local.

---

## Componentes principales

- **`ModelAppVersion`**  
  Value Object con campos como:
  - `version` (cadena semántica, ej: `1.2.3`)
  - `buildNumber` (entero incremental)
  - `channel` (ej: `stable`, `beta`, `internal`)
  - `minSupportedVersion`
  - `forceUpdate`
  - `buildAt` y `metadata` opcional

  Expone `defaultModelAppVersion` como fallback seguro para escenarios offline o legados.

- **`BlocModelVersion`**  
  BLoC ligero que mantiene el **snapshot actual de versión** y lo expone como `stream`.  
  Provee utilidades como:
  - `setVersion`
  - `resetToDefault`
  - Comparaciones:
    - `isNewerThanCurrent`
    - `isCandidateNewerThan`

- **`AppManager`**  
  Fachada de alto nivel que expone:
  - `appVersionBloc` (cuando está configurado en `AppConfig`)
  - `currentAppVersion` (si no hay bloc, cae en `defaultModelAppVersion`)

  Esto facilita el acceso desde la UI, coordinadores, tracking, soporte, etc.

---

## Uso recomendado

1. **Resolver siempre a `ModelAppVersion`**
   Cualquier flujo que determine una versión (sea local o remota) debe terminar en un `ModelAppVersion` y publicarlo mediante:

    ```dart
    void main() {
      appManager.appVersionBloc?.setVersion(modelAppVersion);
    }
    ```
    Ejemplos de fuente:
    - Lectura de un archivo de configuración.
    - Respuesta de un servicio remoto.
    - Parámetros en un deep link de “forced update”.
    - Payload de un socket o mensaje push.

2. **Lectura en UI**
   Los widgets pueden suscribirse a `BlocModelVersion.stream` (vía `AppManager`) para mostrar:

    * Banners de “nueva versión disponible”.
    * Diálogos de actualización obligatoria.
    * Mensajes contextuales en pantallas de ajustes / “Acerca de”.

3. **Comparaciones de versión**
   Use `BlocModelVersion.isCandidateNewerThan` para decidir si una versión candidata es más reciente que la actual.

   La prioridad de comparación es:

    1. `buildNumber` (si está presente y es consistente).
    2. Cadena semántica `version` (con reglas predecibles).
    3. `buildAt` como desempate temporal cuando aplica.

4. **Estados por defecto**
   Si la app **no configura** un `BlocModelVersion`,
   `AppManager.currentAppVersion` devolverá `ModelAppVersion.defaultModelAppVersion`, garantizando que siempre exista un valor consistente aunque la fuente real aún no se haya resuelto.

---

## Flujos típicos

* **Detección de nuevas versiones**

    1. Un flujo cualquiera (HTTP, archivo local, deep link, etc.) obtiene una versión candidata.
    2. Se construye un `ModelAppVersion` con esa información.
    3. Se compara contra la versión actual vía `isCandidateNewerThan`.
    4. Si es mayor, se dispara UI reactiva (banner, diálogo, paso de onboarding, etc.).

* **Cambio de entorno o “downgrade” controlado**

    * En cambios de ambiente (ej: `qa → prod`) o cuando se quiere limpiar estado:

      ```dart
      void main() {
      appManager.appVersionBloc?.resetToDefault();
      }
      ```
    * Luego se aplica la nueva fuente (nueva `ModelAppVersion`) como versión activa.

* **Telemetry y soporte**

    * Loggear siempre `version` y `buildNumber` desde `AppManager.currentAppVersion` al registrar:

        * Errores.
        * Eventos de analytics.
        * Tickets de soporte.
    * Esto asegura diagnósticos consistentes entre equipos (soporte, QA, evolución, producto).

---

## Buenas prácticas

* Mantener sincronizado `buildNumber` con el pipeline de CI/CD para que la comparación sea determinística y trazable.
* Normalizar fechas (`buildAt`) en UTC para evitar problemas por zona horaria al desempatar versiones.
* Cuando se amplíe el modelo, agregar defaults razonables en `ModelAppVersion` para no romper consumidores existentes (apps viejas, scripts, tests).
* Encapsular la lógica de obtención de versión en **usecases o repositories de dominio**, de modo que la UI solo reciba `ModelAppVersion` y nunca tenga que saber:

    * Si vino por HTTP.
    * Si vino de un archivo local.
    * O de un feature flag remoto.