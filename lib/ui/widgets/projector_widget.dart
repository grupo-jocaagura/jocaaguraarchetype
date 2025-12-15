part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Project a fixed-size design canvas into the available layout space.
///
/// Scales [child] proportionally so it fits within the current constraints
/// while preserving the aspect ratio defined by [designWidth] / [designHeight].
///
/// This widget is useful when your UI is authored using absolute measurements
/// from a design tool (e.g. Figma) and you want a consistent “design canvas”
/// that is scaled to the device size.
///
/// Parameters:
/// - [child]: The widget tree laid out on a fixed design canvas.
/// - [designWidth]: The reference width of the design canvas (must be > 0).
/// - [designHeight]: The reference height of the design canvas (must be > 0).
/// - [debug]: When true, paints an amber background to visualize the canvas.
///
/// Notes:
/// - This widget does not apply [SafeArea]. Wrap it if you need notch/padding
///   handling.
/// - The child is scaled visually (via [FittedBox]); it is not re-laid out
///   using responsive constraints.
///
/// Example:
/// ```dart
/// import 'package:flutter/material.dart';
///
/// void main() {
///   runApp(const MaterialApp(
///     home: Scaffold(
///       body: ProjectorWidget(
///         designWidth: 412,
///         designHeight: 892,
///         child: Center(child: Text('Hello canvas')),
///       ),
///     ),
///   ));
/// }
/// ```
class ProjectorWidget extends StatelessWidget {
  const ProjectorWidget({
    required this.child,
    this.designWidth = 412,
    this.designHeight = 892,
    super.key,
    this.debug = false,
  });

  final Widget child;
  final double designWidth;
  final double designHeight;
  final bool debug;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;
        final double aspectRatio = designWidth / designHeight;
        double widthScale = screenWidth;
        double heightScale = widthScale / aspectRatio;

        if (heightScale > screenHeight) {
          heightScale = screenHeight;
          widthScale = heightScale * aspectRatio;
        }
        return Center(
          child: SizedBox(
            width: widthScale,
            height: heightScale,
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: FittedBox(
                child: debug
                    ? Container(
                        color: Colors.amber,
                        width: designWidth,
                        height: designHeight,
                        child: child,
                      )
                    : SizedBox(
                        width: designWidth,
                        height: designHeight,
                        child: child,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
