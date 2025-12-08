import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

final Uri _kAppVersionEndpoint = Uri.parse('https://example.com/app-version');

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

/// Hace la llamada HTTP usando BlocHttpRequest y mapea el body → ModelAppVersion.
///
/// Espera que el body tenga la forma:
/// ```json
/// {
///   "value": { ...ModelAppVersion JSON... }
/// }
/// ```
/// o directamente:
/// ```json
/// { ...ModelAppVersion JSON... }
/// ```
Future<Either<ErrorItem, ModelAppVersion>> _fetchAppVersion(
  BlocHttpRequest http, {
  String requestKey = 'app.version.check',
}) async {
  final Either<ErrorItem, ModelConfigHttpRequest> result = await http.get(
    requestKey: requestKey,
    uri: _kAppVersionEndpoint,
    metadata: <String, dynamic>{
      'feature': 'appVersion',
      'operation': 'fetchVersion',
    },
  );

  return result.fold<Either<ErrorItem, ModelAppVersion>>(
    Left.new,
    (ModelConfigHttpRequest cfg) {
      final Map<String, dynamic> body = cfg.body;
      debugPrint('HTTP app-version cfg.body = $body');

      // Intentamos ser tolerantes con la forma del body:
      // - body['value'] → preferido
      // - body['data']  → alternativo
      // - body completo → fallback
      Map<String, dynamic> rawValue;

      if (body.containsKey('value')) {
        rawValue = Utils.mapFromDynamic(body['value']);
      } else if (body.containsKey('data')) {
        rawValue = Utils.mapFromDynamic(body['data']);
      } else {
        rawValue = body;
      }

      try {
        final ModelAppVersion version = ModelAppVersion.fromJson(
          Map<String, dynamic>.from(rawValue),
        );
        return Right<ErrorItem, ModelAppVersion>(version);
      } on Object catch (error, stackTrace) {
        return Left<ErrorItem, ModelAppVersion>(
          ErrorItem(
            code: 'APP_VERSION_MAPPING_ERROR',
            title: 'Failed to map version JSON',
            description: 'Error: $error',
            meta: <String, dynamic>{
              'stackTrace': stackTrace.toString(),
              'rawValue': rawValue,
            },
          ),
        );
      }
    },
  );
}

class _HttpAndVersionExample {
  _HttpAndVersionExample() : _installedVersion = _buildInstalledVersion() {
    _setupHttpLayer();
    _setupRegistry();
  }

  /// Versión instalada (fuente de verdad para la app).
  ///
  /// Para el ejemplo usamos un build explícito (42) para poder jugar con
  /// +1 / -1 sin depender del valor real de `defaultModelAppVersion`.
  static ModelAppVersion _buildInstalledVersion() {
    const ModelAppVersion base = ModelAppVersion.defaultModelAppVersion;

    const int buildNumber = 42;
    final String version = intToVersion(buildNumber);

    return base.copyWith(
      buildNumber: buildNumber,
      version: version,
    );
  }

  final ModelAppVersion _installedVersion;

  late final BlocModelVersion _blocModelVersion;
  late final BlocHttpRequest _blocHttpRequest;
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
          title: 'Init installed version',
          description: 'Configurando versión instalada…',
          onEnter: () async {
            // Escenario 1:
            // Fuente de verdad: versión instalada constante (ej. build 42).
            _blocModelVersion.setVersion(_installedVersion);
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
        blocModuleList: <String, BlocModule>{
          BlocHttpRequest.name: _blocHttpRequest,
        },
      ),
    );
  }

  void _setupHttpLayer() {
    // Escenario del "servidor":
    // - installed = 42
    // - server inicial = 41 (build - 1)
    final int installedBuild =
        Utils.getIntegerFromDynamic(_installedVersion.buildNumber);
    final int initialServerBuild = installedBuild - 1;
    final ModelAppVersion initialServerVersion = _installedVersion.copyWith(
      buildNumber: initialServerBuild,
      version: intToVersion(initialServerBuild),
    );

    final ServiceHttpRequest service = VersionSimulatingHttpService(
      initialServerVersion: initialServerVersion,
    );

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

class _VersionHomePage extends StatefulWidget {
  const _VersionHomePage();

  static const PageModel pageModel = PageModel(
    name: 'version_home',
    segments: <String>['version_home'],
  );

  @override
  State<_VersionHomePage> createState() => _VersionHomePageState();
}

class _VersionHomePageState extends State<_VersionHomePage> {
  late ModelAppVersion _lastRemoteVersion;

  @override
  void initState() {
    super.initState();
    _lastRemoteVersion = _HttpAndVersionExample._buildInstalledVersion();
  }

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    final BlocHttpRequest http =
        app.requireModuleByKey<BlocHttpRequest>(BlocHttpRequest.name);

    return PageBuilder(
      page: Scaffold(
        appBar: AppBar(title: const Text('HTTP + App Version Demo')),
        body: Center(
          child: StreamBuilder<ModelAppVersion>(
            stream: app.appVersionBloc?.stream ??
                Stream<ModelAppVersion>.value(app.currentAppVersion),
            initialData: app.currentAppVersion,
            builder: (_, AsyncSnapshot<ModelAppVersion> snap) {
              final ModelAppVersion installed =
                  snap.data ?? ModelAppVersion.defaultModelAppVersion;

              final int installedBuild =
                  Utils.getIntegerFromDynamic(installed.buildNumber);

              final String? remoteVersionLabel = app.appVersionBloc
                          ?.isNewerThanCurrent(_lastRemoteVersion) ??
                      false
                  ? '${_lastRemoteVersion.version} '
                      '(build ${Utils.getIntegerFromDynamic(_lastRemoteVersion.buildNumber)})'
                  : null;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Versión instalada (app): ${installed.version} '
                      '(build $installedBuild)',
                      textAlign: TextAlign.center,
                    ),
                    if (remoteVersionLabel != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        'Última versión remota consultada:\n$remoteVersionLabel',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final Either<ErrorItem, ModelAppVersion> result =
                            await _fetchAppVersion(
                          http,
                          requestKey: 'app.version.manual',
                        );

                        result.fold(
                          (ErrorItem error) {
                            app.notifications.showToast(
                              'Error al consultar versión remota: '
                              '${error.title.isNotEmpty ? error.title : error.code}',
                            );
                          },
                          (ModelAppVersion remote) {
                            setState(() {
                              _lastRemoteVersion = remote;
                            });

                            final int remoteBuild = Utils.getIntegerFromDynamic(
                              remote.buildNumber,
                            );

                            if (remoteBuild < installedBuild) {
                              app.notifications.showToast(
                                'Servidor desactualizado.\n'
                                'Remota: ${remote.version} | '
                                'Instalada: ${installed.version}',
                              );
                            } else if (remoteBuild == installedBuild) {
                              app.notifications.showToast(
                                'No hay actualización disponible.\n'
                                'Versión actual: ${installed.version}',
                              );
                            } else {
                              app.notifications.showToast(
                                'Nueva versión disponible: ${remote.version}\n'
                                '(build $remoteBuild > $installedBuild)',
                              );
                            }
                          },
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Consultar versión remota (HTTP)'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: !(app.appVersionBloc
                                  ?.isNewerThanCurrent(_lastRemoteVersion) ??
                              false)
                          ? null
                          : () {
                              final ModelAppVersion remote = _lastRemoteVersion;
                              app.appVersionBloc?.setVersion(remote);

                              app.notifications.showToast(
                                'Versión instalada actualizada a '
                                '${remote.version} '
                                '(build ${Utils.getIntegerFromDynamic(remote.buildNumber)})',
                              );
                            },
                      icon: const Icon(Icons.system_update_alt),
                      label: const Text('Instalar versión remota'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Servicio HTTP que simula un servidor cuya versión de app
/// se incrementa en cada GET al endpoint de versión.
///
/// - Estado interno: [ModelAppVersion] `_serverVersion`.
/// - En cada GET a [_kAppVersionEndpoint]:
///   - Incrementa el build en 1.
///   - Actualiza el campo `version` con `intToVersion(build)`.
///   - Devuelve un payload estilo HTTP response:
///     {
///       "method": "GET",
///       "uri": "...",
///       "statusCode": 200,
///       "headers": { ... },
///       "body": { "value": <_serverVersion.toJson()> },
///       "metadata": { ... },
///       "fake": true,
///       "source": "VersionSimulatingHttpService"
///     }
class VersionSimulatingHttpService implements ServiceHttpRequest {
  VersionSimulatingHttpService({
    required ModelAppVersion initialServerVersion,
  }) : _serverVersion = initialServerVersion;

  ModelAppVersion _serverVersion;

  @override
  Future<Map<String, dynamic>> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    // Simulamos una pequeña latencia.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (uri == _kAppVersionEndpoint) {
      final int currentBuild =
          Utils.getIntegerFromDynamic(_serverVersion.buildNumber);
      final int nextBuild = currentBuild + 1;

      _serverVersion = _serverVersion.copyWith(
        buildNumber: nextBuild,
        version: intToVersion(nextBuild),
      );

      return <String, dynamic>{
        'method': 'GET',
        'uri': uri.toString(),
        'statusCode': 200,
        'reasonPhrase': 'OK',
        'headers': <String, String>{
          'content-type': 'application/json; charset=utf-8',
        },
        'body': <String, dynamic>{
          'value': _serverVersion.toJson(),
        },
        'metadata': <String, dynamic>{
          ...metadata,
          'feature': 'appVersion',
          'source': 'VersionSimulatingHttpService',
        },
        'timeout': timeout?.inMilliseconds,
        'fake': true,
        'source': 'VersionSimulatingHttpService',
      };
    }

    // Fallback genérico para otras rutas (no usadas en este demo).
    return <String, dynamic>{
      'method': 'GET',
      'uri': uri.toString(),
      'statusCode': 200,
      'reasonPhrase': 'OK',
      'headers': <String, String>{
        'content-type': 'application/json; charset=utf-8',
      },
      'body': <String, dynamic>{
        'value': <String, dynamic>{
          'method': 'GET',
          'uri': uri.toString(),
          'metadata': metadata,
          'source': 'VersionSimulatingHttpService',
        },
      },
      'metadata': metadata,
      'timeout': timeout?.inMilliseconds,
      'fake': true,
      'source': 'VersionSimulatingHttpService',
    };
  }

  @override
  Future<Map<String, dynamic>> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    throw UnimplementedError('POST not used in this demo');
  }

  @override
  Future<Map<String, dynamic>> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    throw UnimplementedError('PUT not used in this demo');
  }

  @override
  Future<Map<String, dynamic>> delete(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    throw UnimplementedError('DELETE not used in this demo');
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
