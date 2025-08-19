import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('BlocUserNotifications', () {
    test('showToast emite y luego auto-clear por duración', () async {
      final BlocUserNotifications bloc = BlocUserNotifications(
        autoClose: const Duration(milliseconds: 20),
      );

      final List<String> emissions = <String>[];
      final StreamSubscription<String> sub =
          bloc.toastStream.listen(emissions.add);

      bloc.showToast('Hello');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(bloc.msg, 'Hello');

      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(bloc.msg, isEmpty);

      await sub.cancel();
      await bloc.dispose();
    });

    test('clear limpia inmediatamente', () async {
      final BlocUserNotifications bloc = BlocUserNotifications(
        autoClose: const Duration(seconds: 1),
      );
      bloc.showToast('Ping');
      expect(bloc.msg, 'Ping');

      bloc.clear();
      expect(bloc.msg, isEmpty);

      await bloc.dispose();
    });

    test('dispose cierra recursos', () async {
      final BlocUserNotifications bloc = BlocUserNotifications();
      await bloc.dispose();
      expect(bloc.isClosed, true);
      await bloc.dispose();
    });
  });
}
