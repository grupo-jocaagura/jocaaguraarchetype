part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A widget that ensures its child has a 1:2 aspect ratio (rectangle).
///
/// The `Responsive1x2Widget` creates a rectangular container with the specified [height],
/// ensuring the width is double the height. The child widget is fitted proportionally
/// using a `FittedBox` to maintain the layout.
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
///         appBar: AppBar(title: Text('Responsive 1x2 Example')),
///         body: Center(
///           child: Responsive1x2Widget(
///             height: 100,
///             child: Container(
///               color: Colors.green,
///               child: Center(child: Text('1x2')),
///             ),
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class Responsive1x2Widget extends StatelessWidget {
  /// Creates a `Responsive1x2Widget`.
  ///
  /// - [height]: The height of the container. The width is calculated as `height * 2`.
  /// - [child]: The child widget to be displayed inside the rectangle.
  const Responsive1x2Widget({
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
      width: height * 2,
      height: height,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: child,
      ),
    );
  }
}
