# App Jocaagura: Session + Design System + ACL (guía profesional)

Este documento describe, paso a paso, cómo implementar una app **al estilo Jocaagura** con:

- **Navegación por stack** (`PageManager`)
- **Flujo de sesión plug-and-play** (`JocaaguraAppWithSession`)
- **Material Design / ThemeMode** (`BlocTheme` + `ThemeState`)
- **Design System importable desde JSON** (`BlocDesignSystem`)
- **ACL deny-by-default** (UI gating + navegación + ejecución de acciones)

> **Meta:** que todo sea **copiable, verificable y consistente**: una única instancia por BLoC, rutas determinísticas, y políticas claras.

---

## 1) Arquitectura mental en 30 segundos

### 1.1 Componentes y responsabilidades

- **`PageManager`**: dueña del stack (push/reset/replaceTop).
- **`PageRegistry`**: mapea `PageModel` → widget builder.
- **`AppManager`**: orquesta módulos (theme, DS, onboarding, notifications, menus…).
- **`BlocSession`**: estado de sesión (Unauthenticated / Authenticating / Authenticated / SessionError…).
- **`JocaaguraAppWithSession`**: wrapper que conecta `AppManager + Registry + SessionBloc + SessionPages`
  y aplica la política de navegación (SessionAppManager).

### 1.2 Flujo de navegación esperado

```text
Splash (onboarding)
  ├─ importa DS (JSON)
  ├─ boot de sesión
  └─ entra a HomePublic

HomePublic
  └─ Login

Login
  ├─ Authenticating (overlay page)
  └─ HomeAuthenticated (si OK) / SessionError (si falla)

HomeAuthenticated
  ├─ rutas protegidas (ACL)
  └─ logout → SessionClosed → HomePublic
```

---

## 2) Regla de oro: rutas sin 404

El 90% de los 404 en demos vienen de `PageModel` inconsistentes.

✅ **Regla Jocaagura:** todas las páginas deben tener `segments: [name]`.

```dart
static const String name = 'login';
static const PageModel pageModel =
    PageModel(name: name, segments: <String>[name]);
```

**Qué evita esto:**

* `404 — /` (segments vacíos)
* `404 — /login` (mismatch entre `/login` y `login`)
* inconsistencias entre `initialLocation` y `pageManager.stack.top`

---

## 3) SessionPages: el contrato explícito de sesión

Tu app debe declarar **las 7 páginas canónicas**:

* `SplashPage`
* `HomePublicPage`
* `LoginPage`
* `HomeAuthenticatedPage`
* `SessionClosedPage`
* `AuthenticatingPage`
* `SessionErrorPage`

```dart
const SessionPages sessionPages = SessionPages(
  splash: SplashPage.pageModel,
  homePublic: HomePublicPage.pageModel,
  login: LoginPage.pageModel,
  homeAuthenticated: HomeAuthenticatedPage.pageModel,
  sessionClosed: SessionClosedPage.pageModel,
  authenticating: AuthenticatingPage.pageModel,
  sessionError: SessionErrorPage.pageModel,
);
```

✅ **Check rápido:**

* esas 7 pages existen
* esas 7 pages están en `PageRegistry`

---

## 4) PageRegistry (con PageDef): registro determinístico

Se recomienda registrar páginas vía `PageDef` para eliminar ambigüedades:

```dart
final List<PageDef> defs = <PageDef>[
  PageDef(model: SplashPage.pageModel, builder: (_, __) => const SplashPage()),
  PageDef(model: HomePublicPage.pageModel, builder: (_, __) => const HomePublicPage()),
  PageDef(model: LoginPage.pageModel, builder: (_, __) => const LoginPage()),
  // ... todas las demás
];

final PageRegistry registry =
    PageRegistry.fromDefs(defs, defaultPage: HomePublicPage.pageModel);
```

✅ **Regla:** `defaultPage` debe ser una `PageModel` válida.

---

## 5) PageManager: stack inicial en Splash

```dart
final PageManager pageManager =
    PageManager(initial: NavStackModel.single(SplashPage.pageModel));
```

✅ **Invariante:** si el stack inicial no es Splash, el onboarding no manda.

---

## 6) Material Design: ThemeMode (BlocTheme + ThemeState)

### 6.1 Repo mínimo (demo) o real (producción)

```dart
class RepositoryThemeForExample implements RepositoryTheme {
  @override
  Future<Either<ErrorItem, ThemeState>> read() async =>
      Right<ErrorItem, ThemeState>(ThemeState.defaults);

  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState next) async =>
      Right<ErrorItem, ThemeState>(next);
}
```

### 6.2 BlocTheme

```dart
final RepositoryTheme repositoryTheme = RepositoryThemeForExample();
final BlocTheme blocTheme =
    BlocTheme(themeUsecases: ThemeUsecases.fromRepo(repositoryTheme));
```

### 6.3 Uso desde UI

```dart
void main(){
appManager.theme.setMode(ThemeMode.dark);
appManager.theme.setMode(ThemeMode.light);
}
```

✅ **Resultado:** la app controla `ThemeMode` de forma consistente (y persistible).

---

## 7) Design System (DS): DS-first + import desde JSON

### 7.1 DS fallback (siempre válido)

Arranca con un DS básico (para evitar “pantalla en blanco” si el JSON falla):

```dart
final ModelDesignSystem initialDs = ModelDesignSystem(
  theme: ModelDesignSystem.fromThemeData(
    lightTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
    darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark)),
  ),
  tokens: const ModelDsExtendedTokens(),
  semanticLight: ModelSemanticColors.fallbackLight(),
  semanticDark: ModelSemanticColors.fallbackDark(),
  dataViz: ModelDataVizPalette.fallback(),
);

final BlocDesignSystem blocDs = BlocDesignSystem(initialDs);
```

### 7.2 Parse seguro

```dart
ModelDesignSystem? parseDsJsonOrNull(String raw) {
  try {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    return ModelDesignSystem.fromJson(decoded);
  } catch (_) {
    return null;
  }
}
```

### 7.3 Import en onboarding (recomendado)

En un `OnboardingStep`:

```dart
void main(){
  final ModelDesignSystem? parsed = parseDsJsonOrNull(kDsJson);
  if (parsed != null) {
    blocDs.setNewDs(parsed);
  }
}
```

✅ **Resultado:** DS queda activo antes de Home (o al menos muy temprano), sin bloquear.

---

## 8) Sesión: BlocSession (fake o real)

### 8.1 Demo (FakeRepositoryAuth)

Se implementa un `RepositoryAuth` que emite `authStateChanges()` y soporta `logIn/logOut`.

✅ **Regla:** la instancia registrada en `AppConfig.blocModuleList` es la misma que pasas a `JocaaguraAppWithSession`.

```dart
final BlocSession sessionBloc =
    appManager.requireModuleByKey<BlocSession>(BlocSession.name);
```

---

## 9) ACL: deny-by-default (tres niveles de enforcement)

### 9.1 Objetivo del ACL

* Proteger **pantallas** (navegación)
* Proteger **componentes** (UI gating)
* Proteger **operaciones** (acciones)

✅ **Regla:** si el policy no existe → `false` (deny-by-default).

### 9.2 Policies y roles

```dart
abstract final class DemoPolicies {
  static const String viewer = 'demo.policy.viewer';
  static const String editor = 'demo.policy.editor';
  static const String admin = 'demo.policy.admin';
}
```

### 9.3 UI gating

```dart
void main(){
  final bool allowed = appManager.blocAcl.canRenderWithAcl(DemoPolicies.admin);
  return allowed ? AdminButton() : const SizedBox.shrink();
}
```

### 9.4 Navegación protegida con fallback

```dart
Future<void> main() async{
  await appManager.pushWithAcl(
    AdminPage.pageModel,
    policyId: DemoPolicies.admin,
    forbiddenPage: ForbiddenPage.pageModel,
  );
}
```

### 9.5 Acción protegida (use case / botón / operación)

```dart
Future<void> main() async{

  final Either<ErrorItem, Unit> r = await appManager.executeWithAcl<Unit>(
    policyId: DemoPolicies.editor,
    action: () async => Right<ErrorItem, Unit>(unit),
  );
}
```

### 9.6 Sincronizar ACL con el login

Después de un login exitoso:

```dart
void main(){
appManager.blocAcl.setEmail(user.email);
}
```

✅ **Resultado:** tu rol ACL “sigue” a la sesión en el demo.

---

## 10) Menús dinámicos (logged-in vs logged-out)

`JocaaguraAppWithSession` ejecuta hooks de menú por estado de sesión:

* `configureMenusForLoggedOut(app)`
* `configureMenusForLoggedIn(app)`

Ejemplo de logged-in (con ACL):

* Home Auth
* Viewer / Editor / Admin (vía `pushWithAcl`)
* Logout

✅ **Recomendación:** el menú es la forma más elegante de demostrar el flujo “estado → navegación”.

---

## 11) Onboarding profesional: DS + session.boot + Finish

Un onboarding robusto y didáctico suele tener:

1. **Boot** (visual)
2. **Import DS**
3. **Session boot**
4. **Finish** → ir a HomePublic

Arranque:

```dart
void main(){
  if (pageManager.stack.top == SplashPage.pageModel) {
    appManager.onboarding.start();
  }
}
```

✅ **Invariante de sesión:** mientras el top sea Splash, el SessionAppManager no debería forzar el stack.

---

## 12) runApp correcto (todo conectado)

```dart
void main(){

  runApp(
    JocaaguraAppWithSession(
      appManager: appManager,
      registry: registry,
      sessionBloc: sessionBloc,
      sessionPages: sessionPages,
      seedInitialFromPageManager: true,
      initialLocation: SplashPage.pageModel.toUriString(),
      configureMenusForLoggedIn: _setupMenusForLoggedIn,
      configureMenusForLoggedOut: _setupMenusForLoggedOut,
    ),
  );
  
}
```

✅ Esto garantiza:

* navegación consistente (PageManager manda)
* sesión consistente (BlocSession manda)
* DS-first (BlocDesignSystem manda)
* ACL coherente (deny-by-default)

---

# Checklist final (antes de documentar / publicar)

## Rutas y navegación

* [ ] Todas las páginas tienen `segments: [name]`.
* [ ] `PageRegistry` registra TODAS las páginas del app, especialmente las 7 de `SessionPages`.
* [ ] `PageManager` inicia con `SplashPage.pageModel`.
* [ ] `initialLocation == SplashPage.pageModel.toUriString()`.

## Sesión

* [ ] `BlocSession` registrado en `AppConfig.blocModuleList`.
* [ ] El `sessionBloc` pasado al wrapper es el MISMO objeto.

## Design System

* [ ] `BlocDesignSystem` registrado en módulos.
* [ ] DS fallback válido.
* [ ] Import JSON seguro (no rompe si falla).

## Theme (Material)

* [ ] `BlocTheme` en `AppConfig`.
* [ ] UI puede cambiar `ThemeMode` sin inconsistencias.

## ACL

* [ ] deny-by-default (policy missing → false).
* [ ] gating UI + navegación + acción.
* [ ] login sincroniza el “usuario activo” del ACL.

---

# Appendix: patrones recomendados

## A) Evitar duplicar navegación string

✅ Preferir siempre: `pageManager.resetTo(PageModel)` / `pushModel(PageModel)`
❌ Evitar: `goTo('/login')` salvo casos muy específicos de deep links.

## B) `requiresAuth: true` solo donde aplique

* HomeAuthenticated: sí
* Protected pages: sí
* HomePublic / Login / Splash / SessionError: no

## C) DS tokens seguros

Usa:

```dart
final ModelDsExtendedTokens tok = context.dsTokens;
```

y si estás en frames tempranos o casos especiales, un fallback:

```dart
ModelDsExtendedTokens _safeTokens(BuildContext context) {
  try { return context.dsTokens; } catch (_) { return const ModelDsExtendedTokens(); }
}
```
