import 'package:flutter/material.dart';

class OneXTwoWidget extends StatelessWidget {
  const OneXTwoWidget({
    required this.child,
    this.width = 200,
    super.key,
  });

  final Widget child;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.5,
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
