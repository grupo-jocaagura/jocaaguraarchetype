import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Endpoint de ejemplo que representa el servicio remoto de versión de app.
///
/// En una app real, este URI vendría de configuración/env:
/// - `https://api.miapp.com/app/version`
/// - o similar según ambiente (dev/qa/prod).
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
/// 🧩 Filosofía del flujo:
/// - Toda la orquestación HTTP “seria” vive en el dominio
///   (Service → Gateway → Repository → Usecases → BlocHttpRequest).
/// - Desde la UI solo consumimos `BlocHttpRequest` como una **fachada transversal**.
/// - Este helper es un ejemplo didáctico de cómo leer el body y mapearlo a
///   un modelo de dominio (`ModelAppVersion`).
///
/// Contrato esperado del body:
/// ```json
/// {
///   "value": { ...ModelAppVersion JSON... }
/// }
/// ```
/// o directamente:
/// ```json
/// { ...ModelAppVersion JSON... }
/// ```
///
/// En una implementación productiva este mapeo se debería encapsular en un
/// **usecase/repository específico de AppVersion**, pero aquí lo dejamos
/// local para mostrar el roundtrip completo.
Future<Either<ErrorItem, ModelAppVersion>> _fetchAppVersion(
  BlocHttpRequest http, {
  String requestKey = 'app.version.check',
}) async {
  final Either<ErrorItem, ModelConfigHttpRequest> result = await http.get(
    requestKey: requestKey,
    uri: _kAppVersionEndpoint,
    metadata: <String, dynamic>{
      // Meta pensada para logging/telemetría.
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
      // - body['value'] → preferido (contrato recomendado).
      // - body['data']  → alternativo (APIs existentes).
      // - body completo → fallback (ej. servicio legacy que responde directo).
      //
      // Esto transmite la idea de:
      // - “la app sabe trabajar con varias envolturas razonables”
      // - sin acoplarse a un único backend perfecto.
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
        // 🎯 Mensaje de error pensado para diagnóstico, no para usuario final.
        // El UI solo muestra un resumen; el detalle va a logs/telemetría.
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

/// Bootstrap local del ejemplo:
/// - Define la “versión instalada” (fuente de verdad local).
/// - Cablea el flujo HTTP completo (Service → Gateway → Repository → Bloc).
/// - Expone via AppManager + AppConfig para integrarse con el arquetipo.
class _HttpAndVersionExample {
  _HttpAndVersionExample() : _installedVersion = _buildInstalledVersion() {
    _setupHttpLayer();
    _setupRegistry();
  }

  /// Versión instalada (fuente de verdad para la app).
  ///
  /// 💡 Filosofía:
  /// - La app debe tener claro cuál es su propia versión de compilación.
  /// - Esta versión se compara con la del servidor para tomar decisiones
  ///   (recordatorios suaves, bloqueos hard mínimos, etc.).
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

  /// Representa la versión instalada de la app al momento de compilar.
  final ModelAppVersion _installedVersion;

  late final BlocModelVersion _blocModelVersion;
  late final BlocHttpRequest _blocHttpRequest;
  late final PageRegistry registry;
  late final PageManager _pageManager;

  /// Construye el AppManager usando el AppConfig del arquetipo.
  ///
  /// Aquí se ve la idea central de jocaaguraarchetype:
  /// - `AppConfig` es el “cableado” de blocs core + módulos extra.
  /// - `AppManager` es la fachada de alto nivel que usa la UI.
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
            //
            // En una app real:
            // - Podríamos inyectar aquí la versión desde flavor/env.
            // - O desde un Usecase que lea info de build.
            _blocModelVersion.setVersion(_installedVersion);
            return const Right<ErrorItem, Unit>(Unit.value);
          },
          autoAdvanceAfter: const Duration(milliseconds: 250),
        ),
      ]);

    // En este ejemplo iniciamos el onboarding de una vez.
    // En una app de producción podríamos sincronizarlo con el Splash.
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
        // 🔐 Fuente de verdad de versión disponible en para el arquetipo.
        blocModelVersion: _blocModelVersion,
        // 🌐 HTTP como módulo transversal opcional.
        blocModuleList: <String, BlocModule>{
          BlocHttpRequest.name: _blocHttpRequest,
        },
      ),
    );
  }

  /// Configura la capa HTTP completa para el ejemplo.
  ///
  /// Patrón recomendado:
  /// - ServiceHttpRequest: frontera con el mundo (client real o fake).
  /// - GatewayHttpRequest: mapea errores de transporte → ErrorItem.
  /// - RepositoryHttpRequest: normaliza el modelo de dominio
  ///   (`ModelConfigHttpRequest`).
  /// - Usecases + Facade: orquestan operaciones GET/POST/PUT/DELETE/Retry.
  /// - BlocHttpRequest: fachada reactiva que usa el resto de la app.
  void _setupHttpLayer() {
    // Escenario del "servidor":
    // - installed = 42
    // - server inicial = 41 (build - 1)
    //
    // Esto nos permite ejemplificar:
    // - Servidor desactualizado (< build local).
    // - Servidor igual.
    // - Servidor con build mayor.
    final int installedBuild =
        Utils.getIntegerFromDynamic(_installedVersion.buildNumber);
    final int initialServerBuild = installedBuild - 1;
    final ModelAppVersion initialServerVersion = _installedVersion.copyWith(
      buildNumber: initialServerBuild,
      version: intToVersion(initialServerBuild),
    );

    // En producción, aquí inyectarías tu client HTTP real (Dio, http, etc.)
    // adaptado a `ServiceHttpRequest`. En este demo usamos un servicio
    // en memoria que simula el servidor.
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

  /// Registro de páginas para el arquetipo.
  ///
  /// Aquí se ve cómo el ejemplo encaja en el concepto de `PageRegistry`
  /// y `PageManager` que expone JocaaguraApp.
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

  /// Construye el BlocTheme alineado con el arquetipo (ThemeUsecases).
  ///
  /// Filosofía:
  /// - El tema se trata como fuente de verdad reactiva.
  /// - El ejemplo usa FakeServiceThemeReact, pero la estructura permite
  ///   reemplazarlo por gateways reales sin tocar la UI.
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
  /// Última versión remota conocida.
  ///
  /// No es la fuente de verdad central (esa es BlocModelVersion), sino
  /// el “snapshot” más reciente que el usuario consultó vía HTTP.
  late ModelAppVersion _lastRemoteVersion;

  @override
  void initState() {
    super.initState();
    // Iniciamos la remota igual que la instalada para mantener un estado
    // coherente antes de la primera consulta HTTP.
    _lastRemoteVersion = _HttpAndVersionExample._buildInstalledVersion();
  }

  @override
  Widget build(BuildContext context) {
    final AbstractAppManager app = context.appManager;
    final BlocHttpRequest http =
        app.requireModuleByKey<BlocHttpRequest>(BlocHttpRequest.name);

    return PageBuilder(
      page: Scaffold(
        appBar: AppBar(title: const Text('HTTP + App Version Demo')),
        body: Center(
          child: StreamBuilder<ModelAppVersion>(
            // La UI se suscribe al BlocModelVersion expuesto por AppManager.
            stream: app.appVersionBloc?.stream ??
                Stream<ModelAppVersion>.value(app.currentAppVersion),
            initialData: app.currentAppVersion,
            builder: (_, AsyncSnapshot<ModelAppVersion> snap) {
              final ModelAppVersion installed =
                  snap.data ?? ModelAppVersion.defaultModelAppVersion;

              final int installedBuild =
                  Utils.getIntegerFromDynamic(installed.buildNumber);

              // Solo mostramos la etiqueta de “última versión remota”
              // cuando BlocModelVersion considera que esa remota es “nueva”
              // frente al estado actual.
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
                    // Botón principal: consulta la versión remota mediante HTTP.
                    ElevatedButton.icon(
                      onPressed: () async {
                        final Either<ErrorItem, ModelAppVersion> result =
                            await _fetchAppVersion(
                          http,
                          requestKey: 'app.version.manual',
                        );

                        result.fold(
                          (ErrorItem error) {
                            // Mensaje simple para usuario; el detalle viaja
                            // en ErrorItem.meta hacia logs/telemetría.
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
                    // Botón secundario: aplica la remota como versión instalada.
                    //
                    // Obsérvese que:
                    // - No llamamos HTTP aquí, solo usamos el snapshot `_lastRemoteVersion`.
                    // - Delegamos la fuente de verdad a `BlocModelVersion`.
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
/// 🔍 Objetivo:
/// - Mostrar cómo un `ServiceHttpRequest` real entregaría un “HTTP response”
///   con headers, statusCode y un body JSON.
/// - Reforzar la idea de que el dominio trabaja con `ModelConfigHttpRequest`
///   como representación “normalizada” del request/response.
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
    // Simulamos una pequeña latencia para que el flujo sea visible en UI.
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
    // Sirve de ejemplo de cómo un servicio puede responder para endpoints
    // que aún no están definidos.
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
    // No se usa en este demo. En una app real se implementaría
    // siguiendo el mismo patrón que GET.
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
///
/// Se usa aquí para mostrar al implementador una forma sencilla de
/// derivar versiones legibles a partir de un contador de build.
String intToVersion(int value) {
  if (value < 0) {
    throw ArgumentError('value must be >= 0');
  }

  final int major = value ~/ 100;
  final int minor = (value % 100) ~/ 10;
  final int patch = value % 10;

  return '$major.$minor.$patch';
}
