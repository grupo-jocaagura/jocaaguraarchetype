part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class RepositoryThemeImpl implements RepositoryTheme {
  RepositoryThemeImpl({
    required GatewayTheme gateway,
    ErrorMapper? errorMapper,
  })  : _gw = gateway,
        _mapper = errorMapper ?? DefaultErrorMapper();

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
