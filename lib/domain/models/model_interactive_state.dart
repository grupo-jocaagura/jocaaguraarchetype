part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Enumerates the serialized fields of [ModelInteractiveState].
enum ModelInteractiveStateEnum {
  isEnabled,
  isLoading,
  isVisible,
  isSelected,
  reasonText,
  errorText,
  semantic,
}

/// Defines the visual/semantic intention of an interactive component.
enum ModelInteractiveSemantic {
  primary,
  secondary,
  neutral,
  success,
  warning,
  danger,
}

/// Default instance of [ModelInteractiveState] for fallback/testing.
///
/// It represents a visible, enabled, non-loading and neutral interactive state.
const ModelInteractiveState defaultModelInteractiveState =
    ModelInteractiveState();

/// Canonical, immutable state holder for controlled interactive components.
///
/// `ModelInteractiveState` represents the single source of truth for an
/// actionable UI component driven by a BLoC, such as a button, icon button,
/// action tile, selectable chip, navigation item, or clickable card.
///
/// It carries interaction flags such as [isEnabled], [isLoading], [isVisible],
/// and [isSelected], plus UI-ready feedback texts and a semantic visual intent.
///
/// Functional example:
/// ```dart
/// void main() {
///   const ModelInteractiveState initial = ModelInteractiveState();
///
///   final ModelInteractiveState loading = initial.copyWith(
///     isEnabled: false,
///     isLoading: true,
///     reasonText: 'Signing in...',
///     semantic: ModelInteractiveSemantic.primary,
///   );
///
///   final Map<String, dynamic> json = loading.toJson();
///   final ModelInteractiveState roundtrip =
///       ModelInteractiveState.fromJson(json);
///
///   assert(roundtrip == loading);
///   print(roundtrip);
/// }
/// ```
@immutable
class ModelInteractiveState {
  const ModelInteractiveState({
    this.isEnabled = true,
    this.isLoading = false,
    this.isVisible = true,
    this.isSelected = false,
    this.reasonText = '',
    this.errorText = '',
    this.semantic = ModelInteractiveSemantic.neutral,
  });

  factory ModelInteractiveState.fromJson(Map<String, dynamic> json) {
    return ModelInteractiveState(
      isEnabled: Utils.getBoolFromDynamic(
        json[ModelInteractiveStateEnum.isEnabled.name],
        defaultValueIfNull: true,
      ),
      isLoading: Utils.getBoolFromDynamic(
        json[ModelInteractiveStateEnum.isLoading.name],
      ),
      isVisible: Utils.getBoolFromDynamic(
        json[ModelInteractiveStateEnum.isVisible.name],
        defaultValueIfNull: true,
      ),
      isSelected: Utils.getBoolFromDynamic(
        json[ModelInteractiveStateEnum.isSelected.name],
      ),
      reasonText: Utils.getStringFromDynamic(
        json[ModelInteractiveStateEnum.reasonText.name],
      ),
      errorText: Utils.getStringFromDynamic(
        json[ModelInteractiveStateEnum.errorText.name],
      ),
      semantic: _semanticFromDynamic(
        json[ModelInteractiveStateEnum.semantic.name],
      ),
    );
  }

  /// Whether the component can be interacted with.
  final bool isEnabled;

  /// Whether the component is currently executing an action.
  final bool isLoading;

  /// Whether the component should be rendered.
  final bool isVisible;

  /// Whether the component is selected or active.
  final bool isSelected;

  /// UI-ready explanation for disabled, blocked, or pending interaction states.
  ///
  /// An empty string means "no reason".
  final String reasonText;

  /// UI-ready error message associated with this interactive component.
  ///
  /// An empty string means "no error".
  final String errorText;

  /// Visual/semantic intention for the interactive component.
  final ModelInteractiveSemantic semantic;

  /// Whether this state currently carries an error message.
  bool get hasError => errorText.isNotEmpty;

  /// Whether this state currently carries a reason message.
  bool get hasReason => reasonText.isNotEmpty;

  /// Whether the component can safely execute its action.
  bool get canInteract => isVisible && isEnabled && !isLoading;

  /// Whether the component is visible but cannot be interacted with.
  bool get isBlocked => isVisible && !isEnabled && hasReason;

  /// Message ready for helper/tooltip usage.
  ///
  /// Gives priority to [errorText] over [reasonText].
  String? get feedbackTextToInput {
    if (hasError) {
      return errorText;
    }

    if (hasReason) {
      return reasonText;
    }

    return null;
  }

  /// Creates a copy of this [ModelInteractiveState] with optional new values.
  ///
  /// To clean [reasonText] or [errorText], pass an empty string explicitly.
  ModelInteractiveState copyWith({
    bool? isEnabled,
    bool? isLoading,
    bool? isVisible,
    bool? isSelected,
    String? reasonText,
    String? errorText,
    ModelInteractiveSemantic? semantic,
  }) {
    return ModelInteractiveState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLoading: isLoading ?? this.isLoading,
      isVisible: isVisible ?? this.isVisible,
      isSelected: isSelected ?? this.isSelected,
      reasonText: reasonText ?? this.reasonText,
      errorText: errorText ?? this.errorText,
      semantic: semantic ?? this.semantic,
    );
  }

  /// Returns a new state with an empty [errorText].
  ModelInteractiveState clearError() => copyWith(errorText: '');

  /// Returns a new state with an empty [reasonText].
  ModelInteractiveState clearReason() => copyWith(reasonText: '');

  /// Returns a new state with empty feedback texts.
  ModelInteractiveState clearFeedback() {
    return copyWith(
      reasonText: '',
      errorText: '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ModelInteractiveStateEnum.isEnabled.name: isEnabled,
      ModelInteractiveStateEnum.isLoading.name: isLoading,
      ModelInteractiveStateEnum.isVisible.name: isVisible,
      ModelInteractiveStateEnum.isSelected.name: isSelected,
      if (reasonText.isNotEmpty)
        ModelInteractiveStateEnum.reasonText.name: reasonText,
      if (errorText.isNotEmpty)
        ModelInteractiveStateEnum.errorText.name: errorText,
      ModelInteractiveStateEnum.semantic.name: semantic.name,
    };
  }

  static ModelInteractiveSemantic _semanticFromDynamic(dynamic value) {
    final String semanticName = Utils.getStringFromDynamic(value);

    for (final ModelInteractiveSemantic semantic
        in ModelInteractiveSemantic.values) {
      if (semantic.name == semanticName) {
        return semantic;
      }
    }

    return ModelInteractiveSemantic.neutral;
  }

  @override
  int get hashCode => Object.hash(
        isEnabled,
        isLoading,
        isVisible,
        isSelected,
        reasonText,
        errorText,
        semantic,
      );

  @override
  bool operator ==(Object other) {
    return other is ModelInteractiveState &&
        other.isEnabled == isEnabled &&
        other.isLoading == isLoading &&
        other.isVisible == isVisible &&
        other.isSelected == isSelected &&
        other.reasonText == reasonText &&
        other.errorText == errorText &&
        other.semantic == semantic;
  }

  @override
  String toString() => '${toJson()}';
}
