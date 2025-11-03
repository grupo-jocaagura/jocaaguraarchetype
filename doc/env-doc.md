# env-doc.md — Flavors con `--dart-define` + ejemplo de un solo archivo

Este documento explica **flavors lógicos** usando `--dart-define=APP_MODE=dev|qa|prod`, optimización Web con **onboarding** y un **ejemplo Flutter de un solo archivo** (contador) con un servicio simulado `AnyService`.

## TL;DR

* `APP_MODE` controla comportamiento en runtime.
* Label del contador:

    * **prod**: `contador`
    * **qa**: `contador en QA`
    * **dev**: `Contadr` (typo intencional)
* `AnyService`:

    * **dev**: no se usa
    * **qa**: falla la primera vez (3s), funciona al reintentar
    * **prod**: funciona siempre (2s)
* En proyectos reales, mueve la inicialización a **Onboarding** con **cargas diferidas** (deferred imports).

## Cómo pasar el modo

```bash
# DEV (por defecto si no defines APP_MODE)
flutter run --dart-define=APP_MODE=dev

# QA
flutter run --dart-define=APP_MODE=qa

# PROD
flutter run --dart-define=APP_MODE=prod
```

Builds típicos:

* Web: `flutter build web --dart-define=APP_MODE=qa`
* Android (bundle): `flutter build appbundle --dart-define=APP_MODE=prod`
* Windows (exe): `flutter build windows --dart-define=APP_MODE=dev`

---

## Ejemplo Flutter de un solo archivo (`lib/main.dart`)

Copia y pega tal cual:

```dart
import 'dart:async';
import 'package:flutter/material.dart';

/// --- AppMode y Env minimalistas (idénticos a los del paquete) ---

enum AppMode { dev, qa, prod }

AppMode parseAppMode(String raw) {
  switch (raw) {
    case 'prod':
      return AppMode.prod;
    case 'qa':
      return AppMode.qa;
    case 'dev':
    default:
      return AppMode.dev;
  }
}

class Env {
  static const String _mode = String.fromEnvironment('APP_MODE', defaultValue: 'dev');
  static bool get isQa => _mode == 'qa';
  static bool get isProd => _mode == 'prod';
  static AppMode get mode => parseAppMode(_mode);
}

/// --- AnyService: simula inicialización diferida dependiente del modo ---
/// - dev: no se usa
/// - qa: falla la primera vez (3s), al reintentar funciona
/// - prod: siempre pasa (2s)
class AnyService {
  static bool _qaFirstAttempt = true;

  static Future<void> initialize({required AppMode mode}) async {
    if (mode == AppMode.dev) {
      // No se usa en dev.
      return;
    }
    if (mode == AppMode.qa) {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (_qaFirstAttempt) {
        _qaFirstAttempt = false;
        throw Exception('QA bootstrap failed (simulado)');
      }
      return; // éxito en segundo intento
    }
    // prod
    await Future<void>.delayed(const Duration(seconds: 2));
    return; // éxito
  }
}

/// --- UI: contador con etiqueta por modo + banner de carga de AnyService ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flavors Example',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _count = 0;
  String _status = '';

  String get labelCounter {
    switch (Env.mode) {
      case AppMode.prod:
        return 'contador';
      case AppMode.qa:
        return 'contador en QA';
      case AppMode.dev:
      default:
        return 'Contadr'; // intencional en dev
    }
  }

  @override
  void initState() {
    super.initState();
    _maybeStartAnyService();
  }

  void _maybeStartAnyService() {
    if (Env.mode == AppMode.dev) {
      _status = 'dev: AnyService no se usa';
      return;
    }
    setState(() {
      _status = 'Inicializando AnyService...';
    });
    AnyService.initialize(mode: Env.mode).then((_) {
      if (!mounted) return;
      setState(() {
        _status = 'AnyService listo ✅';
      });
    }).catchError((Object e) {
      if (!mounted) return;
      setState(() {
        _status = 'Fallo al inicializar AnyService: $e';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String subtitle = switch (Env.mode) {
      AppMode.prod => 'Modo: PROD — AnyService debe iniciar en ~2s',
      AppMode.qa => 'Modo: QA — 1er intento falla en ~3s; reintento OK',
      AppMode.dev => 'Modo: DEV — AnyService deshabilitado',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Flavors con --dart-define')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count++),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(subtitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildAnyServiceBanner(),
            const Divider(height: 32),
            Text(labelCounter, style: Theme.of(context).textTheme.headlineSmall),
            Text('$_count', style: Theme.of(context).textTheme.displayMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildAnyServiceBanner() {
    if (Env.mode == AppMode.dev) {
      return _StatusCard(text: _status.isEmpty ? 'dev: AnyService no se usa' : _status);
    }
    final bool isLoading = _status.startsWith('Inicializando');
    final bool failed = _status.startsWith('Fallo');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            if (isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
            if (!isLoading) const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(_status)),
            if (failed)
              TextButton.icon(
                onPressed: _maybeStartAnyService,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            const Icon(Icons.info_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
```

---

## Integración con Onboarding (JocaaguraArchetype)

En un proyecto real, mueve la carga de `AnyService` al **Onboarding** con **carga diferida**:

```dart
// imports diferidos en tu app
import 'package:my_heavy_sdks/heavy.dart' deferred as heavy;

final List<OnboardingStep> steps = <OnboardingStep>[
  deferredStep(
    title: 'Core',
    description: 'Loading heavy SDKs...',
    load: () async {
      if (Env.isProd) {
        await heavy.loadLibrary();
        await heavy.initialize(); // 2s aprox
      } else if (Env.isQa) {
        await heavy.loadLibrary();
        try {
          await heavy.initialize(); // lanzar excepción en 1er intento
        } catch (_) {
          // mostrar mensaje y permitir reintento desde la UI del onboarding
          rethrow;
        }
      } // dev: no se usa
    },
    timeout: const Duration(seconds: 8),
  ),
];
```

---

## Estrategia Android (ID/label distintos sin productFlavors)

Ajusta `applicationId` y `app_name` a partir de `APP_MODE` (leyendo `DART_DEFINES`):

```gradle
// android/app/build.gradle
def dartDefines = []
if (project.hasProperty('dart-defines')) {
  dartDefines = project.property('dart-defines').split(',')
}
def decodeBase64 = { str -> new String(str.decodeBase64()) }
def env = [:]
dartDefines.each { d ->
  def kv = decodeBase64(d).split('=')
  if (kv.length == 2) env[kv[0]] = kv[1]
}
def APP_MODE = (env['APP_MODE'] ?: 'dev')
def idSuffix  = APP_MODE == 'prod' ? '' : APP_MODE == 'qa' ? '.qa' : '.dev'
def nameSuffix = APP_MODE == 'prod' ? '' : APP_MODE == 'qa' ? ' QA' : ' Dev'

android {
  defaultConfig {
    applicationId "com.tuorg.tuapp${idSuffix}"
    resValue "string", "app_name", "TuApp${nameSuffix}"
  }
}
```

Builds:

```bash
flutter build appbundle --dart-define=APP_MODE=dev   # com.tuorg.tuapp.dev
flutter build appbundle --dart-define=APP_MODE=qa    # com.tuorg.tuapp.qa
flutter build appbundle --dart-define=APP_MODE=prod  # com.tuorg.tuapp
```

---

## Buenas prácticas

* Mantén `Env` **mínimo** en el paquete; extiende por proyecto (`API_BASE_URL`, etc.).
* Inicializa servicios en **Onboarding** con `deferredStep(...)`.
* Define **timeouts/reintentos** para Auth/RemoteConfig/DB/Analytics.
* Valida `APP_MODE` en **CI**.
* Loguea `AppMode` en arranque.

