import 'dart:async';

import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../providers/provider_connectivity.dart';
import '../providers/provider_internet.dart';

class ServiceConnectivity {
  const ServiceConnectivity(
    this.connectivityProvider,
    this.internetProvider, {
    required this.debouncer,
  });
  final ProviderConnectivity connectivityProvider;
  final ProviderInternet internetProvider;
  final Debouncer debouncer;

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
