/// Storage gateway used by [EitherFlowBridge].
///
/// This lives in the *tooling layer* (archetype/infrastructure).
/// The core domain remains independent from storage concerns.
///
/// The gateway works on raw JSON strings to keep the boundary simple and
/// clipboard-friendly.
///
/// ### Example
/// ```dart
/// class MemoryFlowStorage implements EitherFlowStorageGateway {
///   final Map<String, String> _db = <String, String>{};
///
///   @override
///   Future<void> save({required String id, required String rawJson}) async {
///     _db[id] = rawJson;
///   }
///
///   @override
///   Future<String?> load({required String id}) async => _db[id];
/// }
/// ```
abstract class EitherFlowStorageGateway {
  /// Saves a raw JSON flow payload under [id].
  Future<void> save({required String id, required String rawJson});

  /// Loads a raw JSON flow payload by [id].
  ///
  /// Returns `null` if the flow does not exist.
  Future<String?> load({required String id});
}
