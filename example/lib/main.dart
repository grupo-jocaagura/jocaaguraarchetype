import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import 'app_registry.dart';
import 'support/example_env.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Registry de páginas del example
  final PageRegistry registry = buildExampleRegistry();

  // Construimos dos configuraciones (DEV y QA) con pasos de onboarding distintos.
  final AppConfig cfgDev = ExampleEnv.buildConfig(
    mode: AppMode.dev,
    registry: registry,
  );
  final AppConfig cfgQa = ExampleEnv.buildConfig(
    mode: AppMode.qa,
    registry: registry,
  );

  // BlocAppConfig para swap en caliente entre DEV/QA
  ExampleEnv.appConfigBloc = BlocAppConfig(initial: cfgDev);
  ExampleEnv.cfgDev = cfgDev;
  ExampleEnv.cfgQa = cfgQa;

  runApp(ExampleRoot(registry: registry));
}

/// Wrapper que escucha el BlocAppConfig y reconstruye el shell.
class ExampleRoot extends StatefulWidget {
  const ExampleRoot({required this.registry, super.key});
  final PageRegistry registry;
  @override
  State<ExampleRoot> createState() => _ExampleRootState();
}

class _ExampleRootState extends State<ExampleRoot> {
  late AppConfig _current;
  late Stream<AppConfig> _stream;

  @override
  void initState() {
    super.initState();
    _current = ExampleEnv.appConfigBloc.state;
    _stream = ExampleEnv.appConfigBloc.stream;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppConfig>(
      stream: _stream,
      initialData: _current,
      builder: (_, AsyncSnapshot<AppConfig> snap) {
        final AppConfig cfg = snap.data ?? _current;
        final AppManager manager = AppManager(cfg);
        return JocaaguraApp(
          appManager: manager,
          registry: widget.registry,
          projectorMode: false,
          initialLocation: '/onboarding',
        );
      },
    );
  }
}
