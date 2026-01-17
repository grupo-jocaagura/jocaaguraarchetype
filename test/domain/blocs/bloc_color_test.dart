import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('BlocColor', () {
    test(
        'Given external DS update When UI echoes same text Then it does not mark dirty nor re-apply',
        () async {
      int applyCount = 0;
      Color? lastApplied;

      final BlocColor bloc = BlocColor(
        const Color(0xFF000000),
        onChangeColorAttempt: (Color c) {
          applyCount++;
          lastApplied = c;
        },
      );

      // External DS pushes canonical hex.
      bloc.onExternalDsChange(const Color(0xFF112233));

      expect(bloc.colorState.value, isNotEmpty);
      expect(bloc.colorState.isDirty, isFalse);
      expect(bloc.colorState.isValid, isTrue);
      expect(bloc.colorState.hasError, isFalse);

      // UI echoes the same value back into onChanged (programmatic set).
      bloc.onColorChangedAttempt(bloc.colorState.value);

      // Should remain clean and no side-effect scheduled.
      expect(bloc.colorState.isDirty, isFalse);
      expect(bloc.colorState.errorTextToInput, isNull);

      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(applyCount, 0);
      expect(lastApplied, isNull);

      bloc.dispose();
    });

    test(
        'Given invalid hex When user types Then it sets error and does not apply',
        () async {
      int applyCount = 0;

      final BlocColor bloc = BlocColor(
        const Color(0xFF000000),
        onChangeColorAttempt: (_) => applyCount++,
      );

      bloc.onColorChangedAttempt('#GGGGGG');

      expect(bloc.colorState.isDirty, isTrue);
      expect(bloc.colorState.isValid, isFalse);
      expect(bloc.colorState.errorText, isNotNull);

      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(applyCount, 0);

      bloc.dispose();
    });

    test(
        'Given rapid valid inputs When user types quickly Then it applies only last (debounced)',
        () async {
      int applyCount = 0;
      Color? lastApplied;

      final BlocColor bloc = BlocColor(
        const Color(0xFF000000),
        onChangeColorAttempt: (Color c) {
          applyCount++;
          lastApplied = c;
        },
      );

      bloc.onColorChangedAttempt('#112233');
      bloc.onColorChangedAttempt('#445566');
      bloc.onColorChangedAttempt('#778899');

      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(applyCount, 1);
      expect(lastApplied, isNotNull);
      expect(lastApplied!.toARGB32(), const Color(0xFF778899).toARGB32());

      bloc.dispose();
    });

    test('Given disposed bloc When called Then it throws StateError', () {
      final BlocColor bloc = BlocColor(
        const Color(0xFF000000),
        onChangeColorAttempt: (_) {},
      );

      bloc.dispose();

      expect(
        () => bloc.onExternalDsChange(const Color(0xFFFFFFFF)),
        throwsStateError,
      );
      expect(() => bloc.onColorChangedAttempt('#FFFFFF'), throwsStateError);
    });
  });
  group('BlocColor + DisposableDebouncer collisions', () {
    test(
      'Given invalid input When external DS updates Then state is clean and has no error',
      () async {
        final List<Color> applied = <Color>[];

        final BlocColor bloc = BlocColor(
          const Color(0xFF000000),
          onChangeColorAttempt: (Color c) => applied.add(c),
        );

        // User types invalid.
        bloc.onColorChangedAttempt('#GGGGGG');
        expect(bloc.colorState.isDirty, isTrue);
        expect(bloc.colorState.isValid, isFalse);
        expect(bloc.colorState.errorText, isNotNull);

        // External DS rescues the field.
        const Color dsColor = Color(0xFF112233);
        bloc.onExternalDsChange(dsColor);

        expect(bloc.colorState.value, ThemeColorUtils.toHex(dsColor));
        expect(bloc.colorState.isDirty, isFalse);
        expect(bloc.colorState.isValid, isTrue);
        expect(bloc.colorState.errorText, isEmpty);
        expect(bloc.colorState.errorTextToInput, isNull);

        // Invalid input should not have scheduled any apply.
        await Future<void>.delayed(const Duration(milliseconds: 350));
        expect(applied, isEmpty);

        bloc.dispose();
      },
    );

    test(
      'Given valid input scheduled When external DS updates before debounce fires Then it must not apply stale user color',
      () async {
        final List<Color> applied = <Color>[];

        final BlocColor bloc = BlocColor(
          const Color(0xFF000000),
          onChangeColorAttempt: (Color c) => applied.add(c),
        );

        // User types valid -> schedules debounced apply.
        bloc.onColorChangedAttempt('#112233');

        // External DS updates BEFORE debounce window ends.
        await Future<void>.delayed(const Duration(milliseconds: 100));
        const Color dsColor = Color(0xFF445566);
        bloc.onExternalDsChange(dsColor);

        // State should be DS and clean.
        expect(bloc.colorState.value, ThemeColorUtils.toHex(dsColor));
        expect(bloc.colorState.isDirty, isFalse);
        expect(bloc.colorState.isValid, isTrue);
        expect(bloc.colorState.errorTextToInput, isNull);
        expect(bloc.colorState.errorText, isEmpty);

        // Wait past debounce.
        await Future<void>.delayed(const Duration(milliseconds: 350));

        // ✅ Ideal: no stale apply happens.
        // ❌ If this fails (applied.length == 1), you still have "stale debounce" collision.
        expect(applied.length, 0);

        bloc.dispose();
      },
    );

    test(
      'Given pending debounced apply When bloc is disposed Then it must not apply after dispose',
      () async {
        final List<Color> applied = <Color>[];

        final BlocColor bloc = BlocColor(
          const Color(0xFF000000),
          onChangeColorAttempt: (Color c) => applied.add(c),
        );

        bloc.onColorChangedAttempt('#112233'); // schedules
        bloc.dispose(); // should cancel timer via wrapper

        await Future<void>.delayed(const Duration(milliseconds: 350));
        expect(applied, isEmpty);
      },
    );
  });
}
