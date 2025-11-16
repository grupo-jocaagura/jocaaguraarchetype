import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ===============================
/// 0) Variables de entorno (compile-time)
/// - Se pasan con --dart-define o --dart-define-from-file
/// - No leen variables del SO
/// ===============================
const String env = String.fromEnvironment('APP_MODE', defaultValue: 'dev');
const Duration autoAdvanceAfter = Duration(
  milliseconds: int.fromEnvironment('AUTO_ADVANCE_AFTER', defaultValue: 5000),
);

/// ===============================
/// 1) Registro de páginas (declarativo)
/// - NO hacemos de Splash el default, el default estable es Home
/// - Splash está registrado para que pueda usarse como página inicial SOLO al boot
/// ===============================
final List<PageDef> defs = <PageDef>[
  PageDef(model: SplashPage.pageModel, builder: (_, __) => const SplashPage()),
  PageDef(model: HomePage.pageModel, builder: (_, __) => const HomePage()),
  PageDef(
    model: HistorialPage.pageModel,
    builder: (_, __) => const HistorialPage(),
  ),
];

final PageRegistry registry = PageRegistry.fromDefs(
  defs,
  // ⚠️ Clave del patrón: defaultPage apunta a Home, no a Splash
  defaultPage: HomePage.pageModel,
);

/// Flag en memoria (una sola vez por sesión)
/// - Mientras la app corre, decidimos si mostrar Splash o no.
/// - Si quisieras “una sola vez por instalación”, este flag se persiste (p.ej. SharedPreferences/gateway).
bool _onboardingDone = false;

/// ===============================
/// 2) PageManager con semilla inicial UNA sola vez
/// - Si el onboarding ya se hizo en esta sesión → Home
/// - Si no → Splash
/// ===============================
PageModel initial() =>
    _onboardingDone ? HomePage.pageModel : SplashPage.pageModel;

final PageManager pageManager = PageManager(
  initial: NavStackModel.single(initial()),
);

/// ===============================
/// 3) AppManager + Onboarding
/// - Configuramos pasos y arrancamos SOLO si la página inicial fue Splash
/// - Al finalizar, marcamos _onboardingDone y reemplazamos Splash por Home
/// ===============================
AppManager buildAppManager() {
  // Setup mínimo de theme (fake service para ejemplo).
  final RepositoryThemeReact themeRepo = RepositoryThemeReactImpl(
    gateway: GatewayThemeReactImpl(service: FakeServiceThemeReact()),
  );
  final ThemeUsecases themeUsecases = ThemeUsecases.fromRepo(themeRepo);
  final WatchTheme watchTheme = WatchTheme(themeRepo);

  // Bloc de Onboarding (debe vivir en AppConfig)
  final BlocOnboarding blocOnboarding = BlocOnboarding();

  // Pasos del onboarding (pueden ser vacíos si se quiere saltar Splash)
  final List<OnboardingStep> onboardingSteps = <OnboardingStep>[
    const OnboardingStep(
      title: 'Verificando el ambiente',
      description: 'Verificando el ambiente de desarrollo',
      autoAdvanceAfter: autoAdvanceAfter,
    ),
    const OnboardingStep(
      title: 'Inicializando entorno',
      description: 'Inicializando entorno de desarrollo',
      autoAdvanceAfter: autoAdvanceAfter,
    ),
    OnboardingStep(
      title: 'Finalizando',
      description: 'Redirigimos al home',
      onEnter: () {
        // ✅ Marca en memoria: en esta sesión ya no volvemos a Splash
        _onboardingDone = true;

        // (Opcional) Avisar al bloc que finalizó
        blocOnboarding.complete();

        // ✅ Reemplaza la página superior (Splash) por Home (no push)
        pageManager.replaceTop(HomePage.pageModel);

        return Right<ErrorItem, Unit>(Unit.value);
      },
    ),
  ];

  // ⚠️ Arranca el onboarding SOLO si la top inicial es Splash
  //    (Evita re-configurar y re-arrancar si alguien llega a Splash por error)
  if (!_onboardingDone && pageManager.stack.top == SplashPage.pageModel) {
    blocOnboarding.configure(onboardingSteps);
    blocOnboarding.start();
  }

  // Puedes condicionar AppConfig por env si lo necesitas.
  final AppConfig config = defaultEnv.isProd
      ? AppConfig(
          blocTheme: BlocThemeReact(
            themeUsecases: themeUsecases,
            watchTheme: watchTheme,
          ),
          blocUserNotifications: BlocUserNotifications(),
          blocLoading: BlocLoading(),
          blocMainMenuDrawer: BlocMainMenuDrawer(),
          blocSecondaryMenuDrawer: BlocSecondaryMenuDrawer(),
          blocResponsive: BlocResponsive(),
          blocOnboarding: blocOnboarding,
          pageManager: pageManager,
        )
      // En dev usamos el atajo del arquetipo (simple y rápido)
      : AppConfig.dev(registry: registry);

  return AppManager(config);
}

/// ===============================
/// 4) Shell de la app (JocaaguraApp)
/// - seedInitialFromPageManager: true → el Router toma la ruta inicial del PageManager.top
///   (esto evita que el Router “pise” tu stack inicial con un initialLocation fijo)
/// - initialLocation puede omitirse si usas el seed (recomendado)
/// ===============================
void main() {
  final AppManager appManager = buildAppManager();

  final JocaaguraApp app = JocaaguraApp(
    appManager: appManager,
    registry: registry,
    // initialLocation: SplashPage.pageModel.toUriString(), // opcional
    seedInitialFromPageManager: true, // ✅ clave para respetar tu stack inicial
  );

  runApp(app);
}

/// ===============================
/// 5) Páginas de ejemplo
/// - Home: muestra env y navega a Historial
/// - Splash: SOLO renderiza OnBoardingPage (la lógica de arranque la hicimos en buildAppManager)
/// - Historial: ejemplo con overlay de loading
/// ===============================
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const String name = 'home';
  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>[name],
  );

  @override
  Widget build(BuildContext context) {
    return PageBuilder(
      page: Center(
        child: InkWell(
          onTap: () => context.appManager.pushModel(HistorialPage.pageModel),
          child: Text('Environment: $env - isProd ${defaultEnv.isProd}'),
        ),
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  static const String name = 'splash';
  static const PageModel pageModel = PageModel(name: name);

  @override
  Widget build(BuildContext context) {
    // OnBoardingPage observa el BlocOnboarding del AppManager
    // La configuración/arranque se hizo al boot (en buildAppManager)
    final BlocOnboarding blocOnboarding = context.appManager.onboarding;
    return OnBoardingPage(blocOnboarding: blocOnboarding);
  }
}

class HistorialPage extends StatelessWidget {
  const HistorialPage({super.key});
  static const String name = 'historial';
  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>[name],
  );

  @override
  Widget build(BuildContext context) {
    // Ejemplo: habilitar AppBar desde el responsive bloc
    context.appManager.responsive.showAppbar = true;

    return PageBuilder(
      page: InkWell(
        onTap: () {
          // Ejemplo de loading overlay centralizado
          context.appManager.loading.loadingMsg = 'Cargando historial';
          Future<void>.delayed(const Duration(seconds: 5)).then((_) {
            if (context.mounted) {
              context.appManager.loading.clearLoading();
            }
          });
        },
        child: Text('Historial ${context.appManager.pageManager.historyNames}'),
      ),
    );
  }
}
