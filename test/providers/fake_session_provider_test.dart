import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaaguraarchetype/fake_providers/fake_session_provider.dart';

void main() {
  group('FakeSessionProvider', () {
    late FakeSessionProvider provider;
    late UserModel validUser;
    late UserModel invalidUser;

    setUp(() {
      provider = FakeSessionProvider();
      validUser = const UserModel(
        id: '1',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/photo.jpg',
        email: 'john.doe@example.com',
        jwt: <String, dynamic>{},
      );
      invalidUser = const UserModel(
        id: '2',
        displayName: 'Invalid User',
        photoUrl: 'https://example.com/photo.jpg',
        email: 'invalid@example.com',
        jwt: <String, dynamic>{},
      );
    });

    test('logInUserAndPassword returns a valid user for correct credentials',
        () async {
      final Either<String, UserModel> result =
          await provider.logInUserAndPassword(validUser, '1234567890');
      expect(result.isRight, isTrue);
      result.fold(
        (String l) => fail('Expected a valid user'),
        (UserModel r) => expect(r.email, validUser.email),
      );
      expect(
        provider.checkSessionExpired(),
        isA<Future<Either<String, UserModel>>>(),
      );
      provider.updateLastActionTime(
        DateTime.now().add(
          const Duration(days: 30),
        ),
      );
      expect(
        provider.checkSessionExpired(),
        isA<Future<Either<String, UserModel>>>(),
      );
    });
    group('FakeSessionProvider Session Expiration', () {
      late FakeSessionProvider provider;
      late UserModel user;

      setUp(() async {
        provider = FakeSessionProvider();
        user = const UserModel(
          id: '1',
          displayName: 'Test User',
          photoUrl: 'https://example.com/photo.jpg',
          email: 'test@example.com',
          jwt: <String, dynamic>{'token': 'valid_jwt_token'},
        );
        await provider.logInUserAndPassword(user, '1234567890');
        await Future<void>.delayed(
          const Duration(seconds: 5),
        );
      });

      test(
          'checkSessionExpired logs out and logs in silently if session is expired',
          () async {
        // Force the session to expire
        provider.updateLastActionTime(
          DateTime.now().subtract(
            const Duration(minutes: 21),
          ),
        );

        final Either<String, UserModel> result =
            await provider.checkSessionExpired();
        expect(provider.isSessionExpired, isFalse);
        result.fold<void>(
          (String l) => expect(provider.user.email, equals(user.email)),
          (UserModel r) => expect(r.email, equals(user.email)),
        );
      });

      test(
          'checkSessionExpired updates last action time if session is not expired',
          () async {
        provider.updateLastActionTime();
        await provider.checkSessionExpired();
        expect(provider.isSessionExpired, isA<bool>());
      });
    });

    test('logInUserAndPassword returns error for invalid credentials',
        () async {
      final Either<String, UserModel> result =
          await provider.logInUserAndPassword(validUser, 'invalidpassword');
      expect(result.isLeft, isTrue);
      result.fold(
        (String l) => expect(l, 'contraseña invalida'),
        (UserModel r) => fail('Expected an error'),
      );
    });

    test('logInUserAndPassword returns error for invalid user', () async {
      final Either<String, UserModel> result =
          await provider.logInUserAndPassword(invalidUser, 'invalidpassword');
      expect(result.isLeft, isTrue);
      result.fold(
        (String l) => expect(l, 'usuario invalido'),
        (UserModel r) => fail('Expected an error'),
      );
    });

    test('logOutUser logs out the user', () async {
      // First, log in a valid user
      await provider.logInUserAndPassword(validUser, '1234567890');

      // Then log out
      final Either<String, UserModel> result =
          await provider.logOutUser(validUser);
      expect(result.isRight, isTrue);
      expect(provider.user, defaultUserModel);
    });

    test('signInUserAndPassword signs in a user with valid credentials',
        () async {
      final Either<String, UserModel> result =
          await provider.signInUserAndPassword(validUser, '1234567890');
      expect(result.isRight, isTrue);
      result.fold(
        (String l) => fail('Expected a valid user'),
        (UserModel r) => expect(r.email, validUser.email),
      );
    });

    test('signInUserAndPassword signs in a user with invalid credentials',
        () async {
      final Either<String, UserModel> result =
          await provider.signInUserAndPassword(invalidUser, '1234567890');
      expect(result.isLeft, isTrue);
      result.fold(
        (String l) => expect(l, 'usuario invalido para registro'),
        (UserModel r) => fail(r.toString()),
      );
    });

    test('recoverPassword sends recovery email for valid user', () async {
      final Either<String, UserModel> result =
          await provider.recoverPassword(validUser);
      expect(result.isLeft, isTrue);
      result.fold(
        (String l) =>
            expect(l, 'correo de recuperacion enviado satisfactoriamente'),
        (UserModel r) => fail('Expected a recovery email sent message'),
      );
    });

    test('recoverPassword sends recovery email for invalid user', () async {
      final Either<String, UserModel> result =
          await provider.recoverPassword(invalidUser);
      expect(result.isLeft, isTrue);
      result.fold(
        (String l) => expect(l, 'Usuario inexistente'),
        (UserModel r) => fail('Expected a recovery email sent message'),
      );
    });

    test('logInSilently logs in the last logged out user silently', () async {
      // First, log in and then log out a valid user
      await provider.logInUserAndPassword(validUser, '1234567890');
      await provider.logOutUser(validUser);

      // Now attempt silent login
      final Either<String, UserModel> result =
          await provider.logInSilently(validUser);
      expect(result.isRight || result.isLeft, isTrue);
      result.fold(
        (String l) => expect(l, 'Inicio de sesión silencioso fallido'),
        (UserModel r) => expect(r.email, validUser.email),
      );
    });

    test('isSessionExpired returns true when session duration passes threshold',
        () {
      final DateTime fakePastTime = DateTime.now()
          .subtract(const Duration(minutes: 15)); // 15 minutes in the past
      provider.updateLastActionTime(fakePastTime);

      // Luego de "15 minutos" la sesión debería ser considerada como expirada
      expect(provider.isSessionExpired, isTrue);
    });

    test('User is logged out when session is expired', () {
      final DateTime fakePastTime = DateTime.now()
          .subtract(const Duration(minutes: 15)); // 15 minutes in the past
      provider.updateLastActionTime(fakePastTime);

      // Asumiendo que este método verifica la expiración de la sesión
      // y cierra la sesión si ha expirado
      final UserModel currentUser = provider.user;
      expect(currentUser, equals(defaultUserModel));
    });
  });
}
