# jocaagura-app-doc.md

Guía práctica para:

1. **Flujo único de Splash (una vez por sesión)** con `PageManager`.
2. **Configuración de variables de entorno** usando `--dart-define-from-file`.

---

## 1. Arquitectura de navegación (visión rápida)

**Componentes clave**

* `PageModel`: ruta lógica (nombre, segmentos, flags).
* `PageDef`: asocia `PageModel → Widget`.
* `PageRegistry`: registro declarativo (defaultPage, notFound).
* `NavStackModel`: pila inmutable de `PageModel`s.
* `PageManager`: **fuente de verdad del historial** (push/replace/pop…).
* `MyRouteInformationParser`: URL ⇄ `NavStackModel`.
* `MyAppRouterDelegate`: `PageManager` ⇄ `Navigator`.
* `AppManager`: fachada (navegación + módulos transversales).
* `JocaaguraApp`: shell que inyecta `AppManager` y crea el Router.

**Claves operativas**

* El **Router** siembra la URL inicial.
* Con `seedInitialFromPageManager: true`, `JocaaguraApp` usa la **página top del `PageManager`** como ruta inicial (evita que el Router “pise” tu stack).

---

## 2. Patrón oficial de Splash (una sola vez por sesión)

**Objetivo**

```
Usuario abre app → Splash (onboarding/configuración) → Home
Splash NO vuelve a mostrarse en la sesión (salvo intención explícita).
```

**Contratos**

1. `PageRegistry.defaultPage = Home`.
2. Decide **una vez**: `initial = (_onboardingDone ? Home : Splash)`.
3. Crea `PageManager(initial: NavStackModel.single(initial))`.
4. `BlocOnboarding.configure(steps)` y `start()` **solo si** `initial == Splash`.
5. Paso final → `replaceTop(Home)` y `_onboardingDone = true`.
6. **Guard en Splash**: si `_onboardingDone` o estado `completed/skipped`, redirigir **inmediato** a Home (evita reasignación del onboarding).

**Shell recomendado**

```
runApp(JocaaguraApp(
  appManager: appManager,
  registry: pageRegistry,
  seedInitialFromPageManager: true, // toma la ruta inicial del PageManager.top
  // initialLocation opcional si usas el seed
));
```

---

## 3. Implementación de referencia (mínima y probada)

```
// === Registry estable ===
final PageRegistry pageRegistry = PageRegistry.fromDefs(
  <PageDef>[
    PageDef(model: SplashPage.pageModel, builder: (_, __) => const SplashPage()),
    PageDef(model: HomePage.pageModel,   builder: (_, __) => const HomePage()),
  ],
  defaultPage: HomePage.pageModel, // <- NUNCA Splash
);

// === Gate en memoria (una vez por sesión) ===
bool _onboardingDone = false;
PageModel initial() => _onboardingDone ? HomePage.pageModel : SplashPage.pageModel;
final PageManager pageManager = PageManager(initial: NavStackModel.single(initial()));

// === Onboarding ===
final BlocOnboarding onboarding = BlocOnboarding()
  ..configure(<OnboardingStep>[
    const OnboardingStep(title: 'Verificando ambiente', autoAdvanceAfter: Duration(milliseconds: 800)),
    OnboardingStep(
      title: 'Finalizando',
      onEnter: () {
        _onboardingDone = true;
        pageManager.replaceTop(HomePage.pageModel);
        return Right<ErrorItem, Unit>(Unit.value);
      },
    ),
  ]);

if (!_onboardingDone && pageManager.topOrNull == SplashPage.pageModel) {
  onboarding.start();
}

// === Shell ===
runApp(JocaaguraApp(
  appManager: AppManager(AppConfig(
    pageManager: pageManager,
    blocOnboarding: onboarding,
    // ... otros blocs
  )),
  registry: pageRegistry,
  seedInitialFromPageManager: true,
));

// === Guard en Splash ===
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  static const PageModel pageModel = PageModel(name: 'splash');

  @override
  Widget build(BuildContext context) {
    final BlocOnboarding ob = context.appManager.onboarding;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_onboardingDone) {
        context.appManager.replaceTopModel(HomePage.pageModel);
      } else if (ob.state.status == OnboardingStatus.idle) {
        ob.start();
      }
    });
    return OnBoardingPage(blocOnboarding: ob);
  }
}
```

**Notas**

* Usa **`replaceTop(Home)`** (no `push`) al completar.
* Si alguien navega a `'/splash'` luego, el **guard** lo redirige de inmediato.

---

## 4. Variables de entorno (Flutter/Dart)

**Qué son**

Valores **de compilación** (“horneados”) que se leen con:

* `String.fromEnvironment('KEY', defaultValue: '...')`
* `int.fromEnvironment('KEY', defaultValue: 0)`
* `bool.fromEnvironment('KEY', defaultValue: false)`

> No leen env del SO. Se pasan con `--dart-define` o **`--dart-define-from-file`**.
> No almacenar secretos.

**Archivo recomendado por flavor**

```
env/
  dev.env
  qa.env
  prod.env
```

**Formato `.env`**

```
APP_MODE=dev
API_BASE_URL=https://dev.api.tuapp.com
FEATURE_X=true
AUTO_ADVANCE_AFTER=1200
```

**Ejecución/Build**

```bash
# Run local
flutter run --dart-define-from-file=env/dev.env

# Build Android
flutter build apk --dart-define-from-file=env/qa.env

# Build iOS
flutter build ipa --dart-define-from-file=env/prod.env

# Tests
flutter test --dart-define-from-file=env/dev.env
```

**Ejemplo de lectura**

```dart
class AppEnv {
  static const String mode =
      String.fromEnvironment('APP_MODE', defaultValue: 'dev');

  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

  static const bool featureX =
      bool.fromEnvironment('FEATURE_X', defaultValue: false);

  static const Duration autoAdvanceAfter = Duration(
    milliseconds: int.fromEnvironment('AUTO_ADVANCE_AFTER', defaultValue: 1500),
  );
}
```

**Android Studio (Run/Debug Configurations)**

* Usar **Additional run args**:

    * `--dart-define-from-file=env/dev.env`
* Dejar vacío “Environment variables” (no aplica).

---

## 5. Matriz de escenarios (Splash + Router)

| Escenario                                | Registry.default | initial (stack) | Router seed         | Resultado                              |
|------------------------------------------|------------------|-----------------|---------------------|----------------------------------------|
| 1. Primera sesión                        | Home             | Splash          | **PageManager.top** | Splash → onboarding → replaceTop(Home) |
| 2. Misma sesión                          | Home             | Home            | PageManager.top     | Home directo                           |
| 3. Deep link a `/splash` tras completar  | Home             | –               | URL externa         | Guard redirige a Home                  |
| 4. Sin pasos (saltarse Splash)           | Home             | Splash          | PageManager.top     | replaceTop(Home) inmediato             |
| 5. Sin seed y `initialLocation: '/home'` | Home             | Splash          | `'/home'`           | Router pisa Splash y muestra Home      |

---

## 6. Checklist de implementación

* [ ] `defaultPage = Home` en el `PageRegistry`.
* [ ] `initial = _onboardingDone ? Home : Splash`.
* [ ] `PageManager` creado con `initial`.
* [ ] `onboarding.configure()` + `start()` **solo** si `initial == Splash`.
* [ ] Último paso: `replaceTop(Home)` y `_onboardingDone = true`.
* [ ] Guard en `SplashPage` (redirige si ya terminó).
* [ ] `JocaaguraApp(seedInitialFromPageManager: true)`.
* [ ] Variables desde archivo `.env` por flavor (run/build/test).

---

## 7. Pruebas sugeridas (sin paquetes externos)

**Caso feliz**

* Arrange: `_onboardingDone = false`, initial = Splash.
* Act: completar onboarding.
* Assert: `top == Home` y `_onboardingDone == true`.

**Reingreso**

* Arrange: `_onboardingDone = true`.
* Assert: pila inicial en Home, sin Splash.

**Deep link a Splash**

* Arrange: `_onboardingDone = true`.
* Act: navegar a `/splash`.
* Assert: guard → `replaceTop(Home)`.

**Router seed**

* Arrange: `seedInitialFromPageManager = true`, initial top `Splash`.
* Assert: URL inicial del provider coincide con `/splash`.

---

## 8. FAQ

**¿Por qué antes veía “flash” de Splash y terminaba en Home?**
El Router sembraba `'/home'` y reemplazaba tu tope. Activa `seedInitialFromPageManager` o alinea `initialLocation` a la página inicial real.

**¿Cómo evito que “vuelvan” a Splash?**

* `defaultPage = Home`,
* Guard en `SplashPage`,
* No hagas `push(Splash)` después de completar.

**¿Puedo saltarme Splash si no hay trabajo que hacer?**
Sí: define pasos vacíos o `skip()` en el primer paso y haz `replaceTop(Home)` inmediato.

---

## 9. Apéndice · DartDoc sugerida (pública en el arquetipo)

```dart
/// JocaaguraApp: top-level shell that wires AppManager to Flutter Router.
///
/// Splash flow (once per session):
/// - Seed PageManager with either Splash or Home (based on a one-time gate).
/// - Configure+start onboarding only when initial == Splash.
/// - On completion: replaceTop(Home) and mark the gate as done.
/// - Guard SplashPage to auto-redirect to Home if onboarding is done.
///
/// Environment config:
/// - Use `--dart-define-from-file=env/<mode>.env`.
/// - Read with `String/int/bool.fromEnvironment`.
///
/// Recommended:
/// - `seedInitialFromPageManager: true` to keep the initial stack ownership.
```

---

## 10. Conclusión

* El **patrón único de Splash** asegura una experiencia consistente, sin reentradas accidentales.
* La **configuración por archivo `.env`** hace reproducibles los entornos y limpia los comandos.
* `seedInitialFromPageManager` protege el stack inicial en el primer sync del Router.

> Con esto, las apps que ya están en producción siguen funcionando (retrocompatible) y los nuevos proyectos tienen una ruta clara y estable.
