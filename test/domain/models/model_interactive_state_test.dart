import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ModelInteractiveState', () {
    test(
      'Given default state When serialized Then roundtrip preserves value',
      () {
        const ModelInteractiveState state = ModelInteractiveState();

        final Map<String, dynamic> json = state.toJson();
        final ModelInteractiveState result = ModelInteractiveState.fromJson(
          json,
        );
        expect(result, state);
        expect(result, defaultModelInteractiveState);
        expect(result.canInteract, isTrue);
        expect(result.hasError, isFalse);
        expect(result.hasReason, isFalse);
      },
    );

    test(
      'Given loading state When serialized Then roundtrip preserves value',
      () {
        const ModelInteractiveState state = ModelInteractiveState(
          isEnabled: false,
          isLoading: true,
          reasonText: 'Signing in...',
          semantic: ModelInteractiveSemantic.primary,
        );

        final Map<String, dynamic> json = state.toJson();
        final ModelInteractiveState result = ModelInteractiveState.fromJson(
          json,
        );

        expect(result, state);
        expect(result.canInteract, isFalse);
        expect(result.isBlocked, isTrue);
        expect(result.feedbackTextToInput, 'Signing in...');
      },
    );

    test(
      'Given error state When serialized Then roundtrip preserves value',
      () {
        const ModelInteractiveState state = ModelInteractiveState(
          isEnabled: false,
          errorText: 'Action unavailable',
          reasonText: 'Missing permission',
          semantic: ModelInteractiveSemantic.warning,
        );

        final Map<String, dynamic> json = state.toJson();
        final ModelInteractiveState result = ModelInteractiveState.fromJson(
          json,
        );

        expect(result, state);
        expect(result.hasError, isTrue);
        expect(result.hasReason, isTrue);
        expect(result.feedbackTextToInput, 'Action unavailable');
      },
    );

    test(
      'Given selected danger state When serialized Then roundtrip preserves value',
      () {
        const ModelInteractiveState state = ModelInteractiveState(
          isSelected: true,
          semantic: ModelInteractiveSemantic.danger,
        );

        final Map<String, dynamic> json = state.toJson();
        final ModelInteractiveState result = ModelInteractiveState.fromJson(
          json,
        );

        expect(result, state);
        expect(result.isSelected, isTrue);
        expect(result.semantic, ModelInteractiveSemantic.danger);
      },
    );

    test(
      'Given unknown semantic When hydrated Then falls back to neutral',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelInteractiveStateEnum.semantic.name: 'unknown',
        };

        final ModelInteractiveState result = ModelInteractiveState.fromJson(
          json,
        );

        expect(result.semantic, ModelInteractiveSemantic.neutral);
        expect(result.isEnabled, isTrue);
        expect(result.isVisible, isTrue);
      },
    );

    test(
      'Given state with feedback When clearFeedback Then removes reason and error',
      () {
        const ModelInteractiveState state = ModelInteractiveState(
          reasonText: 'Wait a moment',
          errorText: 'Something failed',
        );

        final ModelInteractiveState result = state.clearFeedback();

        expect(result.reasonText, '');
        expect(result.errorText, '');
        expect(result.hasReason, isFalse);
        expect(result.hasError, isFalse);
      },
    );

    test(
      'Given disabled visible state with reason When evaluated Then is blocked',
      () {
        const ModelInteractiveState state = ModelInteractiveState(
          isEnabled: false,
          reasonText: 'Not allowed',
        );

        expect(state.isBlocked, isTrue);
        expect(state.canInteract, isFalse);
      },
    );

    test(
      'Given hidden state When evaluated Then cannot interact and is not blocked',
      () {
        const ModelInteractiveState state = ModelInteractiveState(
          isVisible: false,
          isEnabled: false,
          reasonText: 'Hidden by ACL',
        );

        expect(state.canInteract, isFalse);
        expect(state.isBlocked, isFalse);
      },
    );
  });
}
