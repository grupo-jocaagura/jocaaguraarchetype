part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A widget that dynamically chooses its child based on the layout's aspect ratio.
///
/// The `GeneratorWidget` adapts its content by selecting one of the provided child widgets
/// based on the current aspect ratio of the available space. This is useful for creating
/// responsive layouts that need to render different content for various screen sizes or orientations.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
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
///         body: GeneratorWidget(
///           child1x1: Container(color: Colors.blue, child: Center(child: Text('1x1'))),
///           child1x2: Container(color: Colors.green, child: Center(child: Text('1x2'))),
///           child1x3: Container(color: Colors.red, child: Center(child: Text('1x3'))),
///           childVertical: Container(color: Colors.yellow, child: Center(child: Text('Vertical'))),
///           childHorizontal: Container(color: Colors.purple, child: Center(child: Text('Horizontal'))),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class GeneratorWidget extends StatelessWidget {
  /// Creates a `GeneratorWidget`.
  ///
  /// - [child1x1]: The widget to display when the aspect ratio is 1:1.
  /// - [child1x2]: The widget to display when the aspect ratio is 1:2.
  /// - [child1x3]: The widget to display when the aspect ratio is 1:3.
  /// - [childVertical]: The widget to display when the layout is taller than wide.
  /// - [childHorizontal]: The widget to display when the layout is wider than tall.
  const GeneratorWidget({
    required this.child1x1,
    required this.child1x2,
    required this.child1x3,
    required this.childVertical,
    required this.childHorizontal,
    super.key,
  });

  /// The widget to display when the aspect ratio is 1:1.
  final Widget child1x1;

  /// The widget to display when the aspect ratio is 1:2.
  final Widget child1x2;

  /// The widget to display when the aspect ratio is 1:3.
  final Widget child1x3;

  /// The widget to display when the layout is taller than wide.
  final Widget childVertical;

  /// The widget to display when the layout is wider than tall.
  final Widget childHorizontal;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        if (width == height * 3) {
          return child1x3;
        }
        if (width == height * 2) {
          return child1x2;
        }
        if (width == height) {
          return child1x1;
        }
        if (width > height) {
          return childHorizontal;
        }
        return childVertical;
      },
    );
  }
}
