# jocaagura archetype

## Galería DS autocontenida

Desde esta carpeta:

```sh
flutter pub get
flutter run -d chrome -t lib/ds_gallery_example.dart
flutter build web --release -t lib/ds_gallery_example.dart
```

No requiere sesión ni backend. Usa el DS por defecto, un índice por familias y
previews simultáneas en claro y oscuro. Incluye iconos pasivos, superficies,
estados interactivos y los tres widgets de `text_responsive` reexportados.
Cada nueva entrada muestra anatomía, reglas, tokens y uso mínimo.

El catálogo local está en `lib/ds_widget_catalog.dart`; conserva el mismo ID
entre anatomía, entrada y [documentación](../doc/ds-widget-index.md).
Los botones y textos de **Local demonstrations** son clases exclusivas del ejemplo.
La app crea y libera su propio `BlocGallery`.

Un proyecto transversal para desarrollo de las aplicaciones transversales

Este ejemplo consume la integración de 5.2.1 por ruta local. Requiere Flutter
>=3.50.0 y Dart >=3.14.0 <4.0.0, y usa `material_ui` en sus imports.
Consulta la [guía de migración](../doc/migration-5.md) para la dependencia oficial
domain 2.0.0 y las condiciones previas a la publicación.

Desde esta carpeta, valida con `flutter pub get`, `flutter analyze` y
`flutter build web --release`. Las pruebas de componentes y navegación se
ejecutan desde la raíz con `flutter test`.

## jocaaguraApp

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
