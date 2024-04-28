import 'package:jocaagura_domain/jocaagura_domain.dart';

abstract class ProviderInternet implements EntityProvider {
  const ProviderInternet();
  Future<Either<String, ConnectivityModel>> getInternetSpeed(
    ConnectivityModel connectivityModel,
  );
}
