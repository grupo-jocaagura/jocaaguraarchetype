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

  BlocDesignSystem? _tryDsBloc() {
    try {
      return appManager.requireModuleOfType<BlocDesignSystem>();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final BlocDesignSystem? dsBloc = _tryDsBloc();

    // Legacy path: no DS registered
    if (dsBloc == null) {
      return _buildWithThemeStateOnly();
    }

    // DS-first path: rebuild on BOTH ThemeState and DesignSystem changes
    return StreamBuilder<Either<ErrorItem, ModelDesignSystem>>(
      stream: dsBloc.dsStream,
      initialData: dsBloc.currentEither,
      builder: (_, AsyncSnapshot<Either<ErrorItem, ModelDesignSystem>> dsSnap) {
        final Either<ErrorItem, ModelDesignSystem> either =
            dsSnap.data ?? dsBloc.currentEither;

        final ModelDesignSystem ds = either.when(
          (ErrorItem _) => dsBloc.lastGoodDs,
          (ModelDesignSystem ok) => ok,
        );

        return _buildWithThemeAndDs(ds);
      },
    );
  }

  Widget _buildWithThemeStateOnly() {
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

  Widget _buildWithThemeAndDs(ModelDesignSystem ds) {
    return StreamBuilder<ThemeState>(
      stream: themeStream,
      initialData: initialTheme,
      builder: (_, AsyncSnapshot<ThemeState> snap) {
        final ThemeState s = snap.data ?? initialTheme;

        // DS builds full themes (extensions + component themes)
        final ThemeData lightBase =
            ds.toThemeData(brightness: Brightness.light);
        final ThemeData darkBase = ds.toThemeData(brightness: Brightness.dark);

        // Apply ONLY user prefs that should remain global knobs.
        // If you decide DS should fully own typography too, you can remove this.
        final ThemeData light = _applyUserPrefs(lightBase, s);
        final ThemeData dark = _applyUserPrefs(darkBase, s);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerDelegate: routerDelegate,
          routeInformationParser: routeInformationParser,
          routeInformationProvider: routeInformationProvider,
          restorationScopeId: 'app',
          theme: light,
          darkTheme: dark,
          themeMode: s.mode,
          builder: (BuildContext context, Widget? child) {
            appManager.responsive.setSizeFromContext(context);
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }

  ThemeData _applyUserPrefs(ThemeData base, ThemeState s) {
    // Currently: only textScale (safe) from ThemeState.
    final TextTheme scaled = _applyTextScaleSafely(base.textTheme, s.textScale);
    return base.copyWith(textTheme: scaled);
  }

  TextTheme _applyTextScaleSafely(TextTheme t, double factor) {
    if (factor == 1.0 || factor.isNaN) {
      return t;
    }

    TextStyle? scale(TextStyle? s) {
      if (s == null) {
        return null;
      }
      final double? fs = s.fontSize;
      return (fs == null) ? s : s.copyWith(fontSize: fs * factor);
    }

    return t.copyWith(
      displayLarge: scale(t.displayLarge),
      displayMedium: scale(t.displayMedium),
      displaySmall: scale(t.displaySmall),
      headlineLarge: scale(t.headlineLarge),
      headlineMedium: scale(t.headlineMedium),
      headlineSmall: scale(t.headlineSmall),
      titleLarge: scale(t.titleLarge),
      titleMedium: scale(t.titleMedium),
      titleSmall: scale(t.titleSmall),
      bodyLarge: scale(t.bodyLarge),
      bodyMedium: scale(t.bodyMedium),
      bodySmall: scale(t.bodySmall),
      labelLarge: scale(t.labelLarge),
      labelMedium: scale(t.labelMedium),
      labelSmall: scale(t.labelSmall),
    );
  }
}
