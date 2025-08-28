import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Minimal counter BLoC without external deps.
class BlocCounter {
  final BlocGeneral<int> _c = BlocGeneral<int>(0);

  Stream<int> get stream => _c.stream;
  int get value => _c.value;

  void inc() {
    _c.value = value + 1;
  }

  void dec() {
    _c.value = value - 1;
  }

  void reset() {
    _c.value = 0;
  }

  void dispose() {
    _c.dispose();
  }
}
