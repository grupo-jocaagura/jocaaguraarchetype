# JocaaguraArchetype

Arquetipo base para aplicaciones Flutter con enfoque de Clean Architecture, BLoCs transversales, navegación, theming y utilidades reutilizables sobre `jocaagura_domain`.

## Estado actual

- Dependencia alineada con `jocaagura_domain: ^1.39.0`.
- Validación de compatibilidad completada con:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`
- Resultado del upgrade a `1.39.0`: retrocompatible para el arquetipo, sin cambios obligatorios de adopción.

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

## Compatibilidad con `jocaagura_domain 1.39.0`

Se verificó el consumo del arquetipo contra la versión `1.39.0`, poniendo atención en las piezas más sensibles:

- `ModelAppVersion`
- `JocaDateUtils` y normalización ISO usada por snapshots/modelos
- `BlocModule`
- `BlocResponsive`
- patrón de formularios con `ModelFieldState`
- widgets transversales, theme, responsive y bootstrap de app

Conclusión:

- no se detectaron imports rotos por barrels o módulos expuestos
- el arquetipo compila y analiza correctamente con `1.39.0`
- los tests existentes pasan sin requerir adaptaciones funcionales
- el upgrade se considera aditivo y retrocompatible para este repositorio

## Instalación

En tu `pubspec.yaml`:

```yaml
dependencies:
  jocaaguraarchetype: ^4.1.0
  jocaagura_domain: ^1.39.0
```

Luego:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:flutter/material.dart';
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
flutter test
cd example
flutter analyze
```

Esto ayuda a detectar rápido tres tipos de regresión:

- contratos o imports rotos
- cambios de tipos o helpers compartidos
- efectos colaterales en widgets, navegación o bootstrap

## Documentación complementaria

- [Responsive Flow & BlocResponsive Pattern](doc/responsive-flow.md)

## Contribución

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
