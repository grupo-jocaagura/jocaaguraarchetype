import 'package:flutter/material.dart';

class OneXThreeWidget extends StatelessWidget {
  const OneXThreeWidget({
    required this.child,
    this.width = 300,
    super.key,
  });

  final Widget child;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 1 / 3,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).splashColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: child,
      ),
    );
  }
}
