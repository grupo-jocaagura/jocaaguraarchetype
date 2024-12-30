import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaaguraarchetype/providers/provider_internet.dart';

class MockProviderInternet implements ProviderInternet {
  late Future<Either<String, ConnectivityModel>> Function(ConnectivityModel)
      mockGetInternetSpeed;

  @override
  Future<Either<String, ConnectivityModel>> getInternetSpeed(
    ConnectivityModel connectivityModel,
  ) {
    return mockGetInternetSpeed(connectivityModel);
  }
}

void main() {
  group('ProviderInternet Tests', () {
    late MockProviderInternet mockProviderInternet;
    late ConnectivityModel testModel;

    setUp(() {
      mockProviderInternet = MockProviderInternet();
      testModel = const ConnectivityModel(
        connectionType: ConnectionTypeEnum.wifi,
        internetSpeed: 0.0,
      );
    });

    test('Should return ConnectivityModel with updated speed when successful',
        () async {
      // Arrange
      final ConnectivityModel updatedModel =
          testModel.copyWith(internetSpeed: 50.0);
      final Right<String, ConnectivityModel> expectedResult =
          Right<String, ConnectivityModel>(updatedModel);

      mockProviderInternet.mockGetInternetSpeed =
          (ConnectivityModel connectivityModel) async => expectedResult;

      // Act
      final Either<String, ConnectivityModel> result =
          await mockProviderInternet.getInternetSpeed(testModel);

      // Assert
      expect(result, expectedResult);
    });

    test('Should return error message when speed measurement fails', () async {
      // Arrange
      const String errorMessage = 'Failed to measure internet speed';
      final Left<String, ConnectivityModel> expectedResult =
          Left<String, ConnectivityModel>(errorMessage);

      mockProviderInternet.mockGetInternetSpeed =
          (ConnectivityModel connectivityModel) async => expectedResult;

      // Act
      final Either<String, ConnectivityModel> result =
          await mockProviderInternet.getInternetSpeed(testModel);

      // Assert
      expect(result, expectedResult);
    });
  });
}
