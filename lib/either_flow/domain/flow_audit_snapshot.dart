// ignore: unused_import
import 'package:jocaagura_domain/jocaagura_domain.dart';

import 'flow_simulation_plan.dart';
import 'flow_trace_entry.dart';

/// Final status of a [FlowSimulator] run.
enum FlowSimulationStatus {
  /// END was reached (`next == -1`).
  endReached,

  /// Execution was aborted because [FlowSimulator.maxSteps] was exceeded.
  abortedLoopGuard,

  /// Execution was aborted because a referenced step index was missing.
  abortedMissingStep,
}

/// Deterministic audit snapshot produced by [FlowSimulator].
///
/// This snapshot is designed for:
/// - QA reproducibility
/// - debugging / support
/// - exporting a simulation result for review
///
/// It intentionally avoids timestamps to keep the output stable.
///
/// Example:
/// ```dart
/// final FlowAuditSnapshot snap = FlowSimulator().simulate(flow);
/// if (snap.status == FlowSimulationStatus.endReached) {
///   print('END in ${snap.trace.length} steps');
/// }
/// ```
class FlowAuditSnapshot {
  /// Creates a [FlowAuditSnapshot].
  ///
  /// All collections are defensively wrapped as unmodifiable.
  FlowAuditSnapshot({
    required this.flowName,
    required this.flowDescription,
    required this.entryIndex,
    required this.status,
    required this.endIndex,
    required this.lastFailureCode,
    required List<FlowTraceEntry> trace,
    required Map<String, double> totalCostByMetric,
    required this.maxSteps,
  })  : trace = List<FlowTraceEntry>.unmodifiable(trace),
        totalCostByMetric = Map<String, double>.unmodifiable(
          <String, double>{...totalCostByMetric},
        );

  /// Flow name.
  final String flowName;

  /// Flow description.
  final String flowDescription;

  /// Entry index used for simulation.
  final int entryIndex;

  /// Final simulation status.
  final FlowSimulationStatus status;

  /// End index for this run.
  ///
  /// - `-1` when END was reached
  /// - otherwise, the last attempted index when aborted
  final int endIndex;

  /// The last effective failure code produced by the trace.
  ///
  /// This is set when the last executed branch was [FlowBranch.failure].
  final String? lastFailureCode;

  /// Trace entries in execution order.
  final List<FlowTraceEntry> trace;

  /// Total cost accumulated across visited steps.
  final Map<String, double> totalCostByMetric;

  /// Loop guard used in this simulation.
  final int maxSteps;

  /// Converts the snapshot into a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'flowName': flowName,
      'flowDescription': flowDescription,
      'entryIndex': entryIndex,
      'status': status.name,
      'endIndex': endIndex,
      'lastFailureCode': lastFailureCode,
      'maxSteps': maxSteps,
      'totalCostByMetric': totalCostByMetric,
      'trace':
          trace.map((FlowTraceEntry e) => e.toJson()).toList(growable: false),
    };
  }

  @override
  String toString() => '${toJson()}';
}
