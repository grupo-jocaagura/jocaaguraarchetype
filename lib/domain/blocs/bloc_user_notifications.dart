part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A BLoC (Business Logic Component) for managing user notifications.
///
/// The `BlocUserNotifications` class provides a mechanism for showing
/// temporary messages (toasts) to users, using a reactive stream to emit
/// notifications. Messages automatically clear after a defined debounce time.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
///
/// void main() {
///   final blocUserNotifications = BlocUserNotifications();
///
///   // Listen to toast messages
///   blocUserNotifications.toastStream.listen((message) {
///     if (message.isNotEmpty) {
///       print('Toast message: $message');
///     }
///   });
///
///   // Show a toast message
///   blocUserNotifications.showToast('Hello, user!');
/// }
/// ```
/// A BLoC (Business Logic Component) for user-facing toast notifications.
///
/// - Emits [ToastMessage]s via a reactive stream.
/// - Auto-clears the last message after a debounce window.
/// - New messages restart the auto-clear timer.
///
/// ### Example
/// ```dart
/// final BlocUserNotifications bloc = BlocUserNotifications();
/// final StreamSubscription sub = bloc.stream.listen((ToastMessage t) {
///   if (t.isNotEmpty) {
///     print('Toast: ${t.text}');
///   }
/// });
///
/// bloc.showToast('Hello!');
/// // …
//// await sub.cancel();
/// await bloc.dispose();
/// ```
class BlocUserNotifications extends BlocModule {
  BlocUserNotifications({
    Duration? autoClose,
    DateTime Function()? now, // for testability
  })  : _now = now ?? DateTime.now,
        _debouncer = Debouncer(
          milliseconds:
              (autoClose ?? const Duration(seconds: 7)).inMilliseconds,
        );

  static const String name = 'BlocUserNotifications';

  final BlocGeneral<ToastMessage> _controller = BlocGeneral<ToastMessage>(
    ToastMessage.empty(),
  );
  final Debouncer _debouncer;
  final DateTime Function() _now;

  /// Emits the current toast state (including timestamp).
  Stream<ToastMessage> get stream => _controller.stream;

  /// Convenience stream that only emits when message text changes.
  Stream<ToastMessage> get distinctStream =>
      _controller.stream.distinct((ToastMessage a, ToastMessage b) => a == b);

  /// Syntactic sugar for UI layers wanting only text.
  Stream<String> get textStream =>
      _controller.stream.map((ToastMessage t) => t.text);

  /// Current toast value.
  ToastMessage get toast => _controller.value;

  /// Whether the internal controller was closed.
  bool get isClosed => _controller.isClosed;

  /// Clears the current toast to an empty sentinel.
  void clear() {
    if (isDisposed) return;
    _controller.value = ToastMessage.empty();
  }

  /// Shows a toast and schedules auto-clear.
  ///
  /// If [duration] is provided it overrides the default debounce window.
  void showToast(String message, {Duration? duration}) {
    if (isDisposed) return;
    final ToastMessage next = ToastMessage(message, _now());
    if (next == _controller.value) {
      // identical content within same millisecond -> ignore to avoid noise
      return;
    }
    _controller.value = next;

    // Restart auto-clear window.
    final Debouncer d = (duration == null)
        ? _debouncer
        : Debouncer(milliseconds: duration.inMilliseconds);
    d.call(clear);
  }

  bool isDisposed = false;

  @override
  Future<void> dispose() async {
    if (isDisposed) {
      return;
    }
    isDisposed = true;
    _controller.dispose();
  }
  // ------------------------
  // RETROCOMPATIBILIDAD 👇
  // ------------------------

  /// Histórico: muchas UIs consumían directamente el texto.
  @Deprecated('Use textStream (only text) or stream (ToastMessage) instead.')
  Stream<String> get toastStream => textStream;

  /// Histórico: acceso directo al texto actual.
  @Deprecated('Use toast.text instead.')
  String get msg => toast.text;

// ------------------------
}
