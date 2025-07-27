import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../providers/provider_session.dart';

/// A service for managing user sessions.
///
/// The `ServiceSession` class acts as a wrapper around `ProviderSession`, providing
/// an interface for session-related operations such as login, logout, and password recovery.
/// It simplifies interaction with the underlying provider.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/service_session_plus.dart';
/// import 'package:jocaaguraarchetype/provider_session.dart';
/// import 'package:dartz/dartz.dart';
///
/// void main() async {
///   final providerSession = MySessionProvider();
///   final serviceSession = ServiceSession(providerSession);
///
///   // Simulate user login
///   final user = UserModel(email: 'test@example.com');
///   final result = await serviceSession.logInUserAndPassword(user, '123456');
///
///   result.fold(
///     (error) => print('Login Error: $error'),
///     (loggedInUser) => print('User Logged In: ${loggedInUser.email}'),
///   );
/// }
/// ```
class ServiceSessionPlus {
  /// Creates an instance of `ServiceSession`.
  ///
  /// The [ProviderSession] instance is injected to delegate session-related operations.
  const ServiceSessionPlus(this._providerSession);

  /// The underlying `ProviderSession` instance.
  final ProviderSession _providerSession;

  /// Retrieves the current user in the session.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final user = serviceSession.user;
  /// print('Current User: ${user.email}');
  /// ```
  UserModel get user => _providerSession.user;

  /// Checks whether the user is logged in.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final isLoggedIn = serviceSession.isLogged;
  /// print('Is Logged In: $isLoggedIn');
  /// ```
  bool get isLogged => _providerSession.jwtValid;

  /// Logs in a user with their email and password.
  ///
  /// - [user]: The `UserModel` representing the user.
  /// - [password]: The user's password.
  ///
  /// Returns an `Either` type with an error message on the left or a `UserModel` on the right.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await serviceSession.logInUserAndPassword(user, 'password');
  /// result.fold(
  ///   (error) => print('Login Error: $error'),
  ///   (loggedInUser) => print('Logged In: ${loggedInUser.email}'),
  /// );
  /// ```
  Future<Either<String, UserModel>> logInUserAndPassword(
    UserModel user,
    String password,
  ) =>
      _providerSession.logInUserAndPassword(user, password);

  /// Logs out the current user.
  ///
  /// - [user]: The `UserModel` representing the user to log out.
  ///
  /// Returns an `Either` type with an error message on the left or a `UserModel` on the right.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await serviceSession.logOutUser(user);
  /// ```
  Future<Either<String, UserModel>> logOutUser(UserModel user) =>
      _providerSession.logOutUser(user);

  /// Registers a new user with email and password.
  ///
  /// - [user]: The `UserModel` representing the user.
  /// - [password]: The user's password.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await serviceSession.signInUserAndPassword(user, 'password');
  /// ```
  Future<Either<String, UserModel>> signInUserAndPassword(
    UserModel user,
    String password,
  ) =>
      _providerSession.signInUserAndPassword(user, password);

  /// Recovers the password for the user.
  ///
  /// - [user]: The `UserModel` representing the user.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await serviceSession.recoverPassword(user);
  /// ```
  Future<Either<String, UserModel>> recoverPassword(UserModel user) =>
      _providerSession.recoverPassword(user);

  /// Logs in the user silently.
  ///
  /// - [user]: The `UserModel` representing the user.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await serviceSession.logInSilently(user);
  /// ```
  Future<Either<String, UserModel>> logInSilently(UserModel user) =>
      _providerSession.logInSilently(user);
}
