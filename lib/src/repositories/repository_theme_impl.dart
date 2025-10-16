part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Default implementation of [RepositoryTheme].
///
/// Responsibilities
/// - Read/write theme payloads through a [GatewayTheme] abstraction.
/// - Decode/encode [ThemeState] using canonical JSON (`ThemeState.fromJson` / `toJson`).
/// - Normalize and validate payloads (delegates field rules to the gateway + `ThemeState`).
/// - Map I/O or parsing issues into [ErrorItem] via an [ErrorMapper].
///
/// Behavior & Contracts
/// - `read()`:
///   - On success (`Right<Map>`): checks for business errors with `errorMapper.fromPayload`.
///     If any, returns `Left<ErrorItem>`. Otherwise returns `Right<ThemeState>`
///     built from the payload (`ThemeState.fromJson`).
///   - On gateway `ERR_NOT_FOUND`: returns `Right(ThemeState.defaults)`.
///   - On any other error: returns `Left<ErrorItem>` with `meta.location = "RepositoryTheme.read"`.
/// - `save(next)`:
///   - Writes `next.toJson()` to the gateway.
///   - On success: validates business errors with `fromPayload`; otherwise returns the
///     normalized `ThemeState` from the echoed payload.
///   - On error: returns `Left<ErrorItem>` with `meta.location = "RepositoryTheme.save"`.
///
/// Notes
/// - This repository is transport-agnostic: persistence rules live in [GatewayTheme].
/// - The provided [ErrorMapper] is used for both exception mapping and business-payload mapping.
/// - `ThemeState.defaults` is the standard fallback when no persisted theme exists.
///
/// Example
/// ```dart
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
///
/// Future<void> main() async {
///   // In-memory gateway suitable for dev/examples.
///   final GatewayTheme gateway = GatewayThemeImpl();
///   final RepositoryTheme repo = RepositoryThemeImpl(gateway: gateway);
///
///   // Read (falls back to ThemeState.defaults if not found)
///   final eitherLoaded = await repo.read();
///   final ThemeState state = eitherLoaded.fold(
///     (err) {
///       // handle error
///       throw StateError('read failed: ${err.code}');
///     },
///     (ok) => ok,
///   );
///
///   // Save a modified state (echoes back normalized payload)
///   final ThemeState next = state.copyWith(
///     mode: ThemeMode.dark,
///   );
///   final eitherSaved = await repo.save(next);
///   final ThemeState persisted = eitherSaved.fold(
///     (err) => throw StateError('save failed: ${err.code}'),
///     (ok) => ok,
///   );
///
///   // persisted is guaranteed to be the normalized state echoed by the gateway
///   print('Theme saved: mode=${persisted.mode}');
/// }
/// ```
class RepositoryThemeImpl implements RepositoryTheme {
  RepositoryThemeImpl({
    required GatewayTheme gateway,
    ErrorMapper? errorMapper,
  })  : _gw = gateway,
        _mapper = errorMapper ?? const DefaultErrorMapper();

  final GatewayTheme _gw;
  final ErrorMapper _mapper;

  static const String _locRead = 'RepositoryTheme.read';
  static const String _locWrite = 'RepositoryTheme.save';

  @override
  Future<Either<ErrorItem, ThemeState>> read() async {
    try {
      final Either<ErrorItem, Map<String, dynamic>> r = await _gw.read();

      // Mapear resultado del gateway con `when`
      return r.when(
        // LEFT: Error del gateway
        (ErrorItem err) {
          // Si es "no encontrado", devolvemos defaults como éxito
          if (err.code == 'ERR_NOT_FOUND') {
            return Right<ErrorItem, ThemeState>(ThemeState.defaults);
          }
          // Cualquier otro error se propaga como Left
          return Left<ErrorItem, ThemeState>(
            err.copyWith(
              meta: <String, dynamic>{
                ...err.meta,
                'location': _locRead,
              },
            ),
          );
        },
        // RIGHT: Payload ok; validar si trae error de negocio
        (Map<String, dynamic> payload) {
          final ErrorItem? biz =
              _mapper.fromPayload(payload, location: _locRead);
          if (biz != null) {
            return Left<ErrorItem, ThemeState>(biz);
          }
          return Right<ErrorItem, ThemeState>(ThemeState.fromJson(payload));
        },
      );
    } catch (e, st) {
      final ErrorItem mapped = _mapper.fromException(e, st, location: _locRead);
      return Left<ErrorItem, ThemeState>(mapped);
    }
  }

  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState next) async {
    try {
      final Map<String, dynamic> json = next.toJson();
      final Either<ErrorItem, Map<String, dynamic>> r = await _gw.write(json);

      return r.when(
        (ErrorItem err) => Left<ErrorItem, ThemeState>(
          err.copyWith(
            meta: <String, dynamic>{
              ...err.meta,
              'location': _locWrite,
            },
          ),
        ),
        (Map<String, dynamic> payload) {
          final ErrorItem? biz =
              _mapper.fromPayload(payload, location: _locWrite);
          if (biz != null) {
            return Left<ErrorItem, ThemeState>(biz);
          }
          return Right<ErrorItem, ThemeState>(ThemeState.fromJson(payload));
        },
      );
    } catch (e, st) {
      final ErrorItem mapped =
          _mapper.fromException(e, st, location: _locWrite);
      return Left<ErrorItem, ThemeState>(mapped);
    }
  }
}
