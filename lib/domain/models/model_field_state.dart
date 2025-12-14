part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Enumerates the serialized fields of [ModelFieldState].
enum ModelFieldStateEnum {
  value,
  errorText,
  suggestions,
  isDirty,
  isValid,
}

/// Default instance of [ModelFieldState] for fallback/testing.
///
/// It represents a pristine and valid field with safe defaults.
const ModelFieldState defaultModelFieldState = ModelFieldState();

/// Canonical, immutable state holder for controlled form fields.
///
/// `ModelFieldState` represents the single source of truth for a text field
/// driven by a BLoC. It carries the raw [value] typed by the user, the UI-ready
/// [errorText] (if any), optional [suggestions] for autocomplete widgets, and
/// metadata such as [isDirty] and [isValid].
///
/// - Use [copyWith] to emit new states from your BLoC (`BlocGeneral<ModelFieldState>`).
/// - Use [fromJson] / [toJson] to persist or hydrate form snapshots (e.g. drafts).
///
/// ⚠️ Warning about [suggestions]:
/// This class stores the provided list **by reference**.
/// Treat it as immutable after passing it in, or provide a defensive copy
/// from the caller side to avoid unexpected state mutations.
///
/// Functional example:
/// ```dart
/// void main() {
///   const ModelFieldState initial = ModelFieldState();
///
///   final ModelFieldState next = initial.copyWith(
///     value: 'john@',
///     errorText: 'Invalid email',
///     isDirty: true,
///     isValid: false,
///     suggestions: List<String>.unmodifiable(<String>['john@example.com']),
///   );
///
///   final Map<String, dynamic> json = next.toJson();
///   final ModelFieldState roundtrip = ModelFieldState.fromJson(json);
///
///   assert(roundtrip == next);
///   print(roundtrip);
/// }
/// ```
@immutable
class ModelFieldState {
  const ModelFieldState({
    this.value = '',
    this.errorText = '',
    this.suggestions = const <String>[],
    this.isDirty = false,
    this.isValid = true,
  });

  factory ModelFieldState.fromJson(Map<String, dynamic> json) {
    return ModelFieldState(
      value: Utils.getStringFromDynamic(json[ModelFieldStateEnum.value.name]),
      errorText:
          Utils.getStringFromDynamic(json[ModelFieldStateEnum.errorText.name]),
      suggestions: Utils.stringListFromDynamic(
        json[ModelFieldStateEnum.suggestions.name],
      ),
      isDirty: Utils.getBoolFromDynamic(json[ModelFieldStateEnum.isDirty.name]),
      isValid: Utils.getBoolFromDynamic(
        json[ModelFieldStateEnum.isValid.name],
        defaultValueIfNull: true,
      ),
    );
  }

  /// Raw user input. Keep formatting/validation logic in the BLoC.
  final String value;

  /// Message ready for UI consumption.
  ///
  /// An empty string means "no error".
  final String errorText;

  /// Optional suggestions to feed controlled autocomplete widgets.
  ///
  /// ⚠️ Stored by reference. Do not mutate after passing it in.
  final List<String> suggestions;

  /// Whether the field has been touched/edited at least once.
  final bool isDirty;

  /// Validity flag computed by the BLoC. Defaults to `true`.
  final bool isValid;

  /// Whether this state currently carries an error message.
  bool get hasError => _hasError;

  /// Whether the user hasn't interacted with the field yet.
  bool get isPristine => !isDirty;

  /// Creates a copy of this [ModelFieldState] with optional new values.
  ModelFieldState copyWith({
    String? value,
    String? errorText,
    List<String>? suggestions,
    bool? isDirty,
    bool? isValid,
  }) {
    return ModelFieldState(
      value: value ?? this.value,
      errorText: errorText ?? this.errorText,
      suggestions: suggestions ?? this.suggestions,
      isDirty: isDirty ?? this.isDirty,
      isValid: isValid ?? this.isValid,
    );
  }

  /// Returns a new state with an empty [errorText].
  ModelFieldState clearError() => copyWith(errorText: '');

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ModelFieldStateEnum.value.name: value,
      if (_hasError) ModelFieldStateEnum.errorText.name: errorText,
      if (suggestions.isNotEmpty)
        ModelFieldStateEnum.suggestions.name: suggestions,
      ModelFieldStateEnum.isDirty.name: isDirty,
      ModelFieldStateEnum.isValid.name: isValid,
    };
  }

  bool get _hasError => errorText.isNotEmpty;

  @override
  int get hashCode => Object.hash(
        value,
        errorText,
        Object.hashAll(suggestions),
        isDirty,
        isValid,
      );

  @override
  bool operator ==(Object other) {
    return other is ModelFieldState &&
        other.value == value &&
        other.errorText == errorText &&
        Utils.listEquals(other.suggestions, suggestions) &&
        other.isDirty == isDirty &&
        other.isValid == isValid;
  }

  @override
  String toString() => '${toJson()}';
}
