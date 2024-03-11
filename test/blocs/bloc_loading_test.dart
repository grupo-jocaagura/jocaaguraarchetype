import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/blocs/bloc_loading.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('BlocLoading', () {
    late BlocLoading bloc;

    setUp(() {
      // Configuración inicial antes de cada prueba
      bloc = BlocLoading();
    });

    test('clearLoading should clear the loadingMsg', () {
      bloc.loadingMsg = 'Loading in progress...';
      bloc.clearLoading();
      expect(bloc.loadingMsg, '');
    });

    test(
        'loadingMsgWithFuture should set loadingMsg and clear it after completion',
        () async {
      const String msg = 'Loading in progress...';
      bool isFCompleted = false;

      await bloc.loadingMsgWithFuture(msg, () async {
        // Simulamos una tarea asíncrona
        await Future<void>.delayed(const Duration(seconds: 1));
        isFCompleted = true;
      });

      expect(bloc.loadingMsg, '');
      expect(isFCompleted, true);
    });

    test('loadingMsgWithFuture should not set loadingMsg if it is not empty',
        () async {
      bloc.loadingMsg = 'Loading in progress...';
      bool isFCompleted = false;
      bloc.clearLoading();
      bloc.loadingMsgWithFuture('Another loading...', () async {
        await Future<void>.delayed(const Duration(seconds: 1));
        isFCompleted = true;
      });

      expect(bloc.loadingMsg, 'Another loading...');
      await Future<void>.delayed(
        const Duration(seconds: 1),
      );
      expect(bloc.loadingMsg, '');
      expect(isFCompleted, true);
    });
  });

  group('BlocLoading', () {
    late BlocLoading blocLoading;

    setUp(() {
      blocLoading = BlocLoading();
    });

    tearDown(() {
      blocLoading.dispose();
    });

    test('Initial loading message is empty', () {
      expect(blocLoading.loadingMsg, '');
    });

    test('Setting loading message updates the value', () {
      blocLoading.loadingMsg = 'Loading...';
      expect(blocLoading.loadingMsg, 'Loading...');
    });

    testWidgets('Stream emits correct loading message',
        (WidgetTester tester) async {
      const String expectedMessage = 'Loading...';
      String emittedMessage = '';

      final StreamSubscription<String> subscription =
          blocLoading.loadingMsgStream.listen((String message) {
        emittedMessage = message;
      });

      blocLoading.loadingMsg = expectedMessage;
      await tester.pump();
      expect(emittedMessage, expectedMessage);

      subscription.cancel();
    });
  });
}
