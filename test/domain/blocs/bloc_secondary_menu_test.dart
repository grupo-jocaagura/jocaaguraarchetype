import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('BlocSecondaryMenuDrawer', () {
    late BlocSecondaryMenuDrawer bloc;

    setUp(() {
      bloc = BlocSecondaryMenuDrawer();
    });

    tearDown(() {
      bloc.dispose();
    });

    test('inicial: lista vacía e inmutable', () {
      expect(bloc.listMenuOptions, isEmpty);
      // Debe lanzar al intentar mutar una lista inmutable
      expect(
        () => bloc.listMenuOptions.add(
          ModelMainMenuModel(
            onPressed: () {},
            label: 'X',
            iconData: Icons.close,
          ),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('addSecondaryMenuOption → agrega y emite', () async {
      final List<List<ModelMainMenuModel>> emissions =
          <List<ModelMainMenuModel>>[];
      final StreamSubscription<List<ModelMainMenuModel>> sub =
          bloc.listDrawerOptionSizeStream.listen(emissions.add);

      bloc.addSecondaryMenuOption(
        onPressed: () {},
        label: 'Help',
        iconData: Icons.help,
        description: 'Get help',
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.listMenuOptions.length, 1);
      expect(bloc.listMenuOptions.first.label, 'Help');
      expect(emissions, isNotEmpty);
      await sub.cancel();
    });

    test('upsert por label → reemplaza, no duplica', () {
      bloc
        ..addSecondaryMenuOption(
          onPressed: () {},
          label: 'About',
          iconData: Icons.info,
        )
        ..addSecondaryMenuOption(
          onPressed: () {},
          label: 'about',
          iconData: Icons.info_outline,
        );

      expect(bloc.listMenuOptions.length, 1);
      expect(bloc.listMenuOptions.first.iconData, Icons.info_outline);
    });

    test('removeSecondaryMenuOption por label', () {
      bloc
        ..addSecondaryMenuOption(
          onPressed: () {},
          label: 'Legal',
          iconData: Icons.gavel,
        )
        ..removeSecondaryMenuOption('LEGAL');

      expect(bloc.listMenuOptions, isEmpty);
    });

    test('clearSecondaryDrawer → vacía lista', () {
      bloc
        ..addSecondaryMenuOption(
          onPressed: () {},
          label: 'X',
          iconData: Icons.close,
        )
        ..addSecondaryMenuOption(
          onPressed: () {},
          label: 'Y',
          iconData: Icons.circle,
        );
      expect(bloc.listMenuOptions, isNotEmpty);

      bloc.clearSecondaryDrawer();
      expect(bloc.listMenuOptions, isEmpty);
    });

    test('retrocompat: alias deprecated siguen funcionando', () {
      // ignore: deprecated_member_use_from_same_package
      bloc.addMainMenuOption(
        onPressed: () {},
        label: 'Legacy',
        iconData: Icons.history,
      );
      expect(bloc.listMenuOptions.length, 1);

      // ignore: deprecated_member_use_from_same_package
      bloc.removeMainMenuOption('legacy');
      expect(bloc.listMenuOptions, isEmpty);

      // ignore: deprecated_member_use_from_same_package
      bloc.clearMainDrawer(); // no debe fallar
    });
  });
}
