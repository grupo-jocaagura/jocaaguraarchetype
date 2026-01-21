import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('FlowValidationSeverity', () {
    test('Given enum values When iterating Then order is stable', () {
      expect(FlowValidationSeverity.values, <FlowValidationSeverity>[
        FlowValidationSeverity.error,
        FlowValidationSeverity.warning,
      ]);
    });
  });

  group('FlowValidationCode', () {
    test('Given enum values When iterating Then contains expected members', () {
      expect(
        FlowValidationCode.values.contains(FlowValidationCode.emptyFlow),
        isTrue,
      );
      expect(
        FlowValidationCode.values.contains(FlowValidationCode.loopDetected),
        isTrue,
      );
    });
  });

  group('FlowValidationIssue', () {
    test('Given required fields When created Then stores values', () {
      const FlowValidationIssue issue = FlowValidationIssue(
        code: FlowValidationCode.missingStepReference,
        severity: FlowValidationSeverity.error,
        message: 'Missing referenced step.',
        stepIndex: 3,
        refIndex: 99,
      );

      expect(issue.code, FlowValidationCode.missingStepReference);
      expect(issue.severity, FlowValidationSeverity.error);
      expect(issue.message, 'Missing referenced step.');
      expect(issue.stepIndex, 3);
      expect(issue.refIndex, 99);
      expect(issue.cyclePath, isNull);
    });

    test('Given loopDetected When cyclePath provided Then it is preserved', () {
      const List<int> cycle = <int>[0, 2, 5, 0];
      const FlowValidationIssue issue = FlowValidationIssue(
        code: FlowValidationCode.loopDetected,
        severity: FlowValidationSeverity.error,
        message: 'Cycle detected.',
        cyclePath: cycle,
      );

      expect(issue.cyclePath, cycle);
    });

    test('Given issue When toString Then includes key fields', () {
      const FlowValidationIssue issue = FlowValidationIssue(
        code: FlowValidationCode.unreachableStep,
        severity: FlowValidationSeverity.warning,
        message: 'Step is unreachable.',
        stepIndex: 7,
      );

      final String s = issue.toString();
      expect(s, contains('code=${FlowValidationCode.unreachableStep}'));
      expect(s, contains('severity=${FlowValidationSeverity.warning}'));
      expect(s, contains('stepIndex=7'));
      expect(s, contains('message="Step is unreachable."'));
    });
  });

  group('FlowValidationReport', () {
    test('Given no errors When isValid Then true', () {
      const FlowValidationReport report = FlowValidationReport(
        errors: <FlowValidationIssue>[],
        warnings: <FlowValidationIssue>[],
      );

      expect(report.isValid, isTrue);
      expect(report.all, isEmpty);
    });

    test('Given errors When isValid Then false', () {
      const FlowValidationIssue issue = FlowValidationIssue(
        code: FlowValidationCode.emptyFlow,
        severity: FlowValidationSeverity.error,
        message: 'No steps found.',
      );

      const FlowValidationReport report = FlowValidationReport(
        errors: <FlowValidationIssue>[issue],
        warnings: <FlowValidationIssue>[],
      );

      expect(report.isValid, isFalse);
      expect(report.all, <FlowValidationIssue>[issue]);
    });

    test('Given errors and warnings When all Then errors are first', () {
      const FlowValidationIssue e1 = FlowValidationIssue(
        code: FlowValidationCode.invalidEntryIndex,
        severity: FlowValidationSeverity.error,
        message: 'Bad entry index.',
      );
      const FlowValidationIssue w1 = FlowValidationIssue(
        code: FlowValidationCode.unreachableStep,
        severity: FlowValidationSeverity.warning,
        message: 'Unreachable step.',
        stepIndex: 10,
      );

      const FlowValidationReport report = FlowValidationReport(
        errors: <FlowValidationIssue>[e1],
        warnings: <FlowValidationIssue>[w1],
      );

      expect(report.all, <FlowValidationIssue>[e1, w1]);
    });

    test('Given report.all When attempting mutation Then throws', () {
      const FlowValidationReport report = FlowValidationReport(
        errors: <FlowValidationIssue>[],
        warnings: <FlowValidationIssue>[],
      );

      final List<FlowValidationIssue> all = report.all;
      expect(
        () => all.add(
          const FlowValidationIssue(
            code: FlowValidationCode.noTerminalStep,
            severity: FlowValidationSeverity.warning,
            message: 'No terminal.',
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('Given report When toString Then includes summary counters', () {
      const FlowValidationIssue e1 = FlowValidationIssue(
        code: FlowValidationCode.emptyFlow,
        severity: FlowValidationSeverity.error,
        message: 'No steps found.',
      );
      const FlowValidationIssue w1 = FlowValidationIssue(
        code: FlowValidationCode.multipleTerminalSteps,
        severity: FlowValidationSeverity.warning,
        message: 'Multiple terminals.',
      );

      const FlowValidationReport report = FlowValidationReport(
        errors: <FlowValidationIssue>[e1],
        warnings: <FlowValidationIssue>[w1],
      );

      final String s = report.toString();
      expect(s, contains('isValid=false'));
      expect(s, contains('errors=1'));
      expect(s, contains('warnings=1'));
    });
  });
}
