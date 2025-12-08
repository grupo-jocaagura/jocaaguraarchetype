import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final _HttpAndVersionExample bootstrap = _HttpAndVersionExample();
  final AppManager appManager = bootstrap.buildAppManager();

  runApp(
    JocaaguraApp(
      appManager: appManager,
      registry: bootstrap.registry,
      seedInitialFromPageManager: true,
    ),
  );
}

class _HttpAndVersionExample {
  _HttpAndVersionExample() {
    _setupRegistry();
  }

  late final BlocModelVersion _blocModelVersion;
  late final PageRegistry registry;
  late final PageManager _pageManager;

  AppManager buildAppManager() {
    _blocModelVersion = BlocModelVersion();
    _pageManager = PageManager(
      initial: NavStackModel.single(_VersionHomePage.pageModel),
    );

    final BlocOnboarding onboarding = BlocOnboarding()
      ..configure(<OnboardingStep>[
        OnboardingStep(
          title: 'Check App Version',
          description: 'Consultando endpoint…',
          onEnter: () async {
            // Esta es la version de nuestra App compilada, para efectos practicos
            // usaremos default pero en una app real deberia ser la version real
            _blocModelVersion
                .setVersion(ModelAppVersion.defaultModelAppVersion);
            // Simulamos una llamada HTTP para obtener la version mas reciente
            // y aqui podriamos comparar y notificar al usuario si hay una nueva version.
            return Right<ErrorItem, Unit>(Unit.value);
          },
          autoAdvanceAfter: const Duration(milliseconds: 250),
        ),
      ]);
    onboarding.start();
    return AppManager(
      AppConfig(
        blocTheme: _buildThemeBloc(),
        blocUserNotifications: BlocUserNotifications(),
        blocLoading: BlocLoading(),
        blocMainMenuDrawer: BlocMainMenuDrawer(),
        blocSecondaryMenuDrawer: BlocSecondaryMenuDrawer(),
        blocResponsive: BlocResponsive(),
        blocOnboarding: onboarding,
        pageManager: _pageManager,
        blocModelVersion: _blocModelVersion,
        blocModuleList: <String, BlocModule>{},
      ),
    );
  }

  void _setupRegistry() {
    registry = PageRegistry.fromDefs(
      <PageDef>[
        PageDef(
          model: _VersionHomePage.pageModel,
          builder: (_, __) => const _VersionHomePage(),
        ),
      ],
      defaultPage: _VersionHomePage.pageModel,
    );
  }

  BlocTheme _buildThemeBloc() {
    final RepositoryThemeReact repo = RepositoryThemeReactImpl(
      gateway: GatewayThemeReactImpl(service: FakeServiceThemeReact()),
    );
    return BlocThemeReact(
      themeUsecases: ThemeUsecases.fromRepo(repo),
      watchTheme: WatchTheme(repo),
    );
  }
}

class _VersionHomePage extends StatelessWidget {
  const _VersionHomePage();

  static const PageModel pageModel = PageModel(
    name: 'version_home',
    segments: <String>['version_home'],
  );

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;

    return PageBuilder(
      page: Scaffold(
        appBar: AppBar(title: const Text('HTTP + App Version Demo')),
        body: Center(
          child: StreamBuilder<ModelAppVersion>(
            stream: app.appVersionBloc?.stream ??
                Stream<ModelAppVersion>.value(app.currentAppVersion),
            initialData: app.currentAppVersion,
            builder: (_, AsyncSnapshot<ModelAppVersion> snap) {
              final ModelAppVersion version =
                  snap.data ?? ModelAppVersion.defaultModelAppVersion;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Current version: ${version.version}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final int buildNumber = Utils.getIntegerFromDynamic(
                            app.currentAppVersion.buildNumber,
                          ) +
                          1;

                      final String version = intToVersion(buildNumber);

                      final ModelAppVersion next = app.currentAppVersion
                          .copyWith(buildNumber: buildNumber, version: version);
                      app.appVersionBloc?.setVersion(next);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refrescar versión'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Convierte un entero [value] en una versión semántica "major.minor.patch"
/// con las siguientes reglas:
/// - Cada 10 parches incrementa el minor y patch vuelve a 0.
/// - Cada 10 minors incrementa el major, y minor/patch vuelven a 0.
String intToVersion(int value) {
  if (value < 0) {
    throw ArgumentError('value must be >= 0');
  }

  final int major = value ~/ 100;
  final int minor = (value % 100) ~/ 10;
  final int patch = value % 10;

  return '$major.$minor.$patch';
}
