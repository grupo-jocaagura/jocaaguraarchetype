import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('JocaaguraApp user back integration', () {
    testWidgets(
        'Given JocaaguraApp with a policy When PageAppBar requests back Then consult policy and update it on the same delegate',
        (WidgetTester tester) async {
      final List<UserBackNavigationSource> sources =
          <UserBackNavigationSource>[];
      final ValueNotifier<bool> flutterCanPop = ValueNotifier<bool>(true);
      addTearDown(flutterCanPop.dispose);
      final PageRegistry registry = PageRegistry(<String, PageWidgetBuilder>{
        for (final String name in <String>['home', 'details'])
          name: (BuildContext context, PageModel page) {
            final AbstractAppManager app = context.appManager;
            app.responsive.setSizeFromContext(context);
            return ValueListenableBuilder<bool>(
              valueListenable: flutterCanPop,
              builder: (_, bool canPop, __) => PopScope<dynamic>(
                canPop: canPop,
                child: Scaffold(
                  appBar: PageAppBar(
                    app: app,
                    responsive: app.responsive,
                    hasDrawer: false,
                    label: 'App back',
                  ),
                  body: Text(page.name),
                ),
              ),
            );
          },
      });
      final AppManager app = AppManager(AppConfig.dev(registry: registry));
      addTearDown(app.dispose);
      app.pageManager.setStack(
        NavStackModel(const <PageModel>[
          PageModel(name: 'home', segments: <String>['home']),
          PageModel(name: 'details', segments: <String>['details']),
        ]),
      );
      Future<void> mount(UserBackNavigationPolicy? policy) async {
        await tester.pumpWidget(
          JocaaguraApp(
            appManager: app,
            registry: registry,
            initialLocation: '/details',
            userBackNavigationPolicy: policy,
          ),
        );
        await tester.pumpAndSettle();
      }

      await mount((UserBackNavigationRequest request) {
        sources.add(request.source);
        return false;
      });
      final MyAppRouterDelegate delegate =
          Router.of(tester.element(find.byType(PageAppBar))).routerDelegate
              as MyAppRouterDelegate;
      await tester.tap(find.byTooltip('App back'));
      await tester.pumpAndSettle();
      expect(
        sources,
        <UserBackNavigationSource>[UserBackNavigationSource.appBar],
      );
      expect(app.pageManager.historyNames, <String>['home', 'details']);
      int approvals = 0;
      await mount((_) {
        approvals++;
        return true;
      });
      expect(
        identical(
          Router.of(tester.element(find.byType(PageAppBar))).routerDelegate,
          delegate,
        ),
        isTrue,
      );
      flutterCanPop.value = false;
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('App back'));
      await tester.pumpAndSettle();
      expect(approvals, 0);
      expect(app.pageManager.historyNames, <String>['home', 'details']);
      flutterCanPop.value = true;
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('App back'));
      await tester.pumpAndSettle();
      expect(app.pageManager.historyNames, <String>['home']);
      expect(approvals, 1);
      await mount(null);
      expect(delegate.userBackNavigationPolicy, isNull);
    });
  });
}
