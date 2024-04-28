import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../mocks/mock_connectivity_provider.dart';
import '../mocks/mock_internet_provider.dart';
import '../mocks/mock_service_connectivity.dart'; // Importa las clases correctamente

void main() {
  group('BlocConnectivity Tests', () {
    late BlocConnectivity blocConnectivity;
    late MockServiceConnectivity mockServiceConnectivity;

    setUp(() {
      mockServiceConnectivity = MockServiceConnectivity(
        MockConnectivityProvider(),
        MockInternetProvider(),
        debouncer: Debouncer(milliseconds: 0),
      );
      blocConnectivity = BlocConnectivity(mockServiceConnectivity);
    });

    test('updateConnectivity should update connectivity status', () async {
      await blocConnectivity.updateConnectivity();
      expect(blocConnectivity.connectivityStatus.isRight, isTrue);

      blocConnectivity.connectivityStatus.fold(
        (String l) => fail('Expected a successful connectivity update'),
        (ConnectivityModel r) => expect(
          r.connectionType,
          ConnectionTypeEnum.none,
        ),
      );
    });

    test('updateInternetSpeed should update internet speed', () async {
      await blocConnectivity.updateInternetSpeed();
      expect(blocConnectivity.connectivityStatus.isRight, isTrue);

      blocConnectivity.connectivityStatus.fold(
        (String l) => fail('Expected a successful internet speed update'),
        (ConnectivityModel r) => expect(r.internetSpeed, 50.0),
      );
    });

    test(
        'updateConnectionStatus should update both connectivity and internet speed',
        () async {
      await blocConnectivity.updateConnectionStatus();
      expect(blocConnectivity.connectivityStatus.isRight, isTrue);

      blocConnectivity.connectivityStatus.fold(
        (String l) => fail('Expected a successful update'),
        (ConnectivityModel r) => expect(
          r.internetSpeed,
          50.0,
        ),
      );
    });

    test('connectivityStatusStream should emit updates', () async {
      final List<Matcher> expectedResults = <Matcher>[
        isA<Left<String, ConnectivityModel>>(), // Estado inicial
        isA<Right<String, ConnectivityModel>>(),
        isA<Right<String, ConnectivityModel>>(),
      ];

      expectLater(
        blocConnectivity.connectivityStatusStream,
        emitsInOrder(expectedResults),
      );

      blocConnectivity.updateConnectionStatus();
    });
    test('connectivityStatusStream should emit updates', () async {
      final List<Either<String, ConnectivityModel>> expectedResults =
          <Either<String, ConnectivityModel>>[
        Left<String, ConnectivityModel>('Initial State'),
        Right<String, ConnectivityModel>(
          const ConnectivityModel(
            connectionType: ConnectionTypeEnum.none,
            internetSpeed: 0.0,
          ),
        ),
        Right<String, ConnectivityModel>(
          const ConnectivityModel(
            connectionType: ConnectionTypeEnum.none,
            internetSpeed: 50.0,
          ),
        ),
      ];

      // Start listening to the stream right away
      final List<Either<String, ConnectivityModel>> emissions =
          <Either<String, ConnectivityModel>>[];
      final StreamSubscription<Either<String, ConnectivityModel>> subscription =
          blocConnectivity.connectivityStatusStream.listen(
        (Either<String, ConnectivityModel> result) => emissions.add(result),
      );

      // Trigger updates
      await blocConnectivity.updateConnectionStatus();
      await Future<void>.delayed(
        const Duration(
          seconds: 1,
        ),
      ); // Wait for all async operations to complete

      subscription.cancel(); // Stop listening to the stream

      // Check the emissions collected
      expect(emissions, equals(expectedResults));
    });
  });
}
