import 'flow_simulation_plan.dart';

/// Single step execution record produced by [FlowSimulator].
///
/// This record is deterministic and safe to store/serialize.
/// It does not include timestamps to keep simulations reproducible.
///
/// Example:
/// ```dart
/// final FlowAuditSnapshot snap = FlowSimulator().simulate(flow);
/// for (final FlowTraceEntry e in snap.trace) {
///   print('${e.stepIndex} -> ${e.nextIndex} (${e.branch})');
/// }
/// ```
class FlowTraceEntry {
  /// Creates a [FlowTraceEntry].
  ///
  /// All collections are defensively wrapped as unmodifiable.
  FlowTraceEntry({
    required this.stepIndex,
    required this.branch,
    required this.nextIndex,
    required this.wasForced,
    required this.effectiveFailureCode,
    required Map<String, double> costAddedByMetric,
  }) : costAddedByMetric = Map<String, double>.unmodifiable(
            <String, double>{...costAddedByMetric});

  /// Index of the executed step.
  final int stepIndex;

  /// Selected branch.
  final FlowBranch branch;

  /// Next step index (`-1` means END).
  final int nextIndex;

  /// Whether the branch decision came from a [FlowSimulationPlan].
  final bool wasForced;

  /// Effective failure code for this step.
  ///
  /// - When [branch] is [FlowBranch.failure], this is the failure code stored
  ///   in the trace entry.
  /// - When [branch] is [FlowBranch.success], this is `null`.
  final String? effectiveFailureCode;

  /// Cost contributed by this step (normalized, per metric).
  final Map<String, double> costAddedByMetric;

  /// Converts this entry into a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stepIndex': stepIndex,
      'branch': branch.name,
      'nextIndex': nextIndex,
      'wasForced': wasForced,
      'effectiveFailureCode': effectiveFailureCode,
      'costAddedByMetric': costAddedByMetric,
    };
  }

  @override
  String toString() => '${toJson()}';
}
