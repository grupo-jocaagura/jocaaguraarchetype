import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../consts/enum_screen_size.dart';
import 'movil_secondary_menu_widget.dart';
import 'secondary_option_widget.dart';

/// A widget that displays a page with a secondary menu, adapting to the screen size.
///
/// The `PageWidthSecondaryMenuWidget` is designed to include a secondary menu
/// that adapts its layout based on the screen size (`ScreenSizeEnum`). It supports
/// both mobile and desktop layouts, ensuring a responsive design.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/page_width_secondary_menu_widget.dart';
/// import 'package:flutter/material.dart';
///
/// void main() {
///   runApp(MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: PageWidthSecondaryMenuWidget(
///         screenSizeEnum: ScreenSizeEnum.desktop,
///         secondaryMenuWidth: 250.0,
///         page: Center(child: Text('Main Page Content')),
///         listOfModelMainMenu: [
///           ModelMainMenuModel(
///             label: 'Option 1',
///             iconData: Icons.home,
///             onPressed: () => print('Option 1 Pressed'),
///           ),
///           ModelMainMenuModel(
///             label: 'Option 2',
///             iconData: Icons.settings,
///             onPressed: () => print('Option 2 Pressed'),
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
class PageWidthSecondaryMenuWidget extends StatelessWidget {
  /// Creates a `PageWidthSecondaryMenuWidget`.
  ///
  /// - [screenSizeEnum]: Specifies the current screen size.
  /// - [secondaryMenuWidth]: The width of the secondary menu.
  /// - [page]: The main content of the page.
  /// - [listOfModelMainMenu]: The list of menu options to display in the secondary menu.
  const PageWidthSecondaryMenuWidget({
    required this.screenSizeEnum,
    required this.secondaryMenuWidth,
    required this.page,
    required this.listOfModelMainMenu,
    super.key,
  });

  /// The list of menu options to display in the secondary menu.
  final List<ModelMainMenuModel> listOfModelMainMenu;

  /// The width of the secondary menu.
  final double secondaryMenuWidth;

  /// The screen size enum to determine layout adaptations.
  final ScreenSizeEnum screenSizeEnum;

  /// The main content of the page.
  final Widget page;

  @override
  Widget build(BuildContext context) {
    if (listOfModelMainMenu.isEmpty) {
      return page;
    }
    if (screenSizeEnum == ScreenSizeEnum.movil ||
        screenSizeEnum == ScreenSizeEnum.tablet) {
      final double menuItemWidth = secondaryMenuWidth * 0.8;
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            page,
            Positioned(
              bottom: 10.0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: menuItemWidth,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: MovilSecondaryMenuWidget(
                  listOfModelMainMenu: listOfModelMainMenu,
                  menuItemWidth: menuItemWidth,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (listOfModelMainMenu.isNotEmpty) {
      final List<Widget> secondaryMenuTmp = <Widget>[];
      for (final ModelMainMenuModel option in listOfModelMainMenu) {
        secondaryMenuTmp.add(
          SecondaryOptionWidget(
            onPressed: option.onPressed,
            label: option.label,
            icondata: option.iconData,
            description: option.description,
          ),
        );
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            Container(
              width: secondaryMenuWidth,
              decoration: BoxDecoration(
                color: Theme.of(context).focusColor,
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: ListView(
                children: secondaryMenuTmp,
              ),
            ),
            page,
          ],
        ),
      );
    }
    return page;
  }
}
