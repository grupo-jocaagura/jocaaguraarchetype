import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaaguraarchetype/providers/provider_connectivity.dart';

class MockProviderConnectivity implements ProviderConnectivity {
  late Future<Either<String, ConnectivityModel>> Function(ConnectivityModel)
      mockGetConnectivityStatus;

  @override
  Future<Either<String, ConnectivityModel>> getConnectivityStatus(
    ConnectivityModel connectivityModel,
  ) {
    return mockGetConnectivityStatus(connectivityModel);
  }
}

void main() {
  group('ProviderConnectivity Tests', () {
    late MockProviderConnectivity mockProviderConnectivity;
    late ConnectivityModel testModel;

    setUp(() {
      mockProviderConnectivity = MockProviderConnectivity();
      testModel = const ConnectivityModel(
        connectionType: ConnectionTypeEnum.wifi,
        internetSpeed: 100.0,
      );
    });

    test('Should return ConnectivityModel when connectivity is successful',
        () async {
      // Arrange
      final Right<String, ConnectivityModel> expectedResult =
          Right<String, ConnectivityModel>(testModel);

      mockProviderConnectivity.mockGetConnectivityStatus =
          (ConnectivityModel connectivityModel) async => expectedResult;

      // Act
      final Either<String, ConnectivityModel> result =
          await mockProviderConnectivity.getConnectivityStatus(testModel);

      // Assert
      expect(result, expectedResult);
    });

    test('Should return error message when connectivity fails', () async {
      // Arrange
      const String errorMessage = 'No connectivity';
      final Left<String, ConnectivityModel> expectedResult =
          Left<String, ConnectivityModel>(errorMessage);

      mockProviderConnectivity.mockGetConnectivityStatus =
          (ConnectivityModel connectivityModel) async => expectedResult;

      // Act
      final Either<String, ConnectivityModel> result =
          await mockProviderConnectivity.getConnectivityStatus(testModel);

      // Assert
      expect(result, expectedResult);
    });
  });
}
