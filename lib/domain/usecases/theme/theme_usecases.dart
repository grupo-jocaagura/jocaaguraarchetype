part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Aggregates theming use cases built on top of [RepositoryTheme] and [ServiceTheme].
///
/// Scope
/// - High-level API to load, mutate and materialize theme state.
/// - Composes granular commands (set mode/seed, toggle M3, presets, text scale,
///   patch application, full replacement, randomization, and `ThemeData` building).
///
/// Concurrency
/// - Each mutating use case performs a `read → transform → save` cycle. When multiple
///   updates run concurrently, the last write wins. If your app performs simultaneous
///   updates from different UI flows, consider serializing calls or introducing
///   optimistic/versioned saves at the repository layer.
///
/// Construction
/// - Prefer [ThemeUsecases.fromRepo] to wire defaults (including a fake [ServiceTheme]
///   suitable for examples/dev).
class ThemeUsecases {
  ThemeUsecases({
    required this.load,
    required this.setMode,
    required this.setSeed,
    required this.toggleM3,
    required this.applyPreset,
    required this.setTextScale,
    required this.reset,
    required this.randomize,
    required this.applyPatch,
    required this.setFromState,
    required this.buildThemeData,
    this.setTextThemeOverrides,
  });

  factory ThemeUsecases.fromRepo(
    RepositoryTheme repository, {
    ServiceTheme serviceTheme = const FakeServiceJocaaguraArchetypeTheme(),
  }) {
    return ThemeUsecases(
      load: LoadTheme(repository),
      setMode: SetThemeMode(repository),
      setSeed: SetThemeSeed(repository),
      toggleM3: ToggleMaterial3(repository),
      applyPreset: ApplyThemePreset(repository),
      setTextScale: SetThemeTextScale(repository),
      reset: ResetTheme(repository),
      randomize: RandomizeTheme(repository, serviceTheme),
      applyPatch: ApplyThemePatch(repository),
      setFromState: SetThemeState(repository),
      buildThemeData: const BuildThemeData(),
      setTextThemeOverrides: SetTextThemeOverrides(repository),
    );
  }

  final LoadTheme load;
  final SetThemeMode setMode;
  final SetThemeSeed setSeed;
  final ToggleMaterial3 toggleM3;
  final ApplyThemePreset applyPreset;
  final SetThemeTextScale setTextScale;
  final ResetTheme reset;
  final RandomizeTheme randomize;
  final ApplyThemePatch applyPatch;
  final SetThemeState setFromState;
  final BuildThemeData buildThemeData;
  final SetTextThemeOverrides? setTextThemeOverrides;
}

/// Applies a partial [ThemePatch] on top of the current [ThemeState] and persists it.
///
/// Semantics
/// - Reads current state; applies `patch.applyOn(current)`; saves the result.
/// - If `RepositoryTheme.read()` yields `ERR_NOT_FOUND`, the repository is expected
///   to return `ThemeState.defaults` (see repository contract).
class ApplyThemePatch with _ThemeUpdate {
  ApplyThemePatch(this.repo);
  final RepositoryTheme repo;

  /// Applies a partial patch on top of current ThemeState and persists it.
  Future<Either<ErrorItem, ThemeState>> call(ThemePatch patch) =>
      update(repo, patch.applyOn);
}

/// Saves a complete [ThemeState] provided by the UI (full replacement).
///
/// Contracts
/// - Replaces the entire theme state as-is (no merge).
/// - The repository is responsible for normalization and business error mapping.
class SetThemeState {
  const SetThemeState(this.repo);
  final RepositoryTheme repo;

  /// Saves a complete ThemeState provided by the UI (full replacement).
  Future<Either<ErrorItem, ThemeState>> call(ThemeState next) =>
      repo.save(next);
}

/// Helper mixin for update-style cases (`read → transform → save`).
///
/// Concurrency
/// - Not transactional. Two concurrent updates may overwrite each other.
///   If that matters for your UI, serialize calls or add versioning in [RepositoryTheme].
mixin _ThemeUpdate {
  Future<Either<ErrorItem, ThemeState>> update(
    RepositoryTheme repo,
    ThemeState Function(ThemeState) transform,
  ) async {
    final Either<ErrorItem, ThemeState> curr = await repo.read();
    return curr.fold(
      (ErrorItem e) => Left<ErrorItem, ThemeState>(e),
      (ThemeState s) => repo.save(transform(s)),
    );
  }
}

/// Loads the current theme state.
///
/// Returns
/// - `Right(ThemeState)` on success; repositories may fallback to `ThemeState.defaults`
///   when nothing is persisted (e.g., `ERR_NOT_FOUND`).
/// - `Left(ErrorItem)` on error.
class LoadTheme {
  const LoadTheme(this.repo);
  final RepositoryTheme repo;
  Future<Either<ErrorItem, ThemeState>> call() => repo.read();
}

/// Sets the theme mode (system/light/dark) and persists it.
///
/// Concurrency
/// - Last write wins (see [_ThemeUpdate] notes).
class SetThemeMode with _ThemeUpdate {
  SetThemeMode(this.repo);
  final RepositoryTheme repo;
  Future<Either<ErrorItem, ThemeState>> call(ThemeMode mode) =>
      update(repo, (ThemeState s) => s.copyWith(mode: mode));
}

/// Sets the seed color and persists it.
///
/// Notes
/// - Palette generation and color normalization are delegated to upper layers
///   (`ThemeState` / `GatewayTheme` rules).
class SetThemeSeed with _ThemeUpdate {
  SetThemeSeed(this.repo);
  final RepositoryTheme repo;
  Future<Either<ErrorItem, ThemeState>> call(Color seed) =>
      update(repo, (ThemeState s) => s.copyWith(seed: seed));
}

/// Toggles Material 3 (M3) flag and persists it.
class ToggleMaterial3 with _ThemeUpdate {
  ToggleMaterial3(this.repo);
  final RepositoryTheme repo;
  Future<Either<ErrorItem, ThemeState>> call() =>
      update(repo, (ThemeState s) => s.copyWith(useMaterial3: !s.useMaterial3));
}

/// Applies a named preset and persists it.
///
/// Contracts
/// - This use case does not validate preset existence. Upstream layers may
///   normalize empty/unknown values to `'brand'` or handle mapping.
class ApplyThemePreset with _ThemeUpdate {
  ApplyThemePreset(this.repo);
  final RepositoryTheme repo;
  Future<Either<ErrorItem, ThemeState>> call(String preset) =>
      update(repo, (ThemeState s) => s.copyWith(preset: preset));
}

/// Sets the text scale and persists it.
///
/// Contracts
/// - The provided [scale] is clamped to `[0.8, 1.6]`.
/// - Caller should provide a **finite** value. If non-finite values are passed,
///   the behavior depends on `Utils.getDouble` downstream; prefer validating before calling.
class SetThemeTextScale with _ThemeUpdate {
  SetThemeTextScale(this.repo);
  final RepositoryTheme repo;
  Future<Either<ErrorItem, ThemeState>> call(double scale) => update(
        repo,
        (ThemeState s) => s.copyWith(
          textScale: Utils.getDouble(
            scale.clamp(0.8, 1.6),
          ),
        ),
      );
}

/// Resets the theme to [ThemeState.defaults] and persists it.
///
/// Notes
/// - This is a full replacement; any previous overrides/presets are discarded.
class ResetTheme {
  const ResetTheme(this.repo);
  final RepositoryTheme repo;
  Future<Either<ErrorItem, ThemeState>> call() =>
      repo.save(ThemeState.defaults);
}

/// Randomizes the seed color using [ServiceTheme.colorRandom] and sets `preset: 'random'`.
///
/// Notes
/// - Determinism and distribution of `colorRandom()` are defined by [ServiceTheme].
/// - This is a convenience for demos/dev; production apps may want curated palettes.
class RandomizeTheme with _ThemeUpdate {
  RandomizeTheme(this.repo, this.service);
  final RepositoryTheme repo;
  final ServiceTheme service;
  Future<Either<ErrorItem, ThemeState>> call() => update(
        repo,
        (ThemeState s) =>
            s.copyWith(seed: service.colorRandom(), preset: 'random'),
      );
}

/// Sets (or clears) the per-scheme typography overrides and persists them.
///
/// Passing `null` clears current text overrides.
class SetTextThemeOverrides with _ThemeUpdate {
  SetTextThemeOverrides(this.repo);
  final RepositoryTheme repo;

  Future<Either<ErrorItem, ThemeState>> call(TextThemeOverrides? next) =>
      update(repo, (ThemeState s) => s.copyWith(textOverrides: next));
}

/// Streams theme updates from the repository.
///
/// Emits Either<ErrorItem, ThemeState> so the consumer can handle errors
/// without closing the stream.
class WatchTheme {
  const WatchTheme(this.repo);
  final RepositoryThemeReact repo;

  Stream<Either<ErrorItem, ThemeState>> call() => repo.watch();
}
