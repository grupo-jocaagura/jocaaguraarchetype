import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('BlocSecondaryMenuDrawer', () {
    late BlocSecondaryMenuDrawer bloc;

    setUp(() {
      bloc = BlocSecondaryMenuDrawer();
    });

    tearDown(() {
      bloc.dispose();
    });

    test('Initial listMenuOptions should be empty', () {
      expect(bloc.listMenuOptions.isEmpty, true);
    });

    test('Adding a menu option should update listMenuOptions', () {
      void onPressed() {}
      const String label = 'Option 1';
      const IconData iconData = Icons.home;

      bloc.addSecondaryMenuOption(
        onPressed: onPressed,
        label: label,
        iconData: iconData,
      );

      expect(bloc.listMenuOptions.length, 1);
      expect(bloc.listMenuOptions[0].label, label);
      expect(bloc.listMenuOptions[0].iconData, iconData);
    });

    test('Removing a menu option should update listMenuOptions', () {
      void onPressed1() {}
      const String label1 = 'Option 1';
      const IconData iconData1 = Icons.home;

      void onPressed2() {}
      const String label2 = 'Option 2';
      const IconData iconData2 = Icons.settings;

      bloc.addSecondaryMenuOption(
        onPressed: onPressed1,
        label: label1,
        iconData: iconData1,
      );
      bloc.addSecondaryMenuOption(
        onPressed: onPressed2,
        label: label2,
        iconData: iconData2,
      );

      bloc.removeSecondaryMenuOption(label1);

      expect(bloc.listMenuOptions.length, 1);
      expect(bloc.listMenuOptions[0].label, label2);
      expect(bloc.listMenuOptions[0].iconData, iconData2);
    });

    test('Clearing the main drawer should update listMenuOptions to be empty',
        () {
      void onPressed() {}

      const String label = 'Option 1';
      const IconData iconData = Icons.home;

      bloc.addSecondaryMenuOption(
        onPressed: onPressed,
        label: label,
        iconData: iconData,
      );

      bloc.clearSecondaryDrawer();

      expect(bloc.listMenuOptions.isEmpty, true);
    });
    test('listDrawerOptionSizeStream emits initial listMenuOptions', () {
      void onPressed() {}

      const String label = 'Option 1';
      const IconData iconData = Icons.home;

      bloc.addSecondaryMenuOption(
        onPressed: onPressed,
        label: label,
        iconData: iconData,
      );

      expectLater(
        bloc.listDrawerOptionSizeStream,
        emits(
          <ModelMainMenuModel>[
            ModelMainMenuModel(
              label: label,
              iconData: iconData,
              onPressed: onPressed,
            ),
          ],
        ),
      );
    });
  });
}
