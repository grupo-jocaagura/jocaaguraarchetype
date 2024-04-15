import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../providers/provider_session.dart';

class ServiceSession {
  const ServiceSession(this._providerSession);
  final ProviderSession _providerSession;

  UserModel get user => _providerSession.user;
  bool get isLogged => _providerSession.jwtValid;

  Future<Either<String, UserModel>> logInUserAndPassword(
    UserModel user,
    String password,
  ) =>
      _providerSession.logInUserAndPassword(user, password);
  Future<Either<String, UserModel>> logOutUser(UserModel user) =>
      _providerSession.logOutUser(user);
  Future<Either<String, UserModel>> signInUserAndPassword(
    UserModel user,
    String password,
  ) =>
      _providerSession.signInUserAndPassword(user, password);
  Future<Either<String, UserModel>> recoverPassword(UserModel user) =>
      _providerSession.recoverPassword(user);
  Future<Either<String, UserModel>> logInSilently(UserModel user) =>
      _providerSession.logInSilently(user);
}
