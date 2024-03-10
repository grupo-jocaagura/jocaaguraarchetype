import 'package:flutter/material.dart';

class SecondaryOptionWidget extends StatelessWidget {
  const SecondaryOptionWidget({
    required this.onPressed,
    required this.label,
    required this.icondata,
    this.description = '',
    this.getOutOnTap = true,
    super.key,
  });
  final VoidCallback onPressed;
  final String label, description;
  final IconData icondata;
  final bool getOutOnTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      iconColor: Theme.of(context).splashColor,
      onTap: () {
        onPressed();
        if (getOutOnTap) {
          Scaffold.of(context).openDrawer();
        }
      },
      title: Text(label),
      leading: Icon(icondata),
      subtitle: description.isNotEmpty ? Text(description) : null,
    );
  }
}
