import 'dart:async';

import '../entities/entity_bloc.dart';

class BlocLoading extends BlocModule {
  final BlocGeneral<String> _loadingController = BlocGeneral<String>('');

  static const String name = 'blocLoading';
  Stream<String> get loadingMsgStream => _loadingController.stream;
  String get loadingMsg => _loadingController.value;

  set loadingMsg(String val) {
    _loadingController.value = val;
  }

  void clearLoading() {
    loadingMsg = '';
  }

  Future<void> loadingMsgWithFuture(
    String msg,
    FutureOr<void> Function() f,
  ) async {
    if (loadingMsg.isEmpty) {
      loadingMsg = msg;
      await f();
      clearLoading();
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
  }
}
