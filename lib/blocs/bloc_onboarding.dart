import 'dart:async';

import '../jocaaguraarchetype.dart';

class BlocOnboarding extends BlocModule {
  BlocOnboarding(this._blocOnboardingList, {int delayInSeconds = 1}) {
    execute(
      Duration(seconds: delayInSeconds),
    );
  }
  static const String name = 'onboardingBloc';
  final List<FutureOr<void> Function()> _blocOnboardingList;
  final BlocGeneral<String> _blocMsg = BlocGeneral<String>('Inicializando');

  Stream<String> get msgStream => _blocMsg.stream;

  int addFunction(FutureOr<void> Function() function) {
    _blocOnboardingList.add(function);
    return _blocOnboardingList.length;
  }

  Future<void> execute(Duration duration) async {
    await Future<void>.delayed(duration);
    final List<FutureOr<void> Function()> tmpList =
        List<FutureOr<void> Function()>.from(_blocOnboardingList);
    int length = tmpList.length;
    for (final FutureOr<void> Function() f in tmpList) {
      length--;
      await f();
      _blocMsg.value = '$length restantes';
    }
    _blocMsg.value = 'Onboarding completo';
  }

  String get msg => _blocMsg.value;

  @override
  FutureOr<void> dispose() {
    _blocMsg.dispose();
  }
}
