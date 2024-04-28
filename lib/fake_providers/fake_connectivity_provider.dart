import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../providers/provider_connectivity.dart';

class FakeConnectivityProvider implements ProviderConnectivity {
  const FakeConnectivityProvider({
    this.getAppTestingFunction,
  });
  final Either<String, ConnectivityModel>? getAppTestingFunction;

  @override
  Future<Either<String, ConnectivityModel>> getConnectivityStatus(
    ConnectivityModel connectivityModel, {
    Duration duration = const Duration(
      milliseconds: 500,
    ),
    ConnectionTypeEnum connectionType = ConnectionTypeEnum.wifi,
    bool connected = true,
  }) async {
    await Future<void>.delayed(duration);
    return getAppTestingFunction ??
        Right<String, ConnectivityModel>(
          connectivityModel.copyWith(
            connectionType: connectionType,
          ),
        );
  }
}
