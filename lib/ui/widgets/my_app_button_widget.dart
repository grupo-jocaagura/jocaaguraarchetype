import 'package:flutter/material.dart';

class MyAppButtonWidget extends StatelessWidget {
  const MyAppButtonWidget({
    required this.iconData,
    required this.label,
    required this.onPressed,
    this.columnWidth = 200,
    super.key,
  });

  final IconData iconData;
  final String label;
  final void Function() onPressed;
  final double columnWidth;

  @override
  Widget build(BuildContext context) {
    final double iconSize = columnWidth * 0.2;
    return MaterialButton(
      onPressed: onPressed,
      child: Container(
        color: Theme.of(context).splashColor,
        width: columnWidth,
        height: iconSize,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: iconSize,
              child: Icon(iconData),
            ),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
