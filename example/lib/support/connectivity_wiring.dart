import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Construye un [BlocConnectivity] usando un [FakeServiceConnectivity].
BlocConnectivity buildConnectivityBloc(FakeServiceConnectivity svc) {
  final RepositoryConnectivity repo = RepositoryConnectivityImpl(
    GatewayConnectivityImpl(
      svc,
      DefaultErrorMapper(),
    ),
  );
  return BlocConnectivity(
    watch: WatchConnectivityUseCase(repo),
    snapshot: GetConnectivitySnapshotUseCase(repo),
    checkType: CheckConnectivityTypeUseCase(repo),
    checkSpeed: CheckInternetSpeedUseCase(repo),
    initial: svc.current,
  );
}
