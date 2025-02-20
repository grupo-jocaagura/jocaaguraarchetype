import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

class MainMenuOptionWidget extends StatelessWidget {
  const MainMenuOptionWidget({
    required this.option,
    super.key,
  });

  final ModelMainMenuModel option;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(option.iconData),
      onTap: option.onPressed,
      title: Text(option.label),
      subtitle: Text(option.description),
    );
  }
}
