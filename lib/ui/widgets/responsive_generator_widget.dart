import 'package:flutter/material.dart';

class GeneratorWidget extends StatelessWidget {
  const GeneratorWidget({
    required this.child1x1,
    required this.child1x2,
    required this.child1x3,
    required this.childVertical,
    required this.childHorizontal,
    super.key,
  });

  final Widget child1x1;
  final Widget child1x2;
  final Widget child1x3;
  final Widget childVertical;
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
