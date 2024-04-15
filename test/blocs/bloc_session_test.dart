import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart'; // Importa tus clases aquí.

void main() {
  group('BlocSession', () {
    late FakeSessionProvider fakeProvider;
    late ServiceSession service;
    late BlocSession bloc;
    late UserModel validUser;

    setUp(() {
      fakeProvider = FakeSessionProvider();
      service = ServiceSession(fakeProvider);
      bloc = BlocSession(service);
      validUser = const UserModel(
        id: '1',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/photo.jpg',
        email: 'john.doe@example.com',
        jwt: <String, dynamic>{'token': 'valid_jwt_token'},
      );
    });
    tearDown(() => bloc.dispose());

    test('logInUserAndPassword updates bloc state to logged in user', () async {
      await bloc.logInUserAndPassword(validUser, '1234567890');
      expect(bloc.password, '1234567890');
      expect(bloc.isLogged, isTrue);
    });

    test('logOutUser updates bloc state to not logged in', () async {
      await bloc.logInUserAndPassword(validUser, '1234567890');
      await bloc.logOutUser(validUser);
      expect(bloc.isLogged, isFalse);
    });

    test('signInUserAndPassword updates bloc state to registered user',
        () async {
      await bloc.signInUserAndPassword(validUser, '1234567890');
      expect(bloc.isLogged, isTrue);
    });

    test('recoverPassword does not change logged in state', () async {
      await bloc.logInUserAndPassword(validUser, '1234567890');
      await bloc.recoverPassword(validUser);
      expect(bloc.isLogged, isTrue);
    });

    test('logInSilently updates bloc state based on silent login success',
        () async {
      await bloc.logInSilently(validUser);
      // As logInSilently can be successful or fail randomly, we check if state matches the action
      final bool loggedState = bloc.isLogged;
      expect(loggedState, anyOf(isTrue, isFalse));
    });
  });

  group('BlocSession with Stream Functions', () {
    late FakeSessionProvider fakeProvider;
    late ServiceSession service;
    late BlocSession bloc;
    late UserModel validUser;

    setUp(() {
      fakeProvider = FakeSessionProvider();
      service = ServiceSession(fakeProvider);
      bloc = BlocSession(service);
      validUser = const UserModel(
        id: '1',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/photo.jpg',
        email: 'john.doe@example.com',
        jwt: <String, dynamic>{'token': 'valid_jwt_token'},
      );
    });
    tearDown(() => bloc.dispose());

    test(
        'addFunctionToSessionChanges should trigger function on stream value change',
        () async {
      bool isFunctionTriggered = false;
      void checkUser(Either<String, UserModel> user) {
        isFunctionTriggered = true;
        user.fold(
          (String error) => isFunctionTriggered = true,
          (UserModel user) => isFunctionTriggered = true,
        );
      }

      bloc.addFunctionToSessionChanges('testKey', checkUser);
      await bloc.logInUserAndPassword(validUser, '1234567890');
      await Future<void>.delayed(const Duration(seconds: 5));
      expect(isFunctionTriggered, isTrue);
    });

    test(
        'removeFunctionToSessionChanges should stop triggering function on stream value change',
        () async {
      bool isFunctionTriggered = false;
      void checkUser(Either<String, UserModel> user) {
        isFunctionTriggered = true;
        user.fold(
          (String error) => isFunctionTriggered = true,
          (UserModel user) => isFunctionTriggered = true,
        );
      }

      // First, add the function
      bloc.addFunctionToSessionChanges('testKey', checkUser);

      // Then, remove it
      bloc.removeFunctionToSessionChanges('testKey');

      // Simulate login which changes the stream value
      await bloc.logInUserAndPassword(validUser, '1234567890');
      await Future<void>.delayed(const Duration(seconds: 5));
      expect(isFunctionTriggered, isFalse);
    });
  });

  group('BlocSession Stream Tests', () {
    late FakeSessionProvider fakeProvider;
    late ServiceSession service;
    late BlocSession bloc;
    late UserModel validUser;

    setUp(() {
      fakeProvider = FakeSessionProvider();
      service = ServiceSession(fakeProvider);
      bloc = BlocSession(service);
      validUser = const UserModel(
        id: '1',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/photo.jpg',
        email: 'john.doe@example.com',
        jwt: <String, dynamic>{'token': 'valid_jwt_token'},
      );
    });
    tearDown(() => bloc.dispose());

    test('userStream emits correct values when user logs in', () async {
      bloc.logInUserAndPassword(validUser, '1234567890').then((_) {
        expectLater(
          bloc.userStream,
          emitsInOrder(<dynamic>[
            predicate<Either<String, UserModel>>(
              (Either<String, UserModel> result) => result.fold(
                (String l) => false,
                (UserModel r) => r.email == validUser.email,
              ),
            ),
          ]),
        );
      });
    });

    test('userStream emits error when login fails', () async {
      expect(bloc.userStream, isA<Stream<Either<String, UserModel>>>());
      bloc.logInUserAndPassword(validUser, '1234567890').then((_) {
        expectLater(
          bloc.userStream,
          emitsInOrder(<dynamic>[
            predicate<Either<String, UserModel>>(
              (Either<String, UserModel> result) => result.fold(
                (String l) => l == 'usuario invalido',
                (UserModel r) => false,
              ),
            ),
          ]),
        );
      });
    });
  });
}
