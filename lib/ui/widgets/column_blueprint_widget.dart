import 'package:flutter/material.dart';

class ColumnBlueprintWidget extends StatelessWidget {
  const ColumnBlueprintWidget({
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
      color: Theme.of(context).primaryColor,
    );
  }
}
