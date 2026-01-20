import 'package:jocaagura_domain/jocaagura_domain.dart';

import 'flow_audit_snapshot.dart';
import 'flow_simulation_plan.dart';
import 'flow_step_decision.dart';
import 'flow_step_simulation_session.dart';
import 'flow_step_tick.dart';
import 'flow_trace_entry.dart';

/// Deterministic step-by-step simulator for [ModelCompleteFlow].
///
/// This simulator is intended to power UIs that behave like a debugger:
/// - start a session at [ModelCompleteFlow.entryIndex]
/// - advance one step at a time with explicit decisions
/// - optionally use a [FlowSimulationPlan] for forced outcomes
/// - export an audit snapshot at any time
///
/// Safety:
/// - Never throws.
/// - Uses a loop guard via [maxSteps].
/// - Produces stable output (no timestamps).
///
/// Example:
/// ```dart
/// final FlowStepSimulator sim = FlowStepSimulator();
/// FlowSimulationSession s = sim.start(flow);
///
/// while (!s.isTerminal) {
///   final FlowStepTick tick = sim.next(
///     s,
///     decision: const FlowStepDecision.success(),
///   );
///   s = tick.session;
/// }
///
/// final FlowAuditSnapshot snap = sim.snapshot(s);
/// print(snap.status);
/// ```
class FlowStepSimulator {
  /// Starts a new deterministic simulation session.
  FlowSimulationSession start(
    ModelCompleteFlow flow, {
    FlowSimulationPlan plan = const FlowSimulationPlan(),
    int maxSteps = 10000,
    bool allowManualOverride = false,
  }) {
    final int entryIndex = flow.entryIndex;

    if (entryIndex < 0) {
      return FlowSimulationSession(
        flow: flow,
        plan: plan,
        maxSteps: maxSteps,
        allowManualOverride: allowManualOverride,
        entryIndex: entryIndex,
        status: FlowSimulationStatus.abortedMissingStep,
        currentIndex: entryIndex,
        visitedCount: 0,
        trace: const <FlowTraceEntry>[],
        totalCostByMetric: const <String, double>{},
        lastFailureCode: null,
      );
    }

    return FlowSimulationSession(
      flow: flow,
      plan: plan,
      maxSteps: maxSteps,
      allowManualOverride: allowManualOverride,
      entryIndex: entryIndex,
      status: FlowSimulationStatus.running,
      currentIndex: entryIndex,
      visitedCount: 0,
      trace: const <FlowTraceEntry>[],
      totalCostByMetric: const <String, double>{},
      lastFailureCode: null,
    );
  }

  /// Advances the session by a single step.
  ///
  /// Decision selection:
  /// - If the plan contains a forced outcome for the current step, it is used
  ///   (unless [FlowSimulationSession.allowManualOverride] is true and a manual
  ///   [decision] is provided).
  /// - Otherwise, [decision] is required.
  ///
  /// This method never throws.
  FlowStepTick next(
    FlowSimulationSession session, {
    FlowStepDecision? decision,
  }) {
    if (session.isTerminal) {
      return FlowStepTick(
        session: session,
        event: const FlowStepEvent(
          type: FlowStepEventType.alreadyTerminal,
          message: 'Session is terminal and cannot advance.',
        ),
      );
    }

    final int? currentIndex = session.currentIndex;
    if (currentIndex == null) {
      final FlowSimulationSession terminal = FlowSimulationSession(
        flow: session.flow,
        plan: session.plan,
        maxSteps: session.maxSteps,
        allowManualOverride: session.allowManualOverride,
        entryIndex: session.entryIndex,
        status: FlowSimulationStatus.endReached,
        currentIndex: null,
        visitedCount: session.visitedCount,
        trace: session.trace,
        totalCostByMetric: session.totalCostByMetric,
        lastFailureCode: session.lastFailureCode,
      );

      return FlowStepTick(
        session: terminal,
        event: const FlowStepEvent(
          type: FlowStepEventType.endReached,
          message: 'END already reached.',
        ),
      );
    }

    if (session.visitedCount >= session.maxSteps) {
      final FlowSimulationSession aborted = FlowSimulationSession(
        flow: session.flow,
        plan: session.plan,
        maxSteps: session.maxSteps,
        allowManualOverride: session.allowManualOverride,
        entryIndex: session.entryIndex,
        status: FlowSimulationStatus.abortedLoopGuard,
        currentIndex: currentIndex,
        visitedCount: session.visitedCount,
        trace: session.trace,
        totalCostByMetric: session.totalCostByMetric,
        lastFailureCode: session.lastFailureCode,
      );

      return FlowStepTick(
        session: aborted,
        event: FlowStepEvent(
          type: FlowStepEventType.loopGuardAborted,
          stepIndex: currentIndex,
          message: 'Loop guard exceeded (maxSteps=${session.maxSteps}).',
        ),
      );
    }

    final ModelFlowStep? step = session.flow.stepAt(currentIndex);
    if (step == null) {
      final FlowSimulationSession aborted = FlowSimulationSession(
        flow: session.flow,
        plan: session.plan,
        maxSteps: session.maxSteps,
        allowManualOverride: session.allowManualOverride,
        entryIndex: session.entryIndex,
        status: FlowSimulationStatus.abortedMissingStep,
        currentIndex: currentIndex,
        visitedCount: session.visitedCount,
        trace: session.trace,
        totalCostByMetric: session.totalCostByMetric,
        lastFailureCode: session.lastFailureCode,
      );

      return FlowStepTick(
        session: aborted,
        event: FlowStepEvent(
          type: FlowStepEventType.missingStepReference,
          stepIndex: currentIndex,
          message: 'Missing step for index $currentIndex.',
        ),
      );
    }

    final FlowForcedOutcome? forced = session.plan.forcedFor(step.index);

    final bool useManual = session.allowManualOverride && decision != null;
    final FlowDecisionSource? source = useManual
        ? FlowDecisionSource.manual
        : forced != null
            ? FlowDecisionSource.forced
            : decision != null
                ? FlowDecisionSource.manual
                : null;

    final FlowBranch? branch =
        useManual ? decision.branch : forced?.branch ?? decision?.branch;

    final String? override = useManual
        ? decision.failureCodeOverride
        : forced?.failureCodeOverride ?? decision?.failureCodeOverride;

    if (branch == null) {
      final FlowSimulationSession waiting = FlowSimulationSession(
        flow: session.flow,
        plan: session.plan,
        maxSteps: session.maxSteps,
        allowManualOverride: session.allowManualOverride,
        entryIndex: session.entryIndex,
        status: FlowSimulationStatus.waitingDecision,
        currentIndex: currentIndex,
        visitedCount: session.visitedCount,
        trace: session.trace,
        totalCostByMetric: session.totalCostByMetric,
        lastFailureCode: session.lastFailureCode,
      );

      return FlowStepTick(
        session: waiting,
        event: FlowStepEvent(
          type: FlowStepEventType.missingDecision,
          stepIndex: currentIndex,
          message: 'A decision is required for step $currentIndex.',
        ),
      );
    }

    final int nextIndex = branch == FlowBranch.success
        ? step.nextOnSuccessIndex
        : step.nextOnFailureIndex;

    final String? effectiveFailureCode = branch == FlowBranch.failure
        ? (override?.trim().isNotEmpty ?? false)
            ? override!.trim()
            : step.failureCode
        : null;

    final String? lastFailureCode =
        effectiveFailureCode ?? session.lastFailureCode;

    final Map<String, double> addedCost = _normalizeCost(step.cost);
    final Map<String, double> totals = <String, double>{
      ...session.totalCostByMetric,
    };
    _accumulateCost(totals, addedCost);

    final List<FlowTraceEntry> trace = <FlowTraceEntry>[
      ...session.trace,
      FlowTraceEntry(
        stepIndex: step.index,
        branch: branch,
        nextIndex: nextIndex,
        wasForced: source == FlowDecisionSource.forced,
        effectiveFailureCode: effectiveFailureCode,
        costAddedByMetric: addedCost,
      ),
    ];

    if (nextIndex == -1) {
      final FlowSimulationSession ended = FlowSimulationSession(
        flow: session.flow,
        plan: session.plan,
        maxSteps: session.maxSteps,
        allowManualOverride: session.allowManualOverride,
        entryIndex: session.entryIndex,
        status: FlowSimulationStatus.endReached,
        currentIndex: null,
        visitedCount: session.visitedCount + 1,
        trace: trace,
        totalCostByMetric: totals,
        lastFailureCode: lastFailureCode,
      );

      return FlowStepTick(
        session: ended,
        event: FlowStepEvent(
          type: FlowStepEventType.endReached,
          stepIndex: step.index,
          nextIndex: -1,
          decisionSource: source,
          failureCodeEffective: effectiveFailureCode,
        ),
      );
    }

    final FlowSimulationSession progressed = FlowSimulationSession(
      flow: session.flow,
      plan: session.plan,
      maxSteps: session.maxSteps,
      allowManualOverride: session.allowManualOverride,
      entryIndex: session.entryIndex,
      status: FlowSimulationStatus.running,
      currentIndex: nextIndex,
      visitedCount: session.visitedCount + 1,
      trace: trace,
      totalCostByMetric: totals,
      lastFailureCode: lastFailureCode,
    );

    return FlowStepTick(
      session: progressed,
      event: FlowStepEvent(
        type: FlowStepEventType.stepVisited,
        stepIndex: step.index,
        nextIndex: nextIndex,
        decisionSource: source,
        failureCodeEffective: effectiveFailureCode,
      ),
    );
  }

  /// Creates a deterministic snapshot from the current session.
  FlowAuditSnapshot snapshot(FlowSimulationSession session) =>
      session.toSnapshot();

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
