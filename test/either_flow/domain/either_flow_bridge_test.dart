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
  group('DefaultEitherFlowBridge - robustness', () {
    test(
        'Given invalid JSON When importFromJson Then isBusy ends false (never stuck)',
        () async {
      final BlocEitherFlow bloc = BlocEitherFlow();
      final DefaultEitherFlowBridge bridge = DefaultEitherFlowBridge(bloc);

      const String raw = '{invalid-json';

      final Either<ErrorItem, ModelCompleteFlow> res =
          await bridge.importFromJson(raw);

      expect(res.isLeft, isTrue);
      expect(bloc.state.value.isBusy, isFalse);

      bloc.dispose();
    });

    test(
        'Given JSON with non-object root When importFromJson Then returns left and marks field invalid',
        () async {
      final BlocEitherFlow bloc = BlocEitherFlow();
      final DefaultEitherFlowBridge bridge = DefaultEitherFlowBridge(bloc);

      // Valid JSON, but root is a list -> _safeDecodeJson must reject.
      const String raw = '[]';

      final Either<ErrorItem, ModelCompleteFlow> res =
          await bridge.importFromJson(raw);

      expect(res.isLeft, isTrue);
      expect(bloc.state.value.flow, isNull);
      expect(bloc.state.value.jsonField.isValid, isFalse);
      expect(bloc.state.value.jsonField.errorText, isNotEmpty);
      expect(bloc.state.value.isBusy, isFalse);

      bloc.dispose();
    });

    test(
        'Given parsable JSON but weird stepsByIndex When importFromJson Then returns right with empty steps and never stuck busy',
        () async {
      final BlocEitherFlow bloc = BlocEitherFlow();
      final DefaultEitherFlowBridge bridge = DefaultEitherFlowBridge(bloc);

      // "stepsByIndex" is a List, but ModelCompleteFlow.fromJson is lenient:
      // it should produce an empty stepsByIndex map, not throw.
      const String raw =
          '{"name":"Demo","description":"x","entryIndex":0,"stepsByIndex":[]}';

      final Either<ErrorItem, ModelCompleteFlow> res =
          await bridge.importFromJson(raw);

      expect(res.isRight, isTrue);
      expect(bloc.state.value.flow, isNotNull);
      expect(bloc.state.value.flow!.stepsByIndex, isEmpty);

      // Import contract: derived artifacts exist (your tests expect this).
      expect(bloc.state.value.validationReport, isNotNull);
      expect(bloc.state.value.analysisReport, isNotNull);

      // Must always end not busy.
      expect(bloc.state.value.isBusy, isFalse);

      bloc.dispose();
    });

    test(
        'Given no flow When validate Then sets and returns an empty validation report (safe behavior)',
        () {
      final BlocEitherFlow bloc = BlocEitherFlow();
      final DefaultEitherFlowBridge bridge = DefaultEitherFlowBridge(bloc);

      final FlowValidationReport report = bridge.validate();

      expect(report.errors, isEmpty);
      expect(report.warnings, isEmpty);
      expect(bloc.state.value.validationReport, isNotNull);

      bloc.dispose();
    });

    test(
        'Given no flow When analyze Then sets and returns an empty analysis report (safe behavior)',
        () {
      final BlocEitherFlow bloc = BlocEitherFlow();
      final DefaultEitherFlowBridge bridge = DefaultEitherFlowBridge(bloc);

      final FlowAnalysisReport report = bridge.analyze();

      expect(report.entryIndex, equals(-1));
      expect(bloc.state.value.analysisReport, isNotNull);
      expect(bloc.state.value.analysisReport!.entryIndex, equals(-1));

      bloc.dispose();
    });

    test(
        'Given no flow When startStepSimulation Then does nothing and does not flip busy',
        () {
      final BlocEitherFlow bloc = BlocEitherFlow();
      final DefaultEitherFlowBridge bridge = DefaultEitherFlowBridge(bloc);

      bridge.startStepSimulation();

      expect(bloc.state.value.simulationSession, isNull);
      expect(bloc.state.value.lastAuditSnapshot, isNull);
      expect(bloc.state.value.isBusy, isFalse);

      bloc.dispose();
    });

    test(
        'Given started step simulation When clearSimulation Then session and audit are cleared',
        () {
      final BlocEitherFlow bloc = BlocEitherFlow();
      final DefaultEitherFlowBridge bridge = DefaultEitherFlowBridge(bloc);

      final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
        name: 'Demo',
        description: 'Demo',
        steps: <ModelFlowStep>[
          ModelFlowStep.immutable(
            index: 0,
            title: 'A',
            description: '',
            failureCode: 'F',
            nextOnSuccessIndex: -1,
            nextOnFailureIndex: -1,
          ),
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

      bridge.clearSimulation();

      expect(bloc.state.value.simulationSession, isNull);
      expect(bloc.state.value.lastAuditSnapshot, isNull);

      bloc.dispose();
    });

    test(
        'Given storage not configured When saveToStorage/loadFromStorage Then returns left',
        () async {
      final BlocEitherFlow bloc = BlocEitherFlow();
      final DefaultEitherFlowBridge bridge = DefaultEitherFlowBridge(bloc);

      final Either<ErrorItem, Unit> saved = await bridge.saveToStorage(id: 'x');
      expect(saved.isLeft, isTrue);

      final Either<ErrorItem, ModelCompleteFlow> loaded =
          await bridge.loadFromStorage(id: 'x');
      expect(loaded.isLeft, isTrue);

      bloc.dispose();
    });
  });
}
