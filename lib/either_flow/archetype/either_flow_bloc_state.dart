import 'package:flutter/material.dart';

import '../../jocaaguraarchetype.dart';

/// Aggregate, immutable state for a controlled Either-Flow editor/simulator.
///
/// This state is meant to be the single source of truth for UI layers.
/// It intentionally contains **no Flutter types**.
///
/// The intended layering is:
/// UI (Flutter) → `BlocEitherFlow` → (optional) `EitherFlowBridge` → Core tools
/// (validator/analyzer/simulator).
///
/// ### Example
/// ```dart
/// final BlocEitherFlow bloc = BlocEitherFlow();
///
/// bloc.updateRawJson('{"entryIndex":0,"stepsByIndex":{}}');
///
/// // Later, after import+validation (usually performed by a bridge):
/// bloc.setImportedFlow(
///   flow: flow,
///   report: report,
/// );
///
/// bloc.dispose();
/// ```
@immutable
class EitherFlowBlocState {
  /// Creates a new immutable [EitherFlowBlocState].
  const EitherFlowBlocState({
    this.jsonField = const ModelFieldState(),
    this.flow,
    this.validationReport,
    this.analysisReport,
    this.simulationSession,
    this.lastAuditSnapshot,
    this.isBusy = false,
  });

  /// Controlled field holding the raw flow JSON.
  ///
  /// This is the clipboard-first entry point for the editor.
  final ModelFieldState jsonField;

  /// The imported and parsed flow (nullable until import succeeds).
  final ModelCompleteFlow? flow;

  /// Latest validation report (nullable until validation is executed).
  final FlowValidationReport? validationReport;

  /// Latest analysis report (nullable until analysis is executed).
  final FlowAnalysisReport? analysisReport;

  /// Current step-by-step simulation session (nullable until started).
  final FlowSimulationSession? simulationSession;

  /// Last audit snapshot generated either by full-run simulation
  /// or by step-by-step snapshotting.
  final FlowAuditSnapshot? lastAuditSnapshot;

  /// Whether the editor is executing a long-ish operation (import/analyze/simulate).
  ///
  /// Note: this flag does not imply threading; it exists for UI affordances.
  final bool isBusy;

  /// True when [flow] is available.
  bool get hasFlow => flow != null;

  /// True when a flow exists and the latest validation report is valid.
  bool get canSimulate => flow != null && (validationReport?.isValid ?? false);

  /// Creates a copy of this state with optional new values.
  EitherFlowBlocState copyWith({
    ModelFieldState? jsonField,
    ModelCompleteFlow? flow,
    FlowValidationReport? validationReport,
    FlowAnalysisReport? analysisReport,
    FlowSimulationSession? simulationSession,
    FlowAuditSnapshot? lastAuditSnapshot,
    bool? isBusy,
    bool clearFlow = false,
    bool clearValidation = false,
    bool clearAnalysis = false,
    bool clearSimulation = false,
    bool clearAudit = false,
  }) {
    return EitherFlowBlocState(
      jsonField: jsonField ?? this.jsonField,
      flow: clearFlow ? null : (flow ?? this.flow),
      validationReport:
          clearValidation ? null : (validationReport ?? this.validationReport),
      analysisReport:
          clearAnalysis ? null : (analysisReport ?? this.analysisReport),
      simulationSession: clearSimulation
          ? null
          : (simulationSession ?? this.simulationSession),
      lastAuditSnapshot:
          clearAudit ? null : (lastAuditSnapshot ?? this.lastAuditSnapshot),
      isBusy: isBusy ?? this.isBusy,
    );
  }

  @override
  int get hashCode => Object.hash(
        jsonField,
        flow,
        validationReport,
        analysisReport,
        simulationSession,
        lastAuditSnapshot,
        isBusy,
      );

  @override
  bool operator ==(Object other) {
    return other is EitherFlowBlocState &&
        other.jsonField == jsonField &&
        other.flow == flow &&
        other.validationReport == validationReport &&
        other.analysisReport == analysisReport &&
        other.simulationSession == simulationSession &&
        other.lastAuditSnapshot == lastAuditSnapshot &&
        other.isBusy == isBusy;
  }

  @override
  String toString() {
    return '{jsonField:${jsonField.toJson()}, '
        'hasFlow:$hasFlow, '
        'validation:$validationReport, '
        'analysis:$analysisReport, '
        'session:$simulationSession, '
        'audit:$lastAuditSnapshot, '
        'isBusy:$isBusy}';
  }
}

/// Convenience default for tests and initial BLoC state.
const EitherFlowBlocState defaultEitherFlowBlocState = EitherFlowBlocState();
