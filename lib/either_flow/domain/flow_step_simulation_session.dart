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
