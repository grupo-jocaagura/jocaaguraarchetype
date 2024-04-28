import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaaguraarchetype/providers/provider_internet.dart';

class MockInternetProvider implements ProviderInternet {
  @override
  Future<Either<String, ConnectivityModel>> getInternetSpeed(
    ConnectivityModel connectivityModel,
  ) async {
    return Right<String, ConnectivityModel>(
      connectivityModel.copyWith(
        internetSpeed: 100.0,
      ),
    );
  }
}
