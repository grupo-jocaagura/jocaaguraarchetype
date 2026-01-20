import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('AclBridge contract (fake implementation)', () {
    test(
        'Given existing app When fetchPolicies Then returns Right with policies',
        () async {
      // Arrange
      final AclBridge bridge = _FakeAclBridge();

      // Act
      final Either<ErrorItem, List<ModelAclPolicy>> result =
          await bridge.fetchPolicies(appName: 'bienvenido');

      // Assert
      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (List<ModelAclPolicy> policies) {
          expect(policies, isNotEmpty);
        },
      );
    });

    test(
        'Given unknown app When fetchPolicies Then returns Right with empty list',
        () async {
      final AclBridge bridge = _FakeAclBridge();

      final Either<ErrorItem, List<ModelAclPolicy>> result =
          await bridge.fetchPolicies(appName: 'unknown');

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('Expected Right'),
        (List<ModelAclPolicy> policies) => expect(policies, isEmpty),
      );
    });

    test('Given network failure When fetchUserAcl Then returns Left(ErrorItem)',
        () async {
      final AclBridge bridge = _FakeAclBridge(shouldFail: true);

      final Either<ErrorItem, List<ModelAcl>> result =
          await bridge.fetchUserAcl(
        appName: 'bienvenido',
        userEmail: 'user@corp.com',
      );

      expect(result.isLeft, isTrue);
      result.fold(
        (ErrorItem err) => expect(err, isA<ErrorItem>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}

/// --- Test-only fake ---
/// Replace construction of ErrorItem / ModelAclPolicy / ModelAcl
/// with your real constructors/helpers.
class _FakeAclBridge implements AclBridge {
  _FakeAclBridge({this.shouldFail = false});

  final bool shouldFail;

  @override
  Future<Either<ErrorItem, List<ModelAclPolicy>>> fetchPolicies({
    required String appName,
  }) async {
    if (shouldFail) {
      return Left<ErrorItem, List<ModelAclPolicy>>(
        const ErrorItem(
          title: 'network',
          code: 'NETWORK_2',
          description: 'Network error',
        ),
      );
    }
    if (appName == 'bienvenido') {
      return Right<ErrorItem, List<ModelAclPolicy>>(
        const <ModelAclPolicy>[ModelAclPolicy.defaultModelAclPolicy],
      );
    }
    return Right<ErrorItem, List<ModelAclPolicy>>(const <ModelAclPolicy>[]);
  }

  @override
  Future<Either<ErrorItem, List<ModelAcl>>> fetchUserAcl({
    required String appName,
    required String userEmail,
  }) async {
    if (shouldFail) {
      return Left<ErrorItem, List<ModelAcl>>(
        const ErrorItem(
          title: 'network',
          code: 'NETWORK.ERROR',
          description: '',
        ),
      );
    }
    return Right<ErrorItem, List<ModelAcl>>(const <ModelAcl>[]);
  }
}
