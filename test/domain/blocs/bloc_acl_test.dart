import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('BlocAcl.refresh', () {
    test(
        'Given bridge success When refresh Then updates snapshot and returns Right',
        () async {
      // Arrange
      const ModelAclPolicy policy = ModelAclPolicy(
        id: 'bienvenido.user.creation',
        minRoleType: RoleType.editor,
        appName: 'bienvenido',
        feature: 'user.creation',
        isActive: true,
        note: '',
        upsertAtIsoDate: '2026-01-18T10:15:30Z',
        upsertBy: 'admin@corp.com',
      );

      final _FakeAclBridge bridge = _FakeAclBridge(
        policiesResult: Right<ErrorItem, List<ModelAclPolicy>>(
          const <ModelAclPolicy>[policy],
        ),
        userAclResult: Right<ErrorItem, List<ModelAcl>>(<ModelAcl>[
          _grant(
            appName: 'bienvenido',
            userEmail: 'user@corp.com',
            policyId: policy.id,
            roleType: RoleType.admin,
          ),
          _grant(
            appName: 'bienvenido',
            userEmail: 'user@corp.com',
            policyId: '   ',
            roleType: RoleType.viewer,
          ), // ignored
        ]),
      );

      final BlocAcl bloc = BlocAcl(
        bridge: bridge,
        appName: 'bienvenido',
        userEmail: 'user@corp.com',
      );

      // Act
      final Either<ErrorItem, ModelAclSnapshot> result = await bloc.refresh();

      // Assert
      expect(bridge.fetchPoliciesCalls, 1);
      expect(bridge.fetchUserAclCalls, 1);

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (ModelAclSnapshot snap) {
          expect(snap.policiesById[policy.id], policy);
          expect(snap.userAclByPolicyId[policy.id], RoleType.admin);
          expect(snap.lastSyncAtIsoDate, isNotEmpty);
        },
      );

      // Snapshot stored in bloc as well
      expect(bloc.snapshot.policiesById.containsKey(policy.id), isTrue);

      bloc.dispose();
    });

    test(
        'Given policies failure When refresh Then returns Left and does not call fetchUserAcl',
        () async {
      // Arrange
      final _FakeAclBridge bridge = _FakeAclBridge(
        policiesResult: Left<ErrorItem, List<ModelAclPolicy>>(
          const ErrorItem(title: 'x', code: 'NET', description: 'fail'),
        ),
        userAclResult: Right<ErrorItem, List<ModelAcl>>(const <ModelAcl>[]),
      );

      final BlocAcl bloc = BlocAcl(
        bridge: bridge,
        appName: 'bienvenido',
        userEmail: 'user@corp.com',
      );

      // Act
      final Either<ErrorItem, ModelAclSnapshot> result = await bloc.refresh();

      // Assert
      expect(bridge.fetchPoliciesCalls, 1);
      expect(bridge.fetchUserAclCalls, 0);

      expect(result.isLeft, isTrue);
      expect(bloc.snapshot, ModelAclSnapshot.empty);

      bloc.dispose();
    });

    test(
        'Given userAcl failure When refresh Then returns Left and snapshot stays unchanged',
        () async {
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

      final _FakeAclBridge bridge = _FakeAclBridge(
        policiesResult: Right<ErrorItem, List<ModelAclPolicy>>(
          const <ModelAclPolicy>[policy],
        ),
        userAclResult: Left<ErrorItem, List<ModelAcl>>(
          const ErrorItem(title: 'x', code: 'NET', description: 'fail'),
        ),
      );

      final BlocAcl bloc = BlocAcl(
        bridge: bridge,
        appName: 'bienvenido',
        userEmail: 'user@corp.com',
      );

      // Act
      final Either<ErrorItem, ModelAclSnapshot> result = await bloc.refresh();

      // Assert
      expect(bridge.fetchPoliciesCalls, 1);
      expect(bridge.fetchUserAclCalls, 1);
      expect(result.isLeft, isTrue);
      expect(bloc.snapshot, ModelAclSnapshot.empty);

      bloc.dispose();
    });
  });

  group('BlocAcl.canAccessByPolicyId', () {
    test('Given missing policy When canAccessByPolicyId Then deny-by-default',
        () async {
      // Arrange
      final BlocAcl bloc = BlocAcl(
        bridge: _FakeAclBridge(
          policiesResult:
              Right<ErrorItem, List<ModelAclPolicy>>(const <ModelAclPolicy>[]),
          userAclResult: Right<ErrorItem, List<ModelAcl>>(const <ModelAcl>[]),
        ),
        appName: 'a',
        userEmail: 'u@x.com',
      );

      await bloc.refresh();

      // Act + Assert
      expect(bloc.canAccessByPolicyId('a.b'), isFalse);

      bloc.dispose();
    });

    test('Given inactive policy When canAccessByPolicyId Then deny', () async {
      // Arrange
      const ModelAclPolicy inactive = ModelAclPolicy(
        id: 'a.b',
        minRoleType: RoleType.viewer,
        appName: 'a',
        feature: 'b',
        isActive: false,
        note: '',
        upsertAtIsoDate: '',
        upsertBy: '',
      );

      final BlocAcl bloc = BlocAcl(
        bridge: _FakeAclBridge(
          policiesResult: Right<ErrorItem, List<ModelAclPolicy>>(
            const <ModelAclPolicy>[inactive],
          ),
          userAclResult: Right<ErrorItem, List<ModelAcl>>(<ModelAcl>[
            _grant(
              appName: 'a',
              userEmail: 'u@x.com',
              policyId: 'a.b',
              roleType: RoleType.admin,
            ),
          ]),
        ),
        appName: 'a',
        userEmail: 'u@x.com',
      );

      await bloc.refresh();

      // Act + Assert
      expect(bloc.canAccessByPolicyId('a.b'), isFalse);

      bloc.dispose();
    });

    test(
        'Given active policy and sufficient role When canAccessByPolicyId Then allow',
        () async {
      // Arrange
      const ModelAclPolicy policy = ModelAclPolicy(
        id: 'a.b',
        minRoleType: RoleType.editor,
        appName: 'a',
        feature: 'b',
        isActive: true,
        note: '',
        upsertAtIsoDate: '',
        upsertBy: '',
      );

      final BlocAcl bloc = BlocAcl(
        bridge: _FakeAclBridge(
          policiesResult: Right<ErrorItem, List<ModelAclPolicy>>(
            const <ModelAclPolicy>[policy],
          ),
          userAclResult: Right<ErrorItem, List<ModelAcl>>(<ModelAcl>[
            _grant(
              appName: 'a',
              userEmail: 'u@x.com',
              policyId: 'a.b',
              roleType: RoleType.admin,
            ),
          ]),
        ),
        appName: 'a',
        userEmail: 'u@x.com',
      );

      await bloc.refresh();

      // Act + Assert
      expect(bloc.canAccessByPolicyId(' a.b '), isTrue);

      bloc.dispose();
    });
  });

  group('BlocAcl.revalidateIfNeeded / executeWithAcl / canNavigateWithAcl', () {
    test(
        'Given viewer policy When revalidateIfNeeded Then does not refresh again',
        () async {
      // Arrange
      const ModelAclPolicy policy = ModelAclPolicy(
        id: 'a.b',
        minRoleType: RoleType.viewer,
        appName: 'a',
        feature: 'b',
        isActive: true,
        note: '',
        upsertAtIsoDate: '',
        upsertBy: '',
      );

      final _FakeAclBridge bridge = _FakeAclBridge(
        policiesResult: Right<ErrorItem, List<ModelAclPolicy>>(
          const <ModelAclPolicy>[policy],
        ),
        userAclResult: Right<ErrorItem, List<ModelAcl>>(<ModelAcl>[
          _grant(
            appName: 'a',
            userEmail: 'u@x.com',
            policyId: 'a.b',
            roleType: RoleType.viewer,
          ),
        ]),
      );

      final BlocAcl bloc =
          BlocAcl(bridge: bridge, appName: 'a', userEmail: 'u@x.com');
      await bloc.refresh();

      final int policiesCallsBefore = bridge.fetchPoliciesCalls;
      final int userAclCallsBefore = bridge.fetchUserAclCalls;

      // Act
      await bloc.revalidateIfNeeded('a.b');

      // Assert: no extra refresh
      expect(bridge.fetchPoliciesCalls, policiesCallsBefore);
      expect(bridge.fetchUserAclCalls, userAclCallsBefore);

      bloc.dispose();
    });

    test(
        'Given editor policy When revalidateIfNeeded Then refresh is triggered',
        () async {
      // Arrange
      const ModelAclPolicy policy = ModelAclPolicy(
        id: 'a.b',
        minRoleType: RoleType.editor,
        appName: 'a',
        feature: 'b',
        isActive: true,
        note: '',
        upsertAtIsoDate: '',
        upsertBy: '',
      );

      final _FakeAclBridge bridge = _FakeAclBridge(
        policiesResult: Right<ErrorItem, List<ModelAclPolicy>>(
          const <ModelAclPolicy>[policy],
        ),
        userAclResult: Right<ErrorItem, List<ModelAcl>>(<ModelAcl>[
          _grant(
            appName: 'a',
            userEmail: 'u@x.com',
            policyId: 'a.b',
            roleType: RoleType.admin,
          ),
        ]),
      );

      final BlocAcl bloc =
          BlocAcl(bridge: bridge, appName: 'a', userEmail: 'u@x.com');
      await bloc.refresh();

      final int policiesCallsBefore = bridge.fetchPoliciesCalls;
      final int userAclCallsBefore = bridge.fetchUserAclCalls;

      // Act
      await bloc.revalidateIfNeeded('a.b');

      // Assert: one more refresh call
      expect(bridge.fetchPoliciesCalls, policiesCallsBefore + 1);
      expect(bridge.fetchUserAclCalls, userAclCallsBefore + 1);

      bloc.dispose();
    });

    test(
        'Given denied access When executeWithAcl Then returns Left(unauthorized) and does not call action',
        () async {
      // Arrange
      const ModelAclPolicy policy = ModelAclPolicy(
        id: 'a.b',
        minRoleType: RoleType.admin, // requires admin
        appName: 'a',
        feature: 'b',
        isActive: true,
        note: '',
        upsertAtIsoDate: '',
        upsertBy: '',
      );

      final _FakeAclBridge bridge = _FakeAclBridge(
        policiesResult: Right<ErrorItem, List<ModelAclPolicy>>(
          const <ModelAclPolicy>[policy],
        ),
        userAclResult: Right<ErrorItem, List<ModelAcl>>(<ModelAcl>[
          _grant(
            appName: 'a',
            userEmail: 'u@x.com',
            policyId: 'a.b',
            roleType: RoleType.viewer,
          ), // insufficient
        ]),
      );

      final BlocAcl bloc =
          BlocAcl(bridge: bridge, appName: 'a', userEmail: 'u@x.com');
      await bloc.refresh();

      bool actionCalled = false;

      // Act
      final Either<ErrorItem, int> result = await bloc.executeWithAcl<int>(
        policyId: 'a.b',
        action: () async {
          actionCalled = true;
          return Right<ErrorItem, int>(1);
        },
        unauthorizedErrorBuilder: () =>
            HelperAclErrors.unauthorized(policyId: 'a.b', appName: 'a'),
      );

      // Assert
      expect(actionCalled, isFalse);
      expect(result.isLeft, isTrue);
      result.fold(
        (ErrorItem e) => expect(e.code, 'ACL.UNAUTHORIZED'),
        (_) => fail('Expected Left'),
      );

      bloc.dispose();
    });

    test(
        'Given allowed access When executeWithAcl Then calls action and returns its result',
        () async {
      // Arrange
      const ModelAclPolicy policy = ModelAclPolicy(
        id: 'a.b',
        minRoleType: RoleType.viewer,
        appName: 'a',
        feature: 'b',
        isActive: true,
        note: '',
        upsertAtIsoDate: '',
        upsertBy: '',
      );

      final BlocAcl bloc = BlocAcl(
        bridge: _FakeAclBridge(
          policiesResult: Right<ErrorItem, List<ModelAclPolicy>>(
            const <ModelAclPolicy>[policy],
          ),
          userAclResult: Right<ErrorItem, List<ModelAcl>>(<ModelAcl>[
            _grant(
              appName: 'a',
              userEmail: 'u@x.com',
              policyId: 'a.b',
              roleType: RoleType.viewer,
            ),
          ]),
        ),
        appName: 'a',
        userEmail: 'u@x.com',
      );

      await bloc.refresh();

      // Act
      final Either<ErrorItem, int> result = await bloc.executeWithAcl<int>(
        policyId: 'a.b',
        action: () async => Right<ErrorItem, int>(42),
        unauthorizedErrorBuilder: () =>
            HelperAclErrors.unauthorized(policyId: 'a.b', appName: 'a'),
      );

      // Assert
      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (int v) => expect(v, 42),
      );

      bloc.dispose();
    });

    test('Given allowed access When canNavigateWithAcl Then returns true',
        () async {
      // Arrange
      const ModelAclPolicy policy = ModelAclPolicy(
        id: 'a.b',
        minRoleType: RoleType.viewer,
        appName: 'a',
        feature: 'b',
        isActive: true,
        note: '',
        upsertAtIsoDate: '',
        upsertBy: '',
      );

      final BlocAcl bloc = BlocAcl(
        bridge: _FakeAclBridge(
          policiesResult: Right<ErrorItem, List<ModelAclPolicy>>(
            const <ModelAclPolicy>[policy],
          ),
          userAclResult: Right<ErrorItem, List<ModelAcl>>(<ModelAcl>[
            _grant(
              appName: 'a',
              userEmail: 'u@x.com',
              policyId: 'a.b',
              roleType: RoleType.viewer,
            ),
          ]),
        ),
        appName: 'a',
        userEmail: 'u@x.com',
      );

      await bloc.refresh();

      // Act
      final bool allowed = await bloc.canNavigateWithAcl('a.b');

      // Assert
      expect(allowed, isTrue);

      bloc.dispose();
    });
  });
}

class _FakeAclBridge implements AclBridge {
  _FakeAclBridge({
    required this.policiesResult,
    required this.userAclResult,
  });

  Either<ErrorItem, List<ModelAclPolicy>> policiesResult;
  Either<ErrorItem, List<ModelAcl>> userAclResult;

  int fetchPoliciesCalls = 0;
  int fetchUserAclCalls = 0;

  @override
  Future<Either<ErrorItem, List<ModelAclPolicy>>> fetchPolicies({
    required String appName,
  }) async {
    fetchPoliciesCalls++;
    return policiesResult;
  }

  @override
  Future<Either<ErrorItem, List<ModelAcl>>> fetchUserAcl({
    required String appName,
    required String userEmail,
  }) async {
    fetchUserAclCalls++;
    return userAclResult;
  }
}

ModelAcl _grant({
  required String appName,
  required String userEmail,
  required String policyId,
  required RoleType roleType,
}) {
  return ModelAcl.fromJson(<String, dynamic>{
    ModelAclEnum.id.name: 'acl-${policyId.hashCode}',
    ModelAclEnum.roleType.name: roleType.name,
    ModelAclEnum.appName.name: appName,
    ModelAclEnum.feature.name: policyId,
    ModelAclEnum.email.name: userEmail,
    ModelAclEnum.isActive.name: true,
    ModelAclEnum.emailAutorizedBy.name: 'admin@$appName.com',
    ModelAclEnum.autorizedAtIsoDate.name: '2026-01-18T10:15:30Z',
    ModelAclEnum.revokedAtIsoDate.name: '',
    ModelAclEnum.note.name: 'test',
  });
}
