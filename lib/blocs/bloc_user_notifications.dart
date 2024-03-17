import 'dart:async';

import '../jocaaguraarchetype.dart';

class BlocUserNotifications extends BlocModule {
  static const String name = 'blocUserNotifications';

  final BlocGeneral<String> _msgController = BlocGeneral<String>('');

  Stream<String> get toastStream => _msgController.stream;
  String get msg => _msgController.value;

  void clear() {
    _msgController.value = '';
  }

  void showToast(String message) {
    clear();
    if (message.isNotEmpty) {
      _msgController.value = message;
      Future<void>.delayed(
        const Duration(seconds: 7),
      ).then((void value) => clear());
    }
  }

  @override
  FutureOr<void> dispose() {
    _msgController.dispose();
  }
}
