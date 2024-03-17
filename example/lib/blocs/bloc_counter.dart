import 'package:jocaaguraarchetype/entities/entity_bloc.dart';

class BlocCounter extends BlocModule {
  static const String name = 'blocModule';
  final BlocGeneral _counter = BlocGeneral<int>(0);

  void add([int val = 1]) {
    _counter.value = _counter.value + val;
  }

  Stream get counterStream => _counter.stream;
  int get value => _counter.value;
  @override
  void dispose() {
    _counter.dispose();
  }
}
