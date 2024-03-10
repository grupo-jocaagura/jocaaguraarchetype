import 'package:flutter/material.dart';

import '../../models/model_main_menu.dart';

class MainMenuOptionWidget extends StatelessWidget {
  const MainMenuOptionWidget({
    required this.option,
    super.key,
  });

  final ModelMainMenu option;

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
