import 'package:jocaagura_domain/jocaagura_domain.dart';

/// An abstract provider for managing user sessions.
///
/// The `ProviderSession` class defines the contract for handling session-related
/// functionality such as login, logout, password recovery, and silent login.
/// It ensures a consistent API for session management across implementations.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/provider_session.dart';
/// import 'package:dartz/dartz.dart';
///
/// class MySessionProvider extends ProviderSession {
///   @override
///   UserModel get user => UserModel(email: 'test@example.com');
///
///   @override
///   bool get jwtValid => true; // Simulate a valid JWT
///
///   @override
///   Future<Either<String, UserModel>> logInUserAndPassword(
///       UserModel user, String password) async {
///     // Simulate login logic
///     if (password == '123456') {
///       return Right(user.copyWith(jwt: {'token': 'valid_jwt_token'}));
///     } else {
///       return Left('Invalid password');
///     }
///   }
///
///   @override
///   Future<Either<String, UserModel>> logOutUser(UserModel user) async {
///     // Simulate logout logic
///     return Right(user.copyWith(jwt: {}));
///   }
///
///   @override
///   Future<Either<String, UserModel>> signInUserAndPassword(
///       UserModel user, String password) async {
///     // Simulate registration logic
///     return Right(user.copyWith(jwt: {'token': 'new_jwt_token'}));
///   }
///
///   @override
///   Future<Either<String, UserModel>> recoverPassword(UserModel user) async {
///     // Simulate password recovery logic
///     return Left('Password recovery email sent');
///   }
///
///   @override
///   Future<Either<String, UserModel>> logInSilently(UserModel user) async {
///     // Simulate silent login logic
///     return Right(user.copyWith(jwt: {'token': 'valid_jwt_token'}));
///   }
/// }
/// ```
abstract class ProviderSession extends EntityProvider {
  /// Retrieves the current user in the session.
  UserModel get user;

  /// Indicates whether the current JWT token is valid.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final isValid = providerSession.jwtValid;
  /// ```
  bool get jwtValid;

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
  /// final result = await providerSession.logInUserAndPassword(user, 'password');
  /// result.fold(
  ///   (error) => print('Login Error: $error'),
  ///   (loggedInUser) => print('Logged In: ${loggedInUser.email}'),
  /// );
  /// ```
  Future<Either<String, UserModel>> logInUserAndPassword(
    UserModel user,
    String password,
  );

  /// Logs out the current user.
  ///
  /// - [user]: The `UserModel` representing the user to log out.
  ///
  /// Returns an `Either` type with an error message on the left or a `UserModel` on the right.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await providerSession.logOutUser(user);
  /// result.fold(
  ///   (error) => print('Logout Error: $error'),
  ///   (loggedOutUser) => print('Logged Out: ${loggedOutUser.email}'),
  /// );
  /// ```
  Future<Either<String, UserModel>> logOutUser(UserModel user);

  /// Registers a new user with email and password.
  ///
  /// - [user]: The `UserModel` representing the user.
  /// - [password]: The user's password.
  ///
  /// Returns an `Either` type with an error message on the left or a `UserModel` on the right.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await providerSession.signInUserAndPassword(user, 'password');
  /// ```
  Future<Either<String, UserModel>> signInUserAndPassword(
    UserModel user,
    String password,
  );

  /// Recovers the password for the user.
  ///
  /// - [user]: The `UserModel` representing the user.
  ///
  /// Returns an `Either` type with an error message on the left or a `UserModel` on the right.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await providerSession.recoverPassword(user);
  /// result.fold(
  ///   (error) => print('Recovery Error: $error'),
  ///   (message) => print('Recovery Message: $message'),
  /// );
  /// ```
  Future<Either<String, UserModel>> recoverPassword(UserModel user);

  /// Logs in the user silently.
  ///
  /// - [user]: The `UserModel` representing the user.
  ///
  /// Returns an `Either` type with an error message on the left or a `UserModel` on the right.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await providerSession.logInSilently(user);
  /// ```
  Future<Either<String, UserModel>> logInSilently(UserModel user);
}
