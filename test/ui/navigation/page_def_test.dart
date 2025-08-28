import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

PageModel _p(String name) => PageModel(
      name: name,
      segments: <String>[name],
    );

void main() {
  group('PageDef', () {
    test('guarda model y builder y los expone tal cual', () {
      final PageModel m = _p('home');
      final PageDef def = PageDef(
        model: m,
        builder: (_, __) => const SizedBox.shrink(),
      );

      expect(def.model, same(m));
      expect(def.builder, isNotNull);
      final Widget w = def.builder(
        const _DummyContext(),
        m,
      );
      expect(w, isA<SizedBox>());
    });
  });
}

/// BuildContext mínimo para ejecutar el builder sin un árbol Material.
class _DummyContext implements BuildContext {
  const _DummyContext();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
