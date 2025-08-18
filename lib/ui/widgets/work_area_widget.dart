import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import 'columns_blueprint_widget.dart';
import 'main_menu_widget.dart';
import 'page_with_secondary_menu_widget.dart';

/// A widget for constructing a responsive work area with menus and a configurable layout.
///
/// The `WorkAreaWidget` is designed to create a layout that includes:
/// - A primary menu (optional, for TV and desktop layouts).
/// - A secondary menu, dynamically positioned based on the screen size.
/// - A work area, divided into columns.
///
/// It adapts its structure based on the provided [ScreenSizeEnum], supporting TV, desktop, tablet, and mobile layouts.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/work_area_widget.dart';
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
///       home: Scaffold(
///         appBar: AppBar(title: Text('Work Area Example')),
///         body: WorkAreaWidget(
///           columnsNumber: 12,
///           workAreaSize: Size(1200, 800),
///           marginWidth: 16,
///           columnWidth: 80,
///           gutterWidth: 8,
///           drawerWidth: 250,
///           screenSizeEnum: ScreenSizeEnum.desktop,
///           listMenuOptions: [
///             ModelMainMenuModel(
///               label: 'Home',
///               iconData: Icons.home,
///               onPressed: () => print('Home pressed'),
///             ),
///           ],
///           listSecondaryMenuOptions: [
///             ModelMainMenuModel(
///               label: 'Settings',
///               iconData: Icons.settings,
///               onPressed: () => print('Settings pressed'),
///             ),
///           ],
///           page: Center(child: Text('Work Area Content')),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class WorkAreaWidget extends StatelessWidget {
  /// Creates a `WorkAreaWidget`.
  ///
  /// - [columnsNumber]: The number of columns in the work area.
  /// - [workAreaSize]: The size of the work area.
  /// - [marginWidth]: The width of the margins around the work area.
  /// - [columnWidth]: The width of each column.
  /// - [gutterWidth]: The width of the spaces (gutters) between columns.
  /// - [drawerWidth]: The width of the primary menu drawer.
  /// - [screenSizeEnum]: The screen size type to adapt the layout.
  /// - [listMenuOptions]: The list of options for the primary menu.
  /// - [listSecondaryMenuOptions]: The list of options for the secondary menu.
  /// - [page]: The content of the work area. If null, a column blueprint is shown.
  const WorkAreaWidget({
    required this.columnsNumber,
    required this.workAreaSize,
    required this.marginWidth,
    required this.columnWidth,
    required this.gutterWidth,
    required this.screenSizeEnum,
    required this.listMenuOptions,
    required this.drawerWidth,
    required this.listSecondaryMenuOptions,
    super.key,
    this.page,
  });

  /// The number of columns in the work area.
  final int columnsNumber;

  /// The size of the work area.
  final Size workAreaSize;

  /// The width of the margins around the work area.
  final double marginWidth;

  /// The width of each column.
  final double columnWidth;

  /// The width of the spaces (gutters) between columns.
  final double gutterWidth;

  /// The width of the primary menu drawer.
  final double drawerWidth;

  /// The screen size type to adapt the layout.
  final ScreenSizeEnum screenSizeEnum;

  /// The list of options for the primary menu.
  final List<ModelMainMenuModel> listMenuOptions;

  /// The list of options for the secondary menu.
  final List<ModelMainMenuModel> listSecondaryMenuOptions;

  /// The content of the work area.
  final Widget? page;

  @override
  Widget build(BuildContext context) {
    final ColumnsBluePrintWidget columnsBluePrintWidget =
        ColumnsBluePrintWidget(
      numberOfColumns: columnsNumber,
      workAreaSize: workAreaSize,
      marginWidth: marginWidth,
      columnWidth: columnWidth,
      gutterWidth: gutterWidth,
    );

    final Widget child = PageWidthSecondaryMenuWidget(
      screenSizeEnum: screenSizeEnum,
      secondaryMenuWidth: columnWidth * 2,
      page: page ?? columnsBluePrintWidget,
      listOfModelMainMenu: listSecondaryMenuOptions,
    );

    /// TV and Desktop Layout
    if (screenSizeEnum == ScreenSizeEnum.tv ||
        screenSizeEnum == ScreenSizeEnum.desktop) {
      if (listMenuOptions.isNotEmpty) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              MainMenuWidget(
                listMenuOptions: listMenuOptions,
                drawerWidth: drawerWidth,
              ),
              child,
            ],
          ),
        );
      }
      return child;
    }

    /// Tablet Layout
    if (screenSizeEnum == ScreenSizeEnum.tablet) {
      return child;
    }

    /// Mobile Layout
    return child;
  }
}
