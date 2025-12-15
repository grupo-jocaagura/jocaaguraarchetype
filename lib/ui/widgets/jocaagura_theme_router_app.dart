part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class JocaaguraThemedRouterApp extends StatelessWidget {
  const JocaaguraThemedRouterApp({
    required this.themeStream,
    required this.initialTheme,
    required this.routerDelegate,
    required this.routeInformationParser,
    required this.routeInformationProvider,
    required this.appManager,
    super.key,
  });

  final Stream<ThemeState> themeStream;
  final ThemeState initialTheme;

  final RouterDelegate<Object> routerDelegate;
  final RouteInformationParser<Object> routeInformationParser;
  final RouteInformationProvider routeInformationProvider;

  final AbstractAppManager appManager;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeState>(
      stream: themeStream,
      initialData: initialTheme,
      builder: (_, AsyncSnapshot<ThemeState> snap) {
        final ThemeState s = snap.data ?? initialTheme;

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerDelegate: routerDelegate,
          routeInformationParser: routeInformationParser,
          routeInformationProvider: routeInformationProvider,
          restorationScopeId: 'app',
          theme: const BuildThemeData()
              .fromState(s.copyWith(mode: ThemeMode.light)),
          darkTheme: const BuildThemeData()
              .fromState(s.copyWith(mode: ThemeMode.dark)),
          themeMode: s.mode,
          builder: (BuildContext context, Widget? child) {
            appManager.responsive.setSizeFromContext(context);
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
