import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:jocaaguraarchetype/services/service_connectivity.dart';

import '../mocks/mock_connectivity_provider.dart';
import '../mocks/mock_internet_provider.dart';

void main() {
  group('ServiceConnectivity Tests', () {
    late MockConnectivityProvider mockConnectivityProvider;
    late MockInternetProvider mockInternetProvider;
    late ServiceConnectivity serviceConnectivity;
    late Debouncer debouncer;

    setUp(() {
      mockConnectivityProvider = MockConnectivityProvider();
      mockInternetProvider = MockInternetProvider();
      debouncer = Debouncer(
          milliseconds:
              1000); // Utiliza un debouncer con 1 segundo de delay para pruebas
      serviceConnectivity = ServiceConnectivity(
        mockConnectivityProvider,
        mockInternetProvider,
        debouncer: debouncer,
      );
    });

    test('checkConnectivity returns correct result after debounce delay',
        () async {
      var connectivityModel = ConnectivityModel(
        connectionType: ConnectionTypeEnum.wifi,
        internetSpeed: 50.0,
      );
      // Simula la llamada y espera
      final future = serviceConnectivity.checkConnectivity(connectivityModel);
      await Future.delayed(
          Duration(milliseconds: 1100)); // Espera más que el debounce
      final result = await future;

      expect(result.isRight, isTrue);
      result.fold(
        (l) => fail('Expected a successful result'),
        (r) => expect(r.connectionType, ConnectionTypeEnum.wifi),
      );
    });

    test(
        'checkInternetSpeed returns updated internet speed after debounce delay',
        () async {
      var connectivityModel = ConnectivityModel(
        connectionType: ConnectionTypeEnum.mobile,
        internetSpeed: 20.0,
      );
      final future = serviceConnectivity.checkInternetSpeed(connectivityModel);
      await Future.delayed(
          Duration(milliseconds: 1100)); // Espera más que el debounce
      final result = await future;

      expect(result.isRight, isTrue);
      result.fold(
        (l) => fail('Expected a successful result'),
        (r) => expect(r.internetSpeed, 100.0),
      );
    });
  });
}
