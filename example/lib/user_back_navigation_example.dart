import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Run from example/: flutter run -d chrome -t lib/user_back_navigation_example.dart
void main() => runApp(const UserBackNavigationExample());

class UserBackNavigationExample extends StatefulWidget {
  const UserBackNavigationExample({super.key});

  @override
  State<UserBackNavigationExample> createState() =>
      _UserBackNavigationExampleState();
}

class _UserBackNavigationExampleState extends State<UserBackNavigationExample> {
  late final PageRegistry _registry;
  late final AppManager _app;
  bool _blocked = true;

  @override
  void initState() {
    super.initState();
    _registry = PageRegistry(<String, PageWidgetBuilder>{
      for (final String name in <String>['home', 'details', 'review'])
        name: _buildPage,
    });
    _app = AppManager(AppConfig.dev(registry: _registry));
  }

  bool _allowBack(UserBackNavigationRequest request) => !_blocked;

  Widget _buildPage(BuildContext context, PageModel page) {
    return Scaffold(
      appBar:
          PageAppBar(app: _app, responsive: _app.responsive, hasDrawer: false),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Text(page.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Bloquear retroceso del usuario'),
            subtitle: const Text(
              'Prueba el botón Back, el gesto o Atrás del navegador.',
            ),
            value: _blocked,
            onChanged: (bool value) => setState(() => _blocked = value),
          ),
          const SizedBox(height: 16),
          if (page.name != 'review')
            FilledButton(
              onPressed: () => _app.pageManager
                  .pushNamed(page.name == 'home' ? 'details' : 'review'),
              child: const Text('Abrir siguiente página'),
            ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _app.pageManager.resetTo(
              const PageModel(name: 'home', segments: <String>['home']),
            ),
            child: const Text('Reset de aplicación (siempre permitido)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => JocaaguraApp(
        appManager: _app,
        registry: _registry,
        userBackNavigationPolicy: _allowBack,
      );

  @override
  void dispose() {
    _app.dispose();
    super.dispose();
  }
}
