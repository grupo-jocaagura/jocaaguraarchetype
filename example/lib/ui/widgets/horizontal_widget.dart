import 'package:flutter/material.dart';

class HorizontalWidget extends StatelessWidget {
  const HorizontalWidget({
    required this.child,
    this.size = const Size(260, 120),
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
