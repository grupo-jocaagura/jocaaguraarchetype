import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

Future<void> _flushMicrotasks() async {
  // Asegura que los listeners de stream procesen emisiones.
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  group('BlocSecondaryMenuDrawer', () {
    test('estado inicial vacío', () async {
      final BlocSecondaryMenuDrawer bloc = BlocSecondaryMenuDrawer();

      expect(bloc.listMenuOptions, isEmpty);

      // Primer valor que emite el stream debería ser lista vacía (si tu base emite snapshot inicial)
      // Si tu implementación no emite snapshot inicial, elimina esta sección.
      final List<List<ModelMainMenuModel>> first = <List<ModelMainMenuModel>>[];
      final StreamSubscription<List<ModelMainMenuModel>> sub =
          bloc.itemsStream.listen(first.add);

      await _flushMicrotasks();

      // Si tu stream arranca con snapshot, esto será true; si no, comenta la línea.
      if (first.isNotEmpty) {
        expect(first.first, isEmpty);
      }

      await sub.cancel();
    });

    test('addSecondaryMenuOption agrega y no duplica por label (upsert)',
        () async {
      final BlocSecondaryMenuDrawer bloc = BlocSecondaryMenuDrawer();

      // Observamos solo los tamaños para simplificar asserts de orden.
      final List<int> lengths = <int>[];
      final StreamSubscription<List<ModelMainMenuModel>> sub = bloc.itemsStream
          .listen((List<ModelMainMenuModel> e) => lengths.add(e.length));

      // 1) Agrega primer ítem
      bloc.addSecondaryMenuOption(
        onPressed: () {},
        label: 'settings',
        iconData: Icons.settings,
        description: 'config',
      );
      await _flushMicrotasks();

      expect(bloc.listMenuOptions.length, 1);
      expect(
        bloc.listMenuOptions
            .firstWhere((ModelMainMenuModel m) => m.label == 'settings'),
        isA<ModelMainMenuModel>(),
      );

      // 2) Upsert: mismo label, debería reemplazar/actualizar y NO duplicar
      bloc.addSecondaryMenuOption(
        onPressed: () {},
        label: 'settings',
        iconData: Icons.settings_outlined,
        description: 'config-updated',
      );
      await _flushMicrotasks();

      expect(bloc.listMenuOptions.length, 1); // no duplica
      // Si tu modelo expone description, puedes validar actualización:
      // final ModelMainMenuModel item = bloc.listMenuOptions.singleWhere((m) => m.label == 'settings');
      // expect(item.description, 'config-updated');

      await sub.cancel();

      // lengths debería haber reflejado 1 al menos una vez. Si tu stream emite snapshot inicial,
      // la secuencia podría ser [0, 1, 1]; si no, [1, 1]. Validamos al menos el ">= 1".
      expect(lengths.where((int e) => e == 1).isNotEmpty, isTrue);
    });

    test('removeSecondaryMenuOption elimina por label', () async {
      final BlocSecondaryMenuDrawer bloc = BlocSecondaryMenuDrawer();

      bloc.addSecondaryMenuOption(
        onPressed: () {},
        label: 'help',
        iconData: Icons.help,
      );
      bloc.addSecondaryMenuOption(
        onPressed: () {},
        label: 'about',
        iconData: Icons.info,
      );
      await _flushMicrotasks();

      expect(
        bloc.listMenuOptions.map((ModelMainMenuModel e) => e.label),
        containsAll(<String>['help', 'about']),
      );

      bloc.removeSecondaryMenuOption('help');
      await _flushMicrotasks();

      expect(
        bloc.listMenuOptions.map((ModelMainMenuModel e) => e.label),
        isNot(contains('help')),
      );
      expect(
        bloc.listMenuOptions.map((ModelMainMenuModel e) => e.label),
        contains('about'),
      );
    });

    test('clearSecondaryDrawer limpia todas las opciones', () async {
      final BlocSecondaryMenuDrawer bloc = BlocSecondaryMenuDrawer();

      bloc.addSecondaryMenuOption(
        onPressed: () {},
        label: 'a',
        iconData: Icons.adb,
      );
      bloc.addSecondaryMenuOption(
        onPressed: () {},
        label: 'b',
        iconData: Icons.backup,
      );
      await _flushMicrotasks();

      expect(bloc.listMenuOptions, isNotEmpty);

      bloc.clearSecondaryDrawer();
      await _flushMicrotasks();

      expect(bloc.listMenuOptions, isEmpty);
    });

    test('stream emite en orden esperado al agregar múltiples', () async {
      final BlocSecondaryMenuDrawer bloc = BlocSecondaryMenuDrawer();

      // Mapeamos el stream a longitudes para validar la secuencia de tamaños
      final Stream<int> sizes =
          bloc.itemsStream.map((List<ModelMainMenuModel> e) => e.length);

      // Esperamos que, tras dos adds, pase por 1 y luego 2 (puede anteceder 0 si emite snapshot inicial)
      final Future<void> expectation = expectLater(
        sizes,
        emitsInOrder(<Matcher>[
          // opcional: predicate que acepte 0 o 1 primero, según tu implementación
          anyOf(equals(0), equals(1)),
          anyOf(equals(1), equals(2)),
          equals(2),
        ]),
      );

      bloc.addSecondaryMenuOption(
        onPressed: () {},
        label: 'x',
        iconData: Icons.clear,
      );
      await _flushMicrotasks();
      bloc.addSecondaryMenuOption(
        onPressed: () {},
        label: 'y',
        iconData: Icons.face,
      );
      await _flushMicrotasks();

      await expectation;
    });

    test('aliases deprecated delegan al API actual', () async {
      final BlocSecondaryMenuDrawer bloc = BlocSecondaryMenuDrawer();

      // addMainMenuOption -> addSecondaryMenuOption
      // ignore: deprecated_member_use_from_same_package
      bloc.addMainMenuOption(
        onPressed: () {},
        label: 'legacy',
        iconData: Icons.hdr_auto,
      );
      await _flushMicrotasks();
      expect(
        bloc.listMenuOptions.map((ModelMainMenuModel e) => e.label),
        contains('legacy'),
      );

      // removeMainMenuOption -> removeSecondaryMenuOption
      // ignore: deprecated_member_use_from_same_package
      bloc.removeMainMenuOption('legacy');
      await _flushMicrotasks();
      expect(
        bloc.listMenuOptions.map((ModelMainMenuModel e) => e.label),
        isNot(contains('legacy')),
      );

      // clearMainDrawer -> clearSecondaryDrawer
      // ignore: deprecated_member_use_from_same_package
      bloc.addSecondaryMenuOption(
        onPressed: () {},
        label: 'keep',
        iconData: Icons.abc,
      );
      await _flushMicrotasks();
      // ignore: deprecated_member_use_from_same_package
      bloc.clearMainDrawer();
      await _flushMicrotasks();
      expect(bloc.listMenuOptions, isEmpty);
    });
  });
  group('BlocMenuBase lifecycle', () {
    test('disposed is initially false', () {
      final BlocSecondaryMenuDrawer bloc = BlocSecondaryMenuDrawer();
      expect(bloc.disposed, isFalse);
    });

    test('disposed becomes true after dispose()', () {
      final BlocSecondaryMenuDrawer bloc = BlocSecondaryMenuDrawer();
      bloc.dispose();
      expect(bloc.disposed, isTrue);
    });

    test('calling dispose() twice keeps disposed true and safe', () {
      final BlocSecondaryMenuDrawer bloc = BlocSecondaryMenuDrawer();
      bloc.dispose();
      bloc.dispose(); // segunda llamada
      expect(bloc.disposed, isTrue);
    });

    test('isClosed reflects the same as disposed', () {
      final BlocSecondaryMenuDrawer bloc = BlocSecondaryMenuDrawer();
      expect(bloc.isClosed, isFalse);

      bloc.dispose();
      expect(bloc.isClosed, isTrue);
      expect(bloc.isClosed, bloc.disposed);
    });
  });
}
