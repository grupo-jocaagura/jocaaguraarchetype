import 'dart:convert';

import '../../jocaaguraarchetype.dart';

/// Orchestrates Either-Flow tooling over a [BlocEitherFlow].
///
/// This bridge is part of the *tooling layer* (archetype/infrastructure).
/// It keeps Flutter/UI concerns outside the domain core while providing
/// deterministic import/validate/analyze/simulate routines.
///
/// Design goals:
/// - Clipboard-first: JSON string is always the boundary.
/// - Never-throws: operations surface failures through state updates.
/// - Deterministic simulations (driven by [FlowSimulationPlan]).
///
/// The bridge **does not** render UI. Consumers usually bind UI widgets to
/// `bloc.state.stream` and call bridge methods on user intents.
///
/// ### Example
/// ```dart
/// final BlocEitherFlow bloc = BlocEitherFlow();
/// final EitherFlowBridge bridge = DefaultEitherFlowBridge(bloc);
///
/// await bridge.importFromJson('{"entryIndex":0,"stepsByIndex":{}}');
/// await bridge.analyze();
/// bridge.startStepSimulation();
/// bridge.nextStep(const FlowStepDecision.success());
/// ```
abstract class EitherFlowBridge {
  /// Access to the controlled state container.
  BlocEitherFlow get bloc;

  /// Imports [rawJson] into a [ModelCompleteFlow] and updates the BLoC.
  ///
  /// Implementations should:
  /// - Parse JSON safely
  /// - Build the flow using `ModelCompleteFlow.fromJson`
  /// - Run [FlowValidator] and update validation report
  /// - Optionally compute analysis
  Future<Either<ErrorItem, ModelCompleteFlow>> importFromJson(String rawJson);

  /// Exports the current flow to JSON.
  ///
  /// If no flow exists, this returns the controlled raw JSON field.
  String exportToJson();

  /// Validates the current flow (if present) and updates the BLoC.
  FlowValidationReport validate();

  /// Analyzes the current flow (if present) and updates the BLoC.
  FlowAnalysisReport analyze();

  /// Runs a full deterministic simulation over the current flow.
  ///
  /// Updates the audit snapshot in the BLoC.
  FlowAuditSnapshot runSimulation({
    FlowSimulationPlan plan = const FlowSimulationPlan(),
    int maxSteps = 10000,
  });

  /// Starts a step-by-step simulation session.
  ///
  /// Updates the session in the BLoC.
  void startStepSimulation({
    FlowSimulationPlan plan = const FlowSimulationPlan(),
    int maxSteps = 10000,
  });

  /// Advances the current step simulation session.
  ///
  /// Updates session and the derived audit snapshot.
  void nextStep(FlowStepDecision decision);

  /// Clears the current simulation session and audit snapshot.
  void clearSimulation();

  /// Saves the current flow JSON to [storage] under [id].
  Future<Either<ErrorItem, void>> saveToStorage({required String id});

  /// Loads flow JSON from [storage] by [id] and imports it.
  Future<Either<ErrorItem, ModelCompleteFlow>> loadFromStorage({
    required String id,
  });
}

/// Default implementation of [EitherFlowBridge].
class DefaultEitherFlowBridge implements EitherFlowBridge {
  /// Creates a bridge for [bloc].
  ///
  /// [storage] is optional and only required for save/load features.
  DefaultEitherFlowBridge(
    this._bloc, {
    EitherFlowStorageGateway? storage,
    FlowValidator? validator,
    FlowAnalyzer? analyzer,
    FlowSimulator? simulator,
    FlowStepSimulator? stepSimulator,
  })  : _storage = storage,
        _validator = validator ?? FlowValidator(),
        _analyzer = analyzer ?? FlowAnalyzer(),
        _simulator = simulator ?? FlowSimulator(),
        _stepSimulator = stepSimulator ?? FlowStepSimulator();

  final BlocEitherFlow _bloc;
  final EitherFlowStorageGateway? _storage;
  final FlowValidator _validator;
  final FlowAnalyzer _analyzer;
  final FlowSimulator _simulator;
  final FlowStepSimulator _stepSimulator;

  FlowAuditSnapshot _emptySnapshot({int maxSteps = 10000}) {
    return FlowAuditSnapshot(
      flowName: '',
      flowDescription: '',
      entryIndex: -1,
      status: FlowSimulationStatus.abortedMissingStep,
      endIndex: -1,
      lastFailureCode: null,
      trace: const <FlowTraceEntry>[],
      totalCostByMetric: const <String, double>{},
      maxSteps: maxSteps,
    );
  }

  FlowAnalysisReport _emptyAnalysis() {
    return FlowAnalysisReport(
      entryIndex: -1,
      reachable: const <int>[],
      unreachable: const <int>[],
      cycles: const <List<int>>[],
      terminalSteps: const <int>[],
      costByMetric: const <String, double>{},
    );
  }

  @override
  BlocEitherFlow get bloc => _bloc;

  Either<ErrorItem, Map<String, dynamic>> _safeDecodeJson(String rawJson) {
    try {
      final Object? decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        return Right<ErrorItem, Map<String, dynamic>>(decoded);
      }
      return Left<ErrorItem, Map<String, dynamic>>(
        const ErrorItem(
          code: 'either_flow_import_invalid_root',
          description: 'Expected a JSON object at the root.',
          title: '',
        ),
      );
    } catch (e) {
      return Left<ErrorItem, Map<String, dynamic>>(
        ErrorItem(
          code: 'either_flow_import_parse_error',
          description: 'Invalid JSON: $e',
          title: '',
        ),
      );
    }
  }

  @override
  Future<Either<ErrorItem, ModelCompleteFlow>> importFromJson(
    String rawJson,
  ) async {
    bloc.setBusy(true);
    bloc.updateRawJson(rawJson);

    final Either<ErrorItem, Map<String, dynamic>> decoded =
        _safeDecodeJson(rawJson);

    return decoded.fold((ErrorItem error) {
      bloc.setImportError(error.description, rawJson: rawJson);
      bloc.setBusy(false);
      return Left<ErrorItem, ModelCompleteFlow>(error);
    }, (Map<String, dynamic> value) {
      final ModelCompleteFlow flow;

      try {
        flow = ModelCompleteFlow.fromJson(value);
        final FlowValidationReport report = _validator.validateFlow(flow);
        final FlowAnalysisReport analysis = _analyzer.analyze(flow);

        bloc.setImportedFlow(flow: flow, report: report, analysis: analysis);
        bloc.setBusy(false);
        return Right<ErrorItem, ModelCompleteFlow>(flow);
      } catch (e) {
        final ErrorItem err = ErrorItem(
          code: 'either_flow_import_model_error',
          description: 'Cannot build ModelCompleteFlow: $e',
          title: 'Error',
        );
        bloc.setImportError(err.description, rawJson: rawJson);
        bloc.setBusy(false);
        return Left<ErrorItem, ModelCompleteFlow>(err);
      }
    });
  }

  @override
  String exportToJson() {
    final ModelCompleteFlow? flow = bloc.state.value.flow;
    if (flow == null) {
      return bloc.state.value.jsonField.value;
    }
    try {
      return jsonEncode(flow.toJson());
    } catch (_) {
      // As a fallback, return the last controlled JSON string.
      return bloc.state.value.jsonField.value;
    }
  }

  @override
  FlowValidationReport validate() {
    final ModelCompleteFlow? flow = bloc.state.value.flow;
    if (flow == null) {
      const FlowValidationReport empty = FlowValidationReport(
        errors: <FlowValidationIssue>[],
        warnings: <FlowValidationIssue>[],
      );
      bloc.setValidation(empty);
      return empty;
    }

    final FlowValidationReport report = _validator.validateFlow(flow);
    bloc.setValidation(report);
    return report;
  }

  @override
  FlowAnalysisReport analyze() {
    final ModelCompleteFlow? flow = bloc.state.value.flow;
    if (flow == null) {
      final FlowAnalysisReport empty = _emptyAnalysis();
      bloc.setAnalysis(empty);
      return empty;
    }

    final FlowAnalysisReport report = _analyzer.analyze(flow);
    bloc.setAnalysis(report);
    return report;
  }

  @override
  FlowAuditSnapshot runSimulation({
    FlowSimulationPlan plan = const FlowSimulationPlan(),
    int maxSteps = 10000,
  }) {
    final ModelCompleteFlow? flow = bloc.state.value.flow;
    if (flow == null) {
      final FlowAuditSnapshot empty = _emptySnapshot(maxSteps: maxSteps);
      bloc.setAuditSnapshot(empty);
      return empty;
    }

    bloc.setBusy(true);
    final FlowAuditSnapshot snap =
        _simulator.simulate(flow, plan: plan, maxSteps: maxSteps);
    bloc.setAuditSnapshot(snap);
    bloc.setBusy(false);
    return snap;
  }

  @override
  void startStepSimulation({
    FlowSimulationPlan plan = const FlowSimulationPlan(),
    int maxSteps = 10000,
  }) {
    final ModelCompleteFlow? flow = bloc.state.value.flow;
    if (flow == null) {
      return;
    }

    bloc.setBusy(true);
    final FlowSimulationSession session =
        _stepSimulator.start(flow, plan: plan, maxSteps: maxSteps);
    bloc.setSimulationSession(session);
    bloc.setAuditSnapshot(_stepSimulator.snapshot(session));
    bloc.setBusy(false);
  }

  @override
  void nextStep(FlowStepDecision decision) {
    final FlowSimulationSession? session = bloc.state.value.simulationSession;
    if (session == null) {
      return;
    }

    bloc.setBusy(true);
    final FlowStepTick tick = _stepSimulator.next(session, decision: decision);
    bloc.setSimulationSession(tick.session);
    bloc.setAuditSnapshot(_stepSimulator.snapshot(tick.session));
    bloc.setBusy(false);
  }

  @override
  void clearSimulation() {
    bloc.clearSimulation();
  }

  ErrorItem _storageMissing() {
    return const ErrorItem(
      code: 'either_flow_storage_missing',
      description: 'Storage gateway is not configured.',
      title: 'Error',
    );
  }

  @override
  Future<Either<ErrorItem, void>> saveToStorage({required String id}) async {
    final EitherFlowStorageGateway? storage = _storage;
    if (storage == null) {
      return Left<ErrorItem, void>(_storageMissing());
    }

    final String raw = exportToJson();
    try {
      await storage.save(id: id, rawJson: raw);
      return Right<ErrorItem, void>(null);
    } catch (e) {
      return Left<ErrorItem, void>(
        ErrorItem(
          title: 'Error',
          code: 'either_flow_storage_save_error',
          description: 'Cannot save flow: $e',
        ),
      );
    }
  }

  @override
  Future<Either<ErrorItem, ModelCompleteFlow>> loadFromStorage({
    required String id,
  }) async {
    final EitherFlowStorageGateway? storage = _storage;
    if (storage == null) {
      return Left<ErrorItem, ModelCompleteFlow>(_storageMissing());
    }

    try {
      final String? raw = await storage.load(id: id);
      if (raw == null) {
        return Left<ErrorItem, ModelCompleteFlow>(
          ErrorItem(
            title: 'Error',
            code: 'either_flow_storage_not_found',
            description: 'Flow not found for id="$id".',
          ),
        );
      }
      return importFromJson(raw);
    } catch (e) {
      return Left<ErrorItem, ModelCompleteFlow>(
        ErrorItem(
          title: 'Error',
          code: 'either_flow_storage_load_error',
          description: 'Cannot load flow: $e',
        ),
      );
    }
  }
}
