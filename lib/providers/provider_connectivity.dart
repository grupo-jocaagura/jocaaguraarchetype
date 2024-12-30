import 'package:jocaagura_domain/jocaagura_domain.dart';

/// An abstract provider for managing connectivity status.
///
/// The `ProviderConnectivity` class defines a contract for checking the connectivity
/// status of the application. It uses a `ConnectivityModel` to represent the
/// connectivity state and returns the result as an `Either` type.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/provider_connectivity.dart';
/// import 'package:dartz/dartz.dart';
///
/// class MyConnectivityProvider extends ProviderConnectivity {
///   @override
///   Future<Either<String, ConnectivityModel>> getConnectivityStatus(
///       ConnectivityModel connectivityModel) async {
///     // Simulate a connectivity check
///     final isConnected = true; // Replace with actual connectivity logic
///     if (isConnected) {
///       return Right(connectivityModel.copyWith(isConnected: true));
///     } else {
///       return Left('No connectivity');
///     }
///   }
/// }
///
/// void main() async {
///   final provider = MyConnectivityProvider();
///   final connectivityModel = ConnectivityModel(isConnected: false);
///   final result = await provider.getConnectivityStatus(connectivityModel);
///
///   result.fold(
///     (error) => print('Error: $error'),
///     (status) => print('Connectivity Status: ${status.isConnected}'),
///   );
/// }
/// ```
abstract class ProviderConnectivity extends EntityProvider {
  /// Creates an instance of `ProviderConnectivity`.
  const ProviderConnectivity();

  /// Checks the connectivity status of the application.
  ///
  /// The [connectivityModel] parameter represents the current connectivity state.
  /// Returns an `Either` type containing a `String` error message on the left
  /// or a `ConnectivityModel` with the updated status on the right.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await provider.getConnectivityStatus(connectivityModel);
  /// result.fold(
  ///   (error) => print('Error: $error'),
  ///   (status) => print('Connectivity Status: ${status.isConnected}'),
  /// );
  /// ```
  Future<Either<String, ConnectivityModel>> getConnectivityStatus(
    ConnectivityModel connectivityModel,
  );
}
