import 'package:flutter/material.dart';

class ListTileExitDrawerWidget extends StatelessWidget {
  const ListTileExitDrawerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      iconColor: Theme.of(context).canvasColor,
      textColor: Theme.of(context).canvasColor,
      tileColor: Theme.of(context).colorScheme.error,
      onTap: () => Scaffold.of(context).openEndDrawer(),
      title: const Text(
        'Salir',
      ),
      leading: const Icon(
        Icons.close,
      ),
      subtitle: const Text(
        'Cerrar menu lateral',
      ),
    );
  }
}
