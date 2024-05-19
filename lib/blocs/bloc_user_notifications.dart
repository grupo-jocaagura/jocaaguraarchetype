import 'dart:async';

import 'package:jocaagura_domain/jocaagura_domain.dart';

class BlocUserNotifications extends BlocModule {
  static const String name = 'blocUserNotifications';

  final BlocGeneral<String> _msgController = BlocGeneral<String>('');
  final Debouncer debouncer = Debouncer(
    milliseconds: 7000,
  );

  Stream<String> get toastStream => _msgController.stream;
  String get msg => _msgController.value;

  void clear() {
    _msgController.value = '';
  }

  void showToast(String message) {
    _msgController.value = message;
    debouncer.call(clear);
  }

  @override
  FutureOr<void> dispose() {
    _msgController.dispose();
  }
}
