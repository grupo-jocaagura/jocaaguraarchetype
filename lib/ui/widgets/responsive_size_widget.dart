part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A widget that ensures its child fits within a specified size.
///
/// The `ResponsiveSizeWidget` creates a container with the specified [size]
/// and adjusts the child to fit proportionally using a `FittedBox`.
/// This is useful for creating layouts with fixed dimensions or for maintaining
/// consistent scaling.
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
///         appBar: AppBar(title: Text('Responsive Size Example')),
///         body: Center(
///           child: ResponsiveSizeWidget(
///             size: Size(200, 100),
///             child: Container(
///               color: Colors.blue,
///               child: Center(child: Text('200x100')),
///             ),
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class ResponsiveSizeWidget extends StatelessWidget {
  /// Creates a `ResponsiveSizeWidget`.
  ///
  /// - [child]: The widget to be displayed inside the container.
  /// - [size]: The size (width and height) of the container.
  const ResponsiveSizeWidget({
    required this.child,
    required this.size,
    super.key,
  });

  /// The widget to be displayed inside the container.
  final Widget child;

  /// The size (width and height) of the container.
  final Size size;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: child,
      ),
    );
  }
}
