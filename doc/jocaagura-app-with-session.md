# `JocaaguraAppWithSession`

*Flujo de sesión plug-and-play sobre `JocaaguraApp`*

Este documento explica cómo usar `JocaaguraAppWithSession` para tener:

* Navegación **consciente de sesión** (login / logout / errores).
* Menús que cambian automáticamente según el estado de sesión.
* Un flujo de *Splash → Home público → Login → Home autenticado → Logout* listo para copiar y pegar.
* Un **helper de desarrollo** con `FakeServiceSession` para probar rápido sin backend real.

---

## 1. ¿Qué es `JocaaguraAppWithSession`?

Es un **wrapper de alto nivel** que se sienta por encima de `JocaaguraApp` y conecta tres piezas:

1. `AppManager` + `PageRegistry` → se los pasa a `JocaaguraApp` (router, theming, menús, etc.).
2. `BlocSession` → expone el estado de sesión (`Unauthenticated`, `Authenticating`, `Authenticated`, `SessionError`, etc.).
3. `SessionAppManager` → aplica una **política de navegación** según el estado de sesión y configura menús.

Visualmente:

```text
runApp(
  JocaaguraAppWithSession(
    appManager: ...,
    registry: ...,
    sessionBloc: ...,
    splashPage: ...,
    homePublicPage: ...,
    loginPage: ...,
    homeAuthenticatedPage: ...,
    ...
  ),
);

    │
    ▼
JocaaguraAppWithSession
    │    (crea y posee SessionAppManager)
    ▼
JocaaguraApp
    │
    ▼
MaterialApp.router + PageManager + AppManager
```

---

## 2. Responsabilidades

### 2.1. `JocaaguraAppWithSession`

* Recibe:

    * `AppManager`
    * `PageRegistry`
    * `BlocSession`
    * `PageModel`s canónicos de sesión:

        * `splashPage`
        * `homePublicPage`
        * `loginPage`
        * `homeAuthenticatedPage`
        * `sessionClosedPage`
        * `authenticatingPage`
        * `sessionErrorPage`
    * Hooks de menú:

        * `configureMenusForLoggedIn(AppManager app)`
        * `configureMenusForLoggedOut(AppManager app)`
* Crea (o recibe) una instancia de `SessionAppManager`.
* Renderiza un `JocaaguraApp` normal, pero **sin** que éste sea dueño del `AppManager` (el dueño es el wrapper).
* En `dispose()`:

    * Hace `appManager.dispose()` si no está ya destruido.
    * Hace `sessionAppManager.dispose()` si fue creado internamente.

### 2.2. `SessionAppManager`

Se suscribe a:

* `sessionBloc` → cambios en `SessionState`.
* `pageManager.stackStream` → cambios en el `NavStackModel`.

Y garantiza las siguientes invariantes de navegación (simplificadas):

* **Splash**
  Mientras la top sea `splashPage`, no fuerza nada.

* **Unauthenticated**

    * Si estás en página `requiresAuth` → guarda la intención y hace `resetTo(loginPage)`.
    * Si estás en `homeAuthenticatedPage` o `sessionErrorPage` → hace `resetTo(homePublicPage)`.

* **Authenticating**

    * Colapsa el stack a `[authenticatingPage]`.

* **SessionError**

    * Si estabas en protegida → guarda stack en `_pending`.
    * Hace `resetTo(sessionErrorPage)`.

* **Authenticated / Refreshing**

    * Si hay `_pending` → restaura el stack de negocio.
    * Si estabas en `login` o `sessionClosed` → `resetTo(homeAuthenticatedPage)`.
    * Si estabas en `authenticatingPage` → `resetTo(homeAuthenticatedPage)`.
    * Si el stack tiene una sola página que **no es** de sesión ni `homeAuthenticatedPage` → `resetTo(homeAuthenticatedPage)` (normalización).

Además, en cada cambio de sesión ejecuta:

```dart
void _applyMenusForState(SessionState state) {
  if (_isAuthed(state)) {
    configureMenusForLoggedIn?.call(appManager);
  } else {
    configureMenusForLoggedOut?.call(appManager);
  }
}
```

---

## 3. API pública de `JocaaguraAppWithSession`

### 3.1. Constructor principal

Uso cuando ya tienes tu propio `BlocSession` (dominio real):

```
JocaaguraAppWithSession(
  appManager: appManager,
  registry: registry,
  sessionBloc: sessionBloc,
  splashPage: SplashPage.pageModel,
  homePublicPage: HomePage.pageModel,
  loginPage: LoginPage.pageModel,
  homeAuthenticatedPage: HomeAuthenticatedPage.pageModel,
  sessionClosedPage: SessionClosedPage.pageModel,
  authenticatingPage: AuthenticatingPage.pageModel,
  sessionErrorPage: SessionErrorPage.pageModel,
  projectorMode: false,
  initialLocation: '/home',
  seedInitialFromPageManager: true,
  splashOverlayBuilder: null,
  configureMenusForLoggedIn: _setupMenusForLoggedIn,
  configureMenusForLoggedOut: _setupMenusForLoggedOut,
);
```

### 3.2. `factory JocaaguraAppWithSession.dev`

Uso cuando quieres un flujo de sesión listo para jugar **en modo desarrollo**, sin wiring de backend:

```
factory JocaaguraAppWithSession.dev({
  required AppManager appManager,
  required PageRegistry registry,
  required PageModel splashPage,
  required PageModel homePublicPage,
  required PageModel loginPage,
  required PageModel homeAuthenticatedPage,
  required PageModel sessionClosedPage,
  required PageModel authenticatingPage,
  required PageModel sessionErrorPage,
  required void Function(AppManager app) configureMenusForLoggedIn,
  required void Function(AppManager app) configureMenusForLoggedOut,
  BlocSession? sessionBloc,          // opcional: se usa si lo pasas
  bool isSessionInitialized = false, // helper FakeServiceSession
  Map<String, dynamic>? initialUserJson,
  bool projectorMode = false,
  String initialLocation = '/home',
  bool seedInitialFromPageManager = true,
  Widget Function(BuildContext, OnboardingState)? splashOverlayBuilder,
  SessionAppManager? sessionAppManager,
  Key? key,
})
```

Si **no** pasas `sessionBloc`, la factory crea uno usando:

```dart
BlocSession _buildDevSessionBloc({
  required bool isSessionInitialized,
  Map<String, dynamic>? initialUserJson,
}) {
  final GatewayAuth gatewayAuth = GatewayAuthImpl(
    FakeServiceSession(
      initialUserJson: isSessionInitialized ? initialUserJson : null,
    ),
  );

  final RepositoryAuth repositoryAuth =
      RepositoryAuthImpl(gateway: gatewayAuth);

  return BlocSession.fromRepository(repository: repositoryAuth);
}
```

En el ejemplo completo de abajo, usamos el `BlocSession` que ya está registrado en `AppManager` para que **todo comparta la misma instancia**.

---

## 4. Ejemplo completo listo para copiar y pegar

Este ejemplo muestra:

* Splash con onboarding simple.
* `HomePage` pública.
* `LoginPage` usando `BlocSession.logIn`.
* `HomeAuthenticatedPage` para usuarios autenticados.
* `CounterPage` protegida (`requiresAuth: true`).
* Menús dinámicos:

    * Sin sesión → “Go to Login”.
    * Con sesión → “Go to Counter” + “Sign out”.
* Wiring con `JocaaguraAppWithSession.dev`.

> Puedes copiar este archivo como `main.dart` en el `example/` de tu paquete.

```dart
import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ===========================================
/// 0) ENV VARS (compile-time)
/// ===========================================
const String env = String.fromEnvironment('APP_MODE', defaultValue: 'dev');

/// Decide si la app inicia con sesión iniciada (por defecto TRUE)
const bool kIsSessionInitialized =
    bool.fromEnvironment('IS_SESSION_INITIALIZATED', defaultValue: true);

/// Delay para steps automáticos del Splash (ajustable por env si quieres)
const Duration autoAdvanceAfter = Duration(
  milliseconds: int.fromEnvironment('AUTO_ADVANCE_AFTER', defaultValue: 700),
);

/// ===========================================
/// 1) MODELOS DE PÁGINA + REGISTRO + MANAGER
/// ===========================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const String name = 'home';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    return const PageBuilder(
      page: Center(child: Text('HOME · Bienvenid@')),
    );
  }
}

class HomeAuthenticatedPage extends StatelessWidget {
  const HomeAuthenticatedPage({super.key});
  static const String name = 'homeAuthenticated';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    final BlocSession blocSession =
        context.appManager.requireModuleByKey<BlocSession>(BlocSession.name);
    return PageBuilder(
      page: Center(child: Text('${blocSession.state} · Bienvenid@')),
    );
  }
}

class SessionErrorPage extends StatelessWidget {
  const SessionErrorPage({super.key});
  static const String name = 'sessionError';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    final BlocSession blocSession =
        app.requireModuleByKey<BlocSession>(BlocSession.name);
    return Scaffold(
      body: InkWell(
        onTap: () {
          app.pageManager.resetTo(HomePage.pageModel);
        },
        child: Center(
          child: Text('Session Error · ${blocSession.state}'),
        ),
      ),
    );
  }
}

class AuthenticatingPage extends StatelessWidget {
  const AuthenticatingPage({super.key});
  static const String name = 'authenticating';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    return const PageBuilder(
      showAppBar: false,
      page: Center(child: CircularProgressIndicator()),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  static const String name = 'login';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    final BlocSession bloc = app.requireModuleByKey(BlocSession.name);

    String email = bloc.currentUser.email;
    String pass = '';
    return PageBuilder(
      page: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<SessionState>(
          stream: bloc.stream,
          builder: (_, __) {
            if (bloc.state is Authenticating) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              children: <Widget>[
                Text(
                  'Login (anonimo@anonimo.com.co / 12345)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: (String v) => email = v,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onChanged: (String v) => pass = v,
                  onSubmitted: (_) async {
                    final Either<ErrorItem, UserModel> r =
                        await bloc.logIn(email: email, password: pass);
                    r.fold(
                      (ErrorItem e) => app.notifications.showToast(e.title),
                      (_) => app.notifications.showToast('Login OK'),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final Either<ErrorItem, UserModel> r =
                        await bloc.logIn(email: email, password: pass);
                    r.fold(
                      (ErrorItem e) =>
                          app.notifications.showToast(e.title),
                      (_) {
                        app.notifications.showToast('Login OK');
                      },
                    );
                  },
                  child: const Text('Sign in'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SessionClosedPage extends StatelessWidget {
  const SessionClosedPage({super.key});
  static const String name = 'session_closed';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    context.appManager.responsive.showAppbar = false;
    return PageBuilder(
      page: InkWell(
        onTap: () {
          context.appManager.responsive.showAppbar = true;
          context.appManager.pageManager.resetTo(HomePage.pageModel);
        },
        child: const Center(child: Text('Session Closed press to go to Home')),
      ),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  static const String name = 'counter';
  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>[name],
    requiresAuth: true, // 🔐 protegida
  );

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  late BlocSecondaryMenuDrawer _sec;
  late BlocCounter _counter;
  bool _wired = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) {
      return;
    }

    final AppManager app = context.appManager;
    _sec = app.secondaryMenu;
    _counter = app.requireModuleByKey(BlocCounter.name);

    _sec.clearSecondaryDrawer();
    _sec.addSecondaryMenuOption(
      label: 'Increment',
      iconData: Icons.add,
      onPressed: _counter.increment,
      description: 'Add 1',
    );
    _sec.addSecondaryMenuOption(
      label: 'Decrement',
      iconData: Icons.remove,
      onPressed: _counter.decrement,
      description: 'Substract 1',
    );
    _sec.addSecondaryMenuOption(
      label: 'Reset',
      iconData: Icons.refresh,
      onPressed: _counter.reset,
      description: 'Reset counter',
    );

    _wired = true;
  }

  @override
  void dispose() {
    if (_wired) {
      _sec.clearSecondaryDrawer();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BlocResponsive r = context.appManager.responsive;
    r.showAppbar = true;
    final BlocCounter blocCounter =
        context.appManager.requireModuleByKey<BlocCounter>(BlocCounter.name);

    return PageBuilder(
      page: PageWithSecondaryMenuWidget(
        responsive: r,
        content: Center(
          child: StreamBuilder<int>(
            stream: blocCounter.stream,
            initialData: blocCounter.value,
            builder: (_, AsyncSnapshot<int> snap) => Text(
              'Counter: ${blocCounter.value}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
        secondaryMenu: StreamBuilder<List<ModelMainMenuModel>>(
          stream: context.appManager.secondaryMenu.itemsStream,
          initialData: context.appManager.secondaryMenu.items,
          builder: (_, AsyncSnapshot<List<ModelMainMenuModel>> snap) {
            final List<ModelMainMenuModel> items =
                snap.data ?? const <ModelMainMenuModel>[];
            if (items.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: items
                  .map(
                    (ModelMainMenuModel it) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ElevatedButton.icon(
                        onPressed: it.onPressed,
                        icon: Icon(it.iconData),
                        label: Text(it.label),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

/// ===========================================
/// 2) BLoC mínimo: Counter
/// ===========================================
class BlocCounter extends BlocModule {
  BlocCounter([int initial = 0]) {
    _value.value = initial;
  }

  static const String name = 'BlocCounter';

  final BlocGeneral<int> _value = BlocGeneral<int>(0);
  int get value => _value.value;
  Stream<int> get stream => _value.stream;

  void increment() => _value.value = _value.value + 1;
  void decrement() => _value.value = _value.value - 1;
  void reset() => _value.value = 0;

  bool _isDisposed = false;

  @override
  FutureOr<void> dispose() {
    if (!_isDisposed) {
      _value.dispose();
      _isDisposed = true;
    }
  }
}

/// Hooks de menús (usados por JocaaguraAppWithSession)
void _setupMenusForLoggedIn(AppManager app) {
  app.secondaryMenu.clearSecondaryDrawer();
  app.mainMenu.clearMainDrawer();

  app.mainMenu.addMainMenuOption(
    label: 'Go to Counter',
    iconData: Icons.calculate_outlined,
    onPressed: () => app.pushModel(CounterPage.pageModel),
  );
  app.mainMenu.addMainMenuOption(
    label: 'Sign out',
    iconData: Icons.logout,
    onPressed: () async {
      final BlocSession s = app.requireModuleByKey(BlocSession.name);
      await s.logOut();
      _setupMenusForLoggedOut(app);
      app.pageManager.resetTo(SessionClosedPage.pageModel);
      app.notifications.showToast('Signed out');
    },
  );
}

void _setupMenusForLoggedOut(AppManager app) {
  app.secondaryMenu.clearSecondaryDrawer();
  app.mainMenu.clearMainDrawer();
  app.mainMenu.addMainMenuOption(
    label: 'Go to Login',
    iconData: Icons.login,
    onPressed: () => app.pushModel(LoginPage.pageModel),
  );
}

/// ===========================================
/// 4) REGISTRY + PAGE MANAGER + ONBOARDING
/// ===========================================
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  static const String name = 'splash';
  static const PageModel pageModel = PageModel(name: name);

  @override
  Widget build(BuildContext context) {
    final BlocOnboarding ob = context.appManager.onboarding;
    return OnBoardingPage(blocOnboarding: ob);
  }
}

bool _onboardingDone = false;

final List<PageDef> defs = <PageDef>[
  PageDef(model: SplashPage.pageModel, builder: (_, __) => const SplashPage()),
  PageDef(model: HomePage.pageModel, builder: (_, __) => const HomePage()),
  PageDef(model: LoginPage.pageModel, builder: (_, __) => const LoginPage()),
  PageDef(
    model: SessionClosedPage.pageModel,
    builder: (_, __) => const SessionClosedPage(),
  ),
  PageDef(
    model: CounterPage.pageModel,
    builder: (_, __) => const CounterPage(),
  ),
  PageDef(
    model: AuthenticatingPage.pageModel,
    builder: (_, __) => const AuthenticatingPage(),
  ),
  PageDef(
    model: HomeAuthenticatedPage.pageModel,
    builder: (_, __) => const HomeAuthenticatedPage(),
  ),
  PageDef(
    model: SessionErrorPage.pageModel,
    builder: (_, __) => const SessionErrorPage(),
  ),
];

final PageRegistry registry =
    PageRegistry.fromDefs(defs, defaultPage: HomePage.pageModel);

PageModel initial() =>
    _onboardingDone ? HomePage.pageModel : SplashPage.pageModel;

final PageManager pageManager =
    PageManager(initial: NavStackModel.single(initial()));

AppManager buildAppManager() {
  // Theme mínimo
  final RepositoryThemeReact themeRepo = RepositoryThemeReactImpl(
    gateway: GatewayThemeReactImpl(service: FakeServiceThemeReact()),
  );
  final ThemeUsecases themeUsecases = ThemeUsecases.fromRepo(themeRepo);
  final WatchTheme watchTheme = WatchTheme(themeRepo);

  // Auth (con FakeServiceSession que respeta IS_SESSION_INITIALIZATED)
  final GatewayAuth gatewayAuth = GatewayAuthImpl(
    FakeServiceSession(
      initialUserJson: kIsSessionInitialized ? defaultUserModel.toJson() : null,
    ),
  );
  final RepositoryAuth repositoryAuthImpl =
      RepositoryAuthImpl(gateway: gatewayAuth);
  final BlocSession session =
      BlocSession.fromRepository(repository: repositoryAuthImpl);

  // Counter demo
  final BlocCounter counter = BlocCounter();

  // Onboarding → decide navegación inicial
  final BlocOnboarding onboarding = BlocOnboarding()
    ..configure(<OnboardingStep>[
      const OnboardingStep(
        title: 'Boot',
        description: 'Inicializando…',
        autoAdvanceAfter: autoAdvanceAfter,
      ),
      OnboardingStep(
        title: 'Check Session',
        description: 'Verificando sesión…',
        onEnter: () => Right<ErrorItem, Unit>(Unit.value),
        autoAdvanceAfter: autoAdvanceAfter,
      ),
      OnboardingStep(
        title: 'Finish',
        description: 'Entrando a Home…',
        onEnter: () {
          _onboardingDone = true;
          pageManager.replaceTop(HomePage.pageModel);
          return Right<ErrorItem, Unit>(Unit.value);
        },
      ),
    ]);

  // AppConfig con módulos registrados
  final AppConfig cfg = AppConfig(
    blocTheme:
        BlocThemeReact(themeUsecases: themeUsecases, watchTheme: watchTheme),
    blocUserNotifications: BlocUserNotifications(),
    blocLoading: BlocLoading(),
    blocMainMenuDrawer: BlocMainMenuDrawer(),
    blocSecondaryMenuDrawer: BlocSecondaryMenuDrawer(),
    blocResponsive: BlocResponsive(),
    blocOnboarding: onboarding,
    pageManager: pageManager,
    blocModuleList: <String, BlocModule>{
      BlocSession.name: session,
      BlocCounter.name: counter,
    },
  );

  return AppManager(cfg);
}

const SessionPages sessionPages = SessionPages(
  splash: SplashPage.pageModel,
  homePublic: HomePage.pageModel,
  login: LoginPage.pageModel,
  homeAuthenticated: HomeAuthenticatedPage.pageModel,
  sessionClosed: SessionClosedPage.pageModel,
  authenticating: AuthenticatingPage.pageModel,
  sessionError: SessionErrorPage.pageModel,
);

/// ===========================================
/// 5) MAIN con JocaaguraAppWithSession
/// ===========================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppManager am = buildAppManager();

  // Inicia Onboarding si top == Splash
  if (!_onboardingDone && pageManager.stack.top == SplashPage.pageModel) {
    am.onboarding.start();
  }
  final BlocSession session =
  am.requireModuleByKey<BlocSession>(BlocSession.name);
  runApp(
    JocaaguraAppWithSession.dev(
      appManager: am,
      sessionPages: sessionPages,
      registry: registry,
      isSessionInitialized: kIsSessionInitialized,
      initialUserJson: defaultUserModel.toJson(),
      sessionBloc: session,
      configureMenusForLoggedIn: _setupMenusForLoggedIn,
      configureMenusForLoggedOut: _setupMenusForLoggedOut,
    ),
  );
}
```

### Invariantes de navegación por estado de sesión

Unauthenticated  --login--> Authenticating --ok--> Authenticated
^                                          |
|                                          |
+------------------logout------------------+


Este es el contrato que garantiza `SessionAppManager` entre **estado de sesión** y **stack de navegación** (`NavStackModel`):

| Estado de sesión (`SessionState`) | Top esperado (`stack.top`)                    | Forma del stack                       | Notas de comportamiento                                                                                                                            |
|-----------------------------------|-----------------------------------------------|---------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| *Cualquiera* mientras Splash      | `splashPage`                                  | `[* , splashPage]` (libre)            | Mientras la top sea `splashPage`, **no se fuerza ninguna política**. El flujo de onboarding manda.                                                 |
| `Unauthenticated`                 | `loginPage`                                   | `[loginPage]` o `[loginPage, …]`      | Si la top es una página `requiresAuth` distinta de `login/sessionClosed`, se guarda `_pending` y se hace `resetTo(loginPage)`.                     |
| `Unauthenticated`                 | `homePublicPage`                              | `[homePublicPage]`                    | Si estabas en `homeAuthenticatedPage` o `sessionErrorPage`, el stack se colapsa a `homePublicPage`.                                                |
| `Authenticating`                  | `authenticatingPage`                          | `[authenticatingPage]`                | Si la top no es `authenticatingPage` o el stack tiene más de 1 página, se hace `resetTo(authenticatingPage)`.                                      |
| `SessionError`                    | `sessionErrorPage`                            | `[sessionErrorPage]`                  | Si estabas en protegida (≠ login), se guarda `_pending` y se hace `resetTo(sessionErrorPage)`.                                                     |
| `Authenticated` / `Refreshing`    | (restauración de intención)                   | `targetStack` (clonado de `_pending`) | Si `_pending != null`, se restaura ese stack. Si la top allí es `login/sessionClosed` y solo hay 1 página, se normaliza a `homeAuthenticatedPage`. |
| `Authenticated` / `Refreshing`    | `homeAuthenticatedPage` (post-login)          | `[homeAuthenticatedPage]`             | Si la top es `loginPage` o `sessionClosedPage` y `goHomeWhenAuthenticatedOnLogin == true`, se hace `resetTo(homeAuthenticatedPage)`.               |
| `Authenticated` / `Refreshing`    | `homeAuthenticatedPage` (post-authenticating) | `[homeAuthenticatedPage]`             | Si la top es `authenticatingPage`, al volverse authed se hace `resetTo(homeAuthenticatedPage)`.                                                    |
| `Authenticated` / `Refreshing`    | `homeAuthenticatedPage` (normalización base)  | `[homeAuthenticatedPage]`             | Si el stack tiene `length == 1` y la top no es ni página de sesión ni `homeAuthenticatedPage`, se normaliza a `homeAuthenticatedPage`.             |

**Resumen mental rápido**

* **Splash manda**: mientras la top sea `splashPage`, `SessionAppManager` no toca el stack.
* **Sin sesión**: base → `loginPage` (si venías de protegida) o `homePublicPage`.
* **Autenticando**: base → `authenticatingPage`.
* **Error de sesión**: base → `sessionErrorPage`, guardando intención si estabas en protegida.
* **Con sesión**:

    * Si hay intención previa (`_pending`) → se restaura.
    * Si estabas en login/closed/authenticating → se colapsa a `homeAuthenticatedPage`.
    * Si el stack es “raro pero simple” (una sola página no-de-sesión) → se normaliza también a `homeAuthenticatedPage`.
