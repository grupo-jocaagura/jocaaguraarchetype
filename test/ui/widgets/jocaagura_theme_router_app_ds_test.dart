import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Reutiliza tus fakes de Router si ya existen en el archivo.
/// Si no, copia los del grupo legacy (NullRouterDelegate, parsers, providers).

class _NullRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  @override
  Object? get currentConfiguration => null;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}

class _FakeRouteInformationParser extends RouteInformationParser<Object> {
  const _FakeRouteInformationParser();

  @override
  Future<Object> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return Object();
  }

  @override
  RouteInformation restoreRouteInformation(Object configuration) {
    return RouteInformation(uri: Uri.parse('/'));
  }
}

class _FakeRouteInformationProvider extends RouteInformationProvider
    with ChangeNotifier {
  @override
  RouteInformation get value => RouteInformation(uri: Uri.parse('/'));
}

class _FakeBlocResponsive implements BlocResponsive {
  int setSizeCalls = 0;

  @override
  void setSizeFromContext(BuildContext context) {
    setSizeCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Minimal Either constructors helpers (adjust if your Either API differs)
Either<L, R> _left<L, R>(L l) => Left<L, R>(l);
Either<L, R> _right<L, R>(R r) => Right<L, R>(r);

class _FakeBlocDesignSystem implements BlocDesignSystem {
  _FakeBlocDesignSystem({
    required ModelDesignSystem initial,
  })  : _ctrl =
            StreamController<Either<ErrorItem, ModelDesignSystem>>.broadcast(),
        _current = _right<ErrorItem, ModelDesignSystem>(initial),
        _lastGood = initial;

  final StreamController<Either<ErrorItem, ModelDesignSystem>> _ctrl;

  Either<ErrorItem, ModelDesignSystem> _current;
  ModelDesignSystem _lastGood;

  @override
  Stream<Either<ErrorItem, ModelDesignSystem>> get dsStream => _ctrl.stream;

  @override
  Either<ErrorItem, ModelDesignSystem> get currentEither => _current;

  @override
  ModelDesignSystem get lastGoodDs => _lastGood;

  void emitOk(ModelDesignSystem next) {
    _lastGood = next;
    _current = _right<ErrorItem, ModelDesignSystem>(next);
    _ctrl.add(_current);
  }

  void emitErr(ErrorItem err) {
    _current = _left<ErrorItem, ModelDesignSystem>(err);
    _ctrl.add(_current);
  }

  @override
  Future<void> dispose() async {
    await _ctrl.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAppManagerWithDs implements AbstractAppManager {
  _FakeAppManagerWithDs({
    required this.responsive,
    required BlocDesignSystem ds,
  }) : _ds = ds;

  @override
  final BlocResponsive responsive;

  final BlocDesignSystem _ds;

  @override
  T requireModuleOfType<T extends BlocModule>() {
    if (T == BlocDesignSystem) {
      return _ds as T;
    }
    throw UnimplementedError('No module registered for type $T');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ModelDesignSystem _buildDsWithRadius(double radius) {
  // Ajusta estos builders a tus defaults reales si existen.
  // La clave del test es que el token cambie entre DS1 y DS2.
  final ModelThemeData theme = ModelThemeData(
    lightScheme: ThemeData.light(useMaterial3: true).colorScheme,
    darkScheme: ThemeData.dark(useMaterial3: true).colorScheme,
    lightTextTheme: ThemeData.light(useMaterial3: true).textTheme,
    darkTextTheme: ThemeData.dark(useMaterial3: true).textTheme,
    useMaterial3: true,
  );

  final ModelDsExtendedTokens tokens = ModelDsExtendedTokens(
    borderRadius: radius,
    // Para evitar que falle por campos requeridos en tu modelo,
    // completa el resto con tus defaults si aplica.
    // Si tu constructor es const y tiene defaults, perfecto.
  );

  return ModelDesignSystem(
    theme: theme,
    tokens: tokens,
    semanticLight: ModelSemanticColors.fallbackLight(),
    semanticDark: ModelSemanticColors.fallbackDark(),
    dataViz: ModelDataVizPalette.fallback(),
  );
}

void main() {
  group('JocaaguraThemedRouterApp (DS-first)', () {
    testWidgets(
      'Given DS registered When built Then theme contains DS extensions',
      (WidgetTester tester) async {
        final StreamController<ThemeState> themeCtrl =
            StreamController<ThemeState>.broadcast();
        addTearDown(() async => themeCtrl.close());

        final ModelDesignSystem ds1 = _buildDsWithRadius(8);

        final _FakeBlocDesignSystem dsBloc =
            _FakeBlocDesignSystem(initial: ds1);
        addTearDown(() async => dsBloc.dispose());

        final _FakeBlocResponsive responsive = _FakeBlocResponsive();
        final AbstractAppManager appManager =
            _FakeAppManagerWithDs(responsive: responsive, ds: dsBloc);

        await tester.pumpWidget(
          JocaaguraThemedRouterApp(
            themeStream: themeCtrl.stream,
            initialTheme: ThemeState.defaults.copyWith(mode: ThemeMode.light),
            routerDelegate: _NullRouterDelegate(),
            routeInformationParser: const _FakeRouteInformationParser(),
            routeInformationProvider: _FakeRouteInformationProvider(),
            appManager: appManager,
          ),
        );

        await tester.pump();

        final MaterialApp app =
            tester.widget<MaterialApp>(find.byType(MaterialApp));
        final ThemeData t = app.theme!;

        // ✅ Ensure DS token extension is attached
        final DsExtendedTokensExtension? ext =
            t.extension<DsExtendedTokensExtension>();
        expect(ext, isNotNull);
        expect(ext!.tokens.borderRadius, 8);

        expect(responsive.setSizeCalls, greaterThan(0));
      },
    );

    testWidgets(
      'Given DS emits Right(newDs) When rebuilt Then ThemeData reflects new tokens',
      (WidgetTester tester) async {
        final StreamController<ThemeState> themeCtrl =
            StreamController<ThemeState>.broadcast(sync: true);
        addTearDown(() async => themeCtrl.close());

        final ModelDesignSystem ds1 = _buildDsWithRadius(8);
        final ModelDesignSystem ds2 = _buildDsWithRadius(16);

        final _FakeBlocDesignSystem dsBloc =
            _FakeBlocDesignSystem(initial: ds1);
        addTearDown(() async => dsBloc.dispose());

        final _FakeBlocResponsive responsive = _FakeBlocResponsive();
        final AbstractAppManager appManager =
            _FakeAppManagerWithDs(responsive: responsive, ds: dsBloc);

        await tester.pumpWidget(
          JocaaguraThemedRouterApp(
            themeStream: themeCtrl.stream,
            initialTheme: ThemeState.defaults.copyWith(mode: ThemeMode.light),
            routerDelegate: _NullRouterDelegate(),
            routeInformationParser: const _FakeRouteInformationParser(),
            routeInformationProvider: _FakeRouteInformationProvider(),
            appManager: appManager,
          ),
        );
        await tester.pump();

        MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        DsExtendedTokensExtension? ext =
            app.theme!.extension<DsExtendedTokensExtension>();
        expect(ext!.tokens.borderRadius, 8);

        final int callsBefore = responsive.setSizeCalls;

        // Act: emit new DS
        dsBloc.emitOk(ds2);
        await tester.pump();
        await tester.pump();

        // Assert: rebuilt
        expect(responsive.setSizeCalls, greaterThan(callsBefore));

        app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        ext = app.theme!.extension<DsExtendedTokensExtension>();
        expect(ext!.tokens.borderRadius, 16);
      },
    );

    testWidgets(
      'Given DS emits Left(error) When rebuilt Then keeps lastGoodDs tokens',
      (WidgetTester tester) async {
        final StreamController<ThemeState> themeCtrl =
            StreamController<ThemeState>.broadcast(sync: true);
        addTearDown(() async => themeCtrl.close());

        final ModelDesignSystem ds1 = _buildDsWithRadius(8);
        final ModelDesignSystem ds2 = _buildDsWithRadius(16);

        final _FakeBlocDesignSystem dsBloc =
            _FakeBlocDesignSystem(initial: ds1);
        addTearDown(() async => dsBloc.dispose());

        final _FakeBlocResponsive responsive = _FakeBlocResponsive();
        final AbstractAppManager appManager =
            _FakeAppManagerWithDs(responsive: responsive, ds: dsBloc);

        await tester.pumpWidget(
          JocaaguraThemedRouterApp(
            themeStream: themeCtrl.stream,
            initialTheme: ThemeState.defaults.copyWith(mode: ThemeMode.light),
            routerDelegate: _NullRouterDelegate(),
            routeInformationParser: const _FakeRouteInformationParser(),
            routeInformationProvider: _FakeRouteInformationProvider(),
            appManager: appManager,
          ),
        );
        await tester.pump();

        // Move to ds2 first
        dsBloc.emitOk(ds2);
        await tester.pump();
        await tester.pump();

        MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        DsExtendedTokensExtension? ext =
            app.theme!.extension<DsExtendedTokensExtension>();
        expect(ext!.tokens.borderRadius, 16);

        // Act: emit error
        dsBloc.emitErr(
          const ErrorItem(
            title: 'DS.ERROR',
            code: '',
            description: 'failed to load ds',
          ),
        );
        await tester.pump();
        await tester.pump();

        // Assert: stays with last good (16)
        app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        ext = app.theme!.extension<DsExtendedTokensExtension>();
        expect(ext!.tokens.borderRadius, 16);
      },
    );

    testWidgets(
      'Given ThemeState changes When DS active Then updates themeMode',
      (WidgetTester tester) async {
        final StreamController<ThemeState> themeCtrl =
            StreamController<ThemeState>.broadcast(sync: true);
        addTearDown(() async => themeCtrl.close());

        final ModelDesignSystem ds1 = _buildDsWithRadius(8);
        final _FakeBlocDesignSystem dsBloc =
            _FakeBlocDesignSystem(initial: ds1);
        addTearDown(() async => dsBloc.dispose());

        final _FakeBlocResponsive responsive = _FakeBlocResponsive();
        final AbstractAppManager appManager =
            _FakeAppManagerWithDs(responsive: responsive, ds: dsBloc);

        final ThemeState initial =
            ThemeState.defaults.copyWith(mode: ThemeMode.light);
        final ThemeState dark =
            ThemeState.defaults.copyWith(mode: ThemeMode.dark);

        await tester.pumpWidget(
          JocaaguraThemedRouterApp(
            themeStream: themeCtrl.stream,
            initialTheme: initial,
            routerDelegate: _NullRouterDelegate(),
            routeInformationParser: const _FakeRouteInformationParser(),
            routeInformationProvider: _FakeRouteInformationProvider(),
            appManager: appManager,
          ),
        );
        await tester.pump();

        MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(app.themeMode, ThemeMode.light);

        themeCtrl.add(dark);
        await tester.pump();
        await tester.pump();

        app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(app.themeMode, ThemeMode.dark);
      },
    );
  });
}
