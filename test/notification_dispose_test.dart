import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  for (final Duration? duration in <Duration?>[
    null,
    const Duration(seconds: 3),
  ]) {
    final String window = duration == null ? 'default' : 'custom';

    testWidgets('AppManager disposal cancels a pending $window toast',
        (WidgetTester tester) async {
      final PageRegistry registry = PageRegistry(<String, PageWidgetBuilder>{});
      final AppManager manager = AppManager(AppConfig.dev(registry: registry));

      manager.notifications.showToast('Pending toast', duration: duration);
      await manager.dispose();
      await manager.dispose();

      expect(manager.notifications.isDisposed, isTrue);
      expect(manager.notifications.isClosed, isTrue);
      manager.notifications.showToast('Ignored', duration: duration);
      manager.notifications.clear();
    });

    testWidgets('clear cancels a pending $window toast and allows reuse',
        (WidgetTester tester) async {
      final BlocUserNotifications bloc = BlocUserNotifications();
      addTearDown(bloc.dispose);

      bloc.showToast('Cleared', duration: duration);
      bloc.clear();
      expect(bloc.toast.isEmpty, isTrue);

      bloc.showToast('Next', duration: const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(bloc.toast.isEmpty, isTrue);
    });
  }

  for (final bool firstCustom in <bool>[false, true]) {
    for (final bool nextCustom in <bool>[false, true]) {
      testWidgets(
          'Replacing a toast restarts its timer ($firstCustom -> $nextCustom)',
          (WidgetTester tester) async {
        final BlocUserNotifications bloc = BlocUserNotifications(
          autoClose: const Duration(seconds: 2),
        );
        addTearDown(bloc.dispose);

        bloc.showToast(
          'First',
          duration: firstCustom ? const Duration(seconds: 1) : null,
        );
        await tester.pump(const Duration(milliseconds: 500));
        bloc.showToast(
          'Next',
          duration: nextCustom ? const Duration(seconds: 3) : null,
        );

        await tester.pump(const Duration(milliseconds: 1500));
        expect(bloc.toast.text, 'Next');
        await tester.pump(Duration(milliseconds: nextCustom ? 1500 : 500));
        expect(bloc.toast.isEmpty, isTrue);
      });
    }
  }
}
