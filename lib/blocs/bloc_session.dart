import '../jocaaguraarchetype.dart';

class BlocSession extends BlocModule {
  BlocSession(this._serviceSession);
  static const String name = 'blocSession';
  final ServiceSession _serviceSession;
  final BlocGeneral<Either<String, UserModel>> _blocSession =
      BlocGeneral<Either<String, UserModel>>(Left<String, UserModel>(''));

  final BlocGeneral<String> _password = BlocGeneral<String>('');

  String get password => _password.value;

  bool get isLogged => _serviceSession.isLogged;

  Stream<Either<String, UserModel>> get userStream => _blocSession.stream;

  Future<void> logInUserAndPassword(UserModel user, String password) async {
    _password.value = password;
    _blocSession.value = await _serviceSession.logInUserAndPassword(
      user,
      password,
    );
  }

  Future<void> logOutUser(UserModel user) async {
    _password.value = '';
    _blocSession.value = await _serviceSession.logOutUser(user);
  }

  Future<void> signInUserAndPassword(UserModel user, String password) async {
    _password.value = password;
    _blocSession.value = await _serviceSession.signInUserAndPassword(
      user,
      password,
    );
  }

  Future<void> recoverPassword(UserModel user) async {
    _password.value = '';
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
    _blocSession.deleteFunctionToProcessTValueOnStream(key.toLowerCase());
  }

  @override
  void dispose() {
    _blocSession.dispose();
    _password.dispose();
  }
}
