import 'package:flutter/material.dart';

class Responsive1x2Widget extends StatelessWidget {
  const Responsive1x2Widget({
    required this.height,
    required this.child,
    super.key,
  });

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 2,
      height: height,
      child: child,
    );
  }
}
