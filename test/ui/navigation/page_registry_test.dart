import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

PageModel _p(
  String name, {
  PageKind kind = PageKind.material,
  bool requiresAuth = false,
  List<String>? segments,
  Map<String, String>? query,
}) =>
    PageModel(
      name: name,
      segments: segments ?? <String>[name],
      query: query ?? const <String, String>{},
      kind: kind,
      requiresAuth: requiresAuth,
    );

Widget _txt(BuildContext _, PageModel page) => Text('pg:${page.name}');

void main() {
  group('PageRegistry.build()', () {
    test('usa el builder cuando el name existe', () {
      final PageRegistry reg = PageRegistry.fromDefs(<PageDef>[
        PageDef(model: _p('home'), builder: _txt),
      ]);

      final Widget w = reg.build(const _Ctx(), _p('home'));
      expect(w, isA<Text>());
      expect((w as Text).data, 'pg:home');
    });

    test('notFoundBuilder tiene prioridad cuando no existe el name', () {
      final PageRegistry reg = PageRegistry(
        <String, PageWidgetBuilder>{},
        notFoundBuilder: (_, __) => const Placeholder(key: Key('custom404')),
      );

      final Widget w = reg.build(const _Ctx(), _p('unknown'));
      expect(w.key, const Key('custom404'));
    });

    test('cuando defaultStack existe → devuelve widget de redirect', () {
      final NavStackModel fallback = NavStackModel.single(_p('home'));
      final PageRegistry reg = PageRegistry(
        <String, PageWidgetBuilder>{},
        defaultStack: fallback,
      );

      final Widget w = reg.build(const _Ctx(), _p('missing'));
      expect(w.runtimeType.toString(), contains('RegistryRedirect'));
    });

    test('cuando no hay notFound/defaults → devuelve 404 por defecto', () {
      const PageRegistry reg = PageRegistry(<String, PageWidgetBuilder>{});
      final Widget w = reg.build(const _Ctx(), _p('missing'));
      expect(w.runtimeType.toString(), contains('DefaultNotFoundPage'));
    });
  });

  group('PageRegistry.toPage()', () {
    test('material produce MaterialPage', () {
      const PageRegistry reg = PageRegistry(<String, PageWidgetBuilder>{
        'home': _txt,
      });
      final Page<dynamic> pg = reg.toPage(_p('home'));
      expect(pg, isA<MaterialPage<dynamic>>());
      expect(pg.name, 'home');
      expect(reg.contains('home'), isTrue);
      expect(pg.key, isA<ValueKey<String>>());
    });

    test('cupertino produce CupertinoPage', () {
      const PageRegistry reg = PageRegistry(<String, PageWidgetBuilder>{
        'ios': _txt,
      });
      final Page<dynamic> pg = reg.toPage(_p('ios', kind: PageKind.cupertino));
      expect(pg, isA<CupertinoPage<dynamic>>());
      expect(pg.name, 'ios');
    });

    test('fullScreenDialog produce MaterialPage(fullscreenDialog: true)', () {
      const PageRegistry reg = PageRegistry(<String, PageWidgetBuilder>{
        'fsd': _txt,
      });
      final MaterialPage<dynamic> pg =
          reg.toPage(_p('fsd', kind: PageKind.fullScreenDialog))
              as MaterialPage<dynamic>;
      expect(pg.fullscreenDialog, isTrue);
    });

    testWidgets('dialog produce DialogPage y crea DialogRoute',
        (WidgetTester tester) async {
      const PageRegistry reg = PageRegistry(<String, PageWidgetBuilder>{
        'dlg': _txt,
      });
      final Page<dynamic> pg = reg.toPage(_p('dlg', kind: PageKind.dialog));
      expect(pg, isA<DialogPage<dynamic>>());

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext ctx) {
              final Route<dynamic> r =
                  (pg as DialogPage<dynamic>).createRoute(ctx);
              expect(r, isA<DialogRoute<dynamic>>());
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });
}

/// BuildContext dummy para tests unitarios puros (sin árbol widgets).
class _Ctx implements BuildContext {
  const _Ctx();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
