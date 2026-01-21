import 'flow_simulation_plan.dart';

/// Manual decision provided to [FlowStepSimulator.next].
///
/// This is the step-by-step counterpart to [FlowForcedOutcome].
///
/// Example:
/// ```dart
/// final FlowStepDecision ok = const FlowStepDecision.success();
/// final FlowStepDecision fail = const FlowStepDecision.failure(
///   failureCodeOverride: 'SESSION_EXPIRED',
/// );
/// ```
class FlowStepDecision {
  /// Creates a decision.
  const FlowStepDecision._(
    this.branch, {
    this.failureCodeOverride,
  });

  /// Selects [ModelFlowStep.nextOnSuccessIndex].
  const FlowStepDecision.success() : this._(FlowBranch.success);

  /// Selects [ModelFlowStep.nextOnFailureIndex].
  ///
  /// If [failureCodeOverride] is provided, it will be stored as the effective
  /// failure code for the produced trace entry.
  const FlowStepDecision.failure({String? failureCodeOverride})
      : this._(
          FlowBranch.failure,
          failureCodeOverride: failureCodeOverride,
        );

  /// Selected branch.
  final FlowBranch branch;

  /// Optional override for the effective failure code.
  ///
  /// If null, the simulator will use [ModelFlowStep.failureCode].
  final String? failureCodeOverride;
}
