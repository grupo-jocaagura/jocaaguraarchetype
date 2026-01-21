import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('FlowSimulator', () {
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

    test('default plan follows success branch and reaches END', () {
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
            fail: 2,
            cost: <String, double>{'latencyMs': 20},
          ),
          step(
            index: 2,
            ok: -1,
            fail: -1,
            cost: <String, double>{'latencyMs': 30},
          ),
        ],
      );

      final FlowAuditSnapshot snap = FlowSimulator().simulate(flow);

      expect(snap.status, FlowSimulationStatus.endReached);
      expect(snap.endIndex, -1);
      expect(
        snap.trace.map((FlowTraceEntry e) => e.stepIndex).toList(),
        <int>[0, 1],
      );
      expect(snap.totalCostByMetric['latencyMs'], 30);
      expect(snap.lastFailureCode, isNull);
    });

    test(
        'forced failure follows failure branch and records failureCode override',
        () {
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

      final FlowAuditSnapshot snap = FlowSimulator().simulate(flow, plan: plan);

      expect(snap.status, FlowSimulationStatus.endReached);
      expect(
        snap.trace.map((FlowTraceEntry e) => e.stepIndex).toList(),
        <int>[0, 1, 2],
      );

      final FlowTraceEntry failureEntry = snap.trace[1];
      expect(failureEntry.branch, FlowBranch.failure);
      expect(failureEntry.wasForced, isTrue);
      expect(failureEntry.effectiveFailureCode, 'SESSION_EXPIRED');
      expect(snap.lastFailureCode, 'SESSION_EXPIRED');
    });

    test('missing referenced step aborts with abortedMissingStep', () {
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Demo',
        description: 'Demo flow',
        steps: <ModelFlowStep>[
          step(index: 0, ok: 99, fail: -1),
        ],
      );

      final FlowAuditSnapshot snap = FlowSimulator().simulate(flow);

      expect(snap.status, FlowSimulationStatus.abortedMissingStep);
      expect(snap.endIndex, 99);
      expect(snap.trace.length, 1);
      expect(snap.trace.first.nextIndex, 99);
    });

    test('loop guard stops simulation deterministically', () {
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Loop',
        description: 'Self loop',
        steps: <ModelFlowStep>[
          step(index: 0, ok: 0, fail: -1),
        ],
      );

      final FlowAuditSnapshot snap =
          FlowSimulator().simulate(flow, maxSteps: 5);

      expect(snap.status, FlowSimulationStatus.abortedLoopGuard);
      expect(snap.trace.length, 5);
      expect(snap.endIndex, 0);
      expect(
        snap.trace
            .every((FlowTraceEntry e) => e.stepIndex == 0 && e.nextIndex == 0),
        isTrue,
      );
    });

    test('cost normalization ignores negative and non-finite values', () {
      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Cost',
        description: 'Cost normalization',
        steps: <ModelFlowStep>[
          step(
            index: 0,
            ok: -1,
            fail: -1,
            cost: <String, double>{
              'latencyMs': 10,
              'networkKb': -2,
              'weird': double.infinity,
            },
          ),
        ],
      );

      final FlowAuditSnapshot snap = FlowSimulator().simulate(flow);

      expect(snap.status, FlowSimulationStatus.endReached);
      expect(snap.totalCostByMetric['latencyMs'], 10);
      expect(snap.totalCostByMetric['networkKb'], 0);
      expect(snap.totalCostByMetric['weird'], 0);
    });
  });
}
