import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

const String _kBlocHttpRequestKey = 'blocHttpRequest';
final Uri _kAppVersionEndpoint = Uri.parse('https://example.com/app-version');

Future<Either<ErrorItem, ModelAppVersion>> _fetchAppVersion(
  BlocHttpRequest http, {
  String requestKey = 'app.version.check',
}) async {
  final Either<ErrorItem, ModelConfigHttpRequest> response = await http.get(
    requestKey: requestKey,
    uri: _kAppVersionEndpoint,
    metadata: const <String, Object?>{
      'feature': 'appVersion',
      'operation': 'fetchVersion',
    },
  );

  return response.fold<Either<ErrorItem, ModelAppVersion>>(
    Left.new,
    (ModelConfigHttpRequest cfg) {
      final Object body = cfg.body;
      if (body is! Map<String, Object?>) {
        return _invalidPayload();
      }
      final Object? value = body['value'];
      if (value is! Map<String, Object?>) {
        return _invalidPayload();
      }
      try {
        return Right<ErrorItem, ModelAppVersion>(
          ModelAppVersion.fromJson(Map<String, Object?>.from(value)),
        );
      } catch ( err,  trace) {
        return Left<ErrorItem, ModelAppVersion>(
          ErrorItem(
            code: 'APP_VERSION_MAPPING_ERROR',
            title: 'Invalid payload',
            description: 'Failed to map version JSON: $err\n$trace',
          ),
        );
      }
    },
  );
}

Either<ErrorItem, ModelAppVersion> _invalidPayload() {
  return Left<ErrorItem, ModelAppVersion>(
    const ErrorItem(
      code: 'APP_VERSION_INVALID_PAYLOAD',
      title: 'Invalid payload for app version',
      description: 'Missing "value" object with version info.',
    ),
  );
}

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
    _setupHttpLayer();
    _setupRegistry();
  }

  late final BlocHttpRequest _blocHttpRequest;
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
            final Either<ErrorItem, ModelAppVersion> result =
                await _fetchAppVersion(_blocHttpRequest);
            return result.fold(
              (ErrorItem error) {
                debugPrint('App version fetch failed: ${error.title}');
                return  Right<ErrorItem, Unit>(Unit.value);
              },
              (ModelAppVersion version) {
                _blocModelVersion.setVersion(version);
                return  Right<ErrorItem, Unit>(Unit.value);
              },
            );
          },
          autoAdvanceAfter: const Duration(milliseconds: 250),
        ),
      ]);

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
        blocModuleList: <String, BlocModule>{
          _kBlocHttpRequestKey: _blocHttpRequest,
        },
      ),
    );
  }

  void _setupHttpLayer() {
    const FakeHttpRequestConfig config = FakeHttpRequestConfig(
      latency: Duration(milliseconds: 600),
      cannedResponses: <String, Map<String, Object?>>{
        'GET https://example.com/app-version': <String, Object?>{
          'ok': true,
          'value': <String, Object?>{
            'build': '42',
            'version': '3.5.0-demo',
            'minSupported': '3.0.0',
            'platforms': <String, Object?>{
              'android': '3.5.0',
              'ios': '3.5.0',
            },
          },
        },
      },
    );

    final ServiceHttpRequest service = FakeHttpRequest(config: config);
    final GatewayHttpRequest gateway = GatewayHttpRequestImpl(
      service: service,
      errorMapper: const DefaultHttpErrorMapper(),
    );
    final RepositoryHttpRequest repository = RepositoryHttpRequestImpl(gateway);

    final FacadeHttpRequestUsecases facade = FacadeHttpRequestUsecases(
      get: UsecaseHttpRequestGet(repository),
      post: UsecaseHttpRequestPost(repository),
      put: UsecaseHttpRequestPut(repository),
      delete: UsecaseHttpRequestDelete(repository),
      retry: UsecaseHttpRequestRetry(repository),
    );

    _blocHttpRequest = BlocHttpRequest(facade);
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
    final BlocHttpRequest http =
        app.requireModuleByKey(_kBlocHttpRequestKey);

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
                      final Either<ErrorItem, ModelAppVersion> result =
                          await _fetchAppVersion(
                        http,
                        requestKey: 'app.version.manual',
                      );
                      result.fold(
                        (ErrorItem err) {
                          context.appManager.notifications.showToast(
                                'No se pudo refrescar: ${err.title}',
                              );
                        },
                        (ModelAppVersion next) {
                          app.appVersionBloc?.setVersion(next);
                        },
                      );
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
