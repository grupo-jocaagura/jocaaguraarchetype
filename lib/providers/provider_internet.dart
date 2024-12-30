import 'package:jocaagura_domain/jocaagura_domain.dart';

/// An abstract provider for managing internet speed checks.
///
/// The `ProviderInternet` class defines a contract for checking the internet speed
/// using a `ConnectivityModel` to represent the connectivity details. It returns
/// the result as an `Either` type.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/provider_internet.dart';
/// import 'package:dartz/dartz.dart';
///
/// class MyInternetProvider extends ProviderInternet {
///   @override
///   Future<Either<String, ConnectivityModel>> getInternetSpeed(
///       ConnectivityModel connectivityModel) async {
///     // Simulate an internet speed check
///     final speed = 50.0; // Replace with actual speed testing logic
///     if (speed > 0) {
///       return Right(connectivityModel.copyWith(speed: speed));
///     } else {
///       return Left('Failed to measure internet speed');
///     }
///   }
/// }
///
/// void main() async {
///   final provider = MyInternetProvider();
///   final connectivityModel = ConnectivityModel(isConnected: true, speed: 0);
///   final result = await provider.getInternetSpeed(connectivityModel);
///
///   result.fold(
///     (error) => print('Error: $error'),
///     (status) => print('Internet Speed: ${status.speed} Mbps'),
///   );
/// }
/// ```
abstract class ProviderInternet implements EntityProvider {
  /// Creates an instance of `ProviderInternet`.
  const ProviderInternet();

  /// Measures the internet speed and updates the `ConnectivityModel`.
  ///
  /// The [connectivityModel] parameter represents the current connectivity state.
  /// Returns an `Either` type containing a `String` error message on the left
  /// or a `ConnectivityModel` with the updated internet speed on the right.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await provider.getInternetSpeed(connectivityModel);
  /// result.fold(
  ///   (error) => print('Error: $error'),
  ///   (status) => print('Internet Speed: ${status.speed} Mbps'),
  /// );
  /// ```
  Future<Either<String, ConnectivityModel>> getInternetSpeed(
    ConnectivityModel connectivityModel,
  );
}
