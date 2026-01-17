part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class DisposableDebouncer {
  DisposableDebouncer({this.milliseconds = 500});

  final int milliseconds;
  Timer? _timer;
  bool _isDisposed = false;

  void call(void Function() action) {
    if (_isDisposed) {
      return;
    }
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      if (_isDisposed) {
        return;
      }
      action();
    });
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }
    _timer?.cancel();
    _timer = null;
    _isDisposed = true;
  }
}
