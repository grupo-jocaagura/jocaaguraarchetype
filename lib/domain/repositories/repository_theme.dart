part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Repository that maps storage payloads to [ThemeState] and back.
///
/// This layer translates I/O concerns and malformed payloads into domain
/// results (Either<ErrorItem, ThemeState>), never exposing raw maps to usecases.
///
/// ### Example
/// ```dart
/// final RepositoryTheme repo = RepositoryThemeImpl(gateway: InMemoryGatewayTheme());
/// final Either<ErrorItem, ThemeState> result = await repo.load();
/// result.fold(
///   (err) => debugPrint('Error: ${err.message}'),
///   (state) => debugPrint('Loaded theme: ${state.mode}'),
/// );
/// ```
///
/// See also:
/// - GatewayTheme for raw persistence
/// - ThemeUsecases for application-level actions
abstract class RepositoryTheme {
  Future<Either<ErrorItem, ThemeState>> read();
  Future<Either<ErrorItem, ThemeState>> save(ThemeState next);
}
