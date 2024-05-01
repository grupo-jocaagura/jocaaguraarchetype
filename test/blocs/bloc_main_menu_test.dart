import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:jocaaguraarchetype/blocs/bloc_main_menu_drawer.dart';

// revisado 10/03/2024 author: @albertjjimenezp
void main() {
  group('BlocMainMenuDrawer', () {
    test('clearMainDrawer should clear the listMenuOptions', () {
      final BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
      blocMainMenuDrawer.addMainMenuOption(
        onPressed: () {},
        label: 'Option 1',
        iconData: Icons.ac_unit,
      );
      blocMainMenuDrawer.addMainMenuOption(
        onPressed: () {},
        label: 'Option 2',
        iconData: Icons.access_alarm,
      );

      blocMainMenuDrawer.clearMainDrawer();

      expect(blocMainMenuDrawer.listMenuOptions, isEmpty);
    });

    test('addMainMenuOption should add a new menu option', () {
      final BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
      void onPressed() {}
      const String label = 'Option 1';
      const IconData iconData = Icons.ac_unit;

      blocMainMenuDrawer.addMainMenuOption(
        onPressed: onPressed,
        label: label,
        iconData: iconData,
      );

      final List<ModelMainMenuModel> menuOptions =
          blocMainMenuDrawer.listMenuOptions;
      expect(menuOptions.length, 1);
      expect(menuOptions[0].onPressed, onPressed);
      expect(menuOptions[0].label, label);
      expect(menuOptions[0].iconData, iconData);
    });

    test(
        'addMainMenuOption should replace existing menu option with same label',
        () {
      final BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
      bool pressed1 = false;
      void onPressed1() {
        pressed1 = true;
      }

      const String label = 'Option 1';
      const IconData iconData1 = Icons.ac_unit;
      const IconData iconData2 = Icons.access_alarm;

      blocMainMenuDrawer.addMainMenuOption(
        onPressed: onPressed1,
        label: label,
        iconData: iconData1,
      );

      blocMainMenuDrawer.addMainMenuOption(
        onPressed: () {},
        label: label,
        iconData: iconData2,
      );

      final List<ModelMainMenuModel> menuOptions =
          blocMainMenuDrawer.listMenuOptions;
      expect(menuOptions.length, 2);
      menuOptions[0].onPressed();
      expect(pressed1, isTrue);
      expect(menuOptions[0].label, label);
      expect(menuOptions[0].iconData, iconData1);
    });

    test(
        'removeMainMenuOption should remove the menu option with the specified label',
        () {
      final BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
      bool onpressed2 = false;
      void onPressed1() {}
      void onPressed2() {
        onpressed2 = true;
      }

      const String label1 = 'Option 1';
      const String label2 = 'Option 2';
      const IconData iconData1 = Icons.ac_unit;
      const IconData iconData2 = Icons.access_alarm;

      blocMainMenuDrawer.addMainMenuOption(
        onPressed: onPressed1,
        label: label1,
        iconData: iconData1,
      );

      blocMainMenuDrawer.addMainMenuOption(
        onPressed: onPressed2,
        label: label2,
        iconData: iconData2,
      );

      blocMainMenuDrawer.removeMainMenuOption(label1);

      final List<ModelMainMenuModel> menuOptions =
          blocMainMenuDrawer.listMenuOptions;
      expect(menuOptions.length, 1);
      menuOptions[0].onPressed();
      expect(onpressed2, isTrue);
      expect(menuOptions[0].label, label2);
      expect(menuOptions[0].iconData, iconData2);
    });
    test('listDrawerOptionSizeStream emits initial listMenuOptions', () {
      void onPressed() {}

      const String label = 'Option 1';
      const IconData iconData = Icons.home;
      final BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
      blocMainMenuDrawer.addMainMenuOption(
        onPressed: onPressed,
        label: label,
        iconData: iconData,
      );

      expectLater(
        blocMainMenuDrawer.listDrawerOptionSizeStream,
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

    test('dispose blocMenu', () {
      void onPressed() {}

      const String label = 'Option 1';
      const IconData iconData = Icons.home;
      final BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
      blocMainMenuDrawer.addMainMenuOption(
        onPressed: onPressed,
        label: label,
        iconData: iconData,
      );

      blocMainMenuDrawer.dispose();
      expectLater(blocMainMenuDrawer.isClosed, true);
    });
  });
}
