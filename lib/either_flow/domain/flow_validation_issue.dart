/// Severity for flow validation.
///
/// Validation can emit blocking issues ([FlowValidationSeverity.error]) and
/// non-blocking issues ([FlowValidationSeverity.warning]).
enum FlowValidationSeverity {
  /// The flow is inconsistent and should not be executed or simulated.
  error,

  /// The flow may be valid, but it contains suspicious structures.
  warning,
}

/// Machine-friendly codes for flow validation issues.
///
/// These codes are intended for:
/// - deterministic unit tests
/// - analytics/telemetry
/// - mapping to UX copy in higher layers
enum FlowValidationCode {
  /// The flow has no steps.
  emptyFlow,

  /// The flow's entry index is not present in [ModelCompleteFlow.stepsByIndex].
  invalidEntryIndex,

  /// A step references a missing step index (success/failure edge).
  missingStepReference,

  /// The input contained more than one step with the same index.
  ///
  /// Note: this is applicable when validating a raw list of steps.
  duplicateIndexInInput,

  /// A step exists but cannot be reached from the entry step.
  unreachableStep,

  /// A cycle was detected in the directed graph of transitions.
  loopDetected,

  /// No terminal step exists (a terminal step has no outgoing transitions).
  noTerminalStep,

  /// More than one terminal step exists.
  multipleTerminalSteps,
}

/// Single validation issue emitted by [FlowValidator].
///
/// Use [code] as the machine-friendly identifier and [message] as the
/// human-readable explanation safe for logs and UI.
///
/// Optional fields:
/// - [stepIndex]: index of the step directly affected by the issue.
/// - [refIndex]: index referenced by a transition that caused the issue.
/// - [cyclePath]: only meaningful when [code] is [FlowValidationCode.loopDetected].
///
/// Functional example:
/// ```dart
/// void main() {
///   final FlowValidationIssue issue = FlowValidationIssue(
///     code: FlowValidationCode.missingStepReference,
///     severity: FlowValidationSeverity.error,
///     message: 'Step 3 references missing step 99.',
///     stepIndex: 3,
///     refIndex: 99,
///   );
///
///   print(issue);
/// }
/// ```
class FlowValidationIssue {
  /// Creates a [FlowValidationIssue].
  const FlowValidationIssue({
    required this.code,
    required this.severity,
    required this.message,
    this.stepIndex,
    this.refIndex,
    this.cyclePath,
  });

  /// Issue code.
  final FlowValidationCode code;

  /// Issue severity.
  final FlowValidationSeverity severity;

  /// Human-readable message (safe for logs/UX).
  final String message;

  /// Step index related to the issue, if applicable.
  final int? stepIndex;

  /// Referenced index related to the issue, if applicable.
  final int? refIndex;

  /// Optional cycle path when [code] is [FlowValidationCode.loopDetected].
  ///
  /// Contract: when provided, the first and last elements usually match,
  /// representing a closed cycle.
  final List<int>? cyclePath;

  @override
  String toString() => 'FlowValidationIssue('
      'code=$code, severity=$severity, stepIndex=$stepIndex, refIndex=$refIndex, '
      'message="$message", cyclePath=$cyclePath'
      ')';
}
