import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class _MemoryStorage implements EitherFlowStorageGateway {
  final Map<String, String> _db = <String, String>{};

  @override
  Future<void> save({required String id, required String rawJson}) async {
    _db[id] = rawJson;
  }

  @override
  Future<String?> load({required String id}) async => _db[id];
}

ModelFlowStep _step({
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

void main() {
  group('EitherFlowBridge (step 5)', () {
    test('importFromJson sets bloc flow + validation + analysis', () async {
      final BlocEitherFlow bloc = BlocEitherFlow();
      final DefaultEitherFlowBridge bridge = DefaultEitherFlowBridge(bloc);

      const String raw =
          '{"name":"Demo","description":"x","entryIndex":0,"stepsByIndex":{"0":{"index":0,"title":"A","description":"","failureCode":"F","nextOnSuccessIndex":-1,"nextOnFailureIndex":-1,"cost":{}}}}';

      final Either<ErrorItem, ModelCompleteFlow> res =
          await bridge.importFromJson(raw);

      expect(res.isRight, isTrue);
      expect(bloc.state.value.flow, isNotNull);
      expect(bloc.state.value.validationReport, isNotNull);
      expect(bloc.state.value.analysisReport, isNotNull);
      expect(bloc.state.value.jsonField.isValid, isTrue);
      expect(bloc.state.value.isBusy, isFalse);

      bloc.dispose();
    });

    test('importFromJson invalid json marks field invalid and returns left',
        () async {
      final BlocEitherFlow bloc = BlocEitherFlow();
      final DefaultEitherFlowBridge bridge = DefaultEitherFlowBridge(bloc);

      const String raw = '{invalid-json';
      final Either<ErrorItem, ModelCompleteFlow> res =
          await bridge.importFromJson(raw);

      expect(res.isLeft, isTrue);
      expect(bloc.state.value.flow, isNull);
      expect(bloc.state.value.jsonField.isValid, isFalse);
      expect(bloc.state.value.jsonField.errorText, isNotEmpty);

      bloc.dispose();
    });

    test('runSimulation writes audit snapshot into bloc', () {
      final BlocEitherFlow bloc = BlocEitherFlow();
      final DefaultEitherFlowBridge bridge = DefaultEitherFlowBridge(bloc);

      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Demo',
        description: 'Demo',
        steps: <ModelFlowStep>[
          _step(
            index: 0,
            ok: -1,
            fail: -1,
            cost: <String, double>{'latencyMs': 10},
          ),
        ],
      );

      bloc.setImportedFlow(
        flow: flow,
        report: FlowValidator().validateFlow(flow),
        analysis: FlowAnalyzer().analyze(flow),
      );

      final FlowSimulationPlan plan = FlowSimulationPlan.immutable(
        forcedByStepIndex: <int, FlowForcedOutcome>{
          0: const FlowForcedOutcome.success(),
        },
      );

      final FlowAuditSnapshot snap = bridge.runSimulation(plan: plan);

      expect(snap.status, FlowSimulationStatus.endReached);
      expect(bloc.state.value.lastAuditSnapshot, isNotNull);
      expect(
        bloc.state.value.lastAuditSnapshot!.status,
        FlowSimulationStatus.endReached,
      );

      bloc.dispose();
    });

    test('step-by-step simulation produces running snapshot increments', () {
      final BlocEitherFlow bloc = BlocEitherFlow();
      final DefaultEitherFlowBridge bridge = DefaultEitherFlowBridge(bloc);

      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Demo',
        description: 'Demo',
        steps: <ModelFlowStep>[
          _step(index: 0, ok: 1, fail: -1),
          _step(index: 1, ok: -1, fail: -1),
        ],
      );

      bloc.setImportedFlow(
        flow: flow,
        report: FlowValidator().validateFlow(flow),
        analysis: FlowAnalyzer().analyze(flow),
      );

      bridge.startStepSimulation();
      expect(bloc.state.value.simulationSession, isNotNull);
      expect(bloc.state.value.lastAuditSnapshot, isNotNull);
      expect(bloc.state.value.lastAuditSnapshot!.trace.length, 0);

      bridge.nextStep(const FlowStepDecision.success());
      expect(bloc.state.value.lastAuditSnapshot!.trace.length, 1);

      bridge.nextStep(const FlowStepDecision.success());
      expect(
        bloc.state.value.lastAuditSnapshot!.status,
        FlowSimulationStatus.endReached,
      );
      expect(bloc.state.value.lastAuditSnapshot!.trace.length, 2);

      bloc.dispose();
    });

    test('save/load uses storage gateway', () async {
      final BlocEitherFlow bloc = BlocEitherFlow();
      final _MemoryStorage storage = _MemoryStorage();
      final DefaultEitherFlowBridge bridge =
          DefaultEitherFlowBridge(bloc, storage: storage);

      const String raw =
          '{"name":"Demo","description":"x","entryIndex":0,"stepsByIndex":{"0":{"index":0,"title":"A","description":"","failureCode":"F","nextOnSuccessIndex":-1,"nextOnFailureIndex":-1,"cost":{}}}}';
      await bridge.importFromJson(raw);

      final Either<ErrorItem, void> saved = await bridge.saveToStorage(id: 'x');
      expect(saved.isRight, isTrue);

      bloc.updateRawJson('');
      expect(bloc.state.value.flow, isNull);

      final Either<ErrorItem, ModelCompleteFlow> loaded =
          await bridge.loadFromStorage(id: 'x');
      expect(loaded.isRight, isTrue);
      expect(bloc.state.value.flow, isNotNull);

      bloc.dispose();
    });
  });
}
