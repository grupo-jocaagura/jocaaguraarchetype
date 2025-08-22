import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../support/example_env.dart';
import '../support/example_services.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          SwitchListTile(
            title: const Text('Dark mode'),
            value: app.theme.stateOrDefault.mode == ThemeMode.dark,
            onChanged: (bool v) =>
                app.theme.setMode(v ? ThemeMode.dark : ThemeMode.light),
          ),
          const Divider(),
          ListTile(
            title: const Text('Switch to DEV'),
            subtitle: const Text('Fakes: online=true, logged=false'),
            onTap: () => ExampleEnv.appConfigBloc
                .switchTo(ExampleEnv.cfgDev, resetStack: true),
          ),
          ListTile(
            title: const Text('Switch to QA'),
            subtitle: const Text('Fakes: online=true, logged=true'),
            onTap: () => ExampleEnv.appConfigBloc
                .switchTo(ExampleEnv.cfgQa, resetStack: true),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Connectivity: Online'),
            value: true,
            onChanged: (bool v) {
              ExampleConnectivity.instance.setOnline(v);
              app.notify('Connectivity: ${v ? 'Online' : 'Offline'}');
            },
          ),
        ],
      ),
    );
  }
}
