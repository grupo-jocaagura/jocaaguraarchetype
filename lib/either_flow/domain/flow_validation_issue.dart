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

/// Internal JSON keys for [FlowValidationIssue].
abstract final class _FlowValidationIssueKeys {
  static const String code = 'code';
  static const String severity = 'severity';
  static const String message = 'message';
  static const String stepIndex = 'stepIndex';
  static const String refIndex = 'refIndex';
  static const String cyclePath = 'cyclePath';
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

  /// Hydrates a [FlowValidationIssue] from a JSON map.
  ///
  /// This method is lenient and uses safe fallbacks for unknown enum names.
  factory FlowValidationIssue.fromJson(Map<String, dynamic> json) {
    final String codeRaw =
        (json[_FlowValidationIssueKeys.code] ?? '').toString();
    final String severityRaw =
        (json[_FlowValidationIssueKeys.severity] ?? '').toString();
    final String message =
        (json[_FlowValidationIssueKeys.message] ?? '').toString();

    final FlowValidationCode code = FlowValidationCode.values
            .where((FlowValidationCode e) => e.name == codeRaw)
            .cast<FlowValidationCode?>()
            .firstWhere((FlowValidationCode? _) => true, orElse: () => null) ??
        FlowValidationCode.emptyFlow;

    final FlowValidationSeverity severity = FlowValidationSeverity.values
            .where((FlowValidationSeverity e) => e.name == severityRaw)
            .cast<FlowValidationSeverity?>()
            .firstWhere((FlowValidationSeverity? _) => true,
                orElse: () => null) ??
        FlowValidationSeverity.error;

    int? tryInt(Object? v) {
      if (v is int) {
        return v;
      }
      return int.tryParse((v ?? '').toString());
    }

    List<int>? tryIntList(Object? v) {
      if (v is! List) {
        return null;
      }
      final List<int> out = <int>[];
      for (final Object? item in v) {
        final int? parsed = tryInt(item);
        if (parsed != null) {
          out.add(parsed);
        }
      }
      return out.isEmpty ? null : List<int>.unmodifiable(out);
    }

    return FlowValidationIssue(
      code: code,
      severity: severity,
      message: message,
      stepIndex: tryInt(json[_FlowValidationIssueKeys.stepIndex]),
      refIndex: tryInt(json[_FlowValidationIssueKeys.refIndex]),
      cyclePath: tryIntList(json[_FlowValidationIssueKeys.cyclePath]),
    );
  }

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

  /// Converts this issue to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      _FlowValidationIssueKeys.code: code.name,
      _FlowValidationIssueKeys.severity: severity.name,
      _FlowValidationIssueKeys.message: message,
      if (stepIndex != null) _FlowValidationIssueKeys.stepIndex: stepIndex,
      if (refIndex != null) _FlowValidationIssueKeys.refIndex: refIndex,
      if (cyclePath != null)
        _FlowValidationIssueKeys.cyclePath: List<int>.unmodifiable(cyclePath!),
    };
  }

  @override
  String toString() => 'FlowValidationIssue('
      'code=$code, severity=$severity, stepIndex=$stepIndex, refIndex=$refIndex, '
      'message="$message", cyclePath=$cyclePath'
      ')';
}
