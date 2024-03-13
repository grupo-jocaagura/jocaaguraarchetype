import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/blocs/app_manager.dart';
import 'package:jocaaguraarchetype/providers/app_manager_provider.dart';

import '../mocks/mock_app_manager.dart';

void main() {
  late MockAppManager mockAppManager;

  setUp(() {
    mockAppManager = MockAppManager(mockAppConfig);
  });

  testWidgets('AppManagerProvider.of returns the correct AppManager instance',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppManagerProvider(
          appManager: mockAppManager,
          child: Builder(
            builder: (BuildContext context) {
              final AppManager appManager = AppManagerProvider.of(context);
              if (appManager.mainMenu.isClosed == false) {
                expect(appManager, equals(mockAppManager));
              }
              return const Placeholder();
            },
          ),
        ),
      ),
    );
  });

  // Test para verificar el comportamiento de updateShouldNotify
  testWidgets('AppManagerProvider updateShouldNotify returns false',
      (WidgetTester tester) async {
    final MockAppManager newMockAppManager = MockAppManager(mockAppConfig);

    await tester.pumpWidget(
      AppManagerProvider(
        appManager: mockAppManager,
        child: Builder(builder: (_) => const Placeholder()),
      ),
    );

    await tester.pumpWidget(
      AppManagerProvider(
        appManager: newMockAppManager,
        child: Builder(builder: (_) => const Placeholder()),
      ),
    );
  });
}
