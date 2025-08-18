part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A widget that ensures its child has a 1:1 aspect ratio (square).
///
/// The `Responsive1x1Widget` creates a square container with the specified [width].
/// The child widget is fitted proportionally using a `FittedBox` to maintain the layout.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/responsive_1x1_widget.dart';
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
///         appBar: AppBar(title: Text('Responsive 1x1 Example')),
///         body: Center(
///           child: Responsive1x1Widget(
///             width: 100,
///             child: Container(
///               color: Colors.blue,
///               child: Center(child: Text('1x1')),
///             ),
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class Responsive1x1Widget extends StatelessWidget {
  /// Creates a `Responsive1x1Widget`.
  ///
  /// - [width]: The width (and height) of the square container.
  /// - [child]: The child widget to be displayed inside the square.
  const Responsive1x1Widget({
    required this.width,
    required this.child,
    super.key,
  });

  /// The width (and height) of the square container.
  final double width;

  /// The child widget to be displayed inside the square.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: child,
      ),
    );
  }
}
