import 'flow_step_simulation_session.dart';

/// Event types emitted by [FlowStepSimulator.next].
enum FlowStepEventType {
  /// A step was visited and appended to the trace.
  stepVisited,

  /// END was reached (`next == -1`).
  endReached,

  /// The simulation was aborted because the referenced step is missing.
  missingStepReference,

  /// The simulator needs a manual decision for the current step.
  missingDecision,

  /// The simulation was aborted because [FlowSimulationSession.maxSteps] was
  /// exceeded.
  loopGuardAborted,

  /// [FlowSimulationSession] was already terminal and cannot advance.
  alreadyTerminal,
}

/// Source of the decision used for a step.
enum FlowDecisionSource {
  /// The branch was provided by [FlowSimulationSession.plan].
  forced,

  /// The branch was provided by the caller via [FlowStepDecision].
  manual,
}

/// Single tick event emitted by [FlowStepSimulator.next].
class FlowStepEvent {
  /// Creates a [FlowStepEvent].
  const FlowStepEvent({
    required this.type,
    this.stepIndex,
    this.nextIndex,
    this.decisionSource,
    this.failureCodeEffective,
    this.message,
  });

  /// Event type.
  final FlowStepEventType type;

  /// Current step index related to the event, if any.
  final int? stepIndex;

  /// Next step index computed for this tick, if any.
  final int? nextIndex;

  /// Where the decision came from.
  final FlowDecisionSource? decisionSource;

  /// Effective failure code recorded for the tick, if any.
  final String? failureCodeEffective;

  /// Optional human-friendly message for logs/UX.
  final String? message;
}

/// Result of a single step-by-step advancement.
class FlowStepTick {
  /// Creates a [FlowStepTick].
  const FlowStepTick({
    required this.session,
    required this.event,
  });

  /// Updated session.
  final FlowSimulationSession session;

  /// Tick event.
  final FlowStepEvent event;

  /// Convenience helper.
  bool get isTerminal => session.isTerminal;
}
