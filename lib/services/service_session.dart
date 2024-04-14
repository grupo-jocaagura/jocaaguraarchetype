import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../providers/provider_session.dart';

class ServiceSession {
  const ServiceSession(this._providerSession);
  final ProviderSession _providerSession;

  UserModel get user => _providerSession.user;

  Future<Either<String, UserModel>> logInUserAndPassword(
    UserModel user,
    String password,
  ) =>
      logInUserAndPassword(user, password);
  Future<Either<String, UserModel>> logOutUser(UserModel user) =>
      logOutUser(user);
  Future<Either<String, UserModel>> signInUserAndPassword(
    UserModel user,
    String password,
  ) =>
      signInUserAndPassword(user, password);
  Future<Either<String, UserModel>> recoverPassword(UserModel user) =>
      recoverPassword(user);
  Future<Either<String, UserModel>> logInSilently(UserModel user) =>
      logInSilently(user);
}
