import 'package:flutter/material.dart';

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
