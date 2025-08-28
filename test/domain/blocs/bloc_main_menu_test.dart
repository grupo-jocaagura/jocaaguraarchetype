import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('BlocMainMenuDrawer', () {
    late BlocMainMenuDrawer bloc;

    setUp(() {
      bloc = BlocMainMenuDrawer();
    });

    tearDown(() {
      bloc.dispose();
    });

    test('inicial: lista vacía e inmutable', () {
      expect(bloc.listMenuOptions, isEmpty);

      // 🔧 Invocar la funcion para que efectivamente intente mutar
      expect(
        () => bloc.listMenuOptions.add(
          ModelMainMenuModel(
            onPressed: () {},
            label: 'X',
            iconData: Icons.close,
          ),
        ),
        throwsA(isA<UnsupportedError>()), // o: throwsUnsupportedError
      );
    });

    test('addMainMenuOption → agrega y emite lista', () async {
      final List<List<ModelMainMenuModel>> emissions =
          <List<ModelMainMenuModel>>[];
      final StreamSubscription<List<ModelMainMenuModel>> sub =
          bloc.listMenuOptionsStream.listen(emissions.add);

      bloc.addMainMenuOption(
        onPressed: () {},
        label: 'Home',
        iconData: Icons.home,
        description: 'Go home',
      );

      // da un pequeño margen al stream
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.listMenuOptions.length, 1);
      expect(bloc.listMenuOptions.first.label, 'Home');
      expect(emissions, isNotEmpty);

      await sub.cancel();
    });

    test('upsert por label (case-insensitive) → reemplaza, no duplica',
        () async {
      bloc
        ..addMainMenuOption(
          onPressed: () {},
          label: 'Profile',
          iconData: Icons.person,
        )
        ..addMainMenuOption(
          onPressed: () {},
          label: 'profile',
          iconData: Icons.person_outline,
        );

      expect(bloc.listMenuOptions.length, 1);
      expect(bloc.listMenuOptions.first.iconData, Icons.person_outline);
    });

    test('removeMainMenuOption por label (case-insensitive)', () async {
      bloc
        ..addMainMenuOption(
          onPressed: () {},
          label: 'Settings',
          iconData: Icons.settings,
        )
        ..removeMainMenuOption('settings');

      expect(bloc.listMenuOptions, isEmpty);
    });

    test('clearMainDrawer → vacía lista', () {
      bloc
        ..addMainMenuOption(onPressed: () {}, label: 'A', iconData: Icons.abc)
        ..addMainMenuOption(
          onPressed: () {},
          label: 'B',
          iconData: Icons.back_hand,
        );
      expect(bloc.listMenuOptions, isNotEmpty);

      bloc.clearMainDrawer();
      expect(bloc.listMenuOptions, isEmpty);
    });

    test(
        'retrocompat: listDrawerOptionSizeStream emite igual que listMenuOptionsStream',
        () async {
      final List<List<ModelMainMenuModel>> a = <List<ModelMainMenuModel>>[];
      final List<List<ModelMainMenuModel>> b = <List<ModelMainMenuModel>>[];

      final StreamSubscription<List<ModelMainMenuModel>> subA =
          bloc.listMenuOptionsStream.listen(a.add);
      // ignore: deprecated_member_use_from_same_package
      final StreamSubscription<List<ModelMainMenuModel>> subB =
          bloc.listDrawerOptionSizeStream.listen(b.add);

      bloc.addMainMenuOption(
        onPressed: () {},
        label: 'Home',
        iconData: Icons.home,
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Ambos deben tener la misma última emisión
      expect(a, isNotEmpty);
      expect(b, isNotEmpty);
      expect(a.last.length, b.last.length);
      expect(
        a.last.map((ModelMainMenuModel e) => e.label),
        b.last.map((ModelMainMenuModel e) => e.label),
      );

      await subA.cancel();
      await subB.cancel();
    });

    test('dispose cierra recursos', () async {
      expect(bloc.isClosed, isFalse);
      await bloc.dispose();
      expect(bloc.isClosed, isTrue);
    });
  });
}
