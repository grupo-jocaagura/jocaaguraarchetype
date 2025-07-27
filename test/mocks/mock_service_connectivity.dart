import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaaguraarchetype/services/service_connectivity_plus.dart';

class MockServiceConnectivity extends ServiceConnectivityPlus {
  MockServiceConnectivity(
    super.connectivityProvider,
    super.internetProvider, {
    required super.debouncer,
  });

  @override
  Future<Either<String, ConnectivityModel>> checkConnectivity(
    ConnectivityModel connectivityModel,
  ) async {
    return Right<String, ConnectivityModel>(
      ConnectivityModel(
        connectionType: connectivityModel.connectionType,
        internetSpeed: connectivityModel.internetSpeed,
      ),
    );
  }

  @override
  Future<Either<String, ConnectivityModel>> checkInternetSpeed(
    ConnectivityModel connectivityModel,
  ) async {
    return Right<String, ConnectivityModel>(
      connectivityModel.copyWith(
        internetSpeed: 50.0,
      ),
    );
  }
}
