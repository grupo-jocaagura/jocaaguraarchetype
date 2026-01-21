import 'package:jocaagura_domain/jocaagura_domain.dart';

import 'flow_analysis_report.dart';
import 'flow_analyzer.dart';
import 'flow_validation_issue.dart';
import 'flow_validator_report.dart';

/// Pure validator for [ModelCompleteFlow].
///
/// This validator performs *structural* checks only:
/// - dangling references (`nextOnSuccessIndex` / `nextOnFailureIndex`)
/// - unreachable steps
/// - cycles (as warning or error)
/// - terminal-step sanity checks
///
/// It does not execute business logic.
///
/// Example:
/// ```dart
/// final FlowValidationReport report = FlowValidator().validateFlow(flow);
/// if (!report.isValid) {
///   // Handle report.errors
/// }
/// ```
class FlowValidator {
  /// Validates a [ModelCompleteFlow].
  ///
  /// - If [strictLoops] is true, loops become errors; otherwise warnings.
  FlowValidationReport validateFlow(
    ModelCompleteFlow flow, {
    bool strictLoops = false,
  }) {
    final List<FlowValidationIssue> errors = <FlowValidationIssue>[];
    final List<FlowValidationIssue> warnings = <FlowValidationIssue>[];

    if (flow.stepsByIndex.isEmpty) {
      errors.add(
        const FlowValidationIssue(
          code: FlowValidationCode.emptyFlow,
          severity: FlowValidationSeverity.error,
          message: 'Flow has no steps.',
        ),
      );
      return FlowValidationReport(errors: errors, warnings: warnings);
    }

    final int entryIndex = flow
        .entryIndex; // smallest key or -1 :contentReference[oaicite:8]{index=8}
    if (entryIndex < 0 || flow.stepAt(entryIndex) == null) {
      errors.add(
        FlowValidationIssue(
          code: FlowValidationCode.invalidEntryIndex,
          severity: FlowValidationSeverity.error,
          message: 'Invalid entryIndex=$entryIndex for current stepsByIndex.',
          stepIndex: entryIndex,
        ),
      );
      return FlowValidationReport(errors: errors, warnings: warnings);
    }

    // 1) Reference validation (dangling edges)
    for (final ModelFlowStep step in flow.stepsSorted) {
      _validateNextRef(
        flow: flow,
        step: step,
        next: step.nextOnSuccessIndex,
        label: 'nextOnSuccessIndex',
        outErrors: errors,
      );
      _validateNextRef(
        flow: flow,
        step: step,
        next: step.nextOnFailureIndex,
        label: 'nextOnFailureIndex',
        outErrors: errors,
      );
    }

    // 2) Reachability / loops / terminals (via analyzer)
    final FlowAnalyzer analyzer = FlowAnalyzer();
    final FlowAnalysisReport analysis = analyzer.analyze(flow);

    for (final int i in analysis.unreachable) {
      warnings.add(
        FlowValidationIssue(
          code: FlowValidationCode.unreachableStep,
          severity: FlowValidationSeverity.warning,
          message:
              'Step $i is unreachable from entryIndex=${analysis.entryIndex}.',
          stepIndex: i,
        ),
      );
    }

    for (final List<int> cycle in analysis.cycles) {
      final FlowValidationSeverity sev = strictLoops
          ? FlowValidationSeverity.error
          : FlowValidationSeverity.warning;
      final List<FlowValidationIssue> target = strictLoops ? errors : warnings;

      target.add(
        FlowValidationIssue(
          code: FlowValidationCode.loopDetected,
          severity: sev,
          message: 'Cycle detected: ${cycle.join(" -> ")}',
          cyclePath: cycle,
        ),
      );
    }

    if (analysis.terminalSteps.isEmpty) {
      errors.add(
        const FlowValidationIssue(
          code: FlowValidationCode.noTerminalStep,
          severity: FlowValidationSeverity.error,
          message: 'No terminal steps found (both branches to END: -1).',
        ),
      );
    } else if (analysis.terminalSteps.length > 1) {
      warnings.add(
        FlowValidationIssue(
          code: FlowValidationCode.multipleTerminalSteps,
          severity: FlowValidationSeverity.warning,
          message:
              'Multiple terminal steps found: ${analysis.terminalSteps.join(", ")}.',
        ),
      );
    }

    return FlowValidationReport(
      errors: List<FlowValidationIssue>.unmodifiable(errors),
      warnings: List<FlowValidationIssue>.unmodifiable(warnings),
    );
  }

  /// Validates a raw list of steps to detect duplicated indices *before*
  /// creating a [ModelCompleteFlow].
  ///
  /// This is required because [ModelCompleteFlow.immutable] applies "last write wins"
  /// when multiple steps share the same index.
  FlowValidationReport validateRawSteps(List<ModelFlowStep> steps) {
    final List<FlowValidationIssue> errors = <FlowValidationIssue>[];
    final List<FlowValidationIssue> warnings = <FlowValidationIssue>[];

    final Map<int, int> counts = <int, int>{};
    for (final ModelFlowStep s in steps) {
      counts[s.index] = (counts[s.index] ?? 0) + 1;
    }

    for (final MapEntry<int, int> e in counts.entries) {
      if (e.value > 1) {
        errors.add(
          FlowValidationIssue(
            code: FlowValidationCode.duplicateIndexInInput,
            severity: FlowValidationSeverity.error,
            message:
                'Duplicate step index in input: ${e.key} appears ${e.value} times.',
            stepIndex: e.key,
          ),
        );
      }
    }

    return FlowValidationReport(errors: errors, warnings: warnings);
  }

  void _validateNextRef({
    required ModelCompleteFlow flow,
    required ModelFlowStep step,
    required int next,
    required String label,
    required List<FlowValidationIssue> outErrors,
  }) {
    if (next == -1) {
      return;
    }
    if (next < -1) {
      outErrors.add(
        FlowValidationIssue(
          code: FlowValidationCode.missingStepReference,
          severity: FlowValidationSeverity.error,
          message:
              'Invalid $label=$next in step ${step.index}. Only -1 (END) or >= 0 allowed.',
          stepIndex: step.index,
          refIndex: next,
        ),
      );
      return;
    }
    if (flow.stepAt(next) == null) {
      outErrors.add(
        FlowValidationIssue(
          code: FlowValidationCode.missingStepReference,
          severity: FlowValidationSeverity.error,
          message: 'Dangling $label=$next referenced from step ${step.index}.',
          stepIndex: step.index,
          refIndex: next,
        ),
      );
    }
  }

  FlowValidationReport validateStepsAsFlow(
    List<ModelFlowStep> steps, {
    String name = 'report',
    String description = '',
    bool strictLoops = false,
  }) {
    final FlowValidationReport raw = validateRawSteps(steps);
    if (!raw.isValid) {
      return raw;
    }

    final ModelCompleteFlow flow =
        ModelCompleteFlow.immutable(steps: steps, name: '', description: '');
    final FlowValidationReport built =
        validateFlow(flow, strictLoops: strictLoops);

    return FlowValidationReport(
      errors: <FlowValidationIssue>[...raw.errors, ...built.errors],
      warnings: <FlowValidationIssue>[...raw.warnings, ...built.warnings],
    );
  }
}
