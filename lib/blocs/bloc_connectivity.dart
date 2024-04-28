import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../services/service_connectivity.dart';

class BlocConnectivity extends BlocModule {
  BlocConnectivity(this.serviceConnectivity);
  static const String name = 'blocConnectivity';
  final ServiceConnectivity serviceConnectivity;
  final BlocGeneral<Either<String, ConnectivityModel>> _connectivityBloc =
      BlocGeneral<Either<String, ConnectivityModel>>(
    Left<String, ConnectivityModel>('Initial State'),
  );

  Either<String, ConnectivityModel> get connectivityStatus =>
      _connectivityBloc.value;
  Stream<Either<String, ConnectivityModel>> get connectivityStatusStream =>
      _connectivityBloc.stream;

  Future<void> updateConnectivity() async {
    final ConnectivityModel connectivityModel = getConnectivityModel();
    _connectivityBloc.value =
        await serviceConnectivity.checkConnectivity(connectivityModel);
  }

  Future<void> updateInternetSpeed() async {
    final ConnectivityModel connectivityModel = getConnectivityModel();
    _connectivityBloc.value =
        await serviceConnectivity.checkInternetSpeed(connectivityModel);
  }

  Future<void> updateConnectionStatus() async {
    await updateConnectivity();
    await updateInternetSpeed();
  }

  ConnectivityModel getConnectivityModel() {
    return connectivityStatus.fold(
      (String p0) => defaultConnectivityModel,
      (ConnectivityModel p0) => p0,
    );
  }

  @override
  void dispose() {
    _connectivityBloc.dispose();
  }
}
