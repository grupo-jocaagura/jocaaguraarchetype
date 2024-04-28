import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../providers/provider_internet.dart';

class FakeInternetProvider implements ProviderInternet {
  const FakeInternetProvider({
    this.getAppTestingFunction,
  });
  final Either<String, ConnectivityModel>? getAppTestingFunction;
  @override
  Future<Either<String, ConnectivityModel>> getInternetSpeed(
    ConnectivityModel connectivityModel, {
    Duration duration = const Duration(
      milliseconds: 500,
    ),
    double internetSpeed = 10.0, // 0 no hay conexión a internet
  }) async {
    await Future<void>.delayed(duration);
    return getAppTestingFunction ??
        Right<String, ConnectivityModel>(
          connectivityModel.copyWith(
            internetSpeed: internetSpeed,
          ),
        );
  }
}
