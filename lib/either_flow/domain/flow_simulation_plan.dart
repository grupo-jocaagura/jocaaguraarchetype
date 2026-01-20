import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Branch selection used by the simulator.
///
/// This enum exists only for simulation/trace purposes.
enum FlowBranch {
  /// Select [ModelFlowStep.nextOnSuccessIndex].
  success,

  /// Select [ModelFlowStep.nextOnFailureIndex].
  failure,
}

/// Forced outcome for a specific step during simulation.
///
/// This allows deterministic replays, QA scripts, and “what-if” execution.
///
/// Example:
/// ```dart
/// final FlowSimulationPlan plan = FlowSimulationPlan.immutable(
///   forcedByStepIndex: <int, FlowForcedOutcome>{
///     10: const FlowForcedOutcome.failure(failureCodeOverride: 'AUTH_FAILED'),
///     11: const FlowForcedOutcome.success(),
///   },
/// );
/// ```
class FlowForcedOutcome {
  /// Creates an outcome.
  const FlowForcedOutcome._(
    this.branch, {
    this.failureCodeOverride,
  });

  /// Forces the step to take the success branch.
  const FlowForcedOutcome.success() : this._(FlowBranch.success);

  /// Forces the step to take the failure branch.
  ///
  /// If [failureCodeOverride] is provided, it will be stored in the trace
  /// entry as the effective failure code for that step.
  const FlowForcedOutcome.failure({String? failureCodeOverride})
      : this._(
          FlowBranch.failure,
          failureCodeOverride: failureCodeOverride,
        );

  /// Forced branch.
  final FlowBranch branch;

  /// Optional override for the effective failure code.
  ///
  /// If null, the simulator will use [ModelFlowStep.failureCode].
  final String? failureCodeOverride;
}

/// Immutable plan describing how the simulator should behave.
///
/// - When a step index exists in [forcedByStepIndex], its [FlowForcedOutcome]
///   is applied.
/// - Otherwise, the simulator uses [defaultBranch].
///
/// This is intentionally *domain-only* and does not depend on Flutter.
///
/// Example:
/// ```dart
/// final FlowSimulationPlan plan = FlowSimulationPlan.immutable(
///   defaultBranch: FlowBranch.success,
///   forcedByStepIndex: <int, FlowForcedOutcome>{
///     1: const FlowForcedOutcome.failure(),
///   },
/// );
/// ```
class FlowSimulationPlan {
  /// Creates a plan.
  ///
  /// Use [FlowSimulationPlan.immutable] to ensure the map is unmodifiable.
  const FlowSimulationPlan({
    this.defaultBranch = FlowBranch.success,
    this.forcedByStepIndex = const <int, FlowForcedOutcome>{},
  });

  /// Creates a deeply immutable plan.
  factory FlowSimulationPlan.immutable({
    FlowBranch defaultBranch = FlowBranch.success,
    Map<int, FlowForcedOutcome> forcedByStepIndex =
        const <int, FlowForcedOutcome>{},
  }) {
    return FlowSimulationPlan(
      defaultBranch: defaultBranch,
      forcedByStepIndex:
          Map<int, FlowForcedOutcome>.unmodifiable(<int, FlowForcedOutcome>{
        ...forcedByStepIndex,
      }),
    );
  }

  /// Branch to use when a step is not present in [forcedByStepIndex].
  final FlowBranch defaultBranch;

  /// Forced outcomes by step index.
  final Map<int, FlowForcedOutcome> forcedByStepIndex;

  /// Returns the forced outcome for [stepIndex], if any.
  FlowForcedOutcome? forcedFor(int stepIndex) => forcedByStepIndex[stepIndex];
}
