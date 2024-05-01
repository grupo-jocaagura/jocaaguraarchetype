import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaaguraarchetype/providers/provider_connectivity.dart';

class MockConnectivityProvider implements ProviderConnectivity {
  @override
  Future<Either<String, ConnectivityModel>> getConnectivityStatus(
    ConnectivityModel connectivityModel,
  ) async {
    return Right<String, ConnectivityModel>(
      connectivityModel,
    ); // Simula siempre una respuesta exitosa
  }
}
