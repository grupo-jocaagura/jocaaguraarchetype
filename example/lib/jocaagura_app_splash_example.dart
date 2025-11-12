import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

const String env = String.fromEnvironment('APP_MODE', defaultValue: 'dev');
const Duration autoAdvanceAfter = Duration(
  milliseconds: int.fromEnvironment('AUTO_ADVANCE_AFTER', defaultValue: 5000),
);

// 1) Registro de páginas con Splash como default
final List<PageDef> defs = <PageDef>[
  PageDef(model: SplashPage.pageModel, builder: (_, __) => const SplashPage()),
  PageDef(model: HomePage.pageModel, builder: (_, __) => const HomePage()),
  PageDef(
    model: HistorialPage.pageModel,
    builder: (_, __) => const HistorialPage(),
  ),
];
final PageRegistry registry =
    PageRegistry.fromDefs(defs, defaultPage: HomePage.pageModel);

// 2) Un único PageManager que arranca en Splash
PageModel initial() =>
    _onboardingDone ? HomePage.pageModel : SplashPage.pageModel;
final PageManager pageManager = PageManager(
  initial: NavStackModel.single(
    initial(),
  ),
);

// 4) Construimos SIEMPRE un AppManager propio (dev y prod)
AppManager buildAppManager() {
  final RepositoryThemeReact themeRepo = RepositoryThemeReactImpl(
    gateway: GatewayThemeReactImpl(service: FakeServiceThemeReact()),
  );
  final ThemeUsecases themeUsecases = ThemeUsecases.fromRepo(themeRepo);
  final WatchTheme watchTheme = WatchTheme(themeRepo);
  final BlocOnboarding blocOnboarding = BlocOnboarding();
// 3) Onboarding steps y carga en el bloc
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
        _onboardingDone = true;
        blocOnboarding.complete();
        pageManager.replaceTop(HomePage.pageModel);
        return Right<ErrorItem, Unit>(Unit.value);
      },
    ),
  ];
  if (!_onboardingDone && pageManager.stack.top == SplashPage.pageModel) {
    blocOnboarding.configure(onboardingSteps);
    blocOnboarding.start();
  }

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
      : AppConfig.dev(registry: registry);
  return AppManager(config);
}

bool _onboardingDone = false;
void main() {
  final AppManager appManager = buildAppManager();

  final JocaaguraApp app = JocaaguraApp(
    appManager: appManager,
    registry: registry,
    // initialLocation: SplashPage.pageModel.toUriString(),
    seedInitialFromPageManager: true,
  );

  runApp(app);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const String name = 'home';
  static const PageModel pageModel =
      PageModel(name: name, segments: <String>[name]);

  @override
  Widget build(BuildContext context) {
    return PageBuilder(
      page: Center(
        child: InkWell(
          onTap: () {
            context.appManager.pushModel(HistorialPage.pageModel);
          },
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
    context.appManager.responsive.showAppbar = true;
    return PageBuilder(
      page: InkWell(
        onTap: () {
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
