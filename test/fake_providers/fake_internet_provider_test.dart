import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('FakeInternetProvider Tests', () {
    late FakeInternetProvider provider;

    setUp(() {
      provider = const FakeInternetProvider();
    });

    test('should return the specified internet speed', () async {
      const ConnectivityModel connectivityModel = ConnectivityModel(
        connectionType: ConnectionTypeEnum.wifi,
        internetSpeed: 0.0, // Velocidad inicial
      );
      final Either<String, ConnectivityModel> result =
          await provider.getInternetSpeed(
        connectivityModel,
        internetSpeed: 20.0, // Simular 20 Mbps
      );
      expect(result.isRight, isTrue);
      result.fold(
        (String l) => fail('Expected a successful result'),
        (ConnectivityModel r) => expect(r.internetSpeed, 20.0),
      );
    });

    test('should handle no internet connection when speed is 0', () async {
      const ConnectivityModel connectivityModel = ConnectivityModel(
        connectionType: ConnectionTypeEnum.mobile,
        internetSpeed: 5.0,
      );
      final Either<String, ConnectivityModel> result =
          await provider.getInternetSpeed(
        connectivityModel,
        internetSpeed: 0.0, // No hay conexión
      );
      expect(result.isRight, isTrue);
      result.fold(
        (String l) => fail('Expected a successful result'),
        (ConnectivityModel r) => expect(r.internetSpeed, 0.0),
      );
    });

    test('should handle custom internet speed function if provided', () async {
      final FakeInternetProvider customProvider = FakeInternetProvider(
        getAppTestingFunction: Right<String, ConnectivityModel>(
          const ConnectivityModel(
            connectionType: ConnectionTypeEnum.wifi,
            internetSpeed: 50.0, // Simular 50 Mbps
          ),
        ),
      );

      const ConnectivityModel connectivityModel = ConnectivityModel(
        connectionType: ConnectionTypeEnum.mobile,
        internetSpeed: 5.0,
      );
      final Either<String, ConnectivityModel> result =
          await customProvider.getInternetSpeed(connectivityModel);
      expect(result.isRight, isTrue);
      result.fold(
        (String l) => fail('Expected a successful result'),
        (ConnectivityModel r) => expect(r.internetSpeed, 50.0),
      );
    });

    test('should simulate internet speed delay', () async {
      const ConnectivityModel connectivityModel = ConnectivityModel(
        connectionType: ConnectionTypeEnum.wifi,
        internetSpeed: 10.0,
      );
      final DateTime startTime = DateTime.now();
      await provider.getInternetSpeed(
        connectivityModel,
        duration: const Duration(seconds: 1), // Simular un retraso de 1 segundo
      );
      final DateTime endTime = DateTime.now();
      expect(
        endTime.difference(startTime) >= const Duration(seconds: 1),
        isTrue,
      );
    });
  });
}
