part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Visual overlay that renders margin guides for layout debugging.
///
/// This widget should be used only in debug/dev modes to verify spacing
/// decisions against your design tokens.
///
/// ### Example
/// ```dart
/// Stack(
///   children: <Widget>[
///     child,
///     const MarginBlueprintWidget(enabled: kDebugMode),
///   ],
/// );
/// ```
class MarginBlueprintWidget extends StatelessWidget {
  const MarginBlueprintWidget({
    required this.width,
    required this.height,
    super.key,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).focusColor,
    );
  }
}
