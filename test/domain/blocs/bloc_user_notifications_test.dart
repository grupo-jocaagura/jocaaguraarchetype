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
  group('BlocUserNotifications · streams y debounce', () {
    test('stream emite ToastMessage al llamar showToast', () async {
      final BlocUserNotifications bloc = BlocUserNotifications();

      // Nos suscribimos filtrando vacíos para evitar el valor inicial empty().
      final Future<ToastMessage> firstNonEmpty =
          bloc.stream.firstWhere((ToastMessage t) => t.isNotEmpty);

      bloc.showToast('hola stream');

      final ToastMessage msg = await firstNonEmpty;
      expect(msg.text, 'hola stream');

      await bloc.dispose();
    });

    test(
        'distinctStream NO re-emite si llega el mismo mensaje en el mismo instante',
        () async {
      // Inyectamos un "reloj" fijo para que dos showToast queden con el MISMO timestamp.
      final DateTime fixedNow = DateTime(2025, 01, 21, 12);
      final BlocUserNotifications bloc = BlocUserNotifications(
        now: () => fixedNow,
      );

      final List<ToastMessage> received = <ToastMessage>[];
      final StreamSubscription<ToastMessage> sub =
          bloc.distinctStream.listen(received.add);

      // Mismo mensaje, misma marca de tiempo => el segundo se considera igual y no se emite.
      bloc.showToast('dup');
      bloc.showToast('dup');

      // Luego, mensaje diferente => sí emite.
      bloc.showToast('otro');

      // Esperamos a que la cola de microtareas procese las emisiones.
      await pumpEventQueue();

      expect(
        received.length,
        greaterThanOrEqualTo(2),
        reason: 'Debe emitir solo una vez "dup" y luego "otro"',
      );
      expect(received[0].text, '');
      expect(received[1].text, 'dup');
      expect(received[2].text, 'otro');

      await sub.cancel();
      await bloc.dispose();
    });

    test('showToast con duration usa Debouncer override y limpia el mensaje',
        () async {
      final BlocUserNotifications bloc = BlocUserNotifications();

      // Usamos una ventana muy corta para que el test sea veloz.
      bloc.showToast('auto-clear', duration: const Duration(milliseconds: 40));

      // Verificación inmediata: el mensaje está presente.
      expect(bloc.toast.text, 'auto-clear');

      // Esperamos (un poco más que la duration) y vaciamos la cola de eventos.
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await pumpEventQueue();

      // Debe haberse ejecutado clear() programado por el Debouncer override.
      expect(bloc.toast.isEmpty || bloc.toast.text.isEmpty, isTrue);

      await bloc.dispose();
    });

    test('textStream refleja únicamente el texto (sanity check auxiliar)',
        () async {
      final BlocUserNotifications bloc = BlocUserNotifications();
      final Future<String> firstText =
          bloc.textStream.firstWhere((String s) => s.isNotEmpty);

      bloc.showToast('solo texto');
      expect(await firstText, 'solo texto');

      await bloc.dispose();
    });
  });
}
