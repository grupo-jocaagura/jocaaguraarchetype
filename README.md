# JocaaguraArchetype

Arquetipo base para aplicaciones Flutter con enfoque de Clean Architecture, BLoCs transversales, navegación, theming y utilidades reutilizables sobre `jocaagura_domain`.

## Estado actual

- Migración a **5.0.0** con `material_ui` y `cupertino_ui` independientes del SDK de Flutter.
- Requiere **Flutter >=3.50.0** y **Dart >=3.14.0 <4.0.0**.
- Dependencia oficial `jocaagura_domain: ^2.0.0` desde pub.dev, con
  `jocaagura_domain_core: ^1.3.0` de forma transitiva.
- El paquete usa dependencias publicadas y conserva la versión **5.0.0**
  para su próximo release.
- [Guía de migración a 5.0.0](doc/migration-5.md).
- [Certificación con domain 2.0.0 publicado](doc/workflows/evidence/135/certification-domain-2.0.0.md).

## Qué resuelve este arquetipo

Este paquete sirve como base estable para nuevas apps que necesiten:

- bootstrap de aplicación y sesión
- navegación con `PageRegistry`, `PageManager` y coordinadores
- responsividad con `BlocResponsive`
- theming reactivo y persistible
- formularios controlados con `ModelFieldState`
- soporte para ACL, flujos `Either` y utilidades transversales

La idea práctica es esta:

```text
UI -> AppManager -> Bloc -> UseCase -> Repository -> Gateway -> Service
```

El arquetipo orquesta la capa de aplicación y UI, mientras `jocaagura_domain` concentra contratos, modelos, BLoCs base, helpers y utilidades compartidas.

## Soporte destacado para Design System

El paquete no trata el Design System como un detalle cosmético, sino como una capacidad de primer nivel del arquetipo.

Eso significa que puedes trabajar el sistema visual como un activo versionable, serializable y reusable entre apps, ambientes o snapshots de configuración.

Incluye soporte práctico para:

- `ModelDesignSystem` como contenedor integral del sistema visual
- `ModelThemeData` para representar `ThemeData` de forma serializable
- `ModelDsExtendedTokens` para spacing, radius, elevation, alpha y duraciones
- `ModelSemanticColors` para colores semánticos consistentes
- `ModelDataVizPalette` para paletas orientadas a visualización de datos
- `BlocDesignSystem` para actualizar y propagar cambios de forma reactiva
- widgets como `DsTextThemeEditorWidget` y `DsImportExportWidget`

En términos simples: no solo puedes pintar una app, también puedes modelar, persistir, editar, importar, exportar y evolucionar su lenguaje visual sin repartir lógica visual por toda la UI.

## Compatibilidad con domain/core y Material/Cupertino

El barrel `jocaaguraarchetype_domain.dart` mantiene la exposición de las APIs
de domain y sus reexports de core. No necesitas declarar core directamente
salvo que tu aplicación lo importe de forma explícita.

Los tipos de diseño como `ThemeData`, `ColorScheme`, `TextTheme`, `MaterialPage`
y `CupertinoPage` ahora provienen de `material_ui` y `cupertino_ui`. Los
consumidores deben migrar sus imports y dependencias para usar los mismos tipos.
Este cambio requiere una versión major aunque los nombres de clase se conserven.

## Instalación

Para probar esta rama antes de la publicación de 5.0.0, usa en tu `pubspec.yaml`:

```yaml
dependencies:
  jocaaguraarchetype:
    git:
      url: https://github.com/grupo-jocaagura/jocaaguraarchetype.git
      ref: feature/135-feat-migrate-archetype-to-material-ui-and-domaincore-for-500
  material_ui: ^1.11.0
  # Agrega cupertino_ui: ^1.1.6 si lo importas directamente.
```

Luego:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:material_ui/material_ui.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  final AppConfig config = AppConfig.dev();

  final PageRegistry registry = PageRegistry(
    routes: <String, WidgetBuilder>{
      '/': (_) => const MyDemoHomePage(),
      '/onboarding': (_) => const OnboardingPage(
            steps: <Widget>[],
            onFinish: null,
          ),
    },
    notFoundBuilder: (_) => const Page404Widget(),
  );

  runApp(
    JocaaguraApp.dev(
      config: config,
      registry: registry,
    ),
  );
}
```

## Ejemplo de uso de `AppManager`

```dart
void main()async{
  final AppManager app = AppManagerProvider.of(context);
  await app.themeUsecases.toggleMaterial3();
  await app.themeUsecases.setSeedColor(const Color(0xFF6750A4));
  await app.themeUsecases.setMode(ThemeMode.dark);
}
```

Además del theming, desde `AppManager` puedes centralizar acceso a:

- `BlocResponsive`
- `BlocOnboarding`
- `BlocModelVersion`
- módulos registrados en `blocModuleList`
- navegación y estado transversal de la app

## Componentes principales

### App bootstrap

- `AppConfig`: compone BLoCs y módulos base.
- `JocaaguraApp`: punto de entrada para apps basadas en el arquetipo.
- `AppManager`: fachada de acceso a estado, navegación y módulos transversales.

### Navegación

- `PageRegistry`: registro declarativo de páginas.
- `PageManager`: navegación reactiva y estado de pila.
- `SessionNavCoordinator`: coordinación de flujos vinculados a sesión.

### Responsive

- `BlocResponsive`: punto único para decisiones de layout.
- builders y widgets responsive listos para reutilizar.

### Theming y Design System

- `BlocTheme`, `BlocThemeReact`, `ThemeUsecases`
- modelos serializables como `ModelThemeData`, `ModelDesignSystem`, `ModelDsExtendedTokens`
- `BlocDesignSystem` para manejo reactivo del DS
- widgets de edición/import-export para configuraciones visuales

### Forms

- `ModelFieldState` como estado controlado de inputs
- widgets reutilizables para inputs y autocomplete

### ACL y Either Flow

- `BlocAcl`, `AclBridge`, `ModelAclSnapshot`
- utilidades de análisis, validación y simulación de flujos `Either`

## Estructura recomendada

```text
lib/
  domain/
    blocs/
    entities/
    gateways/
    models/
    repositories/
    services/
    states/
    usecases/
  ui/
    builders/
    navigation/
    pages/
    providers/
    theme/
    widgets/
  either_flow/
  env/
  src/
```

## Validación recomendada al integrar cambios de dominio

Si actualizas `jocaagura_domain`, esta es la secuencia mínima recomendada:

```bash
flutter pub get
flutter analyze
dart analyze --fatal-infos --fatal-warnings .
flutter test
dart format --output=none --set-exit-if-changed .
cd example
flutter analyze
flutter build web --release
```

Esto ayuda a detectar rápido tres tipos de regresión:

- contratos o imports rotos
- cambios de tipos o helpers compartidos
- efectos colaterales en widgets, navegación o bootstrap

## Documentación complementaria

- [Responsive Flow & BlocResponsive Pattern](doc/responsive-flow.md)

## Contribución

El pipeline automático y sus checkpoints se describen en
[Publicación desde master](doc/workflows/publication.md).
La [certificación final de 5.1.0](doc/workflows/evidence/139/certification-5.1.0.md)
registra la publicación real. En pub.dev deben estar habilitados **push y
workflow_dispatch**, manteniendo obligatorio el entorno **pub.dev**.

Flujo recomendado:

- `develop` para trabajo diario vía PR
- `master` para releases

Criterios prácticos para contribuir:

- priorizar cambios pequeños y verificables
- mantener separación clara de responsabilidades
- evitar acoplar UI con detalles de infraestructura
- acompañar cambios transversales con tests y notas de migración cuando aplique

## Licencia

MIT (c) Jocaagura
