import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/entities/entity_bloc.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('RepeatLastValueExtension and Bloc', () {
    // Unit testing for RepeatLastValueExtension y Bloc
    late Bloc<int> bloc;
    late StreamController<int> controller;
    setUp(() {
      bloc = MockBloc<int>(0);
      controller = StreamController<int>();
    });

    tearDown(() {
      bloc.dispose();
      controller.close();
    });

    test('RepeatLastValueExtension', () {
      final Stream<int> stream = controller.stream.call(0);
      controller.sink.add(1);
      controller.sink.add(2);
      controller.sink.add(3);
      controller.sink.close();
      expect(
        stream,
        emitsInOrder(<int>[0, 1, 2, 3]),
      );
    });
    test('Bloc initial value', () {
      const int a = 0;
      expect(
        bloc.stream,
        emitsInOrder(<int>[a]),
      );

      expect(
        bloc.value,
        0,
      );
    });

    test('Bloc set value', () {
      final List<int> expectedValues = <int>[0, 1, 2, 3];

      expect(
        bloc.stream,
        emitsInOrder(expectedValues),
      );

      for (final int value in expectedValues.skip(1)) {
        bloc.value = value;
        expect(bloc.value, value);
      }
    });
  });
  group('BlocCore', () {
    late BlocCore<dynamic> blocCore;

    setUp(() {
      blocCore = BlocCore<dynamic>();
    });

    test('getBloc should throw an error when bloc is not initialized', () {
      expect(
        () => blocCore.getBloc('non_existing_bloc'),
        throwsA(isInstanceOf<UnimplementedError>()),
      );
    });

    test('throws exception when BlocModule is not initialized', () {
      expect(
        () => blocCore.getBloc<String>('key'),
        throwsA(isInstanceOf<UnimplementedError>()),
      );
    });

    test('addBlocGeneral should add the bloc to the injector', () {
      final BlocGeneral<int> blocGeneral = BlocGeneral<int>(0);
      blocGeneral.addFunctionToProcessTValueOnStream('test2', (int val) {
        if (kDebugMode) {
          print('the value times 2 is ${val * 2}');
        }
      });
      expect(blocGeneral.containsKeyFunction('test2'), true);
      blocGeneral.deleteFunctionToProcessTValueOnStream('test2');
      expect(blocGeneral.containsKeyFunction('test2'), false);
      blocCore.addBlocGeneral('test', blocGeneral);
      expect(blocCore.getBloc<int>('test'), blocGeneral);
      expect(blocCore.getBloc<int>('test').containsKeyFunction('test'), false);
      expect(blocCore.getBloc<int>('test').valueOrNull, equals(0));
      expect(blocCore.getBloc<int>('test').value, isNot(null));
      blocCore.dispose();
      Future<void>.delayed(const Duration(seconds: 2), () {
        expect(blocCore.isDisposed, true);
      });
    });

    test('addBlocModule should add the module to the moduleInjector', () {
      final MockBlocModule blocModule = MockBlocModule();
      blocCore.addBlocModule<BlocModule>('test', blocModule);
      expect(blocCore.getBlocModule<BlocModule>('test'), blocModule);
    });

    test(
        'deleteBlocGeneral should dispose the bloc and remove it from the injector',
        () {
      final BlocGeneral<int> blocGeneral = BlocGeneral<int>(0);
      blocCore.addBlocGeneral('test', blocGeneral);
      blocCore.deleteBlocGeneral('test');
      expect(
        () => blocCore.getBloc<int>('test'),
        throwsA(isInstanceOf<UnimplementedError>()),
      );
    });

    test(
        'deleteBlocModule should dispose the module and remove it from the moduleInjector',
        () {
      final MockBlocModule blocModule = MockBlocModule();
      blocCore.addBlocModule<BlocModule>('test', blocModule);
      blocCore.deleteBlocModule('test');
      expect(
        () => blocCore.getBlocModule<BlocModule>('test'),
        throwsA(isInstanceOf<UnimplementedError>()),
      );
    });

    test('dispose should dispose all the blocs and modules', () {
      final BlocGeneral<int> blocGeneral = BlocGeneral<int>(0);
      final MockBlocModule blocModule = MockBlocModule();
      blocCore.addBlocGeneral('test1', blocGeneral);
      blocCore.addBlocModule<BlocModule>('test2', blocModule);
      blocCore.dispose();
      Future<void>.delayed(const Duration(seconds: 2), () {
        expect(blocCore.isDisposed, isTrue);
      });
    });
  });

  group('BlocGeneral', () {
    late BlocGeneral<int> blocGeneral;

    setUp(() {
      blocGeneral = BlocGeneral<int>(0);
    });

    test(
        'addFunctionToProcessTValueOnStream should add the function to the _functionsMap',
        () {
      blocGeneral.addFunctionToProcessTValueOnStream('test', (int value) {
        if (kDebugMode) {
          print('value: $value');
        }
      });
      expect(blocGeneral.containsKeyFunction('test'), equals(true));
    });

    test(
        'deleteFunctionToProcessTValueOnStream should remove the function from the _functionsMap',
        () {
      blocGeneral.addFunctionToProcessTValueOnStream('test', (int value) {
        if (kDebugMode) {
          print('value: $value');
        }
      });
      blocGeneral.deleteFunctionToProcessTValueOnStream('test');
      expect(blocGeneral.containsKeyFunction('test'), equals(false));
    });
  });
}

class MockBloc<int> extends Bloc<int> {
  MockBloc(super.initialValue);
}

class MockBlocModule extends BlocModule {
  @override
  FutureOr<void> dispose() {}
}
