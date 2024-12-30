import 'dart:async';

import 'package:jocaagura_domain/jocaagura_domain.dart';

/// A BLoC (Business Logic Component) for managing onboarding processes.
///
/// The `BlocOnboarding` class handles a sequence of asynchronous initialization
/// functions during the onboarding phase of an application. It provides
/// progress updates through a stream and allows dynamically adding new
/// functions to the onboarding process.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/bloc_onboarding.dart';
/// import 'dart:async';
///
/// void main() async {
///   final blocOnboarding = BlocOnboarding([
///     () async {
///       print('Task 1 started');
///       await Future.delayed(Duration(seconds: 1));
///       print('Task 1 completed');
///     },
///     () async {
///       print('Task 2 started');
///       await Future.delayed(Duration(seconds: 1));
///       print('Task 2 completed');
///     },
///   ]);
///
///   // Listen to progress messages
///   blocOnboarding.msgStream.listen((message) {
///     print('Onboarding Message: $message');
///   });
///
///   // Start the onboarding process
///   await blocOnboarding.execute(Duration(seconds: 2));
/// }
/// ```
class BlocOnboarding extends BlocModule {
  /// Creates an instance of `BlocOnboarding` with the provided list of onboarding functions.
  ///
  /// The [delayInSeconds] parameter specifies an initial delay before the
  /// onboarding execution starts.
  BlocOnboarding(this._blocOnboardingList, {int delayInSeconds = 1}) {
    execute(
      Duration(seconds: delayInSeconds),
    );
  }

  /// The name identifier for the BLoC, used for tracking or debugging.
  static const String name = 'onboardingBloc';

  /// A list of asynchronous functions to execute during onboarding.
  final List<FutureOr<void> Function()> _blocOnboardingList;

  /// Internal controller for progress messages.
  final BlocGeneral<String> _blocMsg = BlocGeneral<String>('Inicializando');

  /// A stream of progress messages.
  ///
  /// This stream emits updates as the onboarding process progresses.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocOnboarding.msgStream.listen((message) {
  ///   print('Onboarding Message: $message');
  /// });
  /// ```
  Stream<String> get msgStream => _blocMsg.stream;

  /// Adds a new function to the onboarding process.
  ///
  /// The [function] is a `FutureOr` task to be executed as part of onboarding.
  /// Returns the updated length of the onboarding function list.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocOnboarding.addFunction(() async {
  ///   await Future.delayed(Duration(seconds: 1));
  ///   print('New Task Completed');
  /// });
  /// ```
  int addFunction(FutureOr<void> Function() function) {
    _blocOnboardingList.add(function);
    return _blocOnboardingList.length;
  }

  /// Executes the onboarding functions with a specified [duration] delay.
  ///
  /// Each function is executed sequentially, and progress is reported
  /// through the [msgStream].
  ///
  /// ## Example
  ///
  /// ```dart
  /// await blocOnboarding.execute(Duration(seconds: 2));
  /// ```
  Future<void> execute(Duration duration) async {
    await Future<void>.delayed(duration);
    final List<FutureOr<void> Function()> tmpList =
        List<FutureOr<void> Function()>.from(_blocOnboardingList);
    int length = tmpList.length;
    for (final FutureOr<void> Function() f in tmpList) {
      length--;
      await f();
      _blocMsg.value = '$length restantes';
    }
    _blocMsg.value = 'Onboarding completo';
  }

  /// Gets the current progress message.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(blocOnboarding.msg);
  /// ```
  String get msg => _blocMsg.value;

  /// Releases resources held by the BLoC.
  ///
  /// This method must be called when the BLoC is no longer needed to prevent
  /// memory leaks.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocOnboarding.dispose();
  /// ```
  @override
  FutureOr<void> dispose() {
    _blocMsg.dispose();
  }
}
