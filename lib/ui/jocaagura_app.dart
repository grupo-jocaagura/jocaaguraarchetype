part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Entry point widget for a Jocaagura-based app using the new declarative navigation.
///
/// It creates (once) the RouterDelegate and the RouteInformationParser from:
/// - `PageManager` (navigation source of truth)
/// - `PageRegistry` (name → builder)
///
/// ### Example
/// ```dart
/// final appConfig = AppConfig.dev(registry: registry); // o tu flavor preferido
/// final appManager = AppManager(appConfig);
///
/// runApp(JocaaguraApp(
///   appManager: appManager,
///   registry: registry,
///   title: 'My jocaagura app',
/// ));
/// ```
class JocaaguraApp extends StatefulWidget {
  const JocaaguraApp({
    required this.appManager,
    required this.registry,
    this.title = 'My jocaagura app',
    this.routerDelegate, // opcional: si quieres inyectarlo desde un flavor
    this.routeInformationParser, // opcional: idem
    super.key,
  });

  /// Core app state & blocs (incluye `PageManager`).
  final AppManager appManager;

  /// Registry used to materialize PageModel → Widget.
  final PageRegistry registry;

  /// App title.
  final String title;

  /// Optional delegate injection (useful for flavors/testing).
  final MyAppRouterDelegate? routerDelegate;

  /// Optional parser injection (useful for flavors/testing).
  final MyRouteInformationParser? routeInformationParser;

  @override
  State<JocaaguraApp> createState() => _JocaaguraAppState();
}

class _JocaaguraAppState extends State<JocaaguraApp> {
  late final MyAppRouterDelegate _delegate = widget.routerDelegate ??
      MyAppRouterDelegate(
        registry: widget.registry,
        pageManager: widget.appManager.page,
      );

  late final MyRouteInformationParser _parser =
      widget.routeInformationParser ?? const MyRouteInformationParser();

  @override
  void initState() {
    super.initState();
    final String initialLocation =
        widget.appManager.page.stack.top.toUriString();
    routeInformationProvider:
    PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(location: initialLocation),
    );
    final PageModel top = widget.appManager.page.stack.top;
    assert(
      widget.registry.contains(top.name),
      'No builder in PageRegistry for initial route: ${top.name}. '
      'Known routes: ${widget.registry._builders.keys.toList()}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppManager app = widget.appManager;

    app.responsive.setSizeFromContext(context);

    return AppManagerProvider(
      appManager: app,
      child: StreamBuilder<ThemeState>(
        stream: app.theme.stream,
        initialData: app.theme.stateOrDefault,
        builder: (_, __) {
          final ThemeState s = app.theme.stateOrDefault;
          final String initialLocation =
              widget.appManager.page.stack.top.toUriString();
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: widget.title,
            themeMode: s.mode,
            theme: ThemeDataUtils.light(s),
            darkTheme: ThemeDataUtils.dark(s),
            routerDelegate: _delegate,
            routeInformationParser: _parser,
            routeInformationProvider: PlatformRouteInformationProvider(
              initialRouteInformation:
                  RouteInformation(location: initialLocation), // "/home"
            ),
          );
        },
      ),
    );
  }
}
