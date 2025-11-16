Aquí va el `secondary-menu-builder-doc.md` listo para pegar en tu carpeta de `builders` (o donde estés dejando la doc del arquetipo):

````md
# Secondary Menu Builder · Guía de Uso

Este documento describe el uso de `PageWithSecondaryMenuBuilder` y sus
layouts asociados:

- `SecondaryMenuMobileLayout`
- `SecondaryMenuSidePanelLayout`
- `SecondaryMenuMobileLayoutBuilder`
- `SecondaryMenuSidePanelLayoutBuilder`

Su objetivo es ofrecer un **shell reutilizable** para páginas que necesitan
un **menú secundario** consistente en toda la app, sincronizado con
`BlocSecondaryMenuDrawer` a través de `AppManager`.

---

## 1. Propósito y responsabilidades

`PageWithSecondaryMenuBuilder`:

- **Sí hace**:
  - Construir el layout de la página con:
    - Contenido principal (`content`).
    - Menú secundario (acciones de `BlocSecondaryMenuDrawer`).
  - Adaptar el layout según el `deviceType` de `BlocResponsive`:
    - Mobile → fila flotante de acciones (botones cuadrados).
    - Tablet/Desktop/TV → panel lateral con acciones secundarias.
  - Mantener el menú sincronizado con el bloc (`itemsStream`).

- **No hace**:
  - Navegación.
  - Lógica de negocio.
  - Acceso a capas de dominio o data.

Este widget vive 100% en la **capa UI del arquetipo** y asume que el wiring
de `AppManager` ya está hecho.

---

## 2. Integración con AppManager y BlocSecondaryMenuDrawer

`PageWithSecondaryMenuBuilder` recibe un `AppManager`:

```dart
class PageWithSecondaryMenuBuilder extends StatelessWidget {
  const PageWithSecondaryMenuBuilder({
    required this.app,
    required this.content,
    super.key,
    this.menuItemsOverride,
    this.panelColumns = 2,
    this.secondaryOnRight = true,
    this.animate = true,
    this.backgroundColor,
    this.safeArea = true,
    this.mobileBuilder,
    this.sidePanelBuilder,
  });

  final AppManager app;
  BlocResponsive get responsive => app.responsive;
  final Widget content;
  final List<ModelMainMenuModel>? menuItemsOverride;
  // ...
}
````

El menú secundario se alimenta desde:

```dart
BlocSecondaryMenuDrawer get secondaryMenu => _config.blocSecondaryMenuDrawer;
```

Y el builder se suscribe a:

```
StreamBuilder<List<ModelMainMenuModel>>(
  stream: app.secondaryMenu.itemsStream,
  initialData: app.secondaryMenu.listMenuOptions,
  // ...
)
```

De esta forma:

* Cualquier cambio en `BlocSecondaryMenuDrawer` se refleja automáticamente
  en el menú secundario de la página.
* Puedes seguir usando la API pública del bloc:

    * `addSecondaryMenuOption(...)`
    * `removeSecondaryMenuOption(label)`
    * `clearSecondaryDrawer()`

---

## 3. Comportamiento por dispositivo

### 3.1 Mobile (`ScreenSizeEnum.mobile`)

Layout por defecto: `SecondaryMenuMobileLayout`.

* Fila flotante de botones cuadrados en la parte inferior.
* Cada botón se construye a partir de `ModelMainMenuModel`:

    * `iconData` → ícono central.
    * `label` / `description` → tooltip.
    * `onPressed` → acción.

Firma del layout:

```
typedef SecondaryMenuMobileLayoutBuilder = Widget Function(
  BuildContext context,
  BlocResponsive responsive,
  Widget content,
  List<ModelMainMenuModel> items,
  Color backgroundColor,
  bool animate,
);
```

Implementación usada por defecto:

```
SecondaryMenuMobileLayout.defaultBuilder(...)
```

### 3.2 Tablet / Desktop / TV

Layout por defecto: `SecondaryMenuSidePanelLayout`.

* Panel lateral con acciones secundarias.
* Ancho configurado en **columnas** (`panelColumns`).
* Posición configurable (`secondaryOnRight`).

Firma del layout:

```
typedef SecondaryMenuSidePanelLayoutBuilder = Widget Function(
  BuildContext context,
  BlocResponsive responsive,
  Widget content,
  List<ModelMainMenuModel> items,
  Color backgroundColor,
  int panelColumns,
  bool secondaryOnRight,
  bool animate,
);
```

Implementación usada por defecto:

```
SecondaryMenuSidePanelLayout.defaultBuilder(...)
```

---

## 4. Uso básico

### 4.1 Desde una página de la app

```
class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;

    return PageWithSecondaryMenuBuilder(
      app: app,
      content: const AccountsView(),
    );
  }
}
```

### 4.2 Poblado del menú secundario

En algún punto de inicialización (por ejemplo, en un presenter / manager
de UI), puedes configurar las opciones:

```
void setupSecondaryMenu(AppManager app) {
  app.secondaryMenu.clearSecondaryDrawer();

  app.secondaryMenu.addSecondaryMenuOption(
    label: 'Filtrar',
    description: 'Filtrar cuentas',
    iconData: Icons.filter_list,
    onPressed: () {
      // acción: abrir filtros
    },
  );

  app.secondaryMenu.addSecondaryMenuOption(
    label: 'Nueva cuenta',
    description: 'Crear una nueva cuenta',
    iconData: Icons.add,
    onPressed: () {
      // acción: navegar a creación
    },
  );
}
```

> 👀 Importante: `PageWithSecondaryMenuBuilder` se suscribe al stream,
> así que puedes agregar / eliminar opciones en runtime y el menú se
> actualizará automáticamente.

---

## 5. Overrides y personalización

### 5.1 Reemplazar los items del menú (override de datos)

Usa `menuItemsOverride` cuando:

* Estás escribiendo **tests**.
* Quieres un menú totalmente custom para una página específica.
* No deseas depender del estado actual del bloc.

```
return PageWithSecondaryMenuBuilder(
  app: app,
  content: const AccountsView(),
  menuItemsOverride: <ModelMainMenuModel>[
    ModelMainMenuModel(
      label: 'Refrescar',
      iconData: Icons.refresh,
      onPressed: () {/* ... */},
      description: 'Refrescar información',
    ),
  ],
);
```

Reglas:

* `menuItemsOverride == null` → se usan los items de `app.secondaryMenu`.
* `menuItemsOverride.isEmpty` → no se muestra menú secundario.

---

### 5.2 Personalizar solo el layout mobile

```dart
Widget myCustomMobileLayout(
  BuildContext context,
  BlocResponsive responsive,
  Widget content,
  List<ModelMainMenuModel> items,
  Color backgroundColor,
  bool animate,
) {
  // Ejemplo: menús como chips en vez de botones cuadrados.
  return Container(
    color: backgroundColor,
    child: Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.marginWidth,
          ),
          child: content,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Wrap(
            spacing: 8,
            children: <Widget>[
              for (final ModelMainMenuModel it in items)
                ActionChip(
                  label: Text(it.label),
                  avatar: Icon(it.iconData),
                  onPressed: it.onPressed,
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

Uso:

```
PageWithSecondaryMenuBuilder(
  app: app,
  content: const AccountsView(),
  mobileBuilder: myCustomMobileLayout,
);
```

---

### 5.3 Personalizar solo el layout side panel

```
Widget myCustomSidePanelLayout(
  BuildContext context,
  BlocResponsive responsive,
  Widget content,
  List<ModelMainMenuModel> items,
  Color backgroundColor,
  int panelColumns,
  bool secondaryOnRight,
  bool animate,
) {
  // Ejemplo: panel con tabs o grouping.
  return SecondaryMenuSidePanelLayout(
    responsive: responsive,
    content: content,
    items: items,
    backgroundColor: backgroundColor,
    panelColumns: panelColumns,
    secondaryOnRight: secondaryOnRight,
    animate: animate,
  );
}
```

Uso:

```
PageWithSecondaryMenuBuilder(
  app: app,
  content: const AccountsView(),
  sidePanelBuilder: myCustomSidePanelLayout,
);
```

---

## 6. Consideraciones de diseño

* `PageWithSecondaryMenuBuilder`:

    * No llama `setSizeFromContext`; se asume que `BlocResponsive` ya fue
      sincronizado aguas arriba (por ejemplo, en `PageBuilder`).
    * No mezcla lógica de negocio: sólo layout + lectura de streams.

* Layout móvil:

    * Usa `SingleChildScrollView` horizontal para evitar overflow si hay
      muchas acciones.
    * Los tamaños se derivan de `gutterWidth` para respetar el sistema
      de spacing del arquetipo.

* Layout side panel:

    * Garantiza que el panel no ocupe todas las columnas:
      se asegura al menos 1 columna para el contenido principal.
    * Usa `Flexible` para evitar overflows horizontales en el `Row`.

---

## 7. Checklist de implementación

Antes de usar `PageWithSecondaryMenuBuilder` en una página real, verifica:

1. `AppManager` está correctamente configurado y accesible vía
   `context.appManager`.
2. `BlocSecondaryMenuDrawer` está registrado en la configuración de la app:

   ```dart
   BlocSecondaryMenuDrawer get secondaryMenu => _config.blocSecondaryMenuDrawer;
   ```
3. La página:

    * Usa `PageBuilder` o un wrapper que ya sincroniza `BlocResponsive`.
    * Invoca `PageWithSecondaryMenuBuilder` como shell de contenido.
4. En la inicialización de la pantalla:

    * Se limpian las opciones previas si aplica (`clearSecondaryDrawer()`).
    * Se agregan las opciones específicas del contexto actual.

