# Índice de widgets del Design System

## Imports

Todos los widgets propios y los tres reexportados están disponibles con:

```dart
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';
```

Para consumir solamente texto responsive:

```dart
import 'package:jocaaguraarchetype/jocaaguraarchetype_text_responsive.dart';
import 'package:flutter/widgets.dart';
```

## Componentes públicos

| Componente | Propósito y ejemplo mínimo | API | ID de galería |
| --- | --- | --- | --- |
| `DsIconWidget` | Icono pasivo: `DsIconWidget(icon: Icons.info, semanticLabel: 'Información')` | [Fuente](../lib/ui/widgets/ds_icon_widget.dart) | `ds.widget.icon` |
| `DsLayeredSurfaceWidget` | Superficie: `DsLayeredSurfaceWidget(gradientColors: [Colors.blue, Colors.purple], child: Text('Contenido'))` | [Fuente](../lib/ui/widgets/ds_layered_surface_widget.dart) | `ds.widget.layered_surface` |
| `DsInteractiveBuilder` | Variantes: `DsInteractiveBuilder(state: state, enabledBuilder: (context, state) => Text('Activo'))` | [Fuente](../lib/ui/widgets/ds_interactive_widget.dart) | `ds.widget.interactive_builder` |
| `TextResponsiveWidget` | Ajuste de texto: `TextResponsiveWidget(child: Text('Título', maxLines: 1))` | [API](https://pub.dev/documentation/text_responsive/1.3.0/text_responsive/TextResponsiveWidget-class.html) | `ds.widget.text_responsive` |
| `ParagraphTextWidget` | Párrafo: `ParagraphTextWidget('Contenido', maxLines: 3)` | [API](https://pub.dev/documentation/text_responsive/1.3.0/text_responsive/ParagraphTextWidget-class.html) | `ds.widget.paragraph_text` |
| `InlineTextWidget` | Etiqueta: `InlineTextWidget('Etiqueta')` | [API](https://pub.dev/documentation/text_responsive/1.3.0/text_responsive/InlineTextWidget-class.html) | `ds.widget.inline_text` |

Los tres últimos proceden de `text_responsive: ^1.3.0`: son reexportaciones, no wrappers propios.

La app compone el catálogo navegable con estas fuentes, sin duplicar componentes:

- `BlocGallery.defaultPages()` aporta `ds.widget.layered_surface` y
  `ds.widget.interactive_builder`, con sus anatomías y previews integradas en
  [gallery_widgets.dart](../lib/ui/widgets/gallery_widgets.dart).
- `dsWidgetCatalog` aporta `ds.widget.icon`, `ds.widget.text_responsive`,
  `ds.widget.paragraph_text` y `ds.widget.inline_text` desde
  [ds_widget_catalog.dart](../example/lib/ds_widget_catalog.dart).
- Las demostraciones locales usan el prefijo `example.ds.widgets.*`.

La prueba de catálogo recorre el índice de la app real para verificar que cada
componente de esta tabla tiene una sola entrada, conserva su anatomía y renderiza
su widget. También comprueba IDs únicos en todas las páginas y correspondencia
exacta entre los IDs `ds.widget.*` y esta tabla.

<a id="ds.widget.layered_surface"></a>
<a id="ds.widget.interactive_builder"></a>
Las superficies y los estados interactivos se consultan desde la familia
**Widgets** del índice; los iconos y textos aparecen en sus respectivas familias.

<a id="ds.widget.icon"></a>
### Iconos

`DsIconWidget` acepta `icon`, `size`, `color` y `semanticLabel`.
La prioridad por campo es explícito → `IconTheme` heredado → DS/tema.
El tamaño final usa `tokens.spacing`; sin extensión usa `const ModelDsExtendedTokens().spacing`.
El color final es `colorScheme.onSurface`. Un `IconTheme` completo, como el de
`MaterialApp`, tiene prioridad sobre estos fallbacks. No requiere un administrador.

Un tamaño explícito no positivo o no finito produce `ArgumentError` en `build`.
Una etiqueta recortada no vacía expone un único nodo informativo de imagen.
Sin etiqueta es decorativo. No maneja acciones ni estados interactivos.

<a id="ds.widget.text_responsive"></a>
<a id="ds.widget.paragraph_text"></a>
<a id="ds.widget.inline_text"></a>
### Texto responsive

```dart
SizedBox(
  width: 180,
  height: 48,
  child: TextResponsiveWidget(
    child: Text('Un título adaptable', maxLines: 1,
      style: Theme.of(context).textTheme.titleLarge),
  ),
)
```

- Proporciona espacio acotado y un límite de líneas apropiado.
- Conserva dirección, estilos heredados, escalado y etiquetas accesibles.
- `TextResponsiveWidget.minFontSize` tiene un piso efectivo de 6 píxeles lógicos;
  un original menor conserva su tamaño. Al llegar al mínimo todavía puede haber
  overflow: reserva espacio para una lectura accesible.
- Un `overflow` explícito en el texto o estilo delega en Flutter sin reducción.
- Rich text con `WidgetSpan`, o ambos ejes sin límites, también delegan en Flutter.
- `ParagraphTextWidget` tiene 10 líneas por defecto. `InlineTextWidget` usa el
  límite heredado o una línea cuando aplica el ajuste.
- `overflowCallback` se entrega después del frame, una vez por episodio continuo
  de overflow del tamaño original.

## Infraestructura pública de galería

Import: entrypoint principal. Las páginas iniciales son `ds.gallery.cover` y
`ds.gallery.index`; las vistas de modelos usan `ds.model.*`.

| Widget | Ejemplo mínimo / propósito | API |
| --- | --- | --- |
| `DsGalleryPage` | `DsGalleryPage(designSystem: ds)` | [Fuente](../lib/ui/widgets/ds_gallery_page.dart) |
| `DsGalleryIndexPage` | `DsGalleryIndexPage(state: state, onGoTo: bloc.goTo)` | [Fuente](../lib/ui/widgets/ds_gallery_index_page.dart) |
| `DsGalleryNavigationControls` | `DsGalleryNavigationControls(state: state, onPrevious: bloc.previous, onIndex: bloc.goToIndex, onNext: bloc.next)` | [Fuente](../lib/ui/widgets/ds_gallerry_navigation_controls.dart) |
| `DesignSystemGalleryPage` | `DesignSystemGalleryPage(anatomy: anatomy, designSystem: ds, previewBuilder: preview)` | [Fuente](../lib/ui/widgets/design_system_gallery_page.dart) |
| `DesignSystemGalleryCoverPage` | `DesignSystemGalleryCoverPage(anatomy: anatomy, onStart: bloc.next)` | [Fuente](../lib/ui/widgets/design_system_gallery_cover_page.dart) |
| `SideBySideWidget` | `SideBySideWidget(designSystem: ds, builder: preview)` | [Fuente](../lib/ui/widgets/side_by_side_widget.dart) |

## Editores públicos existentes

Import: entrypoint principal. `dsBloc` es un `BlocDesignSystem(defaultModelDesignSystem())`
propiedad del consumidor, que debe liberarlo al cerrar el editor. No forman parte
 de la galería de consulta. [design_system_example.dart](../example/lib/design_system_example.dart)
muestra los paneles de edición.

| Widget | Ejemplo mínimo | API |
| --- | --- | --- |
| `DsTokenEditorWidget` | `DsTokenEditorWidget(dsBloc: dsBloc)` | [Fuente](../lib/ui/theme/ds_token_editor_widget.dart) |
| `DsTokenDoubleEditWidget` | `DsTokenDoubleEditWidget(label: 'Espacio', value: 16, onChangedAttempt: (value) {})` | [Fuente](../lib/ui/theme/ds_token_editor_widget.dart) |
| `DsTokenDurationEditWidget` | `DsTokenDurationEditWidget(label: 'Duración', value: Duration(milliseconds: 200), onChangedAttempt: (value) {})` | [Fuente](../lib/ui/theme/ds_token_editor_widget.dart) |
| `DsTextThemeEditorWidget` | `DsTextThemeEditorWidget(dsBloc: dsBloc)` | [Fuente](../lib/ui/theme/ds_text_theme_editor_widget.dart) |
| `DsDataVizEditorWidget` | `DsDataVizEditorWidget(dsBloc: dsBloc)` | [Fuente](../lib/ui/theme/ds_data_vis_editor_widget.dart) |
| `DsColorSwatchEditWidget` | `DsColorSwatchEditWidget(label: 'Color', color: Colors.blue, onChangeColorAttempt: (color) {})`; requiere tokens DS | [Fuente](../lib/ui/theme/ds_data_vis_editor_widget.dart) |
| `DsImportExportWidget` | `DsImportExportWidget(dsBloc: dsBloc)` | [Fuente](../lib/ui/theme/ds_import_export_widget.dart) |

`DsOrganicTexturePainter` es un `CustomPainter`, no un widget. Las extensiones
`DsExtendedTokensExtension`, `DsSemanticColorsExtension` y `DsDataVizPaletteExtension`
se instalan en `ThemeData` mediante el DS.

## Ejecutar y ampliar el catálogo

Desde `example`:

```sh
flutter pub get
flutter run -d chrome -t lib/ds_gallery_example.dart
```

La app funciona sin sesión ni backend. Reutiliza el índice por familias y previews
claro/oscuro del paquete. Las nuevas entradas y snippets están en
[ds_widget_catalog.dart](../example/lib/ds_widget_catalog.dart), con
`ModelDsComponentAnatomy` como metadatos y el mismo ID en `ModelDsGalleryPageEntry`.
Los IDs nuevos tienen anclas explícitas en este índice.

**Local demonstrations** contiene `DsPrimaryButtonWidget`, `DsSecondaryButtonWidget`,
`DsTextHeadlineMediumWidget`, `DsTextTitleLargeWidget`, `DsTextBodyMediumWidget` y
`DsTextLabelSmallWidget`: clases exclusivas del ejemplo, no exportadas por el paquete.
Sus IDs agrupados son `example.ds.widgets.buttons` y `example.ds.widgets.typography`.

BienvenidoApp es una referencia de comportamiento y anatomía. Este ejemplo no
depende de su código ni configuración.
