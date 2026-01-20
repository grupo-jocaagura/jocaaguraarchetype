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
  /// Hydrates a [FlowForcedOutcome] from JSON.
  ///
  /// Unknown branches default to [FlowBranch.success].
  factory FlowForcedOutcome.fromJson(Map<String, dynamic> json) {
    final String branchRaw = (json['branch'] ?? '').toString();
    final FlowBranch branch = FlowBranch.values
            .where((FlowBranch e) => e.name == branchRaw)
            .cast<FlowBranch?>()
            .firstWhere((FlowBranch? _) => true, orElse: () => null) ??
        FlowBranch.success;

    final String fc = (json['failureCodeOverride'] ?? '').toString().trim();
    final String? failureCodeOverride = fc.isEmpty ? null : fc;

    return branch == FlowBranch.failure
        ? FlowForcedOutcome.failure(failureCodeOverride: failureCodeOverride)
        : const FlowForcedOutcome.success();
  }

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

  /// Converts this forced outcome to JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'branch': branch.name,
      if (failureCodeOverride != null)
        'failureCodeOverride': failureCodeOverride,
    };
  }
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

  /// Hydrates a [FlowSimulationPlan] from JSON.
  ///
  /// This method is lenient and uses safe fallbacks.
  factory FlowSimulationPlan.fromJson(Map<String, dynamic> json) {
    final String defaultRaw = (json['defaultBranch'] ?? '').toString();
    final FlowBranch defaultBranch = FlowBranch.values
            .where((FlowBranch e) => e.name == defaultRaw)
            .cast<FlowBranch?>()
            .firstWhere((FlowBranch? _) => true, orElse: () => null) ??
        FlowBranch.success;

    final Map<int, FlowForcedOutcome> forced = <int, FlowForcedOutcome>{};
    final Object? rawForced = json['forcedByStepIndex'];
    if (rawForced is Map) {
      rawForced.forEach((Object? k, Object? v) {
        final int? idx = int.tryParse((k ?? '').toString());
        if (idx == null) {
          return;
        }
        if (v is Map<String, dynamic>) {
          forced[idx] = FlowForcedOutcome.fromJson(v);
        } else if (v is Map) {
          forced[idx] =
              FlowForcedOutcome.fromJson(Map<String, dynamic>.from(v));
        }
      });
    }

    return FlowSimulationPlan.immutable(
      defaultBranch: defaultBranch,
      forcedByStepIndex: forced,
    );
  }

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

  /// Converts this plan to JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> forced = <String, dynamic>{};
    forcedByStepIndex.forEach((int k, FlowForcedOutcome v) {
      forced[k.toString()] = v.toJson();
    });
    return <String, dynamic>{
      'defaultBranch': defaultBranch.name,
      if (forced.isNotEmpty) 'forcedByStepIndex': forced,
    };
  }
}
