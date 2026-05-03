part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Builds a widget variant based on a [ModelInteractiveState].
///
/// This widget centralizes the visual interpretation of common interactive
/// states such as hidden, loading, error, selected, disabled and enabled.
///
/// Priority order:
/// 1. hidden
/// 2. loading
/// 3. error
/// 4. selected
/// 5. disabled
/// 6. enabled
///
/// Functional example:
/// ```dart
/// DsInteractiveBuilder(
///   state: const ModelInteractiveState(isLoading: true),
///   enabledBuilder: (context, state) => const Text('Enabled'),
///   disabledBuilder: (context, state) => const Text('Disabled'),
///   loadingBuilder: (context, state) => const CircularProgressIndicator(),
/// )
/// ```
class DsInteractiveBuilder extends StatelessWidget {
  const DsInteractiveBuilder({
    required this.state,
    required this.enabledBuilder,
    this.disabledBuilder,
    this.loadingBuilder,
    this.hiddenBuilder,
    this.errorBuilder,
    this.selectedBuilder,
    super.key,
  });

  /// Controlled interactive state emitted by a BLoC/controller.
  final ModelInteractiveState state;

  /// Builder used when the component can interact normally.
  final InteractiveWidgetBuilder enabledBuilder;

  /// Builder used when the component is visible but cannot interact.
  ///
  /// If omitted, [enabledBuilder] is used with the same [state].
  final InteractiveWidgetBuilder? disabledBuilder;

  /// Builder used when the component is executing an action.
  ///
  /// If omitted, [disabledBuilder] is used when available; otherwise,
  /// [enabledBuilder] is used.
  final InteractiveWidgetBuilder? loadingBuilder;

  /// Builder used when the component is not visible.
  ///
  /// If omitted, renders [SizedBox.shrink].
  final InteractiveWidgetBuilder? hiddenBuilder;

  /// Builder used when the state carries an error.
  ///
  /// If omitted, [disabledBuilder] is used when available; otherwise,
  /// [enabledBuilder] is used.
  final InteractiveWidgetBuilder? errorBuilder;

  /// Builder used when the component is selected or active.
  ///
  /// If omitted, [enabledBuilder] is used.
  final InteractiveWidgetBuilder? selectedBuilder;

  @override
  Widget build(BuildContext context) {
    if (!state.isVisible) {
      return hiddenBuilder?.call(context, state) ?? const SizedBox.shrink();
    }

    if (state.isLoading) {
      return loadingBuilder?.call(context, state) ??
          disabledBuilder?.call(context, state) ??
          enabledBuilder(context, state);
    }

    if (state.hasError) {
      return errorBuilder?.call(context, state) ??
          disabledBuilder?.call(context, state) ??
          enabledBuilder(context, state);
    }

    if (state.isSelected) {
      return selectedBuilder?.call(context, state) ??
          enabledBuilder(context, state);
    }

    if (!state.canInteract) {
      return disabledBuilder?.call(context, state) ??
          enabledBuilder(context, state);
    }

    return enabledBuilder(context, state);
  }
}

/// Builds a widget from a controlled interactive state.
typedef InteractiveWidgetBuilder = Widget Function(
  BuildContext context,
  ModelInteractiveState state,
);
