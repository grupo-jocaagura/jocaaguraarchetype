import 'package:flutter/material.dart';

class DotWidget extends StatelessWidget {
  const DotWidget({
    required this.width,
    super.key,
    this.isActive = false,
  });

  final bool isActive;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? Theme.of(context).primaryColor
            : Theme.of(context).splashColor,
        border: Border.all(
          color: Theme.of(context).splashColor,
        ),
      ),
    );
  }
}
