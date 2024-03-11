import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/blocs/bloc_onboarding.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('BlocOnboarding', () {
    late BlocOnboarding blocOnboarding;
    late StreamSubscription<String> subscription;

    setUp(() {
      blocOnboarding =
          BlocOnboarding(<FutureOr<void> Function()>[], delayInSeconds: 0);
    });

    tearDown(() {
      subscription.cancel();
    });

    test('execute should call the functions in blocOnboardingList', () async {
      final List<String> messages = <String>[];
      subscription = blocOnboarding.msgStream.listen((String message) {
        messages.add(message);
      });
      bool function1Called = false;
      bool function2Called = false;
      blocOnboarding.addFunction(() async {
        function1Called = true;
      });
      blocOnboarding.addFunction(() async {
        function2Called = true;
      });

      await blocOnboarding.execute(Duration.zero);

      expect(function1Called, isTrue);
      expect(function2Called, isTrue);
    });

    test('execute should update msg value', () async {
      blocOnboarding.addFunction(() async {});
      blocOnboarding.addFunction(() async {});

      final List<String> messages = <String>[];
      subscription = blocOnboarding.msgStream.listen((String message) {
        messages.add(message);
      });

      await blocOnboarding.execute(Duration.zero);

      expect(
        messages,
        <String>[
          'Inicializando',
          '1 restantes',
          '0 restantes',
          'Onboarding completo',
          '1 restantes',
        ],
      );
      expect(blocOnboarding.msg, 'Onboarding completo');
      blocOnboarding.dispose();
    });

    // Add more tests to cover other methods and edge cases
  });
}
