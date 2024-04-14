import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../jocaaguraarchetype.dart';
import '../services/service_session.dart';

class BlocSession extends BlocModule {
  BlocSession(this._serviceSession);
  final ServiceSession _serviceSession;
  final BlocGeneral<Either<String, UserModel>> _blocSession =
      BlocGeneral<Either<String, UserModel>>(Left<String, UserModel>(''));

  final BlocGeneral<String> _password = BlocGeneral<String>('');

  String get password => _password.value;

  bool get isLogged {
    return _blocSession.value.fold(
      (_) => false,
      (UserModel user) => user.jwt.isNotEmpty,
    );
  }

  Stream<Either<String, UserModel>> get userStream => _blocSession.stream;

  Future<void> logInUserAndPassword(UserModel user) async {
    _blocSession.value = await _serviceSession.logInUserAndPassword(
      user,
      password,
    );
  }

  Future<void> logOutUser(UserModel user) async {
    _blocSession.value = await _serviceSession.logOutUser(user);
  }

  Future<void> signInUserAndPassword(UserModel user) async {
    _blocSession.value = await _serviceSession.signInUserAndPassword(
      user,
      password,
    );
  }

  Future<void> recoverPassword(UserModel user) async {
    _blocSession.value = await _serviceSession.recoverPassword(user);
  }

  Future<void> logInSilently(UserModel user) async {
    _blocSession.value = await _serviceSession.logInSilently(user);
  }

  void addFunctionToSessionChanges(
    String key,
    void Function(Either<String, UserModel>) onchangeSessionFunction,
  ) {
    _blocSession.addFunctionToProcessTValueOnStream(
      key,
      onchangeSessionFunction,
    );
  }

  void removeFunctionToSessionChanges(String key) {
    _blocSession.deleteFunctionToProcessTValueOnStream(key);
  }

  @override
  void dispose() {
    _blocSession.dispose();
    _password.dispose();
  }
}
