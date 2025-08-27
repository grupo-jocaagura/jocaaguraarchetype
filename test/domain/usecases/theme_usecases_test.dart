import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ----------------------
/// Fakes / Stubs helpers
/// ----------------------

class _RepoOk implements RepositoryTheme {
  ThemeState _s = ThemeState.defaults;

  @override
  Future<Either<ErrorItem, ThemeState>> read() async =>
      Right<ErrorItem, ThemeState>(_s);

  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState s) async =>
      Right<ErrorItem, ThemeState>(_s = s);
}

class _RepoReadLeft implements RepositoryTheme {
  @override
  Future<Either<ErrorItem, ThemeState>> read() async =>
      Left<ErrorItem, ThemeState>(
        const ErrorItem(
          title: 'read-left',
          code: 'READ_ERR',
          description: 'read-left',
        ),
      );

  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState s) async =>
      Right<ErrorItem, ThemeState>(s);
}

class _RepoSaveLeft implements RepositoryTheme {
  final ThemeState _s = ThemeState.defaults;

  @override
  Future<Either<ErrorItem, ThemeState>> read() async =>
      Right<ErrorItem, ThemeState>(_s);

  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState s) async =>
      Left<ErrorItem, ThemeState>(
        const ErrorItem(
          title: 'save-left',
          code: 'SAVE_ERR',
          description: 'save-left',
        ),
      );
}

class _ServiceFixed extends ServiceTheme {
  const _ServiceFixed(this._rand);
  final Color _rand;

  @override
  Color colorRandom() => _rand;

  @override
  ColorScheme schemeFromSeed(Color seed, Brightness b) =>
      ColorScheme.fromSeed(seedColor: seed, brightness: b);

  @override
  ThemeData toThemeData(
    ThemeState state, {
    required Brightness platformBrightness,
  }) {
    final Brightness b = switch (state.mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platformBrightness,
    };
    return ThemeData.from(
      colorScheme: schemeFromSeed(state.seed, b),
      useMaterial3: state.useMaterial3,
    );
  }

  @override
  ThemeData lightTheme(ThemeState state) => ThemeData.from(
        colorScheme: schemeFromSeed(state.seed, Brightness.light),
        useMaterial3: state.useMaterial3,
      );

  @override
  ThemeData darkTheme(ThemeState state) => ThemeData.from(
        colorScheme: schemeFromSeed(state.seed, Brightness.dark),
        useMaterial3: state.useMaterial3,
      );
}

/// Atajo para construir Usecases “by hand”.
ThemeUsecases _ucsWith(RepositoryTheme repo, {ServiceTheme? service}) {
  return ThemeUsecases(
    load: LoadTheme(repo),
    setMode: SetThemeMode(repo),
    setSeed: SetThemeSeed(repo),
    toggleM3: ToggleMaterial3(repo),
    applyPreset: ApplyThemePreset(repo),
    setTextScale: SetThemeTextScale(repo),
    reset: ResetTheme(repo),
    randomize:
        RandomizeTheme(repo, service ?? const _ServiceFixed(Color(0xFF00AA77))),
    applyPatch: ApplyThemePatch(repo),
    setFromState: SetThemeState(repo),
    buildThemeData: const BuildThemeData(),
  );
}

void main() {
  group('ThemeUsecases.load', () {
    test('retorna el estado actual desde el repo', () async {
      final _RepoOk repo = _RepoOk();
      await repo.save(ThemeState.defaults.copyWith(mode: ThemeMode.dark));
      final ThemeUsecases uc = _ucsWith(repo);

      final Either<ErrorItem, ThemeState> r = await uc.load();
      r.when(
        (ErrorItem _) => fail('No debía fallar'),
        (ThemeState s) => expect(s.mode, ThemeMode.dark),
      );
    });

    test('propaga Left cuando repo.read falla', () async {
      final ThemeUsecases uc = _ucsWith(_RepoReadLeft());
      final Either<ErrorItem, ThemeState> r = await uc.load();
      expect(r.isLeft, isTrue);
    });
  });

  group('ThemeUsecases.setMode / setSeed / toggleM3 / applyPreset', () {
    test('actualizan el ThemeState y persisten', () async {
      final ThemeUsecases uc = _ucsWith(_RepoOk());

      final Either<ErrorItem, ThemeState> r1 = await uc.setMode(ThemeMode.dark);
      expect(r1.isRight, isTrue);
      r1.when((_) {}, (ThemeState s) => expect(s.mode, ThemeMode.dark));

      final Either<ErrorItem, ThemeState> r2 =
          await uc.setSeed(const Color(0xFF112233));
      r2.when((_) {}, (ThemeState s) => expect(s.seed.toARGB32(), 0xFF112233));

      final Either<ErrorItem, ThemeState> r3 = await uc.toggleM3();
      r3.when((_) {}, (ThemeState s) => expect(s.useMaterial3, isFalse));

      final Either<ErrorItem, ThemeState> r4 = await uc.applyPreset('brandX');
      r4.when((_) {}, (ThemeState s) => expect(s.preset, 'brandX'));
    });

    test('_ThemeUpdate: si read() falla, propaga Left y no llama save()',
        () async {
      final ThemeUsecases uc = _ucsWith(_RepoReadLeft());
      final Either<ErrorItem, ThemeState> r = await uc.setMode(ThemeMode.dark);
      expect(r.isLeft, isTrue);
    });

    test('_ThemeUpdate: si save() falla, retorna Left', () async {
      final ThemeUsecases uc = _ucsWith(_RepoSaveLeft());
      final Either<ErrorItem, ThemeState> r = await uc.applyPreset('x');
      expect(r.isLeft, isTrue);
    });
  });

  group('ThemeUsecases.setTextScale (clamp y normalización)', () {
    test('clamp inferior (0.1 → 0.8)', () async {
      final ThemeUsecases uc = _ucsWith(_RepoOk());
      final Either<ErrorItem, ThemeState> r = await uc.setTextScale(0.1);
      r.when((_) {}, (ThemeState s) => expect(s.textScale, 0.8));
    });

    test('clamp superior (10 → 1.6)', () async {
      final ThemeUsecases uc = _ucsWith(_RepoOk());
      final Either<ErrorItem, ThemeState> r = await uc.setTextScale(10.0);
      r.when((_) {}, (ThemeState s) => expect(s.textScale, 1.6));
    });

    test('valor intermedio pasa tal cual (1.25)', () async {
      final ThemeUsecases uc = _ucsWith(_RepoOk());
      final Either<ErrorItem, ThemeState> r = await uc.setTextScale(1.25);
      r.when((_) {}, (ThemeState s) => expect(s.textScale, 1.25));
    });
  });

  group('ThemeUsecases.reset', () {
    test('guarda ThemeState.defaults', () async {
      final _RepoOk repo = _RepoOk();
      await repo.save(ThemeState.defaults.copyWith(preset: 'custom'));
      final ThemeUsecases uc = _ucsWith(repo);

      final Either<ErrorItem, ThemeState> r = await uc.reset();
      r.when(
        (ErrorItem _) => fail('No debía fallar'),
        (ThemeState s) => expect(s, ThemeState.defaults),
      );
    });
  });

  group('ThemeUsecases.randomize (usa ServiceTheme.colorRandom)', () {
    test('establece seed devuelto por el ServiceTheme y preset="random"',
        () async {
      final ThemeUsecases uc = _ucsWith(
        _RepoOk(),
        service: const _ServiceFixed(Color(0xFF77CC11)),
      );

      final Either<ErrorItem, ThemeState> r = await uc.randomize();
      r.when(
        (ErrorItem _) => fail('No debía fallar'),
        (ThemeState s) {
          expect(s.seed.toARGB32(), 0xFF77CC11);
          expect(s.preset, 'random');
        },
      );
    });
  });

  group('ThemeUsecases.applyPatch', () {
    test('aplica sólo los campos provistos', () async {
      final ThemeUsecases uc = _ucsWith(_RepoOk());

      final Either<ErrorItem, ThemeState> r = await uc.applyPatch(
        const ThemePatch(
          mode: ThemeMode.dark,
          textScale: 1.3,
        ),
      );

      r.when(
        (ErrorItem _) => fail('No debía fallar'),
        (ThemeState s) {
          expect(s.mode, ThemeMode.dark);
          expect(s.textScale, 1.3);
          // Campos no provistos se conservan
          expect(s.useMaterial3, ThemeState.defaults.useMaterial3);
          expect(s.seed, ThemeState.defaults.seed);
        },
      );
    });
  });

  group('ThemeUsecases.setFromState', () {
    test('reemplaza completamente el ThemeState', () async {
      final ThemeUsecases uc = _ucsWith(_RepoOk());

      final ThemeOverrides overrides = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFFAA5500)),
        dark: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAA5500),
          brightness: Brightness.dark,
        ),
      );

      final ThemeState next = ThemeState(
        mode: ThemeMode.light,
        seed: const Color(0xFF334455),
        useMaterial3: true,
        textScale: 1.15,
        preset: 'designer',
        overrides: overrides,
      );

      final Either<ErrorItem, ThemeState> r = await uc.setFromState(next);
      r.when(
        (ErrorItem _) => fail('No debía fallar'),
        (ThemeState s) {
          expect(s.mode, ThemeMode.light);
          expect(s.seed.toARGB32(), 0xFF334455);
          expect(s.useMaterial3, isTrue);
          expect(s.textScale, 1.15);
          expect(s.preset, 'designer');
          expect(s.overrides, isNotNull);
          expect(s.overrides!.light!.brightness, Brightness.light);
          expect(s.overrides!.dark!.brightness, Brightness.dark);
        },
      );
    });
  });

  group('ThemeUsecases.buildThemeData (smoke)', () {
    test('produce ThemeData desde ThemeState (no lanza)', () {
      final ThemeUsecases uc = _ucsWith(_RepoOk());

      // Un estado custom para verificar que no explode
      final ThemeState s = ThemeState.defaults.copyWith(
        seed: const Color(0xFF336699),
        useMaterial3: true,
        textScale: 1.1,
        mode: ThemeMode.dark,
      );

      final ThemeData t = uc.buildThemeData.fromState(s);
      expect(t, isA<ThemeData>());
      // sanity
      expect(t.useMaterial3, isTrue);
      expect(t.colorScheme.brightness, Brightness.dark);
    });
  });

  group('ThemeUsecases.fromRepo – wiring completo con impl reales', () {
    test('load() → defaults cuando GatewayThemeImpl está vacío (ERR_NOT_FOUND)',
        () async {
      // Gateway en memoria, sin "initial" ⇒ read => ERR_NOT_FOUND
      final GatewayTheme gw = GatewayThemeImpl();
      final RepositoryTheme repo = RepositoryThemeImpl(gateway: gw);

      // Factory under test: inyecta FakeServiceJocaaguraArchetypeTheme por defecto
      final ThemeUsecases ucs = ThemeUsecases.fromRepo(repo);

      final Either<ErrorItem, ThemeState> r = await ucs.load();
      r.when(
        (ErrorItem e) => fail('Debió ser éxito (defaults). Recibido Left: $e'),
        (ThemeState s) {
          expect(s, ThemeState.defaults);
        },
      );
    });

    test('randomize() usa FakeService por defecto (seed 0xFF0066CC) y persiste',
        () async {
      final GatewayTheme gw = GatewayThemeImpl();
      final RepositoryTheme repo = RepositoryThemeImpl(gateway: gw);
      final ThemeUsecases ucs = ThemeUsecases.fromRepo(repo);

      final Either<ErrorItem, ThemeState> r = await ucs.randomize();
      r.when(
        (ErrorItem e) => fail('No debía fallar: $e'),
        (ThemeState s) {
          expect(s.seed.toARGB32(), 0xFF0066CC, reason: 'seed del FakeService');
          expect(s.preset, 'random');
        },
      );

      // Confirmamos que quedó persistido leyendo nuevamente
      final Either<ErrorItem, ThemeState> after = await ucs.load();
      after.when(
        (ErrorItem e) => fail('No debía fallar al leer luego de randomize: $e'),
        (ThemeState s) {
          expect(s.seed.toARGB32(), 0xFF0066CC);
          expect(s.preset, 'random');
        },
      );
    });

    test('setFromState() guarda y luego load() devuelve exactamente ese estado',
        () async {
      final GatewayTheme gw = GatewayThemeImpl();
      final RepositoryTheme repo = RepositoryThemeImpl(gateway: gw);
      final ThemeUsecases ucs = ThemeUsecases.fromRepo(repo);

      final ThemeOverrides overrides = ThemeOverrides(
        light: ColorScheme.fromSeed(seedColor: const Color(0xFFAA5500)),
        dark: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAA5500),
          brightness: Brightness.dark,
        ),
      );

      final ThemeState next = ThemeState(
        mode: ThemeMode.dark,
        seed: const Color(0xFF123456),
        useMaterial3: true,
        textScale: 1.15,
        preset: 'designer',
        overrides: overrides,
      );

      final Either<ErrorItem, ThemeState> saved = await ucs.setFromState(next);
      saved.when(
        (ErrorItem e) => fail('No debía fallar al guardar: $e'),
        (ThemeState s) {
          expect(s.mode, ThemeMode.dark);
          expect(s.seed.toARGB32(), 0xFF123456);
          expect(s.useMaterial3, isTrue);
          expect(s.textScale, closeTo(1.15, 1e-9));
          expect(s.preset, 'designer');
          expect(s.overrides, isNotNull);
          expect(s.overrides!.light!.brightness, Brightness.light);
          expect(s.overrides!.dark!.brightness, Brightness.dark);
        },
      );

      final Either<ErrorItem, ThemeState> loaded = await ucs.load();
      loaded.when(
        (ErrorItem e) => fail('No debía fallar al leer: $e'),
        (ThemeState s) {
          expect(
            s,
            equals(next),
            reason: 'Debe ser exactamente el mismo estado',
          );
        },
      );
    });

    test('buildThemeData produce ThemeData coherente desde el estado',
        () async {
      final GatewayTheme gw = GatewayThemeImpl();
      final RepositoryTheme repo = RepositoryThemeImpl(gateway: gw);
      final ThemeUsecases ucs = ThemeUsecases.fromRepo(repo);

      // Persistimos un estado concreto (dark + M3 + escala 1.1)
      final ThemeState next = ThemeState.defaults.copyWith(
        mode: ThemeMode.dark,
        useMaterial3: true,
        textScale: 1.1,
        seed: const Color(0xFF445566),
      );
      final Either<ErrorItem, ThemeState> saved = await ucs.setFromState(next);
      expect(saved.isRight, isTrue);

      final Either<ErrorItem, ThemeState> loaded = await ucs.load();
      final ThemeState s = loaded.when(
        (ErrorItem e) => fail('No debía fallar: $e'),
        (ThemeState x) => x,
      );

      final ThemeData theme = ucs.buildThemeData.fromState(s);
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.dark);

      // Robustez: no asumir bodyMedium siempre no-nulo
      final bool hasAnyTextStyle = <TextStyle?>[
        theme.textTheme.bodyMedium,
        theme.textTheme.bodyLarge,
        theme.textTheme.titleMedium,
        theme.textTheme.labelLarge,
        theme.textTheme.headlineSmall,
      ].any((TextStyle? e) => e != null);
      expect(
        hasAnyTextStyle,
        isTrue,
        reason: 'Al menos un estilo del TextTheme debería estar definido.',
      );
    });
  });
}
