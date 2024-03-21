import 'package:flutter/material.dart';

class ResponsiveSizeWidget extends StatelessWidget {
  const ResponsiveSizeWidget({
    required this.child,
    required this.size,
    super.key,
  });

  final Widget child;
  final Size size;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: child,
      ),
    );
  }
}
