import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('BlocEitherFlow (controlled states)', () {
    test('starts with safe defaults', () {
      final BlocEitherFlow bloc = BlocEitherFlow();

      expect(bloc.state.value.jsonField, const ModelFieldState());
      expect(bloc.state.value.flow, isNull);
      expect(bloc.state.value.validationReport, isNull);
      expect(bloc.state.value.analysisReport, isNull);
      expect(bloc.state.value.simulationSession, isNull);
      expect(bloc.state.value.lastAuditSnapshot, isNull);
      expect(bloc.state.value.isBusy, isFalse);

      bloc.dispose();
    });

    test('updateRawJson marks field dirty and clears derived artifacts', () {
      final BlocEitherFlow bloc = BlocEitherFlow();

      bloc.updateRawJson('{"entryIndex":0,"stepsByIndex":{}}');

      final EitherFlowBlocState st = bloc.state.value;
      expect(st.jsonField.value, '{"entryIndex":0,"stepsByIndex":{}}');
      expect(st.jsonField.isDirty, isTrue);
      expect(st.jsonField.isValid, isTrue);
      expect(st.jsonField.errorText, '');
      expect(st.flow, isNull);
      expect(st.validationReport, isNull);
      expect(st.analysisReport, isNull);
      expect(st.simulationSession, isNull);
      expect(st.lastAuditSnapshot, isNull);

      bloc.dispose();
    });

    test('setImportError marks field invalid and clears derived artifacts', () {
      final BlocEitherFlow bloc = BlocEitherFlow();

      bloc.setImportError('Invalid JSON');

      final EitherFlowBlocState st = bloc.state.value;
      expect(st.jsonField.isDirty, isTrue);
      expect(st.jsonField.isValid, isFalse);
      expect(st.jsonField.errorText, 'Invalid JSON');
      expect(st.flow, isNull);
      expect(st.validationReport, isNull);
      expect(st.analysisReport, isNull);
      expect(st.simulationSession, isNull);
      expect(st.lastAuditSnapshot, isNull);

      bloc.dispose();
    });
  });
}
