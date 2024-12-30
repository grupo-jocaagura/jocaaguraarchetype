import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../providers/provider_connectivity.dart';

/// A fake implementation of `ProviderConnectivity` for testing purposes.
///
/// The `FakeConnectivityProvider` class simulates connectivity checks, allowing
/// developers to test their code without relying on real network conditions.
/// It provides configurable behavior through the [getAppTestingFunction] parameter.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/fake_connectivity_provider.dart';
/// import 'package:dartz/dartz.dart';
///
/// void main() async {
///   final fakeProvider = FakeConnectivityProvider(
///     getAppTestingFunction: Right(
///       ConnectivityModel(isConnected: true, connectionType: ConnectionTypeEnum.wifi),
///     ),
///   );
///
///   final connectivityModel = ConnectivityModel(isConnected: false);
///   final result = await fakeProvider.getConnectivityStatus(connectivityModel);
///
///   result.fold(
///     (error) => print('Error: $error'),
///     (status) => print('Is Connected: ${status.isConnected}, Connection Type: ${status.connectionType}'),
///   );
/// }
/// ```
class FakeConnectivityProvider implements ProviderConnectivity {
  /// Creates an instance of `FakeConnectivityProvider`.
  ///
  /// The [getAppTestingFunction] parameter allows you to provide a predefined
  /// result for testing. If not provided, the provider simulates a successful
  /// connectivity status with default values.
  const FakeConnectivityProvider({
    this.getAppTestingFunction,
  });

  /// A predefined result for testing connectivity.
  ///
  /// If provided, this value will be returned when [getConnectivityStatus] is called.
  /// If not provided, the method simulates a default connectivity status.
  final Either<String, ConnectivityModel>? getAppTestingFunction;

  /// Simulates a connectivity status check.
  ///
  /// The [connectivityModel] parameter represents the current connectivity state.
  /// You can override the simulation behavior using the optional parameters:
  /// - [duration]: The delay before the result is returned.
  /// - [connectionType]: The type of connection to simulate (e.g., WiFi, Mobile).
  /// - [connected]: Whether the connection is active or not.
  ///
  /// Returns an `Either` type containing a `String` error message on the left
  /// or an updated `ConnectivityModel` on the right.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final fakeProvider = FakeConnectivityProvider();
  /// final connectivityModel = ConnectivityModel(isConnected: false);
  /// final result = await fakeProvider.getConnectivityStatus(connectivityModel);
  ///
  /// result.fold(
  ///   (error) => print('Error: $error'),
  ///   (status) => print('Is Connected: ${status.isConnected}'),
  /// );
  /// ```
  @override
  Future<Either<String, ConnectivityModel>> getConnectivityStatus(
    ConnectivityModel connectivityModel, {
    Duration duration = const Duration(
      milliseconds: 500,
    ),
    ConnectionTypeEnum connectionType = ConnectionTypeEnum.wifi,
    bool connected = true,
  }) async {
    await Future<void>.delayed(duration);
    return getAppTestingFunction ??
        Right<String, ConnectivityModel>(
          connectivityModel.copyWith(
            connectionType: connectionType,
          ),
        );
  }
}
