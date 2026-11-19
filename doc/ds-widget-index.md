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
| `DsIconButtonWidget` | Acción por icono: `DsIconButtonWidget(icon: Icons.add, semanticLabel: 'Agregar ítem', onPressed: addItem)` | [Fuente](../lib/ui/widgets/ds_icon_button_widget.dart) | `ds.widget.icon_button` |
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
- `dsWidgetCatalog` aporta icono, texto responsive, tipografía DS y grillas desde
  [ds_widget_catalog.dart](../example/lib/ds_widget_catalog.dart) y el catálogo
  de [tipografía e ítems](../example/lib/ds_item_family_catalog.dart).
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

<a id="ds.widget.icon_button"></a>
### Botones de icono

Usa `DsIconButtonWidget` para acciones breves que se reconocen por su icono,
como agregar, cerrar o alternar un favorito. Proporciona un `semanticLabel`
localizado y no vacío que describa la acción, como «Agregar ítem».

La superficie circular mide 32 píxeles lógicos y ocupa el centro de un área de
48 × 48. Reserva ese espacio por botón, incluso en barras con varios controles.
La variante predeterminada es `filled`. Para mostrar un borde sobre la
superficie del tema, usa `DsSurfaceVariant.outlined`.

Controla la selección con `ModelInteractiveState` y usa `selectedIcon` si hay
un icono alternativo. La selección añade una marca visual. El callback depende
de `state.canInteract` para puntero, teclado y lector de pantalla. El orden visual
es oculto → carga → error → selección → deshabilitado → normal. Un error
habilitado permite reintentar. El tooltip muestra el nombre de la acción o el
mensaje de feedback del estado, que también se anuncia como pista accesible.

La carga mantiene el nombre de la acción y anuncia `loadingSemanticLabel` por
separado. Puedes suministrar un `DsLoading` para reemplazar el indicador
circular predeterminado. La paleta y los fallbacks de `success`, `warning` y
`danger` son los mismos que los de `DsItemButtonWidget`.

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

## Tipografía Material

| Componente | Cuándo usarlo y ejemplo | API | ID de galería |
| --- | --- | --- | --- |
| `DsTextDisplayLargeWidget` | Mensaje principal de una portada. Espacio amplio para pocas palabras. · `DsTextDisplayLargeWidget(label: 'Explora')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_display_large` |
| `DsTextDisplayMediumWidget` | Mensaje destacado de una campaña. Ancho amplio para una frase breve. · `DsTextDisplayMediumWidget(label: 'Descubre lo nuevo')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_display_medium` |
| `DsTextDisplaySmallWidget` | Cifra o mensaje principal en un espacio moderado. Espacio moderado y contenido corto. · `DsTextDisplaySmallWidget(label: '12 proyectos')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_display_small` |
| `DsTextHeadlineLargeWidget` | Encabezado principal de página. Reserva la línea principal del encabezado. · `DsTextHeadlineLargeWidget(label: 'Panel principal')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_headline_large` |
| `DsTextHeadlineMediumWidget` | Encabezado de sección. Da al encabezado el ancho de su sección. · `DsTextHeadlineMediumWidget(label: 'Actividad reciente')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_headline_medium` |
| `DsTextHeadlineSmallWidget` | Encabezado de subsección. Usa una línea breve en el bloque. · `DsTextHeadlineSmallWidget(label: 'Próximos pasos')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_headline_small` |
| `DsTextTitleLargeWidget` | Título de un contenido destacado. Deja espacio en la cabecera del contenido. · `DsTextTitleLargeWidget(label: 'Resumen de cuenta')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_title_large` |
| `DsTextTitleMediumWidget` | Título de una tarjeta o grupo. Acota el ancho disponible en la tarjeta. · `DsTextTitleMediumWidget(label: 'Informe mensual')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_title_medium` |
| `DsTextTitleSmallWidget` | Título de un componente compacto. Resérvalo para nombres cortos. · `DsTextTitleSmallWidget(label: 'Detalles')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_title_small` |
| `DsTextBodyLargeWidget` | Texto de lectura destacado. Usa ancho generoso o un párrafo para varias líneas. · `DsTextBodyLargeWidget(label: 'Lee lo más destacado')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_body_large` |
| `DsTextBodyMediumWidget` | Texto principal de lectura. Usa el párrafo para lectura que ocupe varias líneas. · `DsTextBodyMediumWidget(label: 'Guardamos tus cambios')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_body_medium` |
| `DsTextBodySmallWidget` | Texto auxiliar o nota breve. Mantén la nota breve o usa un párrafo de detalle. · `DsTextBodySmallWidget(label: 'Actualizado ayer')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_body_small` |
| `DsTextLabelLargeWidget` | Etiqueta de una acción destacada. Reserva el ancho del control para la etiqueta. · `DsTextLabelLargeWidget(label: 'Continuar')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_label_large` |
| `DsTextLabelMediumWidget` | Etiqueta de un ítem compacto. Dale un espacio acotado dentro del ítem. · `DsTextLabelMediumWidget(label: 'Favoritos')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_label_medium` |
| `DsTextLabelSmallWidget` | Texto de una insignia o metadato breve. Usa espacio reducido con texto muy breve. · `DsTextLabelSmallWidget(label: 'Nuevo')` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_label_small` |
| `DsInlineTextWidget` | Texto breve con rol configurable · `DsInlineTextWidget(label: 'Estado', role: DsTextStyleKey.labelLarge)` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.ds_inline_text` |
| `DsTextParagraphWidget` | Lectura en varias líneas · `DsTextParagraphWidget(label: 'Consulta los detalles.', maxLines: 3)` | [Fuente](../lib/ui/widgets/ds_text_widgets.dart) | `ds.widget.text_paragraph` |

<a id="ds.widget.text_display_large"></a>
<a id="ds.widget.text_display_medium"></a>
<a id="ds.widget.text_display_small"></a>
<a id="ds.widget.text_headline_large"></a>
<a id="ds.widget.text_headline_medium"></a>
<a id="ds.widget.text_headline_small"></a>
<a id="ds.widget.text_title_large"></a>
<a id="ds.widget.text_title_medium"></a>
<a id="ds.widget.text_title_small"></a>
<a id="ds.widget.text_body_large"></a>
<a id="ds.widget.text_body_medium"></a>
<a id="ds.widget.text_body_small"></a>
<a id="ds.widget.text_label_large"></a>
<a id="ds.widget.text_label_medium"></a>
<a id="ds.widget.text_label_small"></a>
<a id="ds.widget.ds_inline_text"></a>
<a id="ds.widget.text_paragraph"></a>
### Elegir el rol y reservar espacio

Elige el rol por la función del texto y usa el tamaño como grado de énfasis
dentro de la familia. Da a `display` y `headline` un ancho generoso. En tarjetas
o barras reserva espacio para títulos breves, y en controles compactos usa
etiquetas de una línea. Para lectura continua, usa el párrafo con ancho acotado
y altura acorde al número de líneas. `normal`, `detail` y `display` del párrafo
usan respectivamente `bodyMedium`, `bodySmall` y `headlineMedium`.
Consulta la [escala Material de TextTheme](https://api.flutter.dev/flutter/material/TextTheme-class.html).

Elige en este orden:

1. **Función.** Escoge `display`, `headline`, `title`, `body` o `label` según el
   propósito del texto.
2. **Jerarquía.** Usa `large`, `medium` o `small` según el énfasis dentro de esa familia.
3. **Comportamiento.** Las 15 especializaciones `DsText*Widget` muestran una
   sola línea. Usa `DsInlineTextWidget` si el rol se selecciona dinámicamente.
   Usa `DsTextParagraphWidget` para varias líneas con un rol predefinido o uno
   explícito del `TextTheme` a través de `role`.

Por ejemplo, `DsTextBodyMediumWidget` y este párrafo comparten el rol `bodyMedium`.
El párrafo puede ocupar hasta cuatro líneas. Para otros roles multilínea, como
`bodyLarge`, pasa `role: DsTextStyleKey.bodyLarge`. El rol explícito tiene
prioridad sobre `paragraphStyle`.

```dart
DsTextParagraphWidget(
  label: 'Consulta los movimientos recientes y revisa el resumen de tu cuenta.',
  paragraphStyle: DsTextParagraphStyle.normal,
  maxLines: 4,
)
```

Personaliza fuente, tamaño, peso e interlineado en el `TextTheme` de la app o
del `Theme` local. El rol tipográfico no anuncia por sí solo un encabezado
accesible. Añade la semántica de encabezado en la composición cuando corresponda.

```dart
Semantics(
  header: true,
  child: DsTextHeadlineMediumWidget(label: 'Actividad reciente'),
)
```

El texto en línea se ajusta al espacio disponible y conserva el escalado
del usuario como entrada a la medición. Un `overflow` explícito, incluido el del
estilo del tema, delega el desbordamiento a Flutter sin ajuste de fuente.
Usa texto breve y amplía el contenedor si el mínimo de ajuste no basta.

## Ítems de grilla e indicador

| Componente | Propósito y ejemplo mínimo | API | ID de galería |
| --- | --- | --- | --- |
| `DsItemWidget` | Ítem pasivo · `DsItemWidget(label: 'Favoritos', child: DsIconWidget(icon: Icons.star))` | [Fuente](../lib/ui/widgets/ds_item_widget.dart) | `ds.widget.item` |
| `DsItemButtonWidget` | Acción controlada · `DsItemButtonWidget(label: 'Abrir', child: DsIconWidget(icon: Icons.folder), onPressed: open)` | [Fuente](../lib/ui/widgets/ds_item_button_widget.dart) | `ds.widget.item_button` |
| `DsLoadingWidget` | Carga indeterminada · `DsLoadingWidget(semanticLabel: 'Cargando resultados')` | [Fuente](../lib/ui/widgets/ds_loading_widget.dart) | `ds.widget.loading` |

<a id="ds.widget.item"></a>
<a id="ds.widget.item_button"></a>
<a id="ds.widget.loading"></a>
### Componer la grilla

Los ítems comparten `DsSurfaceVariant.filled` y `DsSurfaceVariant.outlined`.
El tamaño preferido por defecto es el cuadrado `spacingXXl` (64 × 64 con los
tokens base). La etiqueta usa `DsTextParagraphWidget` con el rol `labelMedium`
y el escalado del usuario.
Si necesita varias líneas, conserva su ancho y crece en altura cuando el padre
lo permite. Usa una grilla que admita alturas variables. Si una palabra larga
se parte al ampliar el texto, elige una celda más ancha. Con una altura máxima,
el ítem muestra las líneas que quepan y usa elipsis. Si el espacio es demasiado
pequeño incluso para una línea, reduce visualmente esa línea como último recurso.
El texto completo sigue disponible para accesibilidad. El `child` debe ser
compacto y pasivo.

La prioridad visual del botón es **oculto → carga → error → selección →
deshabilitado → normal**. El callback depende de `canInteract`. Un error puede
permitir reintentar y una selección deshabilitada conserva su marca sin
activar. La carga reemplaza el contenido visual por un `DsLoading` y mantiene
la etiqueta. Puedes definir `loadingSemanticLabel` en el idioma de tu app.

`primary`, `secondary`, `neutral` y `danger` se resuelven con `ColorScheme`.
`success` y `warning` usan `DsSemanticColorsExtension` o la paleta de
respaldo según el brillo. `filled` usa pares de contenedor y contenido.
`outlined` utiliza `surface` y `onSurface`, con la intención aplicada al borde.
El error usa los roles `error` y añade un símbolo. La selección añade una marca.
El botón deriva el color de la etiqueta de la misma superficie y conserva las
demás propiedades de `TextTheme.labelMedium`.


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

**Local demonstrations** muestra `DsPrimaryButtonWidget` y `DsSecondaryButtonWidget`,
clases exclusivas del ejemplo en `example.ds.widgets.buttons`.

BienvenidoApp es una referencia de comportamiento y anatomía. Este ejemplo no
depende de su código ni configuración.
