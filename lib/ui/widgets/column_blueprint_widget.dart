import 'package:flutter/material.dart';

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
class ColumnBlueprintWidget extends StatelessWidget {
  /// Creates a `ColumnBlueprintWidget` with the given dimensions.
  ///
  /// - [width]: The width of the container.
  /// - [height]: The height of the container.
  const ColumnBlueprintWidget({
    required this.width,
    required this.height,
    super.key,
  });

  /// The width of the container.
  final double width;

  /// The height of the container.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).primaryColor,
    );
  }
}
