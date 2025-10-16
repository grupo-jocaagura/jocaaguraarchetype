part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Reactive repository that bridges `GatewayThemeReact` (Map transport)
/// to the domain model `ThemeState`, **absorbing malformed JSON** and
/// mapping failures to `Left<ErrorItem, ThemeState>`.
///
/// ## Behavior
/// - Propagates gateway `Left` as-is.
/// - On gateway `Right<Map>`, tries `ThemeState.fromJson(map)`:
///   - On success → `Right(ThemeState)`.
///   - On any exception → mapped to `Left(ErrorItem)` via [ErrorMapper].
///
/// ## Notes
/// - Normalization remains a gateway concern; this class only translates and
///   guards the Map→ThemeState conversion.
class RepositoryThemeReactImpl implements RepositoryThemeReact {
  RepositoryThemeReactImpl({
    required GatewayThemeReact gateway,
    ErrorMapper? errorMapper,
  })  : _gateway = gateway,
        _mapper = errorMapper ?? const DefaultErrorMapper();

  final GatewayThemeReact _gateway;
  final ErrorMapper _mapper;

  static const String _locRead = 'RepositoryThemeReactImpl.read';
  static const String _locSave = 'RepositoryThemeReactImpl.save';
  static const String _locWatch = 'RepositoryThemeReactImpl.watch';

  @override
  Future<Either<ErrorItem, ThemeState>> read() async {
    final Either<ErrorItem, Map<String, dynamic>> r = await _gateway.read();
    return r.fold(
      (ErrorItem e) => Left<ErrorItem, ThemeState>(e),
      (Map<String, dynamic> m) {
        try {
          return Right<ErrorItem, ThemeState>(ThemeState.fromJson(m));
        } catch (e, st) {
          return Left<ErrorItem, ThemeState>(
            _mapper.fromException(e, st, location: _locRead),
          );
        }
      },
    );
  }

  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState next) async {
    final Either<ErrorItem, Map<String, dynamic>> r =
        await _gateway.write(next.toJson());
    return r.fold(
      (ErrorItem e) => Left<ErrorItem, ThemeState>(e),
      (Map<String, dynamic> m) {
        try {
          return Right<ErrorItem, ThemeState>(ThemeState.fromJson(m));
        } catch (e, st) {
          return Left<ErrorItem, ThemeState>(
            _mapper.fromException(e, st, location: _locSave),
          );
        }
      },
    );
  }

  @override
  Stream<Either<ErrorItem, ThemeState>> watch() {
    return _gateway.watch().map((Either<ErrorItem, Map<String, dynamic>> e) {
      return e.fold(
        (ErrorItem err) => Left<ErrorItem, ThemeState>(err),
        (Map<String, dynamic> m) {
          try {
            return Right<ErrorItem, ThemeState>(ThemeState.fromJson(m));
          } catch (e, st) {
            return Left<ErrorItem, ThemeState>(
              _mapper.fromException(e, st, location: _locWatch),
            );
          }
        },
      );
    });
  }
}
