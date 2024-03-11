import 'dart:async';

// revisado 10/03/2024 author: @albertjjimenezp
class MockBlocGeneral<T> {
  MockBlocGeneral(this._value);
  final StreamController<T> _controller = StreamController<T>.broadcast();

  Stream<T> get stream => _controller.stream;

  T _value;
  T get value => _value;
  set value(T newValue) {
    _value = newValue;
    _controller.add(newValue);
  }

  void dispose() {
    _controller.close();
  }
}
