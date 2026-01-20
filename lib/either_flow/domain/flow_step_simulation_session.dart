import 'package:jocaagura_domain/jocaagura_domain.dart';

import 'flow_audit_snapshot.dart';
import 'flow_simulation_plan.dart';
import 'flow_trace_entry.dart';

/// Immutable session state for step-by-step flow simulation.
///
/// A session represents a deterministic execution that can be advanced with
/// [FlowStepSimulator.next].
///
/// Notes:
/// - This state is *domain-only* and does not depend on Flutter.
/// - It never includes timestamps to keep it reproducible.
///
/// Example:
/// ```dart
/// final FlowSimulationSession s0 = FlowStepSimulator().start(flow);
/// final FlowStepTick t1 = FlowStepSimulator().next(s0,
///   decision: const FlowStepDecision.success(),
/// );
/// print(t1.session.currentIndex);
/// ```
class FlowSimulationSession {
  /// Creates a [FlowSimulationSession].
  ///
  /// All collections are defensively wrapped as unmodifiable.
  FlowSimulationSession({
    required this.flow,
    required this.plan,
    required this.maxSteps,
    required this.allowManualOverride,
    required this.entryIndex,
    required this.status,
    required this.currentIndex,
    required this.visitedCount,
    required List<FlowTraceEntry> trace,
    required Map<String, double> totalCostByMetric,
    required this.lastFailureCode,
  })  : trace = List<FlowTraceEntry>.unmodifiable(trace),
        totalCostByMetric = Map<String, double>.unmodifiable(
          <String, double>{...totalCostByMetric},
        );

  /// Hydrates a [FlowSimulationSession] from JSON.
  ///
  /// This method is lenient and uses safe fallbacks.
  factory FlowSimulationSession.fromJson(Map<String, dynamic> json) {
    int value(Object? v, {int fallback = -1}) {
      if (v is int) {
        return v;
      }
      return int.tryParse((v ?? '').toString()) ?? fallback;
    }

    int? intOrNull(Object? v) {
      if (v == null) {
        return null;
      }
      if (v is int) {
        return v;
      }
      return int.tryParse((v).toString());
    }

    bool boolValue(Object? v) {
      if (v is bool) {
        return v;
      }
      final String s = (v ?? '').toString().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }

    FlowSimulationStatus status(Object? v) {
      final String s = (v ?? '').toString();
      return FlowSimulationStatus.values
              .where((FlowSimulationStatus e) => e.name == s)
              .cast<FlowSimulationStatus?>()
              .firstWhere(
                (FlowSimulationStatus? _) => true,
                orElse: () => null,
              ) ??
          FlowSimulationStatus.running;
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

    final Object? flowRaw = json['flow'];
    final Object? planRaw = json['plan'];
    final ModelCompleteFlow flow = flowRaw is Map<String, dynamic>
        ? ModelCompleteFlow.fromJson(flowRaw)
        : ModelCompleteFlow.fromJson(const <String, dynamic>{});
    final FlowSimulationPlan plan = planRaw is Map<String, dynamic>
        ? FlowSimulationPlan.fromJson(planRaw)
        : const FlowSimulationPlan();

    final String lastFailure =
        (json['lastFailureCode'] ?? '').toString().trim();

    return FlowSimulationSession(
      flow: flow,
      plan: plan,
      maxSteps: value(json['maxSteps'], fallback: 10000),
      allowManualOverride: boolValue(json['allowManualOverride']),
      entryIndex: value(json['entryIndex']),
      status: status(json['status']),
      currentIndex: intOrNull(json['currentIndex']),
      visitedCount: value(json['visitedCount'], fallback: 0),
      trace: trace(json['trace']),
      totalCostByMetric: cost(json['totalCostByMetric']),
      lastFailureCode: lastFailure.isEmpty ? null : lastFailure,
    );
  }

  /// Flow being simulated.
  final ModelCompleteFlow flow;

  /// Simulation plan (forced outcomes + default branch).
  final FlowSimulationPlan plan;

  /// Loop guard limit.
  final int maxSteps;

  /// When true, a manual [FlowStepDecision] can override forced outcomes.
  final bool allowManualOverride;

  /// Entry index used for this session.
  final int entryIndex;

  /// Current status.
  final FlowSimulationStatus status;

  /// Current step index to be executed.
  ///
  /// Null when the session is terminal (e.g. END reached).
  final int? currentIndex;

  /// Number of visited steps appended to [trace].
  final int visitedCount;

  /// Trace entries in execution order.
  final List<FlowTraceEntry> trace;

  /// Total cost accumulated across visited steps.
  final Map<String, double> totalCostByMetric;

  /// Converts this session into JSON.
  ///
  /// Note: This is designed for draft persistence and debug exports.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'flow': flow.toJson(),
      'plan': plan.toJson(),
      'maxSteps': maxSteps,
      'allowManualOverride': allowManualOverride,
      'entryIndex': entryIndex,
      'status': status.name,
      'currentIndex': currentIndex,
      'visitedCount': visitedCount,
      if (lastFailureCode != null) 'lastFailureCode': lastFailureCode,
      'totalCostByMetric': totalCostByMetric,
      'trace':
          trace.map((FlowTraceEntry e) => e.toJson()).toList(growable: false),
    };
  }

  /// The last effective failure code produced by the trace.
  final String? lastFailureCode;

  /// Whether the session cannot advance further.
  bool get isTerminal {
    return status == FlowSimulationStatus.endReached ||
        status == FlowSimulationStatus.abortedLoopGuard ||
        status == FlowSimulationStatus.abortedMissingStep;
  }

  /// Creates a deterministic audit snapshot of the current session.
  ///
  /// This is convenient for UIs that want to display partial progress.
  FlowAuditSnapshot toSnapshot() {
    final int endIndex = currentIndex ?? (isTerminal ? -1 : entryIndex);

    return FlowAuditSnapshot(
      flowName: flow.name,
      flowDescription: flow.description,
      entryIndex: entryIndex,
      status: status,
      endIndex: status == FlowSimulationStatus.endReached ? -1 : endIndex,
      lastFailureCode: lastFailureCode,
      trace: trace,
      totalCostByMetric: totalCostByMetric,
      maxSteps: maxSteps,
    );
  }
}
