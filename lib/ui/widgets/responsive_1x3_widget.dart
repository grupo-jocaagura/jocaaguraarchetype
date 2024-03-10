import 'package:flutter/material.dart';

class Responsive1x3Widget extends StatelessWidget {
  const Responsive1x3Widget({
    required this.height,
    required this.child,
    super.key,
  });

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 3,
      height: height,
      child: child,
    );
  }
}
