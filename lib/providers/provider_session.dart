import 'package:jocaagura_domain/jocaagura_domain.dart';

abstract class ProviderSession extends EntityProvider {
  UserModel get user;
  bool get jwtValid;
  Future<Either<String, UserModel>> logInUserAndPassword(
    UserModel user,
    String password,
  );
  Future<Either<String, UserModel>> logOutUser(UserModel user);
  Future<Either<String, UserModel>> signInUserAndPassword(
    UserModel user,
    String password,
  );
  Future<Either<String, UserModel>> recoverPassword(UserModel user);
  Future<Either<String, UserModel>> logInSilently(UserModel user);
}
