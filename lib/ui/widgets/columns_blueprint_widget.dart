import 'package:flutter/material.dart';

import 'column_blueprint_widget.dart';
import 'gutter_blueprint_widget.dart';
import 'margin_blueprint_widget.dart';

/// A simple widget for creating a fixed-size container with a blueprint style.
///
/// The `ColumnBlueprintWidget` is primarily used for creating placeholder or
/// blueprint components in layouts. It creates a `Container` with the specified
/// width, height, and the primary color from the app's theme.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/column_blueprint_widget.dart';
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
///       theme: ThemeData(primaryColor: Colors.blue),
///       home: Scaffold(
///         appBar: AppBar(title: Text('Column Blueprint Example')),
///         body: Center(
///           child: ColumnBlueprintWidget(
///             width: 100,
///             height: 200,
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class ColumnsBluePrintWidget extends StatelessWidget {
  /// Creates a `ColumnBlueprintWidget` with the given dimensions.
  ///
  /// - [width]: The width of the container.
  /// - [height]: The height of the container.
  const ColumnsBluePrintWidget({
    required this.numberOfColumns,
    required this.workAreaSize,
    required this.marginWidth,
    required this.columnWidth,
    required this.gutterWidth,
    super.key,
  });
  final int numberOfColumns;
  final double marginWidth;
  final double columnWidth;
  final double gutterWidth;
  final Size workAreaSize;

  @override
  Widget build(BuildContext context) {
    final List<Widget> columns = <Widget>[];
    final int numberOfGutters = numberOfColumns < 1 ? 0 : numberOfColumns - 1;
    final MarginBlueprintWidget marginWidget = MarginBlueprintWidget(
      width: marginWidth,
      height: workAreaSize.height,
    );
    int gutterAdded = 0;
    columns.add(marginWidget);
    for (int i = 0; i < numberOfColumns; i++) {
      columns.add(
        ColumnBlueprintWidget(
          width: columnWidth,
          height: workAreaSize.height,
        ),
      );
      if (gutterAdded < numberOfGutters) {
        columns.add(
          GutterBlueprintWidget(
            width: gutterWidth,
            height: workAreaSize.height,
          ),
        );
        gutterAdded++;
      }
    }
    columns.add(marginWidget);

    return Center(
      child: SizedBox(
        width: workAreaSize.width,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: columns,
              ),
            ),
            Center(
              child: Text(
                'Columas: $numberOfColumns',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
