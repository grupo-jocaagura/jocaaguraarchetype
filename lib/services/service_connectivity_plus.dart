import 'dart:async';

import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../providers/provider_connectivity.dart';
import '../providers/provider_internet.dart';

/// A service for managing connectivity and internet speed checks.
///
/// The `ServiceConnectivity` class provides methods to check the connectivity
/// status and measure internet speed using the provided connectivity and
/// internet providers. It uses a `Debouncer` to throttle repeated checks.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/service_connectivity_plus.dart';
/// import 'package:jocaaguraarchetype/provider_connectivity.dart';
/// import 'package:jocaaguraarchetype/provider_internet.dart';
/// import 'package:dartz/dartz.dart';
///
/// class MyConnectivityProvider extends ProviderConnectivity {
///   @override
///   Future<Either<String, ConnectivityModel>> getConnectivityStatus(
///       ConnectivityModel connectivityModel) async {
///     return Right(connectivityModel.copyWith(isConnected: true));
///   }
/// }
///
/// class MyInternetProvider extends ProviderInternet {
///   @override
///   Future<Either<String, ConnectivityModel>> getInternetSpeed(
///       ConnectivityModel connectivityModel) async {
///     return Right(connectivityModel.copyWith(speed: 50.0));
///   }
/// }
///
/// void main() async {
///   final serviceConnectivity = ServiceConnectivity(
///     MyConnectivityProvider(),
///     MyInternetProvider(),
///     debouncer: Debouncer(milliseconds: 500),
///   );
///
///   // Check connectivity
///   final connectivityResult = await serviceConnectivity.checkConnectivity(
///     ConnectivityModel(isConnected: false),
///   );
///
///   connectivityResult.fold(
///     (error) => print('Connectivity Error: $error'),
///     (status) => print('Is Connected: ${status.isConnected}'),
///   );
///
///   // Check internet speed
///   final speedResult = await serviceConnectivity.checkInternetSpeed(
///     ConnectivityModel(isConnected: true),
///   );
///
///   speedResult.fold(
///     (error) => print('Speed Error: $error'),
///     (status) => print('Internet Speed: ${status.speed} Mbps'),
///   );
/// }
/// ```
class ServiceConnectivityPlus {
  /// Creates an instance of `ServiceConnectivity`.
  ///
  /// Requires a [connectivityProvider] to check connectivity status,
  /// an [internetProvider] to measure internet speed, and a [debouncer]
  /// to throttle repeated checks.
  const ServiceConnectivityPlus(
    this.connectivityProvider,
    this.internetProvider, {
    required this.debouncer,
  });

  /// The provider used to check connectivity status.
  final ProviderConnectivity connectivityProvider;

  /// The provider used to measure internet speed.
  final ProviderInternet internetProvider;

  /// A debouncer to throttle repeated checks.
  final Debouncer debouncer;

  /// Checks the connectivity status using the provided [connectivityModel].
  ///
  /// Returns an `Either` type containing a `String` error message on the left
  /// or an updated `ConnectivityModel` on the right.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await serviceConnectivity.checkConnectivity(
  ///   ConnectivityModel(isConnected: false),
  /// );
  /// result.fold(
  ///   (error) => print('Connectivity Error: $error'),
  ///   (status) => print('Is Connected: ${status.isConnected}'),
  /// );
  /// ```
  Future<Either<String, ConnectivityModel>> checkConnectivity(
    ConnectivityModel connectivityModel,
  ) async {
    final Completer<Either<String, ConnectivityModel>> completer =
        Completer<Either<String, ConnectivityModel>>();
    debouncer.call(() async {
      final Either<String, ConnectivityModel> result =
          await connectivityProvider.getConnectivityStatus(connectivityModel);
      completer.complete(result);
    });
    return completer.future;
  }

  /// Measures the internet speed using the provided [connectivityModel].
  ///
  /// Returns an `Either` type containing a `String` error message on the left
  /// or an updated `ConnectivityModel` on the right.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await serviceConnectivity.checkInternetSpeed(
  ///   ConnectivityModel(isConnected: true),
  /// );
  /// result.fold(
  ///   (error) => print('Speed Error: $error'),
  ///   (status) => print('Internet Speed: ${status.speed} Mbps'),
  /// );
  /// ```
  Future<Either<String, ConnectivityModel>> checkInternetSpeed(
    ConnectivityModel connectivityModel,
  ) async {
    final Completer<Either<String, ConnectivityModel>> completer =
        Completer<Either<String, ConnectivityModel>>();
    debouncer.call(() async {
      final Either<String, ConnectivityModel> result =
          await internetProvider.getInternetSpeed(connectivityModel);
      completer.complete(result);
    });
    return completer.future;
  }
}
