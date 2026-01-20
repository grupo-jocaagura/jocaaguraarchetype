part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Central ACL BLoC used to keep an in-memory ACL snapshot and enforce access checks.
///
/// Rules:
/// - Missing/inactive policy => deny (deny-by-default).
/// - Missing user assignment => deny (zero trust).
/// - Revalidates snapshot only for editor/admin policies to reduce stale authorization.
///
/// Notes:
/// - This class is intentionally deterministic for `canAccessByPolicyId`.
/// - `refresh()` depends on [AclBridge] and updates the internal snapshot stream.
///
/// Make sure to call [dispose] to release stream resources.
class BlocAcl extends BlocModule {
  BlocAcl({
    required this.bridge,
    required this.appName,
    required this.userEmail,
  }) : _snapshotBloc = BlocGeneral<ModelAclSnapshot>(ModelAclSnapshot.empty);

  final AclBridge bridge;
  final String appName;
  final String userEmail;

  final BlocGeneral<ModelAclSnapshot> _snapshotBloc;

  Stream<ModelAclSnapshot> get onSnapshot => _snapshotBloc.stream;
  ModelAclSnapshot get snapshot => _snapshotBloc.value;

  /// Refreshes policies + current user's ACL table (session cache).
  Future<Either<ErrorItem, ModelAclSnapshot>> refresh() async {
    final Either<ErrorItem, List<ModelAclPolicy>> policiesResult =
        await bridge.fetchPolicies(appName: appName);

    return policiesResult.fold(
      (ErrorItem e) => Left<ErrorItem, ModelAclSnapshot>(e),
      (List<ModelAclPolicy> policies) async {
        final Either<ErrorItem, List<ModelAcl>> aclResult =
            await bridge.fetchUserAcl(
          appName: appName,
          userEmail: userEmail,
        );

        return aclResult.fold(
          (ErrorItem e) => Left<ErrorItem, ModelAclSnapshot>(e),
          (List<ModelAcl> grants) {
            final Map<String, ModelAclPolicy> policiesById =
                <String, ModelAclPolicy>{
              for (final ModelAclPolicy p in policies) p.id: p,
            };

            final Map<String, RoleType> userAclByPolicyId =
                <String, RoleType>{};
            for (final ModelAcl g in grants) {
              final String policyId = g.feature.trim();
              if (policyId.isEmpty) {
                continue;
              }
              // IMPORTANT: we treat feature as policyId, roleType as user assignment.
              userAclByPolicyId[policyId] = g.roleType;
            }

            final ModelAclSnapshot newSnapshot = ModelAclSnapshot(
              policiesById: policiesById,
              userAclByPolicyId: userAclByPolicyId,
              lastSyncAtIsoDate: DateTime.now().toUtc().toIso8601String(),
            );

            _snapshotBloc.value = newSnapshot;
            return Right<ErrorItem, ModelAclSnapshot>(newSnapshot);
          },
        );
      },
    );
  }

  /// Deterministic access for a controlled policyId.
  ///
  /// deny-by-default:
  /// - missing policy => deny
  /// - inactive policy => deny
  /// - user missing assignment => deny (zero trust)
  bool canAccessByPolicyId(String policyId) {
    final String id = policyId.trim();
    if (id.isEmpty) {
      return false;
    }

    final ModelAclPolicy? policy = snapshot.policiesById[id];
    if (policy == null || policy.isActive == false) {
      return false;
    }

    final RoleType? userRole = snapshot.userAclByPolicyId[id];
    if (userRole == null) {
      return false;
    }

    return ModelAclPolicy.roleMeetsMin(
      userRole: userRole,
      minRole: policy.minRoleType,
    );
  }

  /// Revalidates cache only when the policy requires editor/admin.
  Future<void> revalidateIfNeeded(String policyId) async {
    final String id = policyId.trim();
    final ModelAclPolicy? policy = snapshot.policiesById[id];
    if (policy == null) {
      return;
    }

    final RoleType minRole = policy.minRoleType;
    if (minRole == RoleType.editor || minRole == RoleType.admin) {
      await refresh();
    }
  }

  /// Executes an action guarded by ACL.
  ///
  /// - Revalidates for editor/admin policies.
  /// - If denied, returns a local ACL.UNAUTHORIZED error (single code).
  Future<Either<ErrorItem, T>> executeWithAcl<T>({
    required String policyId,
    required Future<Either<ErrorItem, T>> Function() action,
    required ErrorItem Function() unauthorizedErrorBuilder,
  }) async {
    await revalidateIfNeeded(policyId);

    final bool allowed = canAccessByPolicyId(policyId);
    if (!allowed) {
      return Left<ErrorItem, T>(unauthorizedErrorBuilder());
    }

    return action();
  }

  /// Navigation helper: validate before moving to a controlled route.
  ///
  /// Returns `true` if navigation may proceed, otherwise `false`.
  /// UI/router decides how to redirect to Forbidden.
  Future<bool> canNavigateWithAcl(String policyId) async {
    await revalidateIfNeeded(policyId);
    return canAccessByPolicyId(policyId);
  }

  @override
  void dispose() {
    _snapshotBloc.dispose();
  }
}
