part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class GutterBlueprintWidget extends StatelessWidget {
  const GutterBlueprintWidget({
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
      color: Theme.of(context).splashColor,
    );
  }
}
