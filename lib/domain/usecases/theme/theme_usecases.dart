part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

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
}

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

class LoadTheme {
  const LoadTheme(this.repo);
  final RepositoryTheme repo;
  Future<Either<ErrorItem, ThemeState>> call() => repo.read();
}

class SetThemeMode with _ThemeUpdate {
  SetThemeMode(this.repo);
  final RepositoryTheme repo;
  Future<Either<ErrorItem, ThemeState>> call(ThemeMode mode) =>
      update(repo, (ThemeState s) => s.copyWith(mode: mode));
}

class SetThemeSeed with _ThemeUpdate {
  SetThemeSeed(this.repo);
  final RepositoryTheme repo;
  Future<Either<ErrorItem, ThemeState>> call(Color seed) =>
      update(repo, (ThemeState s) => s.copyWith(seed: seed));
}

class ToggleMaterial3 with _ThemeUpdate {
  ToggleMaterial3(this.repo);
  final RepositoryTheme repo;
  Future<Either<ErrorItem, ThemeState>> call() =>
      update(repo, (ThemeState s) => s.copyWith(useMaterial3: !s.useMaterial3));
}

class ApplyThemePreset with _ThemeUpdate {
  ApplyThemePreset(this.repo);
  final RepositoryTheme repo;
  Future<Either<ErrorItem, ThemeState>> call(String preset) =>
      update(repo, (ThemeState s) => s.copyWith(preset: preset));
}

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

class ResetTheme {
  const ResetTheme(this.repo);
  final RepositoryTheme repo;
  Future<Either<ErrorItem, ThemeState>> call() =>
      repo.save(ThemeState.defaults);
}

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
