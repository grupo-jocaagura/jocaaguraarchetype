import 'package:flutter/material.dart';

import '../../jocaaguraarchetype.dart';

/// BLoC for controlling Either-Flow editing, validation, analysis and simulation.
///
/// This BLoC follows the Jocaagura `BlocGeneral<T>` discipline:
/// - Business logic and UI interact through the `value` setter only.
/// - Consumers should treat emitted states as immutable.
///
/// **Important:**
/// - This BLoC is intentionally a *state container*.
/// - Import/validate/analyze/simulate are expected to be orchestrated by an
///   `EitherFlowBridge` (step 5) or higher-level use cases.
///
/// ### Example
/// ```dart
/// final BlocEitherFlow bloc = BlocEitherFlow();
///
/// bloc.updateRawJson('{"entryIndex":0,"stepsByIndex":{}}');
///
/// // UI listens to bloc.state.stream
/// bloc.dispose();
/// ```
class BlocEitherFlow {
  /// Creates a [BlocEitherFlow] with a safe initial state.
  BlocEitherFlow({
    EitherFlowBlocState initialState = defaultEitherFlowBlocState,
  }) : state = BlocGeneral<EitherFlowBlocState>(initialState);

  /// Reactive state container.
  ///
  /// UI should listen to this stream via `StreamBuilder`.
  final BlocGeneral<EitherFlowBlocState> state;

  /// Emits a new state.
  @protected
  void emit(EitherFlowBlocState next) {
    if (state.value != next) {
      state.value = next;
    }
  }

  /// Updates the controlled raw JSON field.
  ///
  /// This method marks the field as dirty and clears any previous error.
  void updateRawJson(String rawJson) {
    final ModelFieldState nextField = state.value.jsonField.copyWith(
      value: rawJson,
      isDirty: true,
      isValid: true,
      errorText: '',
    );

    emit(
      state.value.copyWith(
        jsonField: nextField,
        // Raw edits invalidate derived artifacts until re-imported.
        clearFlow: true,
        clearValidation: true,
        clearAnalysis: true,
        clearSimulation: true,
        clearAudit: true,
      ),
    );
  }

  /// Applies a JSON import failure to the controlled field.
  ///
  /// This does not throw. It resets derived artifacts.
  void setImportError(String errorText, {String? rawJson}) {
    final ModelFieldState current = state.value.jsonField;
    final ModelFieldState nextField = current.copyWith(
      value: rawJson ?? current.value,
      isDirty: true,
      isValid: false,
      errorText: errorText,
    );

    emit(
      state.value.copyWith(
        jsonField: nextField,
        clearFlow: true,
        clearValidation: true,
        clearAnalysis: true,
        clearSimulation: true,
        clearAudit: true,
      ),
    );
  }

  /// Updates the state after a successful import and validation.
  ///
  /// The [jsonField] is marked as valid. Callers can still attach warnings
  /// inside [report] while keeping the field valid.
  void setImportedFlow({
    required ModelCompleteFlow flow,
    required FlowValidationReport report,
    FlowAnalysisReport? analysis,
    ModelFieldState? jsonField,
  }) {
    final ModelFieldState nextField =
        (jsonField ?? state.value.jsonField).copyWith(
      isValid: report.isValid,
      errorText: report.isValid ? '' : 'Flow is invalid',
    );

    emit(
      state.value.copyWith(
        jsonField: nextField,
        flow: flow,
        validationReport: report,
        analysisReport: analysis,
        clearSimulation: true,
        clearAudit: true,
      ),
    );
  }

  /// Sets a new analysis report.
  void setAnalysis(FlowAnalysisReport analysis) {
    emit(state.value.copyWith(analysisReport: analysis));
  }

  /// Starts or replaces the current simulation session.
  void setSimulationSession(FlowSimulationSession session) {
    emit(state.value.copyWith(simulationSession: session));
  }

  /// Updates the last audit snapshot.
  void setAuditSnapshot(FlowAuditSnapshot snapshot) {
    emit(state.value.copyWith(lastAuditSnapshot: snapshot));
  }

  /// Updates the busy flag.
  void setBusy(bool isBusy) {
    emit(state.value.copyWith(isBusy: isBusy));
  }

  /// Clears simulation artifacts only.
  void clearSimulation() {
    emit(
      state.value.copyWith(
        clearSimulation: true,
        clearAudit: true,
      ),
    );
  }

  /// Disposes internal resources.
  void dispose() {
    state.dispose();
  }
}
