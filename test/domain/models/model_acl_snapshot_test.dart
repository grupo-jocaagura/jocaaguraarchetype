import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ModelAclSnapshot JSON', () {
    test(
        'Given snapshot When toJson->fromJson Then preserves content (policies, roles, lastSyncAtIsoDate)',
        () {
      // Arrange
      final ModelAclPolicy policy = ModelAclPolicy(
        id: ModelAclPolicy.buildId(
          appName: 'bienvenido',
          feature: 'user.creation',
        ),
        minRoleType: RoleType.editor,
        appName: 'bienvenido',
        feature: 'user.creation',
        isActive: true,
        note: 'Controls user creation flow',
        upsertAtIsoDate: DateTime.utc(2026, 1, 18).toIso8601String(),
        upsertBy: 'admin@corp.com',
      );

      const String rawLastSync = '2026-01-18T10:15:30Z';

      final ModelAclSnapshot snapshot = ModelAclSnapshot(
        policiesById: <String, ModelAclPolicy>{policy.id: policy},
        userAclByPolicyId: <String, RoleType>{policy.id: RoleType.admin},
        lastSyncAtIsoDate: rawLastSync,
      );

      // Act
      final Map<String, dynamic> json = snapshot.toJson();
      final ModelAclSnapshot back = ModelAclSnapshot.fromJson(json);

      // Assert
      expect(back.policiesById[policy.id], policy);
      expect(back.userAclByPolicyId[policy.id], RoleType.admin);

      // Compare against normalized representation (stable contract).
      expect(
        back.lastSyncAtIsoDate,
        DateUtils.normalizeIsoOrEmpty(rawLastSync),
      );
    });

    test(
        'Given json without maps When fromJson Then defaults to empty maps (robust parsing)',
        () {
      // Arrange
      const String rawLastSync = '2026-01-18T10:15:30Z';
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclSnapshotKeys.lastSyncAtIsoDate: rawLastSync,
      };

      // Act
      final ModelAclSnapshot back = ModelAclSnapshot.fromJson(json);

      // Assert
      expect(back.policiesById, isEmpty);
      expect(back.userAclByPolicyId, isEmpty);
      expect(
        back.lastSyncAtIsoDate,
        DateUtils.normalizeIsoOrEmpty(rawLastSync),
      );
    });

    test(
        'Given json with null maps When fromJson Then maps become empty and lastSyncAtIsoDate normalizes to empty',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'policiesById': null,
        'userAclByPolicyId': null,
        'lastSyncAtIsoDate': null,
      };

      // Act
      final ModelAclSnapshot back = ModelAclSnapshot.fromJson(json);

      // Assert
      expect(back.policiesById, isEmpty);
      expect(back.userAclByPolicyId, isEmpty);
      expect(back.lastSyncAtIsoDate, '');
    });

    test(
        'Given policy json missing id When fromJson Then id is computed from appName + feature',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'policiesById': <String, dynamic>{
          // key can be anything; we validate the policy object itself computes id.
          'whatever.key': <String, dynamic>{
            // id missing on purpose
            ModelAclPolicyEnum.minRoleType.name: RoleType.viewer.name,
            ModelAclPolicyEnum.appName.name: 'bienvenido',
            ModelAclPolicyEnum.feature.name: 'user.creation',
            ModelAclPolicyEnum.isActive.name: true,
            ModelAclPolicyEnum.note.name: 'n',
            ModelAclPolicyEnum.upsertAtIsoDate.name: '2026-01-18T10:15:30Z',
            ModelAclPolicyEnum.upsertBy.name: 'admin@corp.com',
          },
        },
        'userAclByPolicyId': <String, dynamic>{},
        'lastSyncAtIsoDate': '2026-01-18T10:15:30Z',
      };

      // Act
      final ModelAclSnapshot back = ModelAclSnapshot.fromJson(json);

      // Assert
      final ModelAclPolicy policy = back.policiesById.values.single;
      expect(policy.id, 'bienvenido.user.creation');
    });

    test(
        'Given policy json with empty appName/feature When fromJson Then computed id becomes empty (and policy keeps raw id if present)',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'policiesById': <String, dynamic>{
          'x': <String, dynamic>{
            // raw id provided should win if non-empty, even if app/feature invalid
            ModelAclPolicyEnum.id.name: 'manual.id',
            ModelAclPolicyEnum.minRoleType.name: RoleType.viewer.name,
            ModelAclPolicyEnum.appName.name: '  ',
            ModelAclPolicyEnum.feature.name: '',
            ModelAclPolicyEnum.isActive.name: true,
            ModelAclPolicyEnum.note.name: 'n',
            ModelAclPolicyEnum.upsertAtIsoDate.name: '2026-01-18T10:15:30Z',
            ModelAclPolicyEnum.upsertBy.name: 'admin@corp.com',
          },
        },
        'userAclByPolicyId': <String, dynamic>{},
        'lastSyncAtIsoDate': '2026-01-18T10:15:30Z',
      };

      // Act
      final ModelAclSnapshot back = ModelAclSnapshot.fromJson(json);

      // Assert
      expect(back.policiesById.values.single.id, 'manual.id');
    });

    test(
        'Given json with unknown user role When fromJson Then throws (RoleType.values.byName)',
        () {
      // Arrange
      final ModelAclPolicy policy = ModelAclPolicy(
        id: ModelAclPolicy.buildId(
          appName: 'bienvenido',
          feature: 'user.creation',
        ),
        minRoleType: RoleType.viewer,
        appName: 'bienvenido',
        feature: 'user.creation',
        isActive: true,
        note: '',
        upsertAtIsoDate: DateTime.utc(2026, 1, 18).toIso8601String(),
        upsertBy: 'admin@corp.com',
      );

      final Map<String, dynamic> json = <String, dynamic>{
        'policiesById': <String, dynamic>{policy.id: policy.toJson()},
        'userAclByPolicyId': <String, dynamic>{
          policy.id: 'superAdmin', // not in enum
        },
        'lastSyncAtIsoDate': '2026-01-18T10:15:30Z',
      };

      // Act + Assert
      expect(
        () => ModelAclSnapshot.fromJson(json),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'Given json with unknown policy minRoleType When ModelAclPolicy.fromJson Then falls back to viewer (safe default)',
        () {
      // Arrange
      final Map<String, dynamic> policyJson = <String, dynamic>{
        ModelAclPolicyEnum.id.name: 'bienvenido.user.creation',
        ModelAclPolicyEnum.minRoleType.name:
            'superAdmin', // unknown -> fallback viewer
        ModelAclPolicyEnum.appName.name: 'bienvenido',
        ModelAclPolicyEnum.feature.name: 'user.creation',
        ModelAclPolicyEnum.isActive.name: true,
        ModelAclPolicyEnum.note.name: 'n',
        ModelAclPolicyEnum.upsertAtIsoDate.name: '2026-01-18T10:15:30Z',
        ModelAclPolicyEnum.upsertBy.name: 'admin@corp.com',
      };

      // Act
      final ModelAclPolicy policy = ModelAclPolicy.fromJson(policyJson);

      // Assert
      expect(policy.minRoleType, RoleType.viewer);
    });

    test(
        'Given snapshot When json payload is mutated after toJson Then original snapshot remains unchanged (immutability by unmodifiable maps)',
        () {
      // Arrange
      const ModelAclPolicy policy = ModelAclPolicy(
        id: 'bienvenido.user.creation',
        minRoleType: RoleType.viewer,
        appName: 'bienvenido',
        feature: 'user.creation',
        isActive: true,
        note: '',
        upsertAtIsoDate: '2026-01-18T10:15:30Z',
        upsertBy: 'admin@corp.com',
      );

      final ModelAclSnapshot snapshot = ModelAclSnapshot(
        policiesById: <String, ModelAclPolicy>{policy.id: policy},
        userAclByPolicyId: <String, RoleType>{policy.id: RoleType.admin},
        lastSyncAtIsoDate: '2026-01-18T10:15:30Z',
      );

      final Map<String, dynamic> json = snapshot.toJson();

      // Act: mutate json maps
      (json['policiesById'] as Map<String, dynamic>)['x.y'] = policy.toJson();
      (json['userAclByPolicyId'] as Map<String, dynamic>)['x.y'] =
          RoleType.viewer.name;

      // Assert: snapshot doesn't change
      expect(snapshot.policiesById.keys, isNot(contains('x.y')));
      expect(snapshot.userAclByPolicyId.keys, isNot(contains('x.y')));
    });
  });
  group('ModelAclSnapshot JSON', () {
    test(
        'Given snapshot When toJson->fromJson Then preserves content (normalized lastSyncAtIsoDate)',
        () {
      // Arrange
      final ModelAclPolicy policy = ModelAclPolicy(
        id: ModelAclPolicy.buildId(
          appName: 'bienvenido',
          feature: 'user.creation',
        ),
        minRoleType: RoleType.editor,
        appName: 'bienvenido',
        feature: 'user.creation',
        isActive: true,
        note: 'Controls user creation flow',
        upsertAtIsoDate: DateTime.utc(2026, 1, 18).toIso8601String(),
        upsertBy: 'admin@corp.com',
      );

      const String rawLastSync = '2026-01-18T10:15:30Z';

      final ModelAclSnapshot snapshot = ModelAclSnapshot(
        policiesById: <String, ModelAclPolicy>{policy.id: policy},
        userAclByPolicyId: <String, RoleType>{policy.id: RoleType.admin},
        lastSyncAtIsoDate: rawLastSync,
      );

      // Act
      final Map<String, dynamic> json = snapshot.toJson();
      final ModelAclSnapshot back = ModelAclSnapshot.fromJson(json);

      // Assert
      expect(back.policiesById[policy.id], policy);
      expect(back.userAclByPolicyId[policy.id], RoleType.admin);
      expect(
        back.lastSyncAtIsoDate,
        DateUtils.normalizeIsoOrEmpty(rawLastSync),
      );
    });

    test(
        'Given json without maps When fromJson Then defaults to empty maps and keeps normalized date',
        () {
      // Arrange
      const String rawLastSync = '2026-01-18T10:15:30Z';
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclSnapshotKeys.lastSyncAtIsoDate: rawLastSync,
      };

      // Act
      final ModelAclSnapshot back = ModelAclSnapshot.fromJson(json);

      // Assert
      expect(back.policiesById, isEmpty);
      expect(back.userAclByPolicyId, isEmpty);
      expect(
        back.lastSyncAtIsoDate,
        DateUtils.normalizeIsoOrEmpty(rawLastSync),
      );
    });

    test(
        'Given json with invalid lastSyncAtIsoDate When fromJson Then normalizes to empty',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclSnapshotKeys.policiesById: <String, dynamic>{},
        ModelAclSnapshotKeys.userAclByPolicyId: <String, dynamic>{},
        ModelAclSnapshotKeys.lastSyncAtIsoDate: 'not-a-date',
      };

      // Act
      final ModelAclSnapshot back = ModelAclSnapshot.fromJson(json);

      // Assert
      expect(back.lastSyncAtIsoDate, '');
    });

    test(
        'Given json with unknown user role When fromJson Then throws ArgumentError',
        () {
      // Arrange
      const ModelAclPolicy policy = ModelAclPolicy(
        id: 'bienvenido.user.creation',
        minRoleType: RoleType.viewer,
        appName: 'bienvenido',
        feature: 'user.creation',
        isActive: true,
        note: '',
        upsertAtIsoDate: '2026-01-18T10:15:30Z',
        upsertBy: 'admin@corp.com',
      );

      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclSnapshotKeys.policiesById: <String, dynamic>{
          policy.id: policy.toJson(),
        },
        ModelAclSnapshotKeys.userAclByPolicyId: <String, dynamic>{
          policy.id: 'superAdmin',
        },
        ModelAclSnapshotKeys.lastSyncAtIsoDate: '2026-01-18T10:15:30Z',
      };

      // Act + Assert
      expect(
        () => ModelAclSnapshot.fromJson(json),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
