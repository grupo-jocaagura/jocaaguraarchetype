import 'package:flutter/material.dart';

class OneXOneWidget extends StatelessWidget {
  const OneXOneWidget({
    required this.child, this.width = 100,
    super.key,
  });

  final Widget child;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).splashColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: child,
    );
  }
}
