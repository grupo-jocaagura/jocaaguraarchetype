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
/// import 'package:jocaaguraarchetype/bloc_user_notifications.dart';
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
class BlocUserNotifications extends BlocModule {
  /// The name identifier for the BLoC, used for tracking or debugging.
  static const String name = 'blocUserNotifications';

  /// Internal controller for managing the notification message.
  final BlocGeneral<String> _msgController = BlocGeneral<String>('');

  /// A debouncer to clear messages after a set duration.
  final Debouncer debouncer = Debouncer(
    milliseconds: 7000,
  );

  /// A stream of notification messages.
  ///
  /// This stream emits the current message, which can be used to display
  /// toast notifications in the UI.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocUserNotifications.toastStream.listen((message) {
  ///   if (message.isNotEmpty) {
  ///     print('Toast message: $message');
  ///   }
  /// });
  /// ```
  Stream<String> get toastStream => _msgController.stream;

  /// The current notification message.
  ///
  /// Returns the latest message set in the controller.
  String get msg => _msgController.value;

  /// Clears the current notification message.
  ///
  /// This method resets the message to an empty string, effectively clearing
  /// any active notifications.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocUserNotifications.clear();
  /// ```
  void clear() {
    _msgController.value = '';
  }

  /// Displays a toast notification with the given [message].
  ///
  /// The message is emitted through the [toastStream], and will automatically
  /// clear after the debounce duration.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocUserNotifications.showToast('Hello, user!');
  /// ```
  void showToast(String message) {
    _msgController.value = message;
    debouncer.call(clear);
  }

  /// Releases resources held by the BLoC.
  ///
  /// This method must be called when the BLoC is no longer needed to prevent
  /// memory leaks.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocUserNotifications.dispose();
  /// ```
  @override
  FutureOr<void> dispose() {
    _msgController.dispose();
  }
}
