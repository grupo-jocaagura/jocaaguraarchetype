import 'package:flutter/material.dart';

/// A widget that ensures its child has a 1:3 aspect ratio (wide rectangle).
///
/// The `Responsive1x3Widget` creates a rectangular container with the specified [height],
/// ensuring the width is three times the height. The child widget is fitted proportionally
/// using a `FittedBox` to maintain the layout.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/responsive_1x3_widget.dart';
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
///         appBar: AppBar(title: Text('Responsive 1x3 Example')),
///         body: Center(
///           child: Responsive1x3Widget(
///             height: 100,
///             child: Container(
///               color: Colors.red,
///               child: Center(child: Text('1x3')),
///             ),
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class Responsive1x3Widget extends StatelessWidget {
  /// Creates a `Responsive1x3Widget`.
  ///
  /// - [height]: The height of the container. The width is calculated as `height * 3`.
  /// - [child]: The child widget to be displayed inside the rectangle.
  const Responsive1x3Widget({
    required this.height,
    required this.child,
    super.key,
  });

  /// The height of the container.
  final double height;

  /// The child widget to be displayed inside the rectangle.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 3,
      height: height,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: child,
      ),
    );
  }
}
