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
| `DsPrimaryButtonWidget` | Acción principal · `DsPrimaryButtonWidget(label: 'Guardar', onPressed: save)` | [Fuente](../lib/ui/widgets/ds_action_button_widget.dart) · [Ficha](#ds.widget.primary_button) | `ds.widget.primary_button` |
| `DsSecondaryButtonWidget` | Acción de menor énfasis · `DsSecondaryButtonWidget(label: 'Cancelar', onPressed: cancel)` | [Fuente](../lib/ui/widgets/ds_action_button_widget.dart) · [Ficha](#ds.widget.secondary_button) | `ds.widget.secondary_button` |
| `DsDropdownButtonWidget` | Selección de un valor controlada por el consumidor | [Fuente](../lib/ui/widgets/ds_dropdown_button_widget.dart) · [Ficha](#ds.widget.dropdown_button) | `ds.widget.dropdown_button` |
| `DsSelectInputWidget` | Campo de formulario con selección y validación controladas | [Fuente](../lib/ui/widgets/forms/ds_select_input_widget.dart) · [Ficha](#ds.widget.select_input) | `ds.widget.select_input` |
| `DsRadioGroupFieldWidget` | Grupo vertical de selección única con valor y validación controlados | [Fuente](../lib/ui/widgets/forms/ds_radio_group_field_widget.dart) · [Ficha](#ds.widget.radio_group_field) | `ds.widget.radio_group_field` |
| `DsChipsSelectWidget` | Selección múltiple con chips, valor y validación controlados | [Fuente](../lib/ui/widgets/forms/ds_chips_select_widget.dart) · [Ficha](#ds.widget.chips_select) | `ds.widget.chips_select` |
| `DsCheckboxFieldWidget` | Casilla binaria con valor y validación controlados | [Fuente](../lib/ui/widgets/forms/ds_checkbox_field_widget.dart) · [Ficha](#ds.widget.checkbox_field) | `ds.widget.checkbox_field` |
| `DsSwitchFieldWidget` | Interruptor de preferencias con valor y validación controlados | [Fuente](../lib/ui/widgets/forms/ds_switch_field_widget.dart) · [Ficha](#ds.widget.switch_field) | `ds.widget.switch_field` |
| `DsTextInputWidget` | Campo de texto con edición y validación controladas | [Fuente](../lib/ui/widgets/forms/ds_text_input_widget.dart) · [Ficha](#ds.widget.text_input) | `ds.widget.text_input` |
| `DsPasswordInputWidget` | Campo de contraseña con visibilidad y validación controlada por el consumidor | [Fuente](../lib/ui/widgets/forms/ds_password_input_widget.dart) · [Ficha](#ds.widget.password_input) | `ds.widget.password_input` |
| `DsEmailInputWidget` | Campo de correo de una línea con validación controlada | [Fuente](../lib/ui/widgets/forms/ds_email_input_widget.dart) · [Ficha](#ds.widget.email_input) | `ds.widget.email_input` |
| `DsNumberInputWidget` | Campo de una línea con teclado numérico y validación controlada | [Fuente](../lib/ui/widgets/forms/ds_number_input_widget.dart) · [Ficha](#ds.widget.number_input) | `ds.widget.number_input` |
| `DsDateInputWidget` | Fecha de calendario localizada, con límites inclusivos | [Fuente](../lib/ui/widgets/forms/ds_date_input_widget.dart) · [Ficha](#ds.widget.date_input) | `ds.widget.date_input` |
| `DsDateRangeInputWidget` | Rango localizado de fechas de calendario con límites inclusivos | [Fuente](../lib/ui/widgets/forms/ds_date_range_input_widget.dart) · [Ficha](#ds.widget.date_range_input) | `ds.widget.date_range_input` |
| `DsTimeInputWidget` | Hora del día localizada con selección y validación controladas | [Fuente](../lib/ui/widgets/forms/ds_time_input_widget.dart) · [Ficha](#ds.widget.time_input) | `ds.widget.time_input` |
| `DsFormStepperWidget` | Formulario lineal con paso activo y validación controlados | [Fuente](../lib/ui/widgets/forms/ds_form_stepper_widget.dart) · [Ficha](#ds.widget.form_stepper) | `ds.widget.form_stepper` |
| `DsFormActionsWidget` | Acciones adaptables de formulario con estados independientes | [Fuente](../lib/ui/widgets/forms/ds_form_actions_widget.dart) · [Ficha](#ds.widget.form_actions) | `ds.widget.form_actions` |
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
- `dsWidgetCatalog` aporta iconos, botones, texto responsive, tipografía DS y grillas.
  Consulta el [catálogo](../example/lib/ds_widget_catalog.dart) y sus fichas de
  [botones de acción](../example/lib/ds_action_button_catalog.dart),
  [selector](../example/lib/ds_dropdown_button_catalog.dart),
  [campo de selección](../example/lib/ds_select_input_catalog.dart),
  [grupo de radio](../example/lib/ds_radio_group_field_catalog.dart),
  [selección con chips](../example/lib/ds_chips_select_catalog.dart),
  [casilla de formulario](../example/lib/ds_checkbox_field_catalog.dart),
  [interruptor de formulario](../example/lib/ds_switch_field_catalog.dart),
  [campo de texto](../example/lib/ds_text_input_catalog.dart),
  [campo de contraseña](../example/lib/ds_password_input_catalog.dart),
  [campo de correo](../example/lib/ds_email_input_catalog.dart),
  [campo numérico](../example/lib/ds_number_input_catalog.dart),
  [campo de fecha](../example/lib/ds_date_input_catalog.dart),
  [campo de rango de fechas](../example/lib/ds_date_range_input_catalog.dart),
  [campo de hora](../example/lib/ds_time_input_catalog.dart),
  [formulario por pasos](../example/lib/ds_form_stepper_catalog.dart),
  [acciones de formulario](../example/lib/ds_form_actions_catalog.dart) y
  [tipografía e ítems](../example/lib/ds_item_family_catalog.dart).
- Las herramientas de galería del ejemplo usan el prefijo `example.ds.widgets.*`.

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

<a id="ds.widget.primary_button"></a>
### Botón primario

Usa `DsPrimaryButtonWidget` para la acción principal de una sección, como
«Guardar» o «Continuar». Usa la superficie `filled` y su intención inicial es
`primary`.

<a id="ds.widget.secondary_button"></a>
### Botón secundario

Usa `DsSecondaryButtonWidget` para una acción de menor énfasis, como «Cancelar»
o «Volver». Usa la superficie `outlined` y su intención inicial es `secondary`.

```dart
Wrap(
  spacing: context.dsTokens.spacingSm,
  runSpacing: context.dsTokens.spacingSm,
  children: [
    DsPrimaryButtonWidget(label: 'Guardar', icon: Icons.save, onPressed: save),
    DsSecondaryButtonWidget(label: 'Cancelar', onPressed: cancel),
  ],
)
```

Da a cada botón una etiqueta de acción localizada. El `icon` inicial es
decorativo. La etiqueta usa `TextTheme.labelLarge`, conserva el escalado del
usuario y se distribuye en varias líneas si hace falta. Deja espacio para un
objetivo táctil de al menos 48 × 48 píxeles lógicos y permite que la altura crezca
según la etiqueta. En una fila estrecha, da al botón un ancho acotado con
`Flexible` o permite que los botones pasen a otra fila con `Wrap`.

Controla el estado mediante `ModelInteractiveState`. La precedencia visual es
oculto → carga → error → selección → deshabilitado → normal. El callback depende
de `state.canInteract`, así que un error habilitado permite reintentar. Al pasar
un estado explícito, fija `semantic` a la intención deseada. `success` y `warning`
usan `DsSemanticColorsExtension` o el respaldo claro u oscuro. `danger` usa los
colores de error de `ColorScheme`.

Durante la carga, el indicador usa el espacio del icono inicial y la etiqueta
conserva su posición. Usa `loading` para suministrar otro `DsLoading` y
`loadingSemanticLabel` para localizar el estado que se anuncia. Consulta ambos
botones en la familia **Buttons** de la galería.

<a id="ds.widget.dropdown_button"></a>
### Selector de un valor

Usa `DsDropdownButtonWidget<T>` para elegir un valor en un filtro o dentro de
un campo compuesto. Cada `DropdownMenuItem<T>` tiene un valor único y no nulo.
Usa contenido de presentación en `child` y `enabled` para indicar si la opción
se puede elegir. El consumidor controla `value` y lo actualiza desde `onChanged`.

Para opciones textuales que sigan la tipografía del DS, usa
`DsTextBodyLargeWidget` si la etiqueta cabe en una línea. Si debe poder ocupar
varias líneas, usa `DsTextParagraphWidget` con `DsTextStyleKey.bodyLarge` y
ajusta `maxLines` al espacio disponible.

El `placeholder` se muestra cuando `value` es `null` o ya no está en la lista.
Actualizar `value` o `items` no llama a `onChanged`. Con el menú abierto, una
opción retirada o deshabilitada ya no puede confirmarse. Una lista vacía impide
abrir el menú.

Proporciona `state` siempre que `value` sea distinto de `null`. La visibilidad
y disponibilidad siguen ese estado y `enabled` permite bloquear el control
desde el contenedor. El valor válido sigue visible al deshabilitar el selector.

Usa `label` para mostrar el nombre del campo con `TextTheme.labelLarge`, o
`semanticLabel` cuando el nombre visible provenga del contenedor. El selector
y sus opciones reservan al menos 48 × 48 píxeles lógicos. Dale un ancho acotado
para que el texto largo pueda envolver. Usa `isExpanded` si debe ocupar todo
el ancho disponible.

```dart
InputDecorator(
  decoration: const InputDecoration(
    label: ExcludeSemantics(child: Text('Estado')),
    border: OutlineInputBorder(),
    floatingLabelBehavior: FloatingLabelBehavior.always,
  ),
  child: DsDropdownButtonWidget<String>(
    semanticLabel: 'Estado',
    isExpanded: true,
    value: status,
    state: status == null ? null : const ModelInteractiveState(),
    placeholder: 'Seleccionar estado',
    items: const [
      DropdownMenuItem(value: 'open', child: Text('Abierto')),
      DropdownMenuItem(value: 'closed', child: Text('Cerrado')),
    ],
    onChanged: onStatusChanged,
  ),
)
```

La ficha de la familia **Buttons** muestra el filtro, el campo con borde y
ejemplos sin opciones y con texto al 200 % en temas claro y oscuro.

<a id="ds.widget.select_input"></a>
### Campo de selección de formulario

Usa `DsSelectInputWidget` cuando quieras vincular una selección a
`ModelFieldState` y mostrar obligatoriedad, ayuda o error del formulario. Para
un filtro independiente o una composición propia, usa
[`DsDropdownButtonWidget<T>`](#ds.widget.dropdown_button).

Proporciona claves únicas y no vacías en `options`. `optionLabelBuilder`
permite mostrar una etiqueta localizada para cada clave. Si el estado trae un
valor vacío o una clave que ya no está en las opciones, se muestra el
`placeholder`. Al elegir otra opción, `onChangedAttempt` recibe una copia del
campo con el nuevo valor e `isDirty: true`. El consumidor acepta la propuesta y
gestiona la validación.

`required` muestra y anuncia la obligatoriedad. Usa `requiredSemanticLabel`
para localizar ese anuncio. El error de `field` sustituye
la ayuda y se expone a tecnologías de asistencia. `readOnly` identifica un
valor de consulta con un candado y un anuncio localizable mediante
`readOnlySemanticLabel`. `enabled: false` muestra el campo
deshabilitado y tiene prioridad si se combinan ambos estados. En los dos casos
se conserva la selección y se bloquea la edición.

Deja que el campo crezca en altura cuando el texto ocupe varias líneas. En un
formulario con altura limitada, coloca los campos en un contenedor desplazable.

```dart
DsSelectInputWidget(
  field: documentType,
  label: 'Tipo de documento',
  placeholder: 'Selecciona un tipo',
  required: true,
  options: const ['id_card', 'passport'],
  optionLabelBuilder: (key) => key == 'id_card' ? 'Cédula' : 'Pasaporte',
  onChangedAttempt: onDocumentTypeChanged,
)
```

La ficha de **Forms** incluye ejemplos controlados, con error, de solo lectura,
deshabilitados y con texto al 200 % en los dos temas.

<a id="ds.widget.radio_group_field"></a>
### Grupo de radio de formulario

Usa `DsRadioGroupFieldWidget` cuando convenga mostrar juntas unas pocas
opciones excluyentes. Proporciona claves únicas y no vacías en `options`, en
el orden en que deben aparecer. Usa `optionLabelBuilder` para presentar
etiquetas localizadas. Si la lista está vacía, `emptyMessage` permite
localizar el mensaje de ausencia de opciones.

El valor de `ModelFieldState.value` es la clave aceptada. Un valor vacío o
ausente de la lista se muestra sin selección. Activar una opción diferente
propone su clave con `isDirty: true` y conserva la validez, el error y las
sugerencias. Actualiza `field` para aceptar la propuesta.

El error sustituye a `helperText`. `required` indica obligatoriedad y el
consumidor decide cuándo validar. En solo lectura o deshabilitado se
conserva la selección y se bloquean los cambios. Localiza los avisos con
`requiredSemanticLabel` y `readOnlySemanticLabel`.

Toda la fila de cada opción admite activación. Usa Tab para entrar o salir
del grupo, las flechas para recorrer y proponer opciones y Espacio para
seleccionar la opción enfocada. Deja espacio para que crezcan las etiquetas y
los mensajes. Para un formulario con altura limitada, usa un contenedor
desplazable.

```dart
DsRadioGroupFieldWidget(
  field: movement,
  label: 'Tipo de movimiento',
  options: const ['income', 'expense'],
  optionLabelBuilder: (key) => key == 'income' ? 'Ingreso' : 'Gasto',
  emptyMessage: 'Sin opciones disponibles',
  onChangedAttempt: acceptMovement,
)
```

La ficha de **Forms** muestra los estados del grupo en ambos temas y permite
revisarlos con texto al 200 %.

<a id="ds.widget.chips_select"></a>
### Selección múltiple con chips

Usa `DsChipsSelectWidget` cuando varias opciones visibles puedan estar
activas a la vez. Pasa claves únicas y no vacías en `options`, en el orden de
presentación. `optionLabelBuilder` permite localizar las etiquetas.

Guarda un arreglo JSON de cadenas en `ModelFieldState.value`, como
`["catalog","inventory"]`. El campo muestra una selección vacía con `''`,
`[]` o un valor que no sea un arreglo JSON de cadenas. Conserva el valor
recibido hasta que el consumidor acepte una propuesta.

Al activar un chip, `onChangedAttempt` propone un nuevo arreglo con
`isDirty: true`. La propuesta conserva el orden de primera aparición,
elimina duplicados y añade al final las nuevas claves. Las claves ausentes
de `options` siguen en el JSON aunque no tengan chip visible. Al retirar la
última clave del arreglo, el campo propone `[]`.

El error del consumidor sustituye a `helperText`. `required` indica
obligatoriedad y el consumidor decide la cantidad válida de selecciones.
`readOnly` y `enabled: false` conservan el estado y bloquean el cambio.
Localiza los avisos con `requiredSemanticLabel` y `readOnlySemanticLabel`.
Usa `emptyMessage` cuando quieras localizar el mensaje de lista vacía.

Da al grupo un ancho acotado de al menos 48 píxeles lógicos y espacio
vertical para distribuir los chips y sus etiquetas. Tab recorre los chips
editables y Espacio alterna la selección del chip enfocado.

```dart
DsChipsSelectWidget(
  field: capabilities,
  label: 'Capacidades de la tienda',
  options: const ['catalog', 'inventory'],
  optionLabelBuilder: (key) => key == 'catalog' ? 'Catálogo' : 'Inventario',
  emptyMessage: 'Sin opciones disponibles',
  onChangedAttempt: acceptCapabilities,
)
```

La ficha de **Forms** muestra la selección múltiple y los estados del campo
con texto al 200 % en ambos temas.

<a id="ds.widget.checkbox_field"></a>
### Casilla de formulario

Usa `DsCheckboxFieldWidget` para una elección binaria independiente, como
aceptar los términos de un servicio o elegir recibir avisos. Guarda
`'true'` o `'false'` en `ModelFieldState.value`. El valor vacío se muestra
desmarcado. Los valores inesperados, como `' TRUE '`, también se muestran
desmarcados y se conservan hasta que el consumidor acepte una propuesta.
Normaliza los valores heredados al cargar el formulario si necesitas migrarlos.

Toda la fila activa la casilla. `onChangedAttempt` recibe el nuevo valor
canónico con `isDirty: true` y conserva la validación y las sugerencias. Pasa
el nuevo estado en `field` para aceptar el cambio. Deja que la etiqueta y el
mensaje de ayuda o error crezcan en altura. Coloca los enlaces a condiciones
y otros controles interactivos fuera de la fila.

`required` indica obligatoriedad y el consumidor decide cuándo mostrar el
error. El mensaje de error de `field` tiene prioridad sobre `helperText`.
`readOnly` y `enabled: false` conservan el estado marcado o desmarcado y
bloquean el cambio. Localiza los avisos con `requiredSemanticLabel` y
`readOnlySemanticLabel`. Con el teclado, usa Tab para llegar a la casilla
editable y Espacio para activarla.

```dart
DsCheckboxFieldWidget(
  field: terms,
  label: 'Acepto los términos del servicio',
  required: true,
  requiredSemanticLabel: 'Obligatorio',
  onChangedAttempt: acceptTerms,
)
```

La ficha de **Forms** muestra los estados del campo y texto al 200 % en ambos
temas.

<a id="ds.widget.switch_field"></a>
### Interruptor de formulario

Usa `DsSwitchFieldWidget` para una preferencia que se pueda encender o
apagar, como los avisos por correo. Usa [la casilla](#ds.widget.checkbox_field)
para elecciones como confirmar la aceptación de condiciones.

Guarda `'true'` o `'false'` en `ModelFieldState.value`. Un valor vacío o
inesperado se muestra apagado y se conserva hasta que el consumidor acepte
una propuesta. Al tocar la fila, pulsar Espacio con el foco en el campo o
arrastrar el interruptor a otro estado, `onChangedAttempt` propone el valor
canónico con `isDirty: true`. Un arrastre que vuelve al estado actual
conserva el valor. El consumidor acepta la propuesta al actualizar `field`.

La fila coloca el interruptor al final según la dirección de lectura y
permite que crezcan la etiqueta y la ayuda o el error. Coloca otros controles
interactivos fuera de la fila. El error de `field` tiene prioridad sobre la
ayuda. El consumidor decide qué valor es válido y cuándo mostrar el error.
`required` indica obligatoriedad. `readOnly` y `enabled: false` conservan el
estado y bloquean el cambio. Usa `requiredSemanticLabel` y
`readOnlySemanticLabel` para localizar los avisos.

```dart
DsSwitchFieldWidget(
  field: notifications,
  label: 'Activar avisos por correo',
  onChangedAttempt: acceptNotifications,
)
```

La ficha de **Forms** muestra los estados del campo y texto al 200 % en ambos
temas.

<a id="ds.widget.text_input"></a>
### Campo de texto de formulario

Usa `DsTextInputWidget` para editar texto con `ModelFieldState`. Cada edición
envía una propuesta con el texto tal como se escribió e `isDirty: true`. El
consumidor acepta el valor y determina la validez. El error de `field` tiene
prioridad sobre `helperText`. `required` indica la obligatoriedad del campo.

El controlador conserva la selección y la composición del teclado al actualizar
solo la validación o confirmar el texto que ya se está editando. Un cambio
externo de `field.value` se refleja sin emitir otra propuesta. Si necesitas
descartar un borrador y volver al mismo valor aceptado, recrea el campo con una
`Key` nueva.

Si una actualización externa desplaza un sufijo intacto que contiene la
composición activa, los extremos de la selección dentro de ese sufijo se
desplazan con el texto.

`onSubmittedAttempt` es opcional y recibe el texto actual. En un envío sin
ediciones se conserva `field.isDirty`. Configura `textInputType`,
`textInputAction` y `autofillHints` según el contenido. Elige `maxLines` mayor
que 1 para admitir varias líneas. `TextInputAction.next` avanza al siguiente
campo y `TextInputAction.newline` permite un salto de línea en modo multilínea.

El modo `readOnly` permite consultar, seleccionar y copiar el texto.
`enabled: false` bloquea la interacción. Los anuncios de obligatoriedad y solo
lectura se localizan con `requiredSemanticLabel` y `readOnlySemanticLabel`.

```dart
DsTextInputWidget(
  field: name,
  label: 'Nombre',
  placeholder: 'Escribe tu nombre',
  required: true,
  requiredSemanticLabel: 'Obligatorio',
  textInputAction: TextInputAction.next,
  onChangedAttempt: onNameChanged,
)
```

La ficha de **Forms** muestra edición controlada, error, solo lectura,
deshabilitado, varias líneas y texto al 200 % en ambos temas.

<a id="ds.widget.password_input"></a>
### Campo de contraseña

Usa `DsPasswordInputWidget` para contraseñas de una sola línea. El consumidor
acepta las propuestas de edición y valida mediante `ModelFieldState`. El error
del modelo tiene prioridad sobre `helperText`.

El valor empieza oculto. Al mostrarlo u ocultarlo se conserva la selección.
El campo lo vuelve a ocultar al salir del grupo formado por el editor y su
botón, al deshabilitar el campo o al pasar a solo lectura. Mientras el campo
sea editable se puede pegar. Copiar y cortar están bloqueados incluso cuando
la contraseña está visible.

El autocompletado usa `AutofillHints.password` por defecto. Para crear o cambiar
una contraseña usa `autofillHints: const [AutofillHints.newPassword]`. Pasa
`autofillHints: null` para desactivar el autocompletado. Localiza los nombres
del botón con `showPasswordLabel` y `hidePasswordLabel`, y los anuncios del campo
con `requiredSemanticLabel` y `readOnlySemanticLabel`.

```dart
DsPasswordInputWidget(
  field: password,
  label: 'Contraseña',
  placeholder: 'Escribe tu contraseña',
  required: true,
  requiredSemanticLabel: 'Obligatorio',
  showPasswordLabel: 'Mostrar contraseña',
  hidePasswordLabel: 'Ocultar contraseña',
  onChangedAttempt: onPasswordChanged,
)
```

El valor de `ModelFieldState` contiene la contraseña en claro. Consérvalo en
memoria solo durante el tiempo necesario y evita registrarlo o persistirlo.
La ficha de **Forms** usa datos ficticios y muestra visibilidad, error, solo
lectura, deshabilitado y texto al 200 % en ambos temas.

<a id="ds.widget.email_input"></a>
### Campo de correo electrónico

Usa `DsEmailInputWidget` para capturar un correo en una sola línea con el teclado
de correo. Proporciona una etiqueta localizada y, si hace falta, un ejemplo en
`placeholder`. El campo entrega el valor de `ModelFieldState` tal como se editó,
incluidos espacios y mayúsculas. Aplica la normalización que requiera el
formulario al validar o enviar. El error del modelo tiene prioridad sobre la
ayuda.

El autocompletado usa `AutofillHints.email` por defecto. Puedes configurar
`autofillHints: const [AutofillHints.username]` cuando el correo funciona como
identificador de inicio de sesión, o pasar `autofillHints: null` para
desactivarlo. La autocorrección y las sugerencias del teclado están
desactivadas. Usa `onSubmittedAttempt` y `textInputAction` si el formulario
necesita reaccionar al envío desde el teclado.

```dart
DsEmailInputWidget(
  field: email,
  label: 'Correo electrónico',
  placeholder: 'nombre@example.com',
  required: true,
  requiredSemanticLabel: 'Obligatorio',
  onChangedAttempt: onEmailChanged,
)
```

El modo `readOnly` permite consultar, seleccionar y copiar el correo. Usa
`requiredSemanticLabel` y `readOnlySemanticLabel` para localizar los anuncios
de estado. La ficha de **Forms** muestra edición, error, solo lectura,
deshabilitado y texto al 200 % en ambos temas.

<a id="ds.widget.number_input"></a>
### Campo numérico

Usa `DsNumberInputWidget` para capturar texto en una sola línea con un teclado
numérico. Por defecto solicita un teclado para enteros sin signo. Configura
`signed` y `decimal` según las teclas que quieras solicitar a la plataforma.
El formulario decide qué valores acepta.

Las propuestas de edición y envío conservan el valor de `ModelFieldState`
tal como se escribió o pegó, incluidos ceros iniciales, espacios, signos y
valores intermedios como `-` y `1,`. El consumidor interpreta `.` y `,`,
valida la precisión y el rango, y convierte el texto cuando lo necesita.
El error del modelo tiene prioridad sobre la ayuda.

```dart
DsNumberInputWidget(
  field: measurement,
  label: 'Medición',
  signed: true,
  decimal: true,
  onChangedAttempt: onMeasurementChanged,
)
```

Usa `onSubmittedAttempt` y `textInputAction` para reaccionar al envío desde el
teclado. `autofillHints` es opcional y tiene valor inicial `null`. En
`readOnly` se puede consultar, seleccionar y copiar el valor. Usa
`requiredSemanticLabel` y `readOnlySemanticLabel` para localizar los anuncios
de estado. La ficha de **Forms** muestra un entero, un decimal con signo,
error, solo lectura, deshabilitado y texto al 200 % en ambos temas.

<a id="ds.widget.date_input"></a>
### Campo de fecha

Usa `DsDateInputWidget` para escoger un día de calendario. Guarda el valor en
`ModelFieldState.value` como `yyyy-MM-dd` y usa `''` para un campo vacío.
El widget muestra la fecha con el idioma de la app y conserva un valor
inválido como texto para que se pueda identificar y corregir. Para adaptar
un timestamp existente, decide primero qué día representa en tu dominio y
guarda sus componentes de calendario en el formato del campo.

```dart
DsDateInputWidget(
  field: appointment,
  label: 'Fecha de la cita',
  placeholder: 'Selecciona una fecha',
  firstDate: DateTime(2026, 11, 1),
  lastDate: DateTime(2026, 11, 30),
  required: true,
  requiredSemanticLabel: 'Obligatorio',
  onChangedAttempt: acceptAppointment,
)
```

Ambos límites son inclusivos y se comparan por año, mes y día. El selector
abre en el valor aceptado si está dentro del rango. En los demás casos abre
en hoy, ajustado al límite más cercano si corresponde. El diálogo permite
escoger un día en el calendario o escribirlo en el formato local.

Al confirmar un día diferente, `onChangedAttempt` propone el valor con
`isDirty: true`. Actualiza `field` para aceptar el cambio. Cancelar o confirmar
el mismo día conserva el estado. El consumidor gestiona la validación, la
limpieza y el envío. `errorText` tiene prioridad sobre `helperText`.

Usa `readOnly` para consultar la fecha con el campo habilitado y `enabled`
para controlar su disponibilidad. Usa `requiredSemanticLabel` y
`readOnlySemanticLabel` para localizar los anuncios de estado. Configura los
delegados de localización de `material_ui` para los idiomas de la app. La
ficha de **Forms** muestra el campo y el selector en ambos temas, con un
control para probar texto al 200 %.

<a id="ds.widget.date_range_input"></a>
### Campo de rango de fechas

Usa `DsDateRangeInputWidget` para escoger un periodo de calendario. Guarda
un objeto JSON con `start` y `end` en `ModelFieldState.value`. Cada fecha usa
`yyyy-MM-dd`. Usa `''` para representar un campo vacío. Al cargar timestamps
existentes, conviértelos al día de calendario que corresponda a tu dominio.

```dart
DsDateRangeInputWidget(
  field: const ModelFieldState(
    value: '{"start":"2026-11-19","end":"2026-11-23"}',
  ),
  label: 'Periodo de reserva',
  placeholder: 'Selecciona un rango de fechas',
  firstDate: DateTime(2026, 11, 1),
  lastDate: DateTime(2026, 11, 30),
  onChangedAttempt: acceptReservation,
)
```

Los límites `firstDate` y `lastDate` son obligatorios e inclusivos. Ambos
extremos pueden ser iguales para reservar un día. El calendario abre sin
preselección si el rango recibido está incompleto, invertido o fuera de los
límites. Un valor que no se puede interpretar muestra el `placeholder` si se
proporcionó. Las fechas de un rango completo y ordenado se muestran en el
idioma de la app aunque sus extremos queden fuera de los límites actuales.

Al guardar un rango diferente en el calendario o confirmar ambas fechas
escritas, `onChangedAttempt` propone el nuevo valor con `isDirty: true`.
Actualiza `field` para aceptarlo. Cancelar o confirmar los mismos extremos
conserva el estado. La validación del formulario la controla el consumidor.
`errorText` tiene prioridad sobre `helperText`.

El campo expone inicio y fin en el valor accesible y vuelve a recibir el
foco cuando se cierra el selector si sigue disponible. Usa `readOnly` para
consultar el rango y `enabled` para controlar su disponibilidad. La ficha
de **Forms** muestra ambos temas y permite activar texto al **200 %** para
el campo. `material_ui` aplica un máximo de **130 %** dentro del selector.

<a id="ds.widget.time_input"></a>
### Campo de hora

Usa `DsTimeInputWidget` para escoger una hora del día. Guarda `HH:mm`, de
`00:00` a `23:59`, en `ModelFieldState.value`. Usa `''` para el campo vacío.
Al cargar timestamps existentes, interpreta primero la hora que corresponde
al dominio y guarda sus componentes de hora y minuto.

```dart
DsTimeInputWidget(
  field: const ModelFieldState(value: '21:30'),
  label: 'Hora de cierre',
  placeholder: 'Selecciona una hora',
  onChangedAttempt: acceptClosingTime,
)
```

El campo y el diálogo siguen el idioma y la preferencia horaria de la app.
El diálogo abre con un reloj y permite cambiar al modo de escritura. Abre en
la hora aceptada si es válida, o en la hora local actual. Un valor inválido
se muestra tal como se recibió para facilitar su corrección.

Al confirmar una hora distinta, `onChangedAttempt` propone el nuevo valor
con `isDirty: true`. Actualiza `field` para aceptarlo. Cancelar o confirmar la
misma hora conserva el estado. `errorText` tiene prioridad sobre `helperText`.
El consumidor gestiona la validación, la limpieza y el envío.

La ficha de **Forms** muestra ambos temas, formatos de 12 y 24 horas y texto
al **200 %**. El campo respeta la escala de la app. El diálogo limita su
escala al **110 %**, según el tamaño que reserva el selector de
`material_ui`, para que los editores y sus etiquetas quepan. Desde el
diálogo se puede activar el modo de escritura con el teclado.

<a id="ds.widget.form_stepper"></a>
### Formulario por pasos

Usa `DsFormStepperWidget` para un formulario lineal. Cada `DsFormStep`
requiere un ID estable y único, un título y un contenido. La lista tiene al
menos un paso y `activeStepId` corresponde a uno de sus IDs. El indicador
muestra la posición y el título activo. Las acciones de navegación usan
[`DsFormActionsWidget`](#ds.widget.form_actions). La acción de retroceso
precede a la primaria. Las dos se muestran con anchos iguales en fila si
caben las etiquetas escaladas y se apilan cuando necesitan más espacio.
Una sola acción ocupa todo el ancho. Si `primaryState.isVisible` es `false`
en el primer paso, se retira el pie y su separación del contenido.

`onStepChangeAttempt` recibe el ID del paso adyacente. Valida en el consumidor
cuando corresponda y actualiza `activeStepId` para aceptar el cambio.
`onFinishAttempt` recibe la solicitud de envío desde el último paso.
Conserva los valores y errores en los `ModelFieldState` del formulario y
pásalos a campos como `DsTextInputWidget`. Al regresar, el paso se monta con
esos modelos. El encabezado recibe foco cuando cambia el paso activo.
La navegación por teclado recorre los campos y acciones de cada formulario
como un grupo.

```dart
DsFormStepperWidget(
  steps: [
    DsFormStep(id: 'contact', title: 'Contacto', content: contactForm),
    DsFormStep(id: 'details', title: 'Detalles', content: detailsForm),
  ],
  activeStepId: activeStepId,
  onStepChangeAttempt: validateStepChange,
  onFinishAttempt: submitForm,
  primaryState: ModelInteractiveState(
    semantic: ModelInteractiveSemantic.primary,
    isLoading: isSubmitting,
  ),
  previousLabel: 'Atrás',
  continueLabel: 'Continuar',
  finishLabel: 'Finalizar',
  loadingSemanticLabel: 'Enviando',
  progressLabelBuilder: (step, total) => 'Paso $step de $total',
)
```

Activa `primaryState.isLoading` antes de esperar una validación o un envío
asíncrono. Durante la carga, la acción principal muestra su indicador y
anuncia `loadingSemanticLabel`. Las acciones visibles quedan deshabilitadas.
Si solo se deshabilita la acción primaria, **Atrás** sigue disponible a
partir del segundo paso. La ficha de **Forms** permite probar validación,
regreso, carga y etiquetas largas con texto al 200 % en ambos temas.

<a id="ds.widget.form_actions"></a>
### Acciones de formulario

Usa `DsFormActionsWidget` para agrupar la acción principal y una secundaria
opcional. `primaryLabel` y `onPrimary` son obligatorios. Omite
`secondaryLabel` para mostrar solo la primaria. Si proporcionas la etiqueta
secundaria y omites `onSecondary`, la acción se muestra deshabilitada.

```dart
DsFormActionsWidget(
  primaryLabel: 'Guardar cambios',
  onPrimary: save,
  primaryState: ModelInteractiveState(
    semantic: ModelInteractiveSemantic.primary,
    isLoading: isSaving,
  ),
  primaryLoadingSemanticLabel: 'Guardando',
  secondaryLabel: 'Cancelar edición',
  onSecondary: cancel,
  secondaryState: ModelInteractiveState(
    semantic: ModelInteractiveSemantic.secondary,
    isEnabled: canCancel,
    isLoading: isCanceling,
  ),
  secondaryLoadingSemanticLabel: 'Cancelando',
)
```

Controla cada `ModelInteractiveState` desde el formulario. Un botón en carga
mantiene su etiqueta accesible, anuncia su estado y bloquea su propia
activación. Define los anuncios de carga en el idioma de la app.

La secundaria va primero visualmente y al navegar con Tab. Ambas acciones
ocupan anchos iguales en fila si caben sus etiquetas escaladas. Cuando falta
espacio, se apilan y permiten etiquetas multilínea. Una sola acción visible
llena el ancho disponible. Si ambas están ocultas, el grupo se contrae. Dale
al menos 48 píxeles lógicos de ancho y espacio para crecer en altura. La ficha
de **Forms** permite comprobar la carga independiente, la visibilidad,
la habilitación y el texto al 200 % en ambos temas.

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

BienvenidoApp es una referencia de comportamiento y anatomía. Este ejemplo no
depende de su código ni configuración.
