import 'dart:math';

import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../providers/provider_session.dart';

/// A fake implementation of `ProviderSession` for testing session management.
///
/// The `FakeSessionProvider` class simulates session-related functionality such
/// as user login, logout, password recovery, and silent login. It is designed
/// to test session logic without relying on real authentication systems.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/fake_session_provider.dart';
///
/// void main() async {
///   final fakeSessionProvider = FakeSessionProvider();
///   final user = UserModel(email: 'test@example.com');
///
///   // Simulate user login
///   final loginResult = await fakeSessionProvider.logInUserAndPassword(
///     user,
///     '1234567890',
///   );
///
///   loginResult.fold(
///     (error) => print('Login Error: $error'),
///     (loggedInUser) => print('User Logged In: ${loggedInUser.email}'),
///   );
///
///   // Check session expiration
///   final sessionResult = await fakeSessionProvider.checkSessionExpired();
///   sessionResult.fold(
///     (error) => print('Session Error: $error'),
///     (activeUser) => print('Session Active for: ${activeUser.email}'),
///   );
/// }
/// ```
class FakeSessionProvider extends ProviderSession {
  /// Creates an instance of `FakeSessionProvider`.
  ///
  /// Initializes the last action time to the current time.
  FakeSessionProvider() : _lastActionTime = DateTime.now();

  /// Tracks the last action time for session expiration logic.
  DateTime _lastActionTime;

  /// Updates the last action time to the current time or a [testDateTime].
  ///
  /// ## Example
  ///
  /// ```dart
  /// fakeSessionProvider.updateLastActionTime();
  /// ```
  void updateLastActionTime([DateTime? testDateTime]) {
    _lastActionTime = testDateTime ?? DateTime.now();
  }

  /// Checks if the session is expired.
  ///
  /// A session is considered expired if the time since the last action
  /// exceeds a random interval between 5 and 20 minutes.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final isExpired = fakeSessionProvider.isSessionExpired;
  /// print('Session Expired: $isExpired');
  /// ```
  bool get isSessionExpired {
    return DateTime.now().difference(_lastActionTime).inMinutes >=
        Random().nextInt(10).clamp(5, 20);
  }

  /// The current user in the session.
  UserModel _user = defaultUserModel;

  @override
  UserModel get user {
    if (isSessionExpired == false) {
      logOutUser(_user);
      return _user;
    }
    updateLastActionTime();
    return _user;
  }

  /// Checks if the session is expired and updates the session accordingly.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await fakeSessionProvider.checkSessionExpired();
  /// result.fold(
  ///   (error) => print('Session Error: $error'),
  ///   (user) => print('Active User: ${user.email}'),
  /// );
  /// ```
  Future<Either<String, UserModel>> checkSessionExpired() async {
    if (isSessionExpired == false) {
      logOutUser(user);
      return logInSilently(user);
    }
    updateLastActionTime();
    return Future<Either<String, UserModel>>.value(
      Right<String, UserModel>(user),
    );
  }

  /// Simulates user login with email and password.
  ///
  /// Returns a valid `UserModel` on success or an error message on failure.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await fakeSessionProvider.logInUserAndPassword(
  ///   user,
  ///   '1234567890',
  /// );
  /// ```
  @override
  Future<Either<String, UserModel>> logInUserAndPassword(
    UserModel user,
    String password,
  ) async {
    await _randomDelay();
    if (user.email.contains('invalid')) {
      return Left<String, UserModel>('usuario invalido');
    } else if (password != '1234567890') {
      return Left<String, UserModel>('contraseña invalida');
    } else {
      _user = user.copyWith(
        jwt: <String, dynamic>{
          'token': 'valid_jwt_token',
        },
      );
      return Right<String, UserModel>(_user);
    }
  }

  /// Simulates logging out the user.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await fakeSessionProvider.logOutUser(user);
  /// ```
  @override
  Future<Either<String, UserModel>> logOutUser(UserModel user) async {
    await _randomDelay();
    _user = defaultUserModel;
    return Right<String, UserModel>(_user);
  }

  /// Simulates user registration with email and password.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await fakeSessionProvider.signInUserAndPassword(
  ///   user,
  ///   'password',
  /// );
  /// ```
  @override
  Future<Either<String, UserModel>> signInUserAndPassword(
    UserModel user,
    String password,
  ) async {
    await _randomDelay();
    if (user.email.contains('invalid')) {
      return Left<String, UserModel>('usuario invalido para registro');
    } else {
      _user = user.copyWith(jwt: <String, dynamic>{'token': 'valid_jwt_token'});
      return Right<String, UserModel>(_user);
    }
  }

  /// Simulates password recovery.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await fakeSessionProvider.recoverPassword(user);
  /// ```
  @override
  Future<Either<String, UserModel>> recoverPassword(UserModel user) async {
    await _randomDelay();
    if (user.email.contains('invalid')) {
      return Left<String, UserModel>('Usuario inexistente');
    } else {
      return Left<String, UserModel>(
        'correo de recuperacion enviado satisfactoriamente',
      );
    }
  }

  /// Simulates silent login for the user.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await fakeSessionProvider.logInSilently(user);
  /// ```
  @override
  Future<Either<String, UserModel>> logInSilently(UserModel user) async {
    await _randomDelay();
    final bool success = Random().nextBool();
    if (success) {
      _user = user.copyWith(
        jwt: <String, dynamic>{
          'token': 'valid_jwt_token',
        },
      );
      return Right<String, UserModel>(_user);
    } else {
      return Left<String, UserModel>('Inicio de sesión silencioso fallido');
    }
  }

  /// Validates a JWT token.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final isValid = fakeSessionProvider.validateJwt(jwt);
  /// ```
  bool validateJwt(Map<String, dynamic> jwt) {
    return jwt.isNotEmpty &&
        jwt.containsKey('token') &&
        jwt['token'] is String &&
        !jwt['token'].toString().contains('invalid');
  }

  /// Simulates a random delay to mimic network latency.
  Future<void> _randomDelay() async {
    await Future<void>.delayed(Duration(seconds: Random().nextInt(10) + 1));
  }

  @override
  bool get jwtValid => validateJwt(user.jwt);
}
