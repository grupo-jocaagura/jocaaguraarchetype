import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/blocs/bloc_user_notifications.dart';

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
  });
}
