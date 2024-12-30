import 'dart:async';

import 'package:jocaagura_domain/jocaagura_domain.dart';

/// A BLoC (Business Logic Component) for managing loading states.
///
/// The `BlocLoading` class handles the display of loading messages in the
/// application. It uses a reactive stream to emit loading states and
/// provides utility methods for managing these states.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/bloc_loading.dart';
///
/// void main() async {
///   final blocLoading = BlocLoading();
///
///   // Listen to loading messages
///   blocLoading.loadingMsgStream.listen((message) {
///     if (message.isNotEmpty) {
///       print('Loading: $message');
///     }
///   });
///
///   // Display a loading message while performing a task
///   await blocLoading.loadingMsgWithFuture('Loading data...', () async {
///     await Future.delayed(Duration(seconds: 2));
///     print('Task completed!');
///   });
/// }
/// ```
class BlocLoading extends BlocModule {
  /// Internal controller for managing the loading message state.
  final BlocGeneral<String> _loadingController = BlocGeneral<String>('');

  /// The name identifier for the BLoC, used for tracking or debugging.
  static const String name = 'blocLoading';

  /// A stream of loading messages.
  ///
  /// This stream emits the current loading message, which can be used to
  /// display loading indicators in the UI.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocLoading.loadingMsgStream.listen((message) {
  ///   if (message.isNotEmpty) {
  ///     print('Loading: $message');
  ///   }
  /// });
  /// ```
  Stream<String> get loadingMsgStream => _loadingController.stream;

  /// The current loading message.
  ///
  /// Returns the latest message set in the controller.
  String get loadingMsg => _loadingController.value;

  /// Sets the loading message.
  ///
  /// Updates the loading message state.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocLoading.loadingMsg = 'Loading...';
  /// ```
  set loadingMsg(String val) {
    _loadingController.value = val;
  }

  /// Clears the current loading message.
  ///
  /// Resets the loading state by clearing the message.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocLoading.clearLoading();
  /// ```
  void clearLoading() {
    loadingMsg = '';
  }

  /// Displays a loading message while performing an asynchronous task.
  ///
  /// The [msg] parameter specifies the loading message to display.
  /// The [f] parameter is a function representing the asynchronous task.
  /// Once the task is completed, the loading message is cleared.
  ///
  /// This method prevents overlapping loading messages by ensuring that
  /// a new loading message is not set while another one is active.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await blocLoading.loadingMsgWithFuture('Loading data...', () async {
  ///   await Future.delayed(Duration(seconds: 2));
  ///   print('Task completed!');
  /// });
  /// ```
  Future<void> loadingMsgWithFuture(
    String msg,
    FutureOr<void> Function() f,
  ) async {
    if (loadingMsg.isEmpty) {
      loadingMsg = msg;
      await f();
      clearLoading();
    }
  }

  /// Releases resources held by the BLoC.
  ///
  /// This method must be called when the BLoC is no longer needed to prevent
  /// memory leaks.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocLoading.dispose();
  /// ```
  @override
  void dispose() {
    _loadingController.dispose();
  }
}
