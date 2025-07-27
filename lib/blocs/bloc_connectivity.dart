import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../services/service_connectivity_plus.dart';

/// A BLoC (Business Logic Component) for managing connectivity state.
///
/// The `BlocConnectivity` class provides a reactive interface for monitoring
/// and updating connectivity status and internet speed. It integrates with
/// the `ServiceConnectivity` to perform connectivity checks and emits results
/// via a stream.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/bloc_connectivity.dart';
/// import 'package:jocaaguraarchetype/service_connectivity_plus.dart';
/// import 'package:dartz/dartz.dart';
///
/// void main() async {
///   final serviceConnectivity = ServiceConnectivity(
///     MyConnectivityProvider(),
///     MyInternetProvider(),
///     debouncer: Debouncer(milliseconds: 500),
///   );
///   final blocConnectivity = BlocConnectivity(serviceConnectivity);
///
///   // Listen to connectivity status updates
///   blocConnectivity.connectivityStatusStream.listen((status) {
///     status.fold(
///       (error) => print('Error: $error'),
///       (model) => print('Connectivity Status: ${model.isConnected}'),
///     );
///   });
///
///   // Update connectivity status
///   await blocConnectivity.updateConnectivity();
///
///   // Update internet speed
///   await blocConnectivity.updateInternetSpeed();
///
///   // Update both connectivity and speed
///   await blocConnectivity.updateConnectionStatus();
/// }
/// ```
class BlocConnectivity extends BlocModule {
  /// Creates an instance of `BlocConnectivity` with the given [serviceConnectivity].
  ///
  /// The [serviceConnectivity] is used to perform connectivity and internet speed checks.
  BlocConnectivity(this.serviceConnectivity);

  /// The name identifier for the BLoC, used for tracking or debugging.
  static const String name = 'blocConnectivity';

  /// The service for managing connectivity and internet speed.
  final ServiceConnectivityPlus serviceConnectivity;

  /// Internal controller for managing connectivity state.
  final BlocGeneral<Either<String, ConnectivityModel>> _connectivityBloc =
      BlocGeneral<Either<String, ConnectivityModel>>(
    Left<String, ConnectivityModel>('Initial State'),
  );

  /// Gets the current connectivity status.
  ///
  /// Returns an `Either` type containing a `String` error message on the left
  /// or a `ConnectivityModel` on the right.
  Either<String, ConnectivityModel> get connectivityStatus =>
      _connectivityBloc.value;

  /// A stream of connectivity status updates.
  ///
  /// Emits updates whenever the connectivity status changes.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocConnectivity.connectivityStatusStream.listen((status) {
  ///   status.fold(
  ///     (error) => print('Error: $error'),
  ///     (model) => print('Is Connected: ${model.isConnected}'),
  ///   );
  /// });
  /// ```
  Stream<Either<String, ConnectivityModel>> get connectivityStatusStream =>
      _connectivityBloc.stream;

  /// Updates the connectivity status by performing a connectivity check.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await blocConnectivity.updateConnectivity();
  /// ```
  Future<void> updateConnectivity() async {
    final ConnectivityModel connectivityModel = getConnectivityModel();
    _connectivityBloc.value =
        await serviceConnectivity.checkConnectivity(connectivityModel);
  }

  /// Updates the internet speed by performing an internet speed check.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await blocConnectivity.updateInternetSpeed();
  /// ```
  Future<void> updateInternetSpeed() async {
    final ConnectivityModel connectivityModel = getConnectivityModel();
    _connectivityBloc.value =
        await serviceConnectivity.checkInternetSpeed(connectivityModel);
  }

  /// Updates both the connectivity status and internet speed.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await blocConnectivity.updateConnectionStatus();
  /// ```
  Future<void> updateConnectionStatus() async {
    await updateConnectivity();
    await updateInternetSpeed();
  }

  /// Retrieves the current `ConnectivityModel` from the connectivity status.
  ///
  /// If the status is an error, it returns a default connectivity model.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final model = blocConnectivity.getConnectivityModel();
  /// print('Is Connected: ${model.isConnected}');
  /// ```
  ConnectivityModel getConnectivityModel() {
    return connectivityStatus.fold(
      (String p0) => defaultConnectivityModel,
      (ConnectivityModel p0) => p0,
    );
  }

  /// Releases resources held by the BLoC.
  ///
  /// This method must be called when the BLoC is no longer needed to prevent
  /// memory leaks.
  ///
  /// ## Example
  ///
  /// ```dart
  /// blocConnectivity.dispose();
  /// ```
  @override
  void dispose() {
    _connectivityBloc.dispose();
  }
}
