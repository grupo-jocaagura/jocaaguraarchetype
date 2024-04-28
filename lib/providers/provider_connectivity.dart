import 'package:jocaagura_domain/jocaagura_domain.dart';

abstract class ProviderConnectivity extends EntityProvider {
  const ProviderConnectivity();
  Future<Either<String, ConnectivityModel>> getConnectivityStatus(
    ConnectivityModel connectivityModel,
  );
}
