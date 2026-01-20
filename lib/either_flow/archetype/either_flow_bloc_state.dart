import 'package:flutter/material.dart';

import '../../jocaaguraarchetype.dart';

/// Machine-friendly JSON keys for [EitherFlowBlocState].
///
/// Keep this centralized to preserve roundtrip compatibility when persisting
/// editor/simulator drafts.
abstract final class EitherFlowBlocStateKeys {
  static const String jsonField = 'jsonField';
  static const String rawJson = 'rawJson';
  static const String isDirty = 'isDirty';
  static const String selectedStepIndex = 'selectedStepIndex';
  static const String updatedAtIso = 'updatedAtIso';
  static const String isBusy = 'isBusy';

  // Optional “derived snapshot” fields (safe to omit).
  static const String flow = 'flow';
  static const String validation = 'validation';
  static const String analysis = 'analysis';
  static const String simulationSession = 'simulationSession';
  static const String audit = 'audit';
}

/// Aggregate, immutable state for a controlled Either-Flow editor/simulator.
///
/// This state is meant to be the single source of truth for UI layers.
/// It intentionally contains **no Flutter widget types**.
///
/// The intended layering is:
/// UI (Flutter) → `BlocEitherFlow` → (optional) `EitherFlowBridge` → Core tools
/// (validator/analyzer/simulator).
///
/// ### JSON roundtrip
/// This state supports `toJson()` / `fromJson()` so it can be transported
/// through the typical Jocaagura pipeline:
/// Service → Gateway → Repository → Bloc → UI.
///
/// ### Example
/// ```dart
/// final BlocEitherFlow bloc = BlocEitherFlow();
/// bloc.updateRawJson('{"entryIndex":0,"stepsByIndex":{}}');
///
/// // Persist
/// final Map<String, dynamic> snap = bloc.state.value.toJson();
///
/// // Hydrate
/// final EitherFlowBlocState restored = EitherFlowBlocState.fromJson(snap);
/// bloc.emit(restored);
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
    this.selectedStepIndex,
    this.updatedAtIso,
    this.isBusy = false,
  });

  /// Hydrates an [EitherFlowBlocState] from JSON.
  ///
  /// This method is lenient:
  /// - Missing derived fields simply remain null.
  /// - If `jsonField` is missing, it will be reconstructed from `rawJson`/`isDirty`.
  factory EitherFlowBlocState.fromJson(Map<String, dynamic> json) {
    final Object? jfRaw = json[EitherFlowBlocStateKeys.jsonField];
    final ModelFieldState jsonField = jfRaw is Map<String, dynamic>
        ? ModelFieldState.fromJson(jfRaw)
        : ModelFieldState(
            value: Utils.getStringFromDynamic(
              json[EitherFlowBlocStateKeys.rawJson],
            ),
            isDirty: Utils.getBoolFromDynamic(
              json[EitherFlowBlocStateKeys.isDirty],
            ),
          );

    final Object? flowJson = json[EitherFlowBlocStateKeys.flow];
    final ModelCompleteFlow? flow = flowJson is Map<String, dynamic>
        ? ModelCompleteFlow.fromJson(flowJson)
        : null;

    final Object? vJson = json[EitherFlowBlocStateKeys.validation];
    final FlowValidationReport? validation = vJson is Map<String, dynamic>
        ? FlowValidationReport.fromJson(vJson)
        : null;

    final Object? aJson = json[EitherFlowBlocStateKeys.analysis];
    final FlowAnalysisReport? analysis = aJson is Map<String, dynamic>
        ? FlowAnalysisReport.fromJson(aJson)
        : null;

    final Object? sJson = json[EitherFlowBlocStateKeys.simulationSession];
    final FlowSimulationSession? session = sJson is Map<String, dynamic>
        ? FlowSimulationSession.fromJson(sJson)
        : null;

    final Object? auditJson = json[EitherFlowBlocStateKeys.audit];
    final FlowAuditSnapshot? audit = auditJson is Map<String, dynamic>
        ? FlowAuditSnapshot.fromJson(auditJson)
        : null;

    final int? selectedStepIndex =
        json[EitherFlowBlocStateKeys.selectedStepIndex] is int
            ? json[EitherFlowBlocStateKeys.selectedStepIndex] as int
            : int.tryParse(
                Utils.getStringFromDynamic(
                  json[EitherFlowBlocStateKeys.selectedStepIndex],
                ),
              );

    final String updatedAtIso = Utils.getStringFromDynamic(
      json[EitherFlowBlocStateKeys.updatedAtIso],
    ).trim();

    return EitherFlowBlocState(
      jsonField: jsonField,
      flow: flow,
      validationReport: validation,
      analysisReport: analysis,
      simulationSession: session,
      lastAuditSnapshot: audit,
      selectedStepIndex: selectedStepIndex,
      updatedAtIso: updatedAtIso.isEmpty ? null : updatedAtIso,
      isBusy: Utils.getBoolFromDynamic(json[EitherFlowBlocStateKeys.isBusy]),
    );
  }

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

  /// Step currently selected in the editor, if any.
  final int? selectedStepIndex;

  /// Timestamp (ISO-8601) for the last state update, if provided.
  ///
  /// This value is optional and may be omitted to keep drafts deterministic.
  final String? updatedAtIso;

  /// Whether the editor is executing a long-ish operation (import/analyze/simulate).
  ///
  /// Note: this flag does not imply threading; it exists for UI affordances.
  final bool isBusy;

  /// True when [flow] is available.
  bool get hasFlow => flow != null;

  /// True when a flow exists and the latest validation report is valid.
  bool get canSimulate => flow != null && (validationReport?.isValid ?? false);

  /// Converts this state into a JSON map.
  ///
  /// Contract:
  /// - Always includes `jsonField` (full snapshot).
  /// - Also includes `rawJson` + `isDirty` for convenience/backward-compat.
  /// - Derived fields may be omitted safely.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      EitherFlowBlocStateKeys.jsonField: jsonField.toJson(),
      EitherFlowBlocStateKeys.rawJson: jsonField.value,
      EitherFlowBlocStateKeys.isDirty: jsonField.isDirty,
      if (selectedStepIndex != null)
        EitherFlowBlocStateKeys.selectedStepIndex: selectedStepIndex,
      if (updatedAtIso != null)
        EitherFlowBlocStateKeys.updatedAtIso: updatedAtIso,
      EitherFlowBlocStateKeys.isBusy: isBusy,
      if (flow != null) EitherFlowBlocStateKeys.flow: flow!.toJson(),
      if (validationReport != null)
        EitherFlowBlocStateKeys.validation: validationReport!.toJson(),
      if (analysisReport != null)
        EitherFlowBlocStateKeys.analysis: analysisReport!.toJson(),
      if (simulationSession != null)
        EitherFlowBlocStateKeys.simulationSession: simulationSession!.toJson(),
      if (lastAuditSnapshot != null)
        EitherFlowBlocStateKeys.audit: lastAuditSnapshot!.toJson(),
    };
  }

  /// Creates a copy of this state with optional new values.
  EitherFlowBlocState copyWith({
    ModelFieldState? jsonField,
    ModelCompleteFlow? flow,
    FlowValidationReport? validationReport,
    FlowAnalysisReport? analysisReport,
    FlowSimulationSession? simulationSession,
    FlowAuditSnapshot? lastAuditSnapshot,
    int? selectedStepIndex,
    String? updatedAtIso,
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
      selectedStepIndex: selectedStepIndex ?? this.selectedStepIndex,
      updatedAtIso: updatedAtIso ?? this.updatedAtIso,
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
        selectedStepIndex,
        updatedAtIso,
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
        other.selectedStepIndex == selectedStepIndex &&
        other.updatedAtIso == updatedAtIso &&
        other.isBusy == isBusy;
  }

  @override
  String toString() => '${toJson()}';
}

/// Convenience default for tests and initial BLoC state.
const EitherFlowBlocState defaultEitherFlowBlocState = EitherFlowBlocState();
