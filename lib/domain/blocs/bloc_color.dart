part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Manage a color field state and propagate valid changes with debounce.
///
/// This bloc keeps a hex color string in a [ModelFieldState] and exposes it
/// through a stream for UI binding.
///
/// It supports two update sources:
/// - User input via [onColorChangedAttempt]
/// - External Design System updates via [onExternalDsChange]
///
/// The external update is considered the “source of truth” and does not mark
/// the field as dirty.
///
/// Functional example:
/// ```dart
/// void main() {
///   final BlocColor bloc = BlocColor(
///     const Color(0xFF00FF00),
///     onChangeColorAttempt: (Color c) {
///       // Apply the color to your DS tokens, theme, etc.
///       // This call is debounced.
///       // print('apply: $c');
///     },
///   );
///
///   // User types a valid hex:
///   bloc.onColorChangedAttempt('00FF00'); // normalizes to '#00FF00'
///
///   // External system pushes an update (should not mark dirty):
///   bloc.onExternalDsChange(const Color(0xFF112233));
///
///   bloc.dispose();
/// }
/// ```
///
/// Throws:
/// - [StateError] if any public method is used after [dispose].
class BlocColor extends BlocModule {
  BlocColor(
    this.initialColor, {
    required this.onChangeColorAttempt,
  }) : _colorState = BlocGeneral<ModelFieldState>(
          ModelFieldState(value: ThemeColorUtils.toHex(initialColor)),
        );

  final Color initialColor;
  final BlocGeneral<ModelFieldState> _colorState;
  final void Function(Color color) onChangeColorAttempt;

  Stream<ModelFieldState> get colorStream => _colorState.stream;
  ModelFieldState get colorState => _colorState.value;

  final DisposableDebouncer _debouncer = DisposableDebouncer(milliseconds: 300);

  bool _isDisposed = false;

  // Invalidate pending debounced callbacks whenever state changes.
  int _revision = 0;

  void _emit(ModelFieldState next) {
    if (next == colorState) {
      return;
    }
    _revision++;
    _colorState.value = next;
  }

  void onExternalDsChange(Color color) {
    ensureNotDisposed();

    final String colorHex = ThemeColorUtils.toHex(color);

    // External source is canonical: clean + valid + no error.
    final ModelFieldState nextState = colorState.copyWith(
      value: colorHex,
      isDirty: false,
      isValid: true,
      errorText: '',
    );

    _emit(nextState);
  }

  void onColorChangedAttempt(String colorHex) {
    ensureNotDisposed();

    final String raw = colorHex.trim();
    final String normalized = raw.startsWith('#') ? raw : '#$raw';

    if (normalized == colorState.value && colorState.isDirty == false) {
      return;
    }

    final Color? parsed = ThemeColorUtils.tryParseColor(normalized);
    final bool isValid = parsed != null;

    final ModelFieldState nextState = colorState.copyWith(
      value: normalized,
      errorText: isValid ? '' : 'Invalid hex color',
      isDirty: true,
      isValid: isValid,
    );

    _emit(nextState);

    if (!isValid) {
      return;
    }

    final int scheduledRevision = _revision;
    final String scheduledValue = normalized;
    final Color next = parsed;

    _debouncer.call(() {
      if (_isDisposed) {
        return;
      }

      if (_revision != scheduledRevision) {
        return;
      }

      if (colorState.value != scheduledValue) {
        return;
      }
      if (colorState.isValid != true) {
        return;
      }

      onChangeColorAttempt(next);
    });
  }

  Color get colorStateValue =>
      ThemeColorUtils.tryParseColor(colorState.value) ?? initialColor;

  void ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('BlocColor has been disposed');
    }
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _debouncer.dispose();
    _colorState.dispose();
    _isDisposed = true;
  }
}
