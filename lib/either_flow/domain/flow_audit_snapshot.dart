import 'flow_simulation_plan.dart';
import 'flow_trace_entry.dart';

/// Final status of a [FlowSimulator] run.
enum FlowSimulationStatus {
  /// The simulation is in progress.
  ///
  /// This status is mainly used by step-by-step simulation sessions.
  running,

  /// The simulator is waiting for a manual decision.
  ///
  /// This status is mainly used by step-by-step simulation sessions when the
  /// current step has no forced outcome in the plan.
  waitingDecision,

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

  /// Hydrates a [FlowAuditSnapshot] from JSON.
  ///
  /// This method is lenient and uses safe fallbacks for unknown enum names.
  factory FlowAuditSnapshot.fromJson(Map<String, dynamic> json) {
    FlowSimulationStatus status(Object? v) {
      final String s = (v ?? '').toString();
      return FlowSimulationStatus.values
              .where((FlowSimulationStatus e) => e.name == s)
              .cast<FlowSimulationStatus?>()
              .firstWhere(
                (FlowSimulationStatus? _) => true,
                orElse: () => null,
              ) ??
          FlowSimulationStatus.abortedMissingStep;
    }

    int value(Object? v, {int fallback = -1}) {
      if (v is int) {
        return v;
      }
      return int.tryParse((v ?? '').toString()) ?? fallback;
    }

    Map<String, double> cost(Object? v) {
      if (v is! Map) {
        return <String, double>{};
      }
      final Map<String, double> out = <String, double>{};
      v.forEach((Object? k, Object? val) {
        final String key = (k ?? '').toString();
        if (key.isEmpty) {
          return;
        }
        if (val is num) {
          out[key] = val.toDouble();
          return;
        }
        final double? parsed = double.tryParse((val ?? '').toString());
        if (parsed != null) {
          out[key] = parsed;
        }
      });
      return out;
    }

    List<FlowTraceEntry> trace(Object? v) {
      if (v is! List) {
        return <FlowTraceEntry>[];
      }
      final List<FlowTraceEntry> out = <FlowTraceEntry>[];
      for (final Object? item in v) {
        if (item is Map<String, dynamic>) {
          out.add(FlowTraceEntry.fromJson(item));
        } else if (item is Map) {
          out.add(FlowTraceEntry.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return out;
    }

    final String lastFailure =
        (json['lastFailureCode'] ?? '').toString().trim();

    return FlowAuditSnapshot(
      flowName: (json['flowName'] ?? '').toString(),
      flowDescription: (json['flowDescription'] ?? '').toString(),
      entryIndex: value(json['entryIndex']),
      status: status(json['status']),
      endIndex: value(json['endIndex']),
      lastFailureCode: lastFailure.isEmpty ? null : lastFailure,
      trace: trace(json['trace']),
      totalCostByMetric: cost(json['totalCostByMetric']),
      maxSteps: value(json['maxSteps'], fallback: 10000),
    );
  }

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
