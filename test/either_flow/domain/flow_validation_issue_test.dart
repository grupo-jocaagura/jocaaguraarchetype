import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('FlowValidationIssue', () {
    test('Given minimal fields When created Then exposes required properties',
        () {
      // Arrange
      const FlowValidationIssue issue = FlowValidationIssue(
        code: FlowValidationCode.emptyFlow,
        severity: FlowValidationSeverity.error,
        message: 'Flow has no steps.',
      );

      // Assert
      expect(issue.code, FlowValidationCode.emptyFlow);
      expect(issue.severity, FlowValidationSeverity.error);
      expect(issue.message, 'Flow has no steps.');
      expect(issue.stepIndex, isNull);
      expect(issue.refIndex, isNull);
      expect(issue.cyclePath, isNull);
    });

    test('Given all optional fields When toString Then contains key fields',
        () {
      // Arrange
      const FlowValidationIssue issue = FlowValidationIssue(
        code: FlowValidationCode.loopDetected,
        severity: FlowValidationSeverity.error,
        message: 'Cycle detected.',
        stepIndex: 1,
        refIndex: 2,
        cyclePath: <int>[1, 2, 3, 1],
      );

      // Act
      final String s = issue.toString();

      // Assert (contains instead of exact match to avoid brittle tests)
      expect(s, contains('code=FlowValidationCode.loopDetected'));
      expect(s, contains('severity=FlowValidationSeverity.error'));
      expect(s, contains('stepIndex=1'));
      expect(s, contains('refIndex=2'));
      expect(s, contains('message="Cycle detected."'));
      expect(s, contains('cyclePath=[1, 2, 3, 1]'));
    });
  });

  group('FlowValidationReport', () {
    test('Given empty errors When isValid Then returns true', () {
      // Arrange
      const FlowValidationReport report = FlowValidationReport(
        errors: <FlowValidationIssue>[],
        warnings: <FlowValidationIssue>[],
      );

      // Assert
      expect(report.isValid, isTrue);
    });

    test('Given at least one error When isValid Then returns false', () {
      // Arrange
      const FlowValidationReport report = FlowValidationReport(
        errors: <FlowValidationIssue>[
          FlowValidationIssue(
            code: FlowValidationCode.invalidEntryIndex,
            severity: FlowValidationSeverity.error,
            message: 'Entry index is not present in stepsByIndex.',
          ),
        ],
        warnings: <FlowValidationIssue>[],
      );

      // Assert
      expect(report.isValid, isFalse);
    });

    test(
        'Given errors and warnings When all Then returns errors first then warnings',
        () {
      // Arrange
      const FlowValidationIssue e1 = FlowValidationIssue(
        code: FlowValidationCode.emptyFlow,
        severity: FlowValidationSeverity.error,
        message: 'Empty flow.',
      );
      const FlowValidationIssue w1 = FlowValidationIssue(
        code: FlowValidationCode.unreachableStep,
        severity: FlowValidationSeverity.warning,
        message: 'Unreachable step.',
        stepIndex: 5,
      );

      const FlowValidationReport report = FlowValidationReport(
        errors: <FlowValidationIssue>[e1],
        warnings: <FlowValidationIssue>[w1],
      );

      // Act
      final List<FlowValidationIssue> all = report.all;

      // Assert
      expect(all, hasLength(2));
      expect(all[0], same(e1));
      expect(all[1], same(w1));
    });

    test('Given report.all When trying to mutate Then throws UnsupportedError',
        () {
      // Arrange
      const FlowValidationReport report = FlowValidationReport(
        errors: <FlowValidationIssue>[],
        warnings: <FlowValidationIssue>[],
      );

      // Act
      final List<FlowValidationIssue> all = report.all;

      // Assert
      expect(
        () => all.add(
          const FlowValidationIssue(
            code: FlowValidationCode.noTerminalStep,
            severity: FlowValidationSeverity.error,
            message: 'No terminal step.',
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('Given report When toString Then contains summary counts', () {
      // Arrange
      const FlowValidationReport report = FlowValidationReport(
        errors: <FlowValidationIssue>[
          FlowValidationIssue(
            code: FlowValidationCode.noTerminalStep,
            severity: FlowValidationSeverity.error,
            message: 'No terminal step.',
          ),
        ],
        warnings: <FlowValidationIssue>[
          FlowValidationIssue(
            code: FlowValidationCode.multipleTerminalSteps,
            severity: FlowValidationSeverity.warning,
            message: 'Multiple terminal steps.',
          ),
        ],
      );

      // Act
      final String s = report.toString();

      // Assert
      expect(s, contains('isValid=false'));
      expect(s, contains('errors=1'));
      expect(s, contains('warnings=1'));
    });
  });
}
