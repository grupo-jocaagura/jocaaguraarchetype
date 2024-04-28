import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('FakeConnectivityProvider Tests', () {
    late FakeConnectivityProvider provider;

    setUp(() {
      provider = const FakeConnectivityProvider();
    });

    test('should return WiFi connection when specified', () async {
      final Either<String, ConnectivityModel> result =
          await provider.getConnectivityStatus(
        defaultConnectivityModel,
      );
      expect(result.isRight, isTrue);
      result.fold(
        (String l) => fail('Expected a successful result'),
        (ConnectivityModel r) =>
            expect(r.connectionType, ConnectionTypeEnum.wifi),
      );
    });

    test('should return no connection when specified', () async {
      final Either<String, ConnectivityModel> result =
          await provider.getConnectivityStatus(
        defaultConnectivityModel,
        connectionType: ConnectionTypeEnum.none,
      );
      expect(result.isRight, isTrue);
      result.fold(
        (String l) => fail('Expected a successful result'),
        (ConnectivityModel r) =>
            expect(r.connectionType, ConnectionTypeEnum.none),
      );
    });

    test('should handle custom connectivity function if provided', () async {
      final FakeConnectivityProvider customProvider = FakeConnectivityProvider(
        getAppTestingFunction:
            Right<String, ConnectivityModel>(const ConnectivityModel(
          connectionType: ConnectionTypeEnum.mobile,
          internetSpeed: 100.0,
        )),
      );

      final Either<String, ConnectivityModel> result =
          await customProvider.getConnectivityStatus(defaultConnectivityModel);
      expect(result.isRight, isTrue);
      result.fold(
        (String l) => fail('Expected a successful result'),
        (ConnectivityModel r) {
          expect(r.connectionType, ConnectionTypeEnum.mobile);
          expect(r.internetSpeed, 100.0);
        },
      );
    });

    test('should simulate connectivity delay', () async {
      final DateTime startTime = DateTime.now();
      await provider.getConnectivityStatus(
        defaultConnectivityModel,
        duration: const Duration(seconds: 1),
      );
      final DateTime endTime = DateTime.now();
      expect(
          endTime.difference(startTime) >= const Duration(seconds: 1), isTrue);
    });
  });
}
