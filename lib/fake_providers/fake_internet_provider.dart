import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../providers/provider_internet.dart';

/// A fake implementation of `ProviderInternet` for testing internet speed checks.
///
/// The `FakeInternetProvider` class simulates internet speed measurements,
/// allowing developers to test their code without relying on real network conditions.
/// It provides configurable behavior through the [getAppTestingFunction] parameter.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/fake_internet_provider.dart';
/// import 'package:dartz/dartz.dart';
///
/// void main() async {
///   final fakeInternetProvider = FakeInternetProvider(
///     getAppTestingFunction: Right(
///       ConnectivityModel(isConnected: true, internetSpeed: 50.0),
///     ),
///   );
///
///   final connectivityModel = ConnectivityModel(isConnected: true);
///   final result = await fakeInternetProvider.getInternetSpeed(connectivityModel);
///
///   result.fold(
///     (error) => print('Error: $error'),
///     (status) => print('Internet Speed: ${status.internetSpeed} Mbps'),
///   );
/// }
/// ```
class FakeInternetProvider implements ProviderInternet {
  /// Creates an instance of `FakeInternetProvider`.
  ///
  /// The [getAppTestingFunction] parameter allows you to provide a predefined
  /// result for testing. If not provided, the provider simulates a default
  /// internet speed value.
  const FakeInternetProvider({
    this.getAppTestingFunction,
  });

  /// A predefined result for testing internet speed.
  ///
  /// If provided, this value will be returned when [getInternetSpeed] is called.
  /// If not provided, the method simulates a default internet speed.
  final Either<String, ConnectivityModel>? getAppTestingFunction;

  /// Simulates measuring the internet speed.
  ///
  /// The [connectivityModel] parameter represents the current connectivity state.
  /// You can override the simulation behavior using the optional parameters:
  /// - [duration]: The delay before the result is returned.
  /// - [internetSpeed]: The internet speed to simulate, where `0.0` represents no connection.
  ///
  /// Returns an `Either` type containing a `String` error message on the left
  /// or an updated `ConnectivityModel` on the right.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final fakeProvider = FakeInternetProvider();
  /// final connectivityModel = ConnectivityModel(isConnected: true);
  /// final result = await fakeProvider.getInternetSpeed(connectivityModel);
  ///
  /// result.fold(
  ///   (error) => print('Error: $error'),
  ///   (status) => print('Internet Speed: ${status.internetSpeed} Mbps'),
  /// );
  /// ```
  @override
  Future<Either<String, ConnectivityModel>> getInternetSpeed(
    ConnectivityModel connectivityModel, {
    Duration duration = const Duration(milliseconds: 500),
    double internetSpeed = 10.0, // 0 indicates no internet connection
  }) async {
    await Future<void>.delayed(duration);
    return getAppTestingFunction ??
        Right<String, ConnectivityModel>(
          connectivityModel.copyWith(
            internetSpeed: internetSpeed,
          ),
        );
  }
}
