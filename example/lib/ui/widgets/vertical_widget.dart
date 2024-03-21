import 'package:flutter/material.dart';

class VerticalWidget extends StatelessWidget {
  const VerticalWidget({
    required this.child,
    this.size = const Size(160, 250),
    super.key,
  });

  final Widget child;
  final Size size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
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
