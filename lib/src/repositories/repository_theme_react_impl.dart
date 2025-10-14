part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Reactive Repository: bridges GatewayThemeReact to ThemeState.
///
/// - read/save: same semantics, mapping Map <-> ThemeState
/// - watch(): stream of Either<ErrorItem, ThemeState>
class RepositoryThemeReactImpl implements RepositoryThemeReact {
  RepositoryThemeReactImpl({
    required GatewayThemeReact gateway,
    ErrorMapper? errorMapper,
  }) : _gateway = gateway;

  final GatewayThemeReact _gateway;

  @override
  Future<Either<ErrorItem, ThemeState>> read() async {
    final Either<ErrorItem, Map<String, dynamic>> r = await _gateway.read();
    return r.fold(
      (ErrorItem e) => Left<ErrorItem, ThemeState>(e),
      (Map<String, dynamic> m) =>
          Right<ErrorItem, ThemeState>(ThemeState.fromJson(m)),
    );
  }

  @override
  Future<Either<ErrorItem, ThemeState>> save(ThemeState next) async {
    final Either<ErrorItem, Map<String, dynamic>> r =
        await _gateway.write(next.toJson());
    return r.fold(
      (ErrorItem e) => Left<ErrorItem, ThemeState>(e),
      (Map<String, dynamic> m) =>
          Right<ErrorItem, ThemeState>(ThemeState.fromJson(m)),
    );
  }

  @override
  Stream<Either<ErrorItem, ThemeState>> watch() {
    return _gateway.watch().map((Either<ErrorItem, Map<String, dynamic>> e) {
      return e.fold(
        (ErrorItem err) => Left<ErrorItem, ThemeState>(err),
        (Map<String, dynamic> m) =>
            Right<ErrorItem, ThemeState>(ThemeState.fromJson(m)),
      );
    });
  }
}
