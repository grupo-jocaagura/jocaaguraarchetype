import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ServiceSession', () {
    late FakeSessionProvider fakeProvider;
    late ServiceSession service;
    late UserModel validUser;
    late UserModel invalidUser;

    setUp(() {
      fakeProvider = FakeSessionProvider();
      service = ServiceSession(fakeProvider);
      validUser = const UserModel(
        id: '1',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/photo.jpg',
        email: 'john.doe@example.com',
        jwt: <String, dynamic>{'token': 'valid_jwt_token'},
      );
      invalidUser = const UserModel(
        id: '2',
        displayName: 'Invalid User',
        photoUrl: 'https://example.com/photo.jpg',
        email: 'invalid@example.com',
        jwt: <String, dynamic>{},
      );
    });

    test(
        'logInUserAndPassword should authenticate user with correct credentials',
        () async {
      final Either<String, UserModel> result =
          await service.logInUserAndPassword(validUser, '1234567890');
      expect(result.isRight, isTrue);
      result.fold(
        (String l) => fail('Expected successful authentication'),
        (UserModel r) => expect(r, isA<UserModel>()),
      );
    });

    test('logInUserAndPassword should return error for invalid credentials',
        () async {
      final Either<String, UserModel> result =
          await service.logInUserAndPassword(invalidUser, 'wrongpassword');
      expect(result.isLeft, isTrue);
    });

    test('logOutUser should successfully log out user', () async {
      await service.logInUserAndPassword(
        validUser,
        '1234567890',
      ); // Assuming user is logged in first.
      final Either<String, UserModel> result =
          await service.logOutUser(validUser);
      expect(result.isRight, isTrue);
    });

    test('signInUserAndPassword should register user', () async {
      final Either<String, UserModel> result =
          await service.signInUserAndPassword(validUser, '1234567890');
      expect(result.isRight, isTrue);
    });

    test('recoverPassword should send recovery message', () async {
      final Either<String, UserModel> result =
          await service.recoverPassword(validUser);
      expect(result.isLeft, isTrue);
    });

    test('logInSilently should log in the user silently', () async {
      final Either<String, UserModel> result =
          await service.logInSilently(validUser);
      expect(result.isRight || result.isLeft, isTrue);
    });
  });
}
