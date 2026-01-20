import 'package:jocaagura_domain/jocaagura_domain.dart';

import 'flow_audit_snapshot.dart';
import 'flow_simulation_plan.dart';
import 'flow_trace_entry.dart';

/// Deterministic simulator for [ModelCompleteFlow].
///
/// This simulator does **not** execute business logic. Instead, it traverses
/// the flow graph using the routing declared in each [ModelFlowStep]:
/// - [ModelFlowStep.nextOnSuccessIndex] (Right)
/// - [ModelFlowStep.nextOnFailureIndex] (Left)
///
/// The traversal decisions are driven by a [FlowSimulationPlan] to enable
/// deterministic "what-if" execution.
///
/// Safety:
/// - The simulator never throws.
/// - It stops when END is reached (`-1`), when a missing step is referenced,
///   or when the loop guard [maxSteps] is exceeded.
///
/// Example:
/// ```dart
/// final ModelCompleteFlow flow = ...;
/// final FlowSimulationPlan plan = FlowSimulationPlan.immutable(
///   forcedByStepIndex: <int, FlowForcedOutcome>{
///     10: const FlowForcedOutcome.success(),
///     11: const FlowForcedOutcome.failure(failureCodeOverride: 'SESSION_EXPIRED'),
///   },
/// );
///
/// final FlowAuditSnapshot snap = FlowSimulator().simulate(
///   flow,
///   plan: plan,
///   maxSteps: 200,
/// );
///
/// print(snap.status);
/// print(snap.totalCostByMetric);
/// ```
class FlowSimulator {
  /// Runs a deterministic simulation over [flow] using [plan].
  ///
  /// If [maxSteps] is exceeded, the simulation is aborted with
  /// [FlowSimulationStatus.abortedLoopGuard].
  FlowAuditSnapshot simulate(
    ModelCompleteFlow flow, {
    FlowSimulationPlan plan = const FlowSimulationPlan(),
    int maxSteps = 10000,
  }) {
    final List<FlowTraceEntry> trace = <FlowTraceEntry>[];
    final Map<String, double> totals = <String, double>{};

    final int entryIndex = flow.entryIndex;
    if (entryIndex < 0) {
      return FlowAuditSnapshot(
        flowName: flow.name,
        flowDescription: flow.description,
        entryIndex: entryIndex,
        status: FlowSimulationStatus.abortedMissingStep,
        endIndex: entryIndex,
        lastFailureCode: null,
        trace: trace,
        totalCostByMetric: totals,
        maxSteps: maxSteps,
      );
    }

    int currentIndex = entryIndex;
    String? lastFailureCode;

    for (int stepCount = 0; stepCount < maxSteps; stepCount++) {
      final ModelFlowStep? step = flow.stepAt(currentIndex);
      if (step == null) {
        return FlowAuditSnapshot(
          flowName: flow.name,
          flowDescription: flow.description,
          entryIndex: entryIndex,
          status: FlowSimulationStatus.abortedMissingStep,
          endIndex: currentIndex,
          lastFailureCode: lastFailureCode,
          trace: trace,
          totalCostByMetric: totals,
          maxSteps: maxSteps,
        );
      }

      final FlowForcedOutcome? forced = plan.forcedFor(step.index);
      final FlowBranch branch = forced?.branch ?? plan.defaultBranch;
      final bool wasForced = forced != null;

      final int nextIndex = branch == FlowBranch.success
          ? step.nextOnSuccessIndex
          : step.nextOnFailureIndex;

      final String? effectiveFailureCode = branch == FlowBranch.failure
          ? (forced?.failureCodeOverride?.trim().isNotEmpty ?? false)
              ? forced!.failureCodeOverride!.trim()
              : step.failureCode
          : null;

      if (effectiveFailureCode != null) {
        lastFailureCode = effectiveFailureCode;
      }

      final Map<String, double> stepCost = _normalizeCost(step.cost);
      _accumulateCost(totals, stepCost);

      trace.add(
        FlowTraceEntry(
          stepIndex: step.index,
          branch: branch,
          nextIndex: nextIndex,
          wasForced: wasForced,
          effectiveFailureCode: effectiveFailureCode,
          costAddedByMetric: stepCost,
        ),
      );

      if (nextIndex == -1) {
        return FlowAuditSnapshot(
          flowName: flow.name,
          flowDescription: flow.description,
          entryIndex: entryIndex,
          status: FlowSimulationStatus.endReached,
          endIndex: -1,
          lastFailureCode: lastFailureCode,
          trace: trace,
          totalCostByMetric: totals,
          maxSteps: maxSteps,
        );
      }

      currentIndex = nextIndex;
    }

    return FlowAuditSnapshot(
      flowName: flow.name,
      flowDescription: flow.description,
      entryIndex: entryIndex,
      status: FlowSimulationStatus.abortedLoopGuard,
      endIndex: currentIndex,
      lastFailureCode: lastFailureCode,
      trace: trace,
      totalCostByMetric: totals,
      maxSteps: maxSteps,
    );
  }

  Map<String, double> _normalizeCost(Map<String, dynamic> raw) {
    final Map<String, double> out = <String, double>{};

    for (final MapEntry<String, dynamic> entry in raw.entries) {
      final String key = entry.key;
      final double parsed = Utils.getDouble(entry.value, 0.0);
      final double normalized = parsed.isFinite && parsed >= 0.0 ? parsed : 0.0;
      out[key] = normalized;
    }

    return out;
  }

  void _accumulateCost(Map<String, double> totals, Map<String, double> add) {
    for (final MapEntry<String, double> e in add.entries) {
      totals[e.key] = (totals[e.key] ?? 0.0) + e.value;
    }
  }
}
