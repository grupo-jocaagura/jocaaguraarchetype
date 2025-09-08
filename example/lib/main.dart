import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Registry de páginas del example
  final PageRegistry registry = buildExampleRegistry();

  // Construimos dos configuraciones (DEV y QA) con pasos de onboarding distintos.
  final AppConfig cfgDev = ExampleEnv.buildConfig(
    mode: AppMode.dev,
    registry: registry,
  );
  final AppConfig cfgQa = ExampleEnv.buildConfig(
    mode: AppMode.qa,
    registry: registry,
  );

  // BlocAppConfig para swap en caliente entre DEV/QA
  ExampleEnv.appConfigBloc = BlocAppConfig(initial: cfgDev);
  ExampleEnv.cfgDev = cfgDev;
  ExampleEnv.cfgQa = cfgQa;

  runApp(ExampleRoot(registry: registry));
}

/// Wrapper que escucha el BlocAppConfig y reconstruye el shell.
class ExampleRoot extends StatefulWidget {
  const ExampleRoot({required this.registry, super.key});
  final PageRegistry registry;
  @override
  State<ExampleRoot> createState() => _ExampleRootState();
}

class _ExampleRootState extends State<ExampleRoot> {
  late AppConfig _current;
  late Stream<AppConfig> _stream;

  @override
  void initState() {
    super.initState();
    _current = ExampleEnv.appConfigBloc.state;
    _stream = ExampleEnv.appConfigBloc.stream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppConfig>(
      stream: _stream,
      initialData: _current,
      builder: (_, AsyncSnapshot<AppConfig> snap) {
        final AppConfig cfg = snap.data ?? _current;
        final AppManager manager = AppManager(cfg);
        return JocaaguraApp(
          key: ObjectKey(cfg),
          appManager: manager,
          registry: widget.registry,
          projectorMode: false,
          initialLocation: '/onboarding',
        );
      },
    );
  }
}

PageRegistry buildExampleRegistry() {
  return PageRegistry.fromDefs(
    <PageDef>[
      PageDef(
        model: const PageModel(
          name: 'onboarding',
          segments: <String>['onboarding'], // <- sin "/"
        ),
        builder: (BuildContext ctx, PageModel args) => const OnboardingPage(),
      ),
      PageDef(
        model: const PageModel(
          name: 'home',
          segments: <String>['home'], // <- sin "/"
        ),
        builder: (BuildContext ctx, PageModel args) => const HomeGuestPage(),
      ),
      PageDef(
        model: const PageModel(
          name: 'homeSession',
          segments: <String>['home-session'], // <- sin "/"
        ),
        builder: (BuildContext ctx, PageModel args) => const HomeSessionPage(),
      ),
      PageDef(
        model: const PageModel(
          name: 'counter',
          segments: <String>['counter'], // <- sin "/"
        ),
        builder: (BuildContext ctx, PageModel args) => const CounterPage(),
      ),
      PageDef(
        model: const PageModel(
          name: 'login',
          segments: <String>['login'], // <- sin "/"
        ),
        builder: (BuildContext ctx, PageModel args) => const LoginPage(),
      ),
      PageDef(
        model: const PageModel(
          name: 'settings',
          segments: <String>['settings'], // <- sin "/"
        ),
        builder: (BuildContext ctx, PageModel args) => const SettingsPage(),
      ),
      PageDef(
        model: const PageModel(
          name: 'notFound',
          segments: <String>['not-found'], // <- sin "/"
        ),
        builder: (BuildContext ctx, PageModel args) => const NotFoundPage(),
      ),
    ],
    notFoundBuilder: (BuildContext ctx, PageModel args) => const NotFoundPage(),
    // Sugerido: que el default sea el onboarding
    defaultPage: const PageModel(
      name: 'onboarding',
      segments: <String>['onboarding'],
    ),
  );
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  Object? _lastManagerIdentity;
  bool _startedForThisManager = false;

  void _ensureStarted() {
    final AppManager app = context.appManager;
    final Object identity = app; // identidad por instancia

    if (!identical(_lastManagerIdentity, identity)) {
      _lastManagerIdentity = identity;
      _startedForThisManager = false;
    }

    if (!_startedForThisManager) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        app.onboarding.start();
      });
      _startedForThisManager = true;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureStarted());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureStarted();
  }

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    return StreamBuilder<OnboardingState>(
      stream: app.onboarding.stateStream,
      initialData: app.onboarding.state,
      builder: (BuildContext context, AsyncSnapshot<OnboardingState> snap) {
        final OnboardingState s = snap.data ?? OnboardingState.idle();
        if (s.status == OnboardingStatus.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final bool logged =
                await ExampleServices.auth.ensureInitializedAndCheck();
            app.replaceTopNamed(
              logged ? 'homeSession' : 'home',
              segments: <String>[if (logged) 'home-session' else 'home'],
            );
          });
        }
        final String title = (s.hasStep && app.onboarding.currentStep != null)
            ? (app.onboarding.currentStep!.title)
            : 'Starting…';
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(title),
                if (s.error != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    s.error!.description,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: app.onboarding.retryOnEnter,
                    child: const Text('Retry'),
                  ),
                  TextButton(
                    onPressed: app.onboarding.skip,
                    child: const Text('Skip'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

enum AppMode { dev, qa }

class ExampleEnv {
  static late BlocAppConfig appConfigBloc;
  static late AppConfig cfgDev;
  static late AppConfig cfgQa;

  static AppConfig buildConfig({
    required AppMode mode,
    required PageRegistry registry,
  }) {
    final List<OnboardingStep> steps = <OnboardingStep>[
      OnboardingStep(
        title: 'net-check',
        onEnter: () async {
          try {
            final ConnectionTypeEnum t =
                await ExampleServices.connectivity.checkConnectivity();
            final bool online = t != ConnectionTypeEnum.none;
            if (!online) {
              return Left<ErrorItem, Unit>(
                const ErrorItem(
                  title: 'Offline',
                  code: 'NET_OFFLINE',
                  description:
                      'No network connection detected. Please check your connectivity.',
                  errorLevel: ErrorLevelEnum.severe,
                ),
              );
            }
            return Right<ErrorItem, Unit>(Unit.value);
          } catch (e) {
            return Left<ErrorItem, Unit>(
              ErrorItem(
                title: 'Connectivity Error',
                code: 'NET_CHECK_FAIL',
                description: e.toString(),
                errorLevel: ErrorLevelEnum.severe,
              ),
            );
          }
        },
        autoAdvanceAfter: const Duration(seconds: 1),
      ),
      OnboardingStep(
        title: 'session-check',
        onEnter: () async {
          await ExampleServices.auth.ensureInitializedAndCheck();
          return Right<ErrorItem, Unit>(Unit.value);
        },
        autoAdvanceAfter: const Duration(seconds: 1),
      ),
    ];

    if (mode == AppMode.dev) {
      ExampleServices.connectivity.simulateConnection(ConnectionTypeEnum.wifi);
      ExampleServices.auth.setLoggedIn(false);
    } else {
      ExampleServices.connectivity.simulateConnection(ConnectionTypeEnum.wifi);
      ExampleServices.auth.setLoggedIn(true);
    }

    return AppConfig.dev(
      registry: registry,
      onboardingSteps: steps,
    );
  }
}

class ExampleServices {
  static final FakeServiceConnectivity connectivity = FakeServiceConnectivity();

  static final ExampleAuth auth = ExampleAuth._();
}

class ExampleConnectivity {
  ExampleConnectivity._();
  static final ExampleConnectivity instance = ExampleConnectivity._();
  bool _online = true;

  Future<bool> checkNow() async => _online;
  void setOnline(bool v) {
    if (v != _online) {
      _online = v;
    }
  }

  Stream<bool> stream() async* {
    yield _online;
  }
}

class ExampleAuth {
  ExampleAuth._();
  static final ExampleAuth instance = ExampleAuth._();
  bool _logged = false;

  Future<bool> ensureInitializedAndCheck() async => _logged;
  void setLoggedIn(bool v) {
    if (v != _logged) {
      _logged = v;
    }
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          SwitchListTile(
            title: const Text('Dark mode'),
            value: app.theme.stateOrDefault.mode == ThemeMode.dark,
            onChanged: (bool v) =>
                app.theme.setMode(v ? ThemeMode.dark : ThemeMode.light),
          ),
          const Divider(),
          ListTile(
            title: const Text('Switch to DEV'),
            subtitle: const Text('Fakes: online=true, logged=false'),
            onTap: () => ExampleEnv.appConfigBloc
                .switchTo(ExampleEnv.cfgDev, resetStack: true),
          ),
          ListTile(
            title: const Text('Switch to QA'),
            subtitle: const Text('Fakes: online=true, logged=true'),
            onTap: () => ExampleEnv.appConfigBloc
                .switchTo(ExampleEnv.cfgQa, resetStack: true),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Connectivity: Online'),
            value: true,
            onChanged: (bool v) {
              ExampleConnectivity.instance.setOnline(v);
              app.notify('Connectivity: ${v ? 'Online' : 'Offline'}');
            },
          ),
        ],
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});
  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('404 — Page not found'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => app.goTo('/home'),
              icon: const Icon(Icons.home),
              label: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                ExampleAuth.instance.setLoggedIn(true);
                app.replaceTop('/home-session');
              },
              child: const Text('Simulate Login'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                ExampleAuth.instance.setLoggedIn(false);
                app.replaceTop('/home');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSessionPage extends StatelessWidget {
  const HomeSessionPage({super.key});
  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    return Scaffold(
      appBar: AppBar(title: const Text('Home (Session)')),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('Counter'),
              onTap: () => app.pushOnce('/counter'),
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () => app.pushOnce('/settings'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You are logged in.'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => app.pushOnce('/counter'),
              child: const Text('Open Counter'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeGuestPage extends StatelessWidget {
  const HomeGuestPage({super.key});
  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    return Scaffold(
      appBar: AppBar(title: const Text('Home (Guest)')),
      drawer: _ExampleDrawer(app: app),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome! Please sign in to access Counter.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => app.goTo('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleDrawer extends StatelessWidget {
  const _ExampleDrawer({required this.app});
  final AppManager app;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Settings'),
            onTap: () => app.pushOnce('/settings'),
          ),
        ],
      ),
    );
  }
}

/// Responsive Counter page using a simple breakpoint.
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final BlocCounter _bloc = BlocCounter();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;

    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isWide =
              constraints.maxWidth >= 720; // md breakpoint aprox
          final Widget counter = StreamBuilder<int>(
            stream: _bloc.stream,
            initialData: _bloc.value,
            builder: (BuildContext context, AsyncSnapshot<int> snap) => Text(
              'Count: ${snap.data}',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          );

          final Widget controls = Wrap(
            spacing: 8,
            children: <Widget>[
              ElevatedButton(onPressed: _bloc.inc, child: const Text('+1')),
              ElevatedButton(onPressed: _bloc.dec, child: const Text('-1')),
              OutlinedButton(
                onPressed: _bloc.reset,
                child: const Text('Reset'),
              ),
            ],
          );

          final Widget connectivityBanner = StreamBuilder<bool>(
            stream: ExampleConnectivity.instance.stream(),
            initialData: true,
            builder: (BuildContext context, AsyncSnapshot<bool> snap) {
              final bool online = snap.data ?? true;
              return Container(
                padding: const EdgeInsets.all(8),
                color: online ? Colors.green.shade100 : Colors.red.shade100,
                child: Text(online ? 'Online' : 'Offline'),
              );
            },
          );

          final Widget content = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              connectivityBanner,
              const SizedBox(height: 12),
              counter,
              const SizedBox(height: 24),
              controls,
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => app.clearAndGoHome(),
                child: const Text('Back to Home'),
              ),
            ],
          );

          if (isWide) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(child: Center(child: content)),
                const Expanded(child: Placeholder()), // side panel demo
              ],
            );
          }
          return Center(child: content);
        },
      ),
    );
  }
}

/// Minimal counter BLoC without external deps.
class BlocCounter {
  final BlocGeneral<int> _c = BlocGeneral<int>(0);

  Stream<int> get stream => _c.stream;
  int get value => _c.value;

  void inc() {
    _c.value = value + 1;
  }

  void dec() {
    _c.value = value - 1;
  }

  void reset() {
    _c.value = 0;
  }

  void dispose() {
    _c.dispose();
  }
}
