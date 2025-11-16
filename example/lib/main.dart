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
                      (ErrorItem e) => app.notifications.showToast(e.title),
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
    final AppManager app = context.appManager;
    final BlocResponsive r = app.responsive;
    r.showAppbar = true;
    final BlocCounter blocCounter =
        context.appManager.requireModuleByKey<BlocCounter>(BlocCounter.name);

    return PageBuilder(
      page: PageWithSecondaryMenuBuilder(
        app: app,
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
