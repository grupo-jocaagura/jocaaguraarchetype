import 'package:jocaagura_domain/jocaagura_domain.dart';

class BlocCounter extends BlocModule {
  static const String name = 'blocCounter';
  final BlocGeneral<int> _counter = BlocGeneral<int>(0);

  void add([int val = 1]) {
    _counter.value = _counter.value + val;
  }

  void decrement([int val = 1]) {
    _counter.value = _counter.value - val;
  }

  void reset([int val = 0]) {
    if (val != _counter.value) {
      _counter.value = val;
    }
  }

  Stream<int> get counterStream => _counter.stream;
  int get value => _counter.value;

  @override
  String toString() {
    return 'Llevamos $value';
  }

  @override
  void dispose() {
    _counter.dispose();
  }
}
