import 'dart:async';

import 'package:flutter/material.dart';
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

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  static const String name = 'login';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    final BlocSession bloc =
        context.appManager.requireModuleByKey(BlocSession.name);

    String email = bloc.email;
    String pass = '';

    return PageBuilder(
      page: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                await _performLoginWithAuthenticatingPage(
                  context,
                  bloc,
                  email,
                  pass,
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _performLoginWithAuthenticatingPage(
                  context,
                  bloc,
                  email,
                  pass,
                );
              },
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performLoginWithAuthenticatingPage(
    BuildContext context,
    BlocSession bloc,
    String email,
    String pass,
  ) async {
    final AppManager app = context.appManager;

    // 1) Ir a la página de "autenticando..."
    app.pushModel(AuthenticatingPage.pageModel);

    // 2) Ejecutar el login
    final Either<ErrorItem, Unit> r = await bloc.login(email, pass);

    // 3) Procesar resultado
    r.fold(
      (ErrorItem e) {
        // En error: volver al login y mostrar mensaje
        app.pageManager.resetTo(LoginPage.pageModel);
        app.notifications.showToast(e.title);
      },
      (_) {
        // En éxito: configurar menús y mandar a Home
        app.notifications.showToast('Login OK');
        _setupMenusForLoggedIn(app);
        app.pageManager.resetTo(HomePage.pageModel);
      },
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
    return const PageBuilder(
      page: Center(child: Text('Session Closed · Please login')),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  static const String name = 'counter';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

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

    // Configura el menú secundario una única vez
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
    // Opcional: limpiar acciones al salir
    if (_wired) {
      _sec.clearSecondaryDrawer();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BlocResponsive r = context.appManager.responsive;
    r.showAppbar = true;

    return PageBuilder(
      page: PageWithSecondaryMenuWidget(
        responsive: r,
        content: Center(
          child: StreamBuilder<int>(
            stream: context.appManager
                .requireModuleByKey<BlocCounter>(BlocCounter.name)
                .stream,
            initialData: context.appManager
                .requireModuleByKey<BlocCounter>(BlocCounter.name)
                .value,
            builder: (_, AsyncSnapshot<int> snap) => Text(
              'Counter: ${snap.data}',
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
/// 2) BLoCs mínimos: Session + Counter
/// ===========================================
class BlocSession extends BlocModule {
  BlocSession({bool initialized = false}) {
    _loggedIn.value = initialized;
    if (initialized) {
      _email = 'anonimo@anonimo.com.co';
    }
  }

  static const String name = 'BlocSession';

  final BlocGeneral<bool> _loggedIn = BlocGeneral<bool>(false);
  bool get isLoggedIn => _loggedIn.value;
  Stream<bool> get isLoggedInStream => _loggedIn.stream;

  String _email = '';
  String get email => _email;

  Future<Either<ErrorItem, Unit>> login(String email, String pass) async {
    // Mock: solo acepta anonimo@anonimo.com.co / 12345
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (email.trim().toLowerCase() == 'anonimo@anonimo.com.co' &&
        pass == '12345') {
      _email = email.trim();
      _loggedIn.value = true;
      return Right<ErrorItem, Unit>(Unit.value);
    }
    return Left<ErrorItem, Unit>(
      const ErrorItem(
        title: 'Credenciales inválidas',
        code: '',
        description: '',
      ),
    );
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _email = '';
    _loggedIn.value = false;
  }

  @override
  FutureOr<void> dispose() async {
    _loggedIn.dispose();
  }
}

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

/// ===========================================
/// 3) SessionNavCoordinator (menús/flujo)
/// ===========================================
class SessionNavCoordinator {
  SessionNavCoordinator(this.app);
  final AppManager app;

  /// Prepara menú principal según el estado de sesión.
  void setupMainMenuForCurrentSession() {
    final BlocSession s = app.requireModuleByKey(BlocSession.name);
    app.mainMenu.clearMainDrawer();

    if (s.isLoggedIn) {
      app.mainMenu.addMainMenuOption(
        label: 'Go to Counter',
        iconData: Icons.calculate_outlined,
        onPressed: () => app.pushModel(CounterPage.pageModel),
        description: 'Navigate to CounterPage',
      );
      app.mainMenu.addMainMenuOption(
        label: 'Sign out',
        iconData: Icons.logout,
        onPressed: () async {
          await s.logout();
          _setupMenusForLoggedOut(app);
          app.pageManager.resetTo(SessionClosedPage.pageModel);
          app.notifications.showToast('Signed out');
        },
        description: 'Cerrar sesión',
      );
    } else {
      app.mainMenu.addMainMenuOption(
        label: 'Go to Login',
        iconData: Icons.login,
        onPressed: () => app.pushModel(LoginPage.pageModel),
        description: 'Navigate to LoginPage',
      );
    }
  }
}

/// Helpers puros para que también puedas llamarlos desde Login/Logout
void _setupMenusForLoggedIn(AppManager app) {
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
      await s.logout();
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
///    · Splash decide sesión y prepara menús
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
];

final PageRegistry registry =
    PageRegistry.fromDefs(defs, defaultPage: HomePage.pageModel);

PageModel initial() =>
    _onboardingDone ? HomePage.pageModel : SplashPage.pageModel;

final PageManager pageManager =
    PageManager(initial: NavStackModel.single(initial()));

AppManager buildAppManager() {
  // Theme mínimo (igual a tus ejemplos)
  final RepositoryThemeReact themeRepo = RepositoryThemeReactImpl(
    gateway: GatewayThemeReactImpl(service: FakeServiceThemeReact()),
  );
  final ThemeUsecases themeUsecases = ThemeUsecases.fromRepo(themeRepo);
  final WatchTheme watchTheme = WatchTheme(themeRepo);

  // ----- Registrar módulos propios -----
  final BlocCounter counter = BlocCounter();
  final BlocSession session = BlocSession(initialized: kIsSessionInitialized);

  // Onboarding: verifica sesión, ajusta menús, navega a Home
  final BlocOnboarding onboarding = BlocOnboarding()
    ..configure(<OnboardingStep>[
      const OnboardingStep(
        title: 'Boot',
        description: 'Inicializando…',
        autoAdvanceAfter: autoAdvanceAfter,
      ),
      OnboardingStep(
        title: 'Check Session',
        description: 'Verificando sesión y menús…',
        onEnter: () {
          final SessionNavCoordinator coord =
              SessionNavCoordinator(appManagerProd!); // se setea luego
          coord.setupMainMenuForCurrentSession();
          return Right<ErrorItem, Unit>(Unit.value);
        },
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

  // AppConfig
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
    // 🔹 Registra los BLoCs propios en el AppManager (si tu AppManager soporta módulos)
    blocModuleList: <String, BlocModule>{
      BlocCounter.name: counter,
      BlocSession.name: session,
    },
  );

  return AppManager(cfg);
}

class AuthenticatingPage extends StatelessWidget {
  const AuthenticatingPage({super.key});
  static const String name = 'authenticating';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    return const PageBuilder(
      page: Center(child: CircularProgressIndicator()),
    );
  }
}

// Referencia cruzada para el coordinator dentro del step:
AppManager? appManagerProd;

/// ===========================================
/// 5) MAIN · seedInitialFromPageManager (recomendado)
/// ===========================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppManager am = buildAppManager();
  appManagerProd = am;

  // Arranca onboarding solo si arrancaste en Splash
  if (!_onboardingDone && pageManager.stack.top == SplashPage.pageModel) {
    am.onboarding.start();
  }

  runApp(
    JocaaguraApp(
      appManager: am,
      registry: registry,
      seedInitialFromPageManager: true,
    ),
  );
}
