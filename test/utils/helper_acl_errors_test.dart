import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('AclErrors', () {
    test(
        'Given policyId/appName When unauthorized Then builds deterministic ErrorItem with meta and code',
        () {
      // Arrange
      const String policyId = 'bienvenido.user.creation';
      const String appName = 'bienvenido';

      // Act
      final ErrorItem err = HelperAclErrors.unauthorized(
        policyId: policyId,
        appName: appName,
      );

      // Assert
      expect(err.title, 'Unauthorized');
      expect(err.code, 'ACL.UNAUTHORIZED');
      expect(err.description, isNotEmpty);

      expect(err.meta, isA<Map<String, dynamic>>());
      expect(err.meta['appName'], appName);
      expect(err.meta['policyId'], policyId);

      expect(err.errorLevel, ErrorLevelEnum.severe);
    });

    test(
        'Given custom description When unauthorized Then uses provided description',
        () {
      // Arrange
      const String description = 'Custom';

      // Act
      final ErrorItem err = HelperAclErrors.unauthorized(
        policyId: 'x.y',
        appName: 'app',
        description: description,
      );

      // Assert
      expect(err.description, description);
    });
  });
}
