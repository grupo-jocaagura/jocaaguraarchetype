import 'package:flutter/material.dart';

class Responsive1x1Widget extends StatelessWidget {
  const Responsive1x1Widget({
    required this.width,
    required this.child,
    super.key,
  });

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: child,
      ),
    );
  }
}
