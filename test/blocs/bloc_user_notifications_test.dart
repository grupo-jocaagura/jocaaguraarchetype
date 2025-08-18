import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('BlocUserNotifications', () {
    late BlocUserNotifications bloc;

    setUp(() {
      bloc = BlocUserNotifications();
    });

    tearDown(() async {
      await Future<void>.delayed(const Duration(seconds: 10));
      bloc.dispose();
    });

    test('Initial value of toastStream is empty', () {
      expect(bloc.toastStream, emits(''));
    });

    test('toastStream emits correct message when showToast is called', () {
      const String message = 'This is a toast message';

      bloc.showToast(message);

      expect(bloc.toastStream, emits(message));
    });

    test('toastStream emits empty message after 7 seconds', () async {
      const String message = 'This is a toast message';

      bloc.showToast(message);

      await Future<void>.delayed(const Duration(seconds: 7));

      expect(bloc.toastStream, emits(''));
    });

    test('msg returns current message value', () {
      const String message = 'This is a toast message';

      bloc.showToast(message);

      expect(bloc.msg, equals(message));
    });

    test('clear method clears the message', () {
      const String message = 'This is a toast message';

      bloc.showToast(message);

      expect(bloc.msg, equals(message));

      bloc.clear();

      expect(bloc.msg, equals(''));
    });

    test('showToast should emit message and clear after 7 seconds', () async {
      final List<String> expectedResults = <String>[
        '', // Valor por defecto del Stream
        'Hello, World!',
        '', // Después de 7 segundos
      ];

      expectLater(
        bloc.toastStream,
        emitsInOrder(expectedResults),
      );

      bloc.showToast('Hello, World!');
      await Future<void>.delayed(
        const Duration(seconds: 8),
      ); // Espera más de 7 segundos para verificar el clear
    });

    test('showToast should reset timer if called before clear', () async {
      final List<String> expectedResults = <String>[
        '',
        'First Message',
        'Second Message',
        '', // Después de 7 segundos del segundo mensaje
      ];

      expectLater(
        bloc.toastStream,
        emitsInOrder(expectedResults),
      );

      bloc.showToast('First Message');
      await Future<void>.delayed(
        const Duration(seconds: 3),
      ); // Espera 3 segundos
      bloc.showToast('Second Message'); // Reinicia el temporizador
      await Future<void>.delayed(
        const Duration(seconds: 8),
      ); // Espera más de 7 segundos desde el segundo mensaje
    });
  });
}
