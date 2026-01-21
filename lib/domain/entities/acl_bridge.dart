part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Provides a backend-facing adapter for Access Control List (ACL) data.
///
/// Implementers may fetch data from HTTP, WebSockets, Apps Script, local caches,
/// or any other source. This contract is intentionally read-only.
///
/// Contracts:
/// - `appName` and `userEmail` are expected to be non-empty and trimmed.
/// - Implementers should return `Left(ErrorItem)` for network/auth/mapping issues,
///   and `Right(...)` on success.
/// - The returned lists may be empty when no policies/assignments exist.
///
/// Notes:
/// - Missing/inactive policies should be handled by the ACL evaluator (deny-by-default),
///   not by this bridge.
/// - Calls are not required to be strongly consistent with each other (different fetch times).
abstract class AclBridge {
  /// Fetches the global ACL policies for an application.
  ///
  /// Returns:
  /// - `Right(List<ModelAclPolicy>)` on success (possibly empty).
  /// - `Left(ErrorItem)` on failure (network/auth/backend/mapping).
  Future<Either<ErrorItem, List<ModelAclPolicy>>> fetchPolicies({
    required String appName,
  });

  /// Fetches the ACL assignments for a specific user within an application.
  ///
  /// Returns:
  /// - `Right(List<ModelAcl>)` on success (possibly empty).
  /// - `Left(ErrorItem)` on failure (network/auth/backend/mapping).
  Future<Either<ErrorItem, List<ModelAcl>>> fetchUserAcl({
    required String appName,
    required String userEmail,
  });
}
