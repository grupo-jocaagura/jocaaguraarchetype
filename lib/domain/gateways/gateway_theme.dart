part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Contract for reading/writing the persisted Theme state.
///
/// Implementations may use in-memory maps, local storage, secure storage,
/// or a remote endpoint. The payload is expected to be valid JSON.
///
/// Implementations **must** be idempotent and avoid throwing on unknown keys.
///
/// ### Example
/// ```dart
/// final GatewayTheme gateway = InMemoryGatewayTheme();
/// final Map<String, dynamic>? json = await gateway.readThemeJson();
/// await gateway.writeThemeJson(<String, dynamic>{'mode':'dark'});
/// ```
///
/// See also:
/// - RepositoryTheme for domain mapping
/// - ServiceJocaaguraArchetypeTheme for ThemeData building
abstract class GatewayTheme {
  Future<Either<ErrorItem, Map<String, dynamic>>> read();
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    Map<String, dynamic> json,
  );
}
