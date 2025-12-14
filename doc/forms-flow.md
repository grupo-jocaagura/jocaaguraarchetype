# Forms Flow Pattern (FieldState + BLoC)

Jocaagura apps adopt a *controlled form* pattern inspired by OKANE's `BlocIncomeForm`. Each input field is driven by a `BlocGeneral<ModelFieldState>` so the BLoC remains the single source of truth and the UI is a projection of that state.

## Key Concepts

- **ModelFieldState**: immutable object with `value`, `errorText`, `suggestions`, `isDirty`, `isValid`. Exposes `copyWith`, `hasError`, `isPristine` and JSON roundtrip for persistence.
- **BlocXxxForm**: owns one `BlocGeneral<ModelFieldState>` per field and exposes user intents (`onXxxChangedAttempt`, `onXxxSubmittedAttempt`, `submit`).
- **Controlled widgets**: inputs such as `JocaaguraAutocompleteInputWidget` receive `value`/`errorText` from the bloc and emit raw attempts back.
- **Flow**: user types → `onChangedAttempt` → validation/formatting → emit new `ModelFieldState` → UI rebuilds. Submit re-validates, builds domain entities and returns `Either`.

## Canonical Field State

```dart
final BlocGeneral<ModelFieldState> _email =
    BlocGeneral(const ModelFieldState());

void onEmailChangedAttempt(String raw) {
  final String value = raw.trim();
  final bool looksValid = value.contains('@');
  _email.value = _email.value.copyWith(
    value: value,
    isDirty: true,
    isValid: looksValid,
    errorText: looksValid ? '' : 'Invalid email',
  );
}
```

### JSON Roundtrip

```dart
final ModelFieldState state = ModelFieldState.fromJson(jsonMap);
final Map<String, dynamic> json = state.toJson();
```

## Bloc Form Template

1. Declare `BlocGeneral<ModelFieldState>` per field.
2. Provide getters/streams for UI consumption.
3. Implement `onXxxChangedAttempt` and optional `onXxxSubmittedAttempt`.
4. Implement `bool get isValid` and `Future<Either<ErrorItem, Result>> submit()`.

```dart
class DemoLoginFormBloc extends BlocModule {
  final BlocGeneral<ModelFieldState> _password =
      BlocGeneral(const ModelFieldState());

  void onPasswordChangedAttempt(String raw) {
    final bool valid = raw.length >= 6;
    _password.value = ModelFieldState(
      value: raw,
      isDirty: true,
      isValid: valid,
      errorText: valid ? '' : 'Min 6 chars',
    );
  }

  Future<Either<ErrorItem, Unit>> submit() async {
    onPasswordChangedAttempt(_password.value.value);
    if (!isValid) {
      return const Left(ErrorItem(
        code: 'INVALID_FORM',
        title: 'Invalid form',
        description: 'Check the fields',
      ));
    }
    // Build domain entity, call usecase, return Right(...)
    return const Right(Unit.value);
  }
}
```

## UI Wiring

```
StreamBuilder<ModelFieldState>(
  stream: bloc.emailStream,
  initialData: bloc.email,
  builder: (_, __) {
    final ModelFieldState s = bloc.email;
    return JocaaguraAutocompleteInputWidget(
      label: 'Email',
      value: s.value,
      errorText: s.errorText.isEmpty ? null : s.errorText,
      onChangedAttempt: bloc.onEmailChangedAttempt,
      onSubmittedAttempt: bloc.onEmailSubmittedAttempt,
      suggestList: s.suggestions,
    );
  },
);
```

## Example Flows

### Login (2 fields)
- Bloc: `_email`, `_password` with `ModelFieldState`.
- UI: `JocaaguraAutocompleteInputWidget` instances bound to each stream.
- Submit: `bloc.submit()` returns `Either<ErrorItem, Unit>`.

### Search with suggestions
- On change: filter base dataset, assign to `suggestions`.
- UI: same widget, suggestions feed dropdown automatically.
- Submit: emit domain event (e.g. `onQuerySubmittedAttempt`).

## Best Practices
- Keep validation/formatting in the BLoC, never in the widget.
- Use `isDirty`/`isValid` (or `hasError`) to control when to show errors.
- Re-validate inside `submit()` before hitting the usecase.
- For tests, use `setSizeForTesting` for responsive contexts and `ModelFieldState.fromJson` to hydrate fixtures.

## Common Pitfalls
- Mutating `ModelFieldState` (always emit a new instance).
- Triggering side effects from widgets instead of BLoC intents.
- Forgetting to dispose `BlocGeneral` instances.
- Mixing validation logic between UI/BLoC (leads to inconsistent state).

## References
- OKANE `BlocIncomeForm` + `FormLedgerWidget`.
- `example/lib/forms_example.dart` showcasing the canonical flow.
- `JocaaguraAutocompleteInputWidget` DartDoc for controlled usage instructions.
