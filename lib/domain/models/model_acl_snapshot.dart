part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract final class ModelAclSnapshotKeys {
  static const String policiesById = 'policiesById';
  static const String userAclByPolicyId = 'userAclByPolicyId';
  static const String lastSyncAtIsoDate = 'lastSyncAtIsoDate';
}

/// Provides an immutable in-memory snapshot used for ACL evaluation.
///
/// Stores:
/// - A map of policies indexed by policyId ("<appName>.<feature>").
/// - A map of the user's assigned roles indexed by the same policyId.
/// - The last synchronization timestamp as an ISO-8601 string.
///
/// Functional example:
/// ```dart
/// void main() {
///   final ModelAclSnapshot snapshot = ModelAclSnapshot(
///     policiesById: <String, ModelAclPolicy>{},
///     userAclByPolicyId: <String, RoleType>{},
///     lastSyncAtIsoDate: '2026-01-18T10:15:30Z',
///   );
///
///   print('policies: ${snapshot.policiesById.length}');
///   print('roles: ${snapshot.userAclByPolicyId.length}');
///   print('last sync: ${snapshot.lastSyncAtIsoDate}');
/// }
/// ```
///
/// Preconditions:
/// - Keys should match the policyId convention "<appName>.<feature>".
/// - [lastSyncAtIsoDate] should be ISO-8601 or empty when unknown.
class ModelAclSnapshot {
  ModelAclSnapshot({
    required Map<String, ModelAclPolicy> policiesById,
    required Map<String, RoleType> userAclByPolicyId,
    required this.lastSyncAtIsoDate,
  })  : _policiesById = Map<String, ModelAclPolicy>.unmodifiable(policiesById),
        _userAclByPolicyId =
            Map<String, RoleType>.unmodifiable(userAclByPolicyId);

  final Map<String, ModelAclPolicy> _policiesById;
  final Map<String, RoleType> _userAclByPolicyId;

  /// Key: policyId ("<appName>.<feature>").
  Map<String, ModelAclPolicy> get policiesById => _policiesById;

  /// Key: policyId ("<appName>.<feature>"), Value: user's assigned role for that policy.
  Map<String, RoleType> get userAclByPolicyId => _userAclByPolicyId;

  final String lastSyncAtIsoDate;

  static final ModelAclSnapshot empty = ModelAclSnapshot(
    policiesById: const <String, ModelAclPolicy>{},
    userAclByPolicyId: const <String, RoleType>{},
    lastSyncAtIsoDate: '',
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelAclSnapshotKeys.policiesById: policiesById.map(
          (String k, ModelAclPolicy v) =>
              MapEntry<String, dynamic>(k, v.toJson()),
        ),
        ModelAclSnapshotKeys.userAclByPolicyId: userAclByPolicyId.map(
          (String k, RoleType v) => MapEntry<String, dynamic>(k, v.name),
        ),
        ModelAclSnapshotKeys.lastSyncAtIsoDate: lastSyncAtIsoDate,
      };

  static ModelAclSnapshot fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawPolicies =
        Utils.mapFromDynamic(json[ModelAclSnapshotKeys.policiesById]);
    final Map<String, dynamic> rawRoles =
        Utils.mapFromDynamic(json[ModelAclSnapshotKeys.userAclByPolicyId]);

    return ModelAclSnapshot(
      policiesById: rawPolicies.map(
        (String k, dynamic v) => MapEntry<String, ModelAclPolicy>(
          k,
          ModelAclPolicy.fromJson(Utils.mapFromDynamic(v)),
        ),
      ),
      userAclByPolicyId: rawRoles.map(
        (String k, dynamic v) => MapEntry<String, RoleType>(
          k,
          RoleType.values.byName(Utils.getStringFromDynamic(v)),
        ),
      ),
      lastSyncAtIsoDate: DateUtils.normalizeIsoOrEmpty(
          json[ModelAclSnapshotKeys.lastSyncAtIsoDate]),
    );
  }
}
