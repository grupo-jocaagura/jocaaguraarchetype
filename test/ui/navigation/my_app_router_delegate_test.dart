import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

PageModel _p(String name, {PageKind kind = PageKind.material}) => PageModel(
      name: name,
      segments: <String>[name],
      kind: kind,
    );

// Builder simple: muestra el name plano.
Widget _w(BuildContext _, PageModel page) => Text(page.name);

Widget _host(MyAppRouterDelegate del) => AnimatedBuilder(
      animation: del,
      builder: (BuildContext ctx, _) => del.build(ctx),
    );

void main() {
  group('MyAppRouterDelegate.build()', () {
    testWidgets('projectorMode=false: materializa todas las pages del stack',
        (WidgetTester tester) async {
      const PageRegistry reg = PageRegistry(<String, PageWidgetBuilder>{
        'home': _w,
        'profile': _w,
      });

      final PageManager pm = PageManager(
        initial: NavStackModel(<PageModel>[_p('home'), _p('profile')]),
      );

      final MyAppRouterDelegate del = MyAppRouterDelegate(
        registry: reg,
        pageManager: pm,
      );

      await tester.pumpWidget(MaterialApp(home: _host(del)));
      await tester.pumpAndSettle();

      // 'home' está offstage (no visible), así que skipOffstage: false
      expect(find.text('home', skipOffstage: false), findsOneWidget);
      expect(find.text('profile', skipOffstage: false), findsOneWidget);

      pm.dispose();
    });

    testWidgets('projectorMode=true: sólo renderiza el top del stack',
        (WidgetTester tester) async {
      const PageRegistry reg = PageRegistry(<String, PageWidgetBuilder>{
        'home': _w,
        'profile': _w,
      });

      final PageManager pm = PageManager(
        initial: NavStackModel(<PageModel>[_p('home'), _p('profile')]),
      );

      final MyAppRouterDelegate del = MyAppRouterDelegate(
        registry: reg,
        pageManager: pm,
        projectorMode: true,
      );

      await tester.pumpWidget(MaterialApp(home: _host(del)));
      await tester.pumpAndSettle();

      expect(find.text('home', skipOffstage: false), findsNothing);
      expect(find.text('profile', skipOffstage: false), findsOneWidget);

      pm.dispose();
    });
  });

  group('MyAppRouterDelegate acciones', () {
    test('push/pop delegan en PageManager', () {
      const PageRegistry reg = PageRegistry(
        <String, PageWidgetBuilder>{'home': _w, 'a': _w, 'b': _w},
      );
      final PageManager pm = PageManager(
        initial: NavStackModel.single(_p('home')),
      );
      final MyAppRouterDelegate del = MyAppRouterDelegate(
        registry: reg,
        pageManager: pm,
      );

      expect(pm.historyNames, <String>['home']);

      del.push(_p('a'));
      del.push(_p('b'));
      expect(pm.historyNames, <String>['home', 'a', 'b']);

      final bool popped = del.pop();
      expect(popped, isTrue);
      expect(pm.historyNames, <String>['home', 'a']);
      expect(del.currentConfiguration.pages.isNotEmpty, isTrue);
      del.popRoute();
      expect(popped, isTrue);
      expect(pm.historyNames, <String>[
        'home',
      ]);

      pm.dispose();
      del.dispose();
      expect(
        del.isDisposed,
        isTrue,
      );
    });

    test('setNewRoutePath sustituye el stack completo', () async {
      const PageRegistry reg = PageRegistry(
        <String, PageWidgetBuilder>{'home': _w, 'x': _w, 'y': _w},
      );
      final PageManager pm = PageManager(
        initial: NavStackModel.single(_p('home')),
      );
      final MyAppRouterDelegate del = MyAppRouterDelegate(
        registry: reg,
        pageManager: pm,
      );

      final NavStackModel next = NavStackModel(<PageModel>[_p('x'), _p('y')]);
      await del.setNewRoutePath(next);

      expect(pm.historyNames, <String>['x', 'y']);

      pm.dispose();
    });
  });
}
