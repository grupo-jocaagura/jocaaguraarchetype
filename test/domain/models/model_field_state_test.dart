import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ModelFieldState', () {
    test('Given default constructor When created Then uses safe defaults', () {
      // Arrange
      const ModelFieldState state = ModelFieldState();

      // Assert
      expect(state.value, '');
      expect(state.errorText, '');
      expect(state.suggestions, isEmpty);
      expect(state.isDirty, isFalse);
      expect(state.isValid, isTrue);
      expect(state.hasError, isFalse);
      expect(state.isPristine, isTrue);
      expect(state.toJson(), <String, dynamic>{
        ModelFieldStateEnum.value.name: '',
        ModelFieldStateEnum.isDirty.name: false,
        ModelFieldStateEnum.isValid.name: true,
      });
      expect(state.toString(), isNotEmpty); // hits toString()
    });

    test(
        'Given defaultModelFieldState When used Then matches expected baseline',
        () {
      expect(defaultModelFieldState, const ModelFieldState());
      expect(defaultModelFieldState.hasError, isFalse);
    });

    test(
        'Given state with error and suggestions When toJson Then includes optional keys',
        () {
      const ModelFieldState state = ModelFieldState(
        value: 'a@',
        errorText: 'Invalid email',
        suggestions: <String>['a@example.com', 'a@domain.com'],
        isDirty: true,
        isValid: false,
      );

      final Map<String, dynamic> json = state.toJson();

      expect(json[ModelFieldStateEnum.value.name], 'a@');
      expect(json[ModelFieldStateEnum.errorText.name], 'Invalid email');
      expect(
        json[ModelFieldStateEnum.suggestions.name],
        <String>['a@example.com', 'a@domain.com'],
      );
      expect(json[ModelFieldStateEnum.isDirty.name], isTrue);
      expect(json[ModelFieldStateEnum.isValid.name], isFalse);
      expect(state.hasError, isTrue);
      expect(state.isPristine, isFalse);
    });

    test(
        'Given json without isValid When fromJson Then defaults isValid to true',
        () {
      final Map<String, dynamic> json = <String, dynamic>{
        ModelFieldStateEnum.value.name: 'x',
        ModelFieldStateEnum.errorText.name: '',
        ModelFieldStateEnum.suggestions.name: <dynamic>[],
        ModelFieldStateEnum.isDirty.name: true,
        // isValid intentionally missing
      };

      final ModelFieldState state = ModelFieldState.fromJson(json);

      expect(state.value, 'x');
      expect(state.errorText, '');
      expect(state.suggestions, isEmpty);
      expect(state.isDirty, isTrue);
      expect(state.isValid, isTrue);
    });

    test('Given copyWith When empty call Then returns equivalent state', () {
      const ModelFieldState base = ModelFieldState(
        value: 'v',
        suggestions: <String>['s'],
        isDirty: true,
      );

      final ModelFieldState next = base.copyWith(); // required by you :)

      expect(next, base);
      expect(next.hashCode, base.hashCode);
    });

    test('Given copyWith When overriding some fields Then keeps others', () {
      const ModelFieldState base = ModelFieldState(
        value: 'old',
        suggestions: <String>['a'],
      );

      final ModelFieldState next = base.copyWith(
        value: 'new',
        isDirty: true,
        isValid: false,
      );

      expect(next.value, 'new');
      expect(next.errorText, '');
      expect(next.suggestions, <String>['a']);
      expect(next.isDirty, isTrue);
      expect(next.isValid, isFalse);
    });

    test('Given clearError When invoked Then errorText becomes empty', () {
      const ModelFieldState withError = ModelFieldState(
        value: 'x',
        errorText: 'Boom',
      );

      final ModelFieldState cleared = withError.clearError();

      expect(cleared.errorText, '');
      expect(cleared.hasError, isFalse);
    });

    test('Given equality When same content Then == true and hashCode matches',
        () {
      const ModelFieldState a = ModelFieldState(
        value: '1',
        suggestions: <String>['x'],
        isDirty: true,
      );
      const ModelFieldState b = ModelFieldState(
        value: '1',
        suggestions: <String>['x'],
        isDirty: true,
      );

      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
    });

    test('Given equality When suggestions order differs Then == false', () {
      const ModelFieldState a = ModelFieldState(
        value: '1',
        suggestions: <String>['a', 'b'],
      );
      const ModelFieldState b = ModelFieldState(
        value: '1',
        suggestions: <String>['b', 'a'],
      );

      expect(a == b, isFalse);
    });

    test(
        'Given suggestions list provided When mutated externally Then state changes (documented warning)',
        () {
      final List<String> shared = <String>['a'];
      final ModelFieldState state = ModelFieldState(suggestions: shared);

      shared.add('b'); // mutation after creation

      expect(
        state.suggestions,
        <String>['a', 'b'],
      ); // demonstrates reference behavior
    });
  });
}
