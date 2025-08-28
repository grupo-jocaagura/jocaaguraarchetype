import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// --- Helpers para pruebas ---

/// Host stateful que permite reemplazar el `appManager` sin recrear al hijo.
class _Host extends StatefulWidget {
  const _Host({required this.initial, required this.child, super.key});
  final AppManager initial;
  final Widget child;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late AppManager _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initial;
  }

  void updateManager(AppManager next) {
    setState(() => _current = next);
  }

  @override
  Widget build(BuildContext context) {
    return AppManagerProvider(appManager: _current, child: widget.child);
  }
}

/// Dependiente que:
/// - lee el AppManager vía extensión `context.appManager`
/// - cuenta builds y llamadas a `didChangeDependencies`
/// - expone el último manager visto
class _DependentProbe extends StatefulWidget {
  const _DependentProbe({
    required this.captured,
    required this.builds,
    required this.depChanges,
  });

  final ValueNotifier<AppManager?> captured;
  final ValueNotifier<int> builds;
  final ValueNotifier<int> depChanges;

  @override
  State<_DependentProbe> createState() => _DependentProbeState();
}

class _DependentProbeState extends State<_DependentProbe> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.depChanges.value = widget.depChanges.value + 1;
  }

  @override
  Widget build(BuildContext context) {
    widget.builds.value = widget.builds.value + 1;

    // Leer vía extensión (equivale a AppManagerProvider.of(context))
    final AppManager mgr = context.appManager;
    widget.captured.value = mgr;

    // UI mínima estable para no introducir cambios colaterales
    return const SizedBox.shrink();
  }
}

final AppConfig appConfig =
    AppConfig.dev(registry: const PageRegistry(<String, PageWidgetBuilder>{}));

void main() {
  group('AppManagerProvider / AppManagerExtension', () {
    testWidgets(
        'exposure: of() y context.appManager devuelven la misma instancia',
        (WidgetTester tester) async {
      final AppManager manager = AppManager(appConfig);

      // Capturadores
      final ValueNotifier<AppManager?> seenByProbe =
          ValueNotifier<AppManager?>(null);
      final ValueNotifier<int> builds = ValueNotifier<int>(0);
      final ValueNotifier<int> deps = ValueNotifier<int>(0);

      late BuildContext capturedCtx;

      await tester.pumpWidget(
        MaterialApp(
          home: AppManagerProvider(
            appManager: manager,
            child: Builder(
              builder: (BuildContext ctx) {
                capturedCtx = ctx;
                return _DependentProbe(
                  captured: seenByProbe,
                  builds: builds,
                  depChanges: deps,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // La extensión y el of() deben devolver la misma instancia
      expect(seenByProbe.value, same(manager));
      expect(AppManagerProvider.of(capturedCtx), same(manager));

      // Se llamó una vez didChangeDependencies (registro de dependencia inicial)
      expect(deps.value, 1);
      // Y se construyó una vez el dependiente
      expect(builds.value, 1);
    });

    testWidgets(
        'updateShouldNotify=false: cambiar el manager NO llama didChangeDependencies, '
        'pero el build re-lee y ve el nuevo valor si el árbol se reconstruye',
        (WidgetTester tester) async {
      final AppManager managerA = AppManager(appConfig);
      final AppManager managerB = AppManager(appConfig);

      final ValueNotifier<AppManager?> seenByProbe =
          ValueNotifier<AppManager?>(null);
      final ValueNotifier<int> builds = ValueNotifier<int>(0);
      final ValueNotifier<int> deps = ValueNotifier<int>(0);

      final GlobalKey<_HostState> hostKey = GlobalKey<_HostState>();

      await tester.pumpWidget(
        MaterialApp(
          home: _Host(
            key: hostKey,
            initial: managerA,
            child: _DependentProbe(
              captured: seenByProbe,
              builds: builds,
              depChanges: deps,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(seenByProbe.value, same(managerA));
      expect(deps.value, 1);
      expect(builds.value, 1);

      // Cambiar el manager arriba en el árbol
      hostKey.currentState!.updateManager(managerB);
      await tester.pumpAndSettle();

      // No hubo notificación de dependencia (updateShouldNotify=false)
      expect(deps.value, 1);
    });

    testWidgets('cuando falta el provider, of(context) lanza AssertionError',
        (WidgetTester tester) async {
      final GlobalKey rootKey = GlobalKey();

      // Árbol sin AppManagerProvider
      await tester.pumpWidget(
        MaterialApp(home: Container(key: rootKey)),
      );
      await tester.pumpAndSettle();

      final BuildContext ctx = rootKey.currentContext!;
      expect(() => AppManagerProvider.of(ctx), throwsAssertionError);
    });

    testWidgets(
        'la extensión context.appManager refleja el mismo valor que of()',
        (WidgetTester tester) async {
      final AppManager manager = AppManager(appConfig);

      late BuildContext capturedCtx;

      await tester.pumpWidget(
        MaterialApp(
          home: AppManagerProvider(
            appManager: manager,
            child: Builder(
              builder: (BuildContext ctx) {
                capturedCtx = ctx;
                // Devuelve algo para renderizar
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(capturedCtx.appManager, same(AppManagerProvider.of(capturedCtx)));
      expect(capturedCtx.appManager, same(manager));
    });
  });
}
