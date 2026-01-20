import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('FlowStepSimulator', () {
    ModelFlowStep step({
      required int index,
      required int ok,
      required int fail,
      String title = '',
      String description = '',
      String failureCode = 'UNKNOWN',
      Map<String, double> cost = const <String, double>{},
    }) {
      return ModelFlowStep.immutable(
        index: index,
        title: title,
        description: description,
        failureCode: failureCode,
        nextOnSuccessIndex: ok,
        nextOnFailureIndex: fail,
        cost: cost,
      );
    }

    test('start() creates a running session at entryIndex', () {
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Demo',
        description: 'Demo flow',
        steps: <ModelFlowStep>[
          step(index: 0, ok: -1, fail: -1),
        ],
      );

      final FlowSimulationSession s0 = FlowStepSimulator().start(flow);

      expect(s0.status, FlowSimulationStatus.running);
      expect(s0.entryIndex, 0);
      expect(s0.currentIndex, 0);
      expect(s0.trace, isEmpty);
      expect(s0.visitedCount, 0);
    });

    test('manual decisions advance one step at a time and reach END', () {
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Demo',
        description: 'Demo flow',
        steps: <ModelFlowStep>[
          step(
            index: 0,
            ok: 1,
            fail: -1,
            cost: <String, double>{'latencyMs': 10},
          ),
          step(
            index: 1,
            ok: -1,
            fail: -1,
            cost: <String, double>{'latencyMs': 20},
          ),
        ],
      );

      final FlowStepSimulator sim = FlowStepSimulator();
      final FlowSimulationSession s0 = sim.start(flow);

      final FlowStepTick t1 = sim.next(
        s0,
        decision: const FlowStepDecision.success(),
      );

      expect(t1.event.type, FlowStepEventType.stepVisited);
      expect(t1.session.status, FlowSimulationStatus.running);
      expect(t1.session.currentIndex, 1);
      expect(t1.session.trace.length, 1);
      expect(t1.session.totalCostByMetric['latencyMs'], 10);

      final FlowStepTick t2 = sim.next(
        t1.session,
        decision: const FlowStepDecision.success(),
      );

      expect(t2.event.type, FlowStepEventType.endReached);
      expect(t2.session.status, FlowSimulationStatus.endReached);
      expect(t2.session.currentIndex, isNull);
      expect(t2.session.trace.length, 2);
      expect(t2.session.totalCostByMetric['latencyMs'], 30);
    });

    test('missingDecision returns waitingDecision without mutating trace', () {
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Demo',
        description: 'Demo flow',
        steps: <ModelFlowStep>[
          step(index: 0, ok: -1, fail: -1),
        ],
      );

      final FlowStepSimulator sim = FlowStepSimulator();
      final FlowSimulationSession s0 = sim.start(flow);

      final FlowStepTick tick = sim.next(s0);

      expect(tick.event.type, FlowStepEventType.missingDecision);
      expect(tick.session.status, FlowSimulationStatus.waitingDecision);
      expect(tick.session.currentIndex, 0);
      expect(tick.session.trace, isEmpty);
      expect(tick.session.visitedCount, 0);
    });

    test('forced outcomes work without manual decision', () {
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Demo',
        description: 'Demo flow',
        steps: <ModelFlowStep>[
          step(index: 0, ok: 1, fail: -1),
          step(index: 1, ok: -1, fail: 2, failureCode: 'STEP_1_FAILED'),
          step(index: 2, ok: -1, fail: -1),
        ],
      );

      final FlowSimulationPlan plan = FlowSimulationPlan.immutable(
        forcedByStepIndex: <int, FlowForcedOutcome>{
          1: const FlowForcedOutcome.failure(
            failureCodeOverride: 'SESSION_EXPIRED',
          ),
        },
      );

      final FlowStepSimulator sim = FlowStepSimulator();
      final FlowSimulationSession s0 = sim.start(flow, plan: plan);

      final FlowStepTick t1 = sim.next(
        s0,
        decision: const FlowStepDecision.success(),
      );
      expect(t1.session.currentIndex, 1);

      final FlowStepTick t2 = sim.next(t1.session);
      expect(t2.event.type, FlowStepEventType.stepVisited);
      expect(t2.event.decisionSource, FlowDecisionSource.forced);
      expect(t2.event.failureCodeEffective, 'SESSION_EXPIRED');
      expect(t2.session.lastFailureCode, 'SESSION_EXPIRED');
      expect(t2.session.currentIndex, 2);
    });

    test('missing referenced step aborts with abortedMissingStep', () {
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Demo',
        description: 'Demo flow',
        steps: <ModelFlowStep>[
          step(index: 0, ok: 99, fail: -1),
        ],
      );

      final FlowStepSimulator sim = FlowStepSimulator();
      final FlowSimulationSession s0 = sim.start(flow);

      final FlowStepTick t1 = sim.next(
        s0,
        decision: const FlowStepDecision.success(),
      );
      expect(t1.session.currentIndex, 99);
      expect(t1.session.trace.length, 1);

      final FlowStepTick t2 =
          sim.next(t1.session, decision: const FlowStepDecision.success());
      expect(t2.event.type, FlowStepEventType.missingStepReference);
      expect(t2.session.status, FlowSimulationStatus.abortedMissingStep);
      expect(t2.session.currentIndex, 99);
      expect(t2.session.trace.length, 1);
    });

    test('loop guard aborts on the tick after reaching maxSteps', () {
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Loop',
        description: 'Self loop',
        steps: <ModelFlowStep>[
          step(index: 0, ok: 0, fail: -1),
        ],
      );

      final FlowStepSimulator sim = FlowStepSimulator();
      FlowSimulationSession s = sim.start(flow, maxSteps: 3);

      for (int i = 0; i < 3; i++) {
        final FlowStepTick tick = sim.next(
          s,
          decision: const FlowStepDecision.success(),
        );
        s = tick.session;
      }

      expect(s.status, FlowSimulationStatus.running);
      expect(s.trace.length, 3);
      expect(s.visitedCount, 3);

      final FlowStepTick aborted = sim.next(
        s,
        decision: const FlowStepDecision.success(),
      );

      expect(aborted.event.type, FlowStepEventType.loopGuardAborted);
      expect(aborted.session.status, FlowSimulationStatus.abortedLoopGuard);
      expect(aborted.session.trace.length, 3);
    });
  });
}
