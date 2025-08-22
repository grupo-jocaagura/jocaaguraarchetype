class ExampleConnectivity {
  ExampleConnectivity._();
  static final ExampleConnectivity instance = ExampleConnectivity._();
  bool _online = true;

  Future<bool> checkNow() async => _online;
  void setOnline(bool v) {
    if (v != _online) {
      _online = v;
    }
  }

  Stream<bool> stream() async* {
    yield _online;
  }
}

class ExampleAuth {
  ExampleAuth._();
  static final ExampleAuth instance = ExampleAuth._();
  bool _logged = false;

  Future<bool> ensureInitializedAndCheck() async => _logged;
  void setLoggedIn(bool v) {
    if (v != _logged) {
      _logged = v;
    }
  }
}
