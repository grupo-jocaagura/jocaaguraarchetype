# JocaaguraArchetype

Este paquete es diseñado para asegurar que las funcionalidades transversales de las aplicaciones desarrolladas por Jocaagura estén resueltas al inicio de cada proyecto. Esto proporciona una base uniforme y robusta para los equipos de desarrollo, facilitando la integración y el escalado de nuevas características y funcionalidades.

## LabColor

### Descripción
`LabColor` es una clase utilitaria que proporciona métodos para convertir colores entre diferentes espacios de color, específicamente RGB y Lab (CIELAB). Estos métodos son útiles para manipulaciones precisas de color que pueden ser necesarias en temas personalizados, visualización de datos, entre otros.

### Parámetros
- `lightness`: La luminosidad del color.
- `a`: Componente a del color en el espacio CIELAB.
- `b`: Componente b del color en el espacio CIELAB.

### Ejemplo de uso en lenguaje natural
Para convertir un color RGB a su correspondiente en el espacio Lab y ajustar su luminosidad, se puede utilizar el método `withLightness` después de convertir el color con `colorToLab`.

### Ejemplo de uso en código Dart
```dart
Color colorRGB = Color.fromARGB(255, 255, 0, 0); // Color rojo
List<double> labColor = LabColor.colorToLab(colorRGB);
LabColor lab = LabColor(labColor[0], labColor[1], labColor[2]);
LabColor adjustedLab = lab.withLightness(50.0);
```
## ProviderTheme

### Descripción
`ProviderTheme` actúa como intermediario entre los servicios de temas y las interfaces de usuario que consumen estos temas. Esta clase facilita la aplicación de temas personalizados y la manipulación de colores a nivel de aplicación, permitiendo una integración fluida y coherente del diseño visual a través de las funcionalidades proporcionadas por `ServiceTheme`.

### Parámetros
- `serviceTheme`: Instancia de `ServiceTheme` que provee los métodos necesarios para la manipulación de temas y colores.

### Ejemplo de uso en lenguaje natural
Para obtener un tema personalizado basado en un esquema de colores y un tema de texto proporcionados, se puede utilizar el método `customThemeFromColorScheme` de `ProviderTheme`.

### Ejemplo de uso en código Dart
```dart
ColorScheme colorScheme = ColorScheme.light(primary: Color(0xFF00FF00));
TextTheme textTheme = TextTheme(bodyText1: TextStyle(color: Color(0xFF000000)));
ProviderTheme providerTheme = ProviderTheme(ServiceTheme());
ThemeData customTheme = providerTheme.customThemeFromColorScheme(colorScheme, textTheme);
```
## ServiceTheme

### Descripción
`ServiceTheme` proporciona una serie de métodos para la creación y manipulación de temas y colores. Incluye funciones para convertir colores RGB a `MaterialColor`, oscurecer y aclarar colores, y generar temas personalizados a partir de esquemas de colores. Es fundamental para gestionar la apariencia visual de las aplicaciones desarrolladas.

### Parámetros
No aplica directamente, ya que `ServiceTheme` proporciona métodos estáticos y servicios sin almacenar estados específicos.

### Ejemplo de uso en lenguaje natural
Para convertir un color RGB a `MaterialColor`, que luego puede ser utilizado en la configuración de un tema, se utiliza el método `materialColorFromRGB`.

### Ejemplo de uso en código Dart
```dart
ServiceTheme serviceTheme = ServiceTheme();
MaterialColor materialColor = serviceTheme.materialColorFromRGB(255, 0, 0); // Color rojo
```
## BlocTheme

### Descripción
`BlocTheme` es un módulo del BLoC (Business Logic Component) que gestiona el estado del tema dentro de la aplicación. Permite la actualización dinámica de temas, facilitando la adaptación de la interfaz de usuario a las preferencias del usuario o a condiciones específicas, como el cambio entre modos claro y oscuro.

### Parámetros
- `providerTheme`: Instancia de `ProviderTheme` que permite acceder a los servicios de manipulación de temas y colores proporcionados por `ServiceTheme`.

```dart
ProviderTheme providerTheme = ProviderTheme(ServiceTheme());
BlocTheme blocTheme = BlocTheme(providerTheme);
```

### Ejemplo de uso en lenguaje natural
Para cambiar el tema de la aplicación de forma dinámica en respuesta a una acción del usuario, como puede ser el cambio entre un tema claro y un tema oscuro, se puede utilizar el método `customThemeFromColorScheme` proporcionado por `BlocTheme`.

### Ejemplo de uso en código Dart
```dart
void main(){
  ColorScheme lightScheme = ColorScheme.light();
  ColorScheme darkScheme = ColorScheme.dark();
  TextTheme textTheme = TextTheme(bodyText1: TextStyle(color: Colors.white));

// Supongamos que esto se invoca cuando el usuario cambia el modo de tema
  bool isDarkMode = true; // Esto podría estar vinculado a alguna preferencia del usuario
  ThemeData themeToUpdate = isDarkMode
      ? blocTheme.providerTheme.serviceTheme.customThemeFromColorScheme(darkScheme, textTheme, true)
      : blocTheme.providerTheme.serviceTheme.customThemeFromColorScheme(lightScheme, textTheme, false);

  blocTheme._themeDataController.value = themeToUpdate;
}

```

### Ejemplo de uso en lenguaje natural
Para generar un tema aleatorio, lo que puede ser útil durante pruebas o como una función de personalización del usuario, se utiliza el método `randomTheme` de `BlocTheme`.

### Ejemplo de uso en código Dart
```dart
// Esta función podría ser activada por una acción del usuario, como presionar un botón 'Sorpresa me'
void main(){
  blocTheme.randomTheme();
}
```
## BlocLoading

### Descripción
`BlocLoading` es un componente del BLoC que gestiona los mensajes de carga dentro de la aplicación. Proporciona una manera centralizada de mostrar y actualizar mensajes de estado de carga, lo que es útil para informar a los usuarios sobre operaciones en curso.

### Parámetros
- `_loadingController`: Controlador de tipo `BlocGeneral<String>` que maneja el estado del mensaje de carga actual.

```dart
void main(){
  BlocLoading blocLoading = BlocLoading();
}
```

### Ejemplo de uso en lenguaje natural
Para mostrar un mensaje de carga durante una operación que puede tardar un tiempo, como la carga de datos de red, se utiliza el método `loadingMsgWithFuture`. Este método establece el mensaje de carga antes de ejecutar la operación y lo limpia automáticamente al finalizar.

```dart
void main()async{
  await blocLoading.loadingMsgWithFuture(
      "Cargando datos...",
          () async {
        await Future.delayed(Duration(seconds: 2)); // Simulando una operación de carga de datos
      }
  );

}
```
## BlocResponsive

### Descripción
`BlocResponsive` es un componente crucial para la gestión de la interfaz de usuario adaptativa en una aplicación. Este BLoC facilita el manejo de tamaños de pantalla y visibilidad de componentes, permitiendo que la aplicación se ajuste de manera óptima a diferentes resoluciones y dispositivos.

### Importancia de `widthByColumns` y `getDeviceType`
`widthByColumns` es esencial para calcular el ancho basado en un número específico de columnas de la cuadrícula, ajustándose automáticamente a cambios de tamaño de pantalla para una mayor flexibilidad en el diseño. Por otro lado, `getDeviceType` simplifica la adaptación al evaluar solo el ancho de la pantalla para determinar el tipo de dispositivo, lo cual es crucial para la visualización de menús principal y secundario de manera adecuada.

### Métodos Principales
- `setSizeFromContext(BuildContext context)`: Ajusta el tamaño de la pantalla basado en el contexto actual.
- `setSizeForTesting(Size size)`: Define un tamaño de pantalla para pruebas.
- `showAppbar(bool val)`: Modifica la visibilidad de la barra de aplicaciones.

```dart
void main(){
  BlocResponsive blocResponsive = BlocResponsive();

}
```

### Ejemplo de uso en lenguaje natural
Para actualizar el tamaño de la pantalla cuando el dispositivo cambia su orientación o tamaño, se puede usar el método `setSizeFromContext`.

```dart
void main(){
  BuildContext context; // Contexto actual de la aplicación
  blocResponsive.setSizeFromContext(context);
}
```

### Ejemplo de uso en lenguaje natural
Para determinar el espacio que debe ocupar un widget basado en la cantidad de columnas y ajustarse dinámicamente con los cambios de tamaño, se utiliza `widthByColumns` en combinación con `AspectRatio`, lo que mejora la responsividad y la experiencia de usuario.

### Ejemplo de uso en código Dart

```dart
void main(){
  Widget responsiveWidget = AspectRatio(
    aspectRatio: 16 / 9,
    child: Container(
      width: blocResponsive.widthByColumns(4), // Asume que el widget debe ocupar 4 columnas
      decoration: BoxDecoration(color: Colors.blue),
    ),
  );
}
```
### Aclaración sobre cálculo de gutters y columnWidth
El cálculo de `gutters` y `columnWidth` sigue lineamientos de diseño responsivo que permiten una maquetación flexible y eficiente. Los gutters son los espacios entre columnas y el `columnWidth` es el ancho de cada columna, ambos ajustados dinámicamente para responder a diferentes tamaños de pantalla y orientaciones.

## BlocNavigator

### Descripción
`BlocNavigator` es un componente que gestiona la navegación dentro de la aplicación. Utiliza un `PageManager` para controlar el stack de páginas, permitiendo operaciones como la navegación hacia atrás, el reemplazo de páginas y la gestión dinámica de rutas. Este enfoque modular facilita la manipulación de la navegación y la integración con sistemas de rutas más complejos.

### Parámetros
- `pageManager`: Instancia de `PageManager` que maneja el historial de páginas y la navegación.
- `homePage`: Widget opcional que define la página de inicio de la aplicación.

### Aclaración sobre el manejo del stack de páginas
El `PageManager` mantiene un stack de páginas donde cada nueva página agregada se convierte en la página "activa" que se muestra en la interfaz. Aunque múltiples páginas pueden estar en el stack, solo la página en la cima del stack es visible en cualquier momento, lo que asegura que la interfaz del usuario se mantenga enfocada y clara.

```dart
void main(){
  Widget homePage = Scaffold(body: Center(child: Text("Home Page")));
  BlocNavigator blocNavigator = BlocNavigator(PageManager(), homePage);
}
```

### Ejemplo de uso en lenguaje natural
Para añadir una página al historial y navegar a ella, se utiliza el método `pushPage`. Este método es útil para añadir páginas de forma dinámica mientras el usuario navega a través de la aplicación.

### Ejemplo de uso en código Dart
```dart
void main(){
  Widget newPage = Scaffold(body: Center(child: Text("New Page")));
  String routeName = "/newPage";
  blocNavigator.pushPage(routeName, newPage);
}
```

### Ejemplo de uso en lenguaje natural
Para manejar el regreso a la página anterior, se utiliza el método `back`. Este es esencial para permitir a los usuarios navegar hacia atrás en su historial de navegación de forma intuitiva.

### Ejemplo de uso en código Dart
```dart
void main(){
blocNavigator.back();
}
```

### Importancia de la integración con `BlocNavigator`
Integrar `BlocNavigator` en la arquitectura de la aplicación permite una gestión centralizada y coherente de la navegación, lo que facilita la implementación de características como la navegación basada en rutas nombradas, el manejo de rutas no encontradas y la restauración de estados de navegación.

### Métodos Principales
- `pushPage(String routeName, Widget widget, [Object? arguments])`: Navega a una nueva página con argumentos opcionales.
- `back()`: Regresa a la página anterior en el historial.
- `setHomePage(Widget widget, [Object? arguments])`: Establece la página de inicio de la aplicación.

## BlocOnboarding

### Descripción
`BlocOnboarding` es un componente diseñado para manejar secuencias de operaciones de inicio, como la carga inicial de datos o configuraciones necesarias antes de que el usuario empiece a interactuar con la aplicación. Este BLoC permite programar una serie de funciones que se ejecutarán de manera secuencial, ofreciendo retroalimentación en tiempo real sobre el progreso.

### Parámetros
- `_blocOnboardingList`: Lista de funciones que se ejecutarán durante el proceso de onboarding.
- `delayInSeconds`: Retardo inicial antes de comenzar la ejecución de las funciones de onboarding.

```dart
void main(){
  List<FutureOr<void> Function()> onboardingFunctions = [
        () async => print("Cargando configuraciones..."),
        () async => print("Cargando datos del usuario..."),
  ];
  BlocOnboarding blocOnboarding = BlocOnboarding(onboardingFunctions, delayInSeconds: 2);

}
```

### Ejemplo de uso en lenguaje natural
Para iniciar el proceso de onboarding, se configura el `BlocOnboarding` con una lista de funciones y un retardo inicial. Cada función puede realizar tareas como cargar configuraciones, preparar el entorno del usuario, entre otros. La ejecución se maneja automáticamente y proporciona retroalimentación sobre el número de tareas restantes.

```dart
void main(){
  // Suponiendo que el BlocOnboarding ya ha sido inicializado como mostrado anteriormente.
  blocOnboarding.execute(Duration(seconds: 1));
}
```

### Ejemplo de uso en lenguaje natural
Para agregar nuevas funciones al proceso de onboarding después de su inicialización, se puede utilizar el método `addFunction`. Esto es útil para modificar dinámicamente el proceso de onboarding basado en condiciones que pueden cambiar en tiempo de ejecución.

```dart
void main(){
  FutureOr<void> additionalFunction() async {
    print("Cargando recursos adicionales...");
  }
  int newPosition = blocOnboarding.addFunction(additionalFunction);
}
```
## BlocUserNotifications

### Métodos Principales
- `execute(Duration duration)`: Inicia la ejecución del proceso de onboarding después de un retardo especificado.
- `addFunction(FutureOr<void> Function() function)`: Añade una nueva función al proceso de onboarding y retorna la nueva longitud de la lista de funciones.

### Descripción
`BlocUserNotifications` es un componente destinado a gestionar las notificaciones de usuario en forma de mensajes breves o "toasts". Facilita la visualización de mensajes y su eliminación automática después de un tiempo predefinido, mejorando la interacción del usuario con la aplicación.

### Parámetros
- `_msgController`: Controlador que maneja el estado del mensaje de notificación.

### Ejemplo de uso en lenguaje natural
Para mostrar un mensaje de notificación al usuario, se utiliza el método `showToast`. Este método limpia cualquier mensaje anterior, establece el nuevo mensaje y lo elimina automáticamente después de un intervalo de tiempo, en este caso, 7 segundos.

```dart
void main(){
  BlocUserNotifications blocUserNotifications = BlocUserNotifications();
  blocUserNotifications.showToast("Bienvenido a la aplicación!");

}
```

### Ejemplo de uso en lenguaje natural
Para eliminar manualmente un mensaje de notificación antes de que expire el tiempo, se puede usar el método `clear`. Esto es útil en escenarios donde el usuario realiza una acción que debería interrumpir la visualización del mensaje.


```dart
void main(){
  blocUserNotifications.clear();

}
```

### Métodos Principales
- `showToast(String message)`: Muestra un mensaje de toast y lo limpia automáticamente después de 7 segundos.
- `clear()`: Limpia el mensaje de notificación activo inmediatamente.

## BlocMainMenuDrawer

### Descripción
`BlocMainMenuDrawer` es un componente diseñado para gestionar las opciones del menú principal de un cajón de navegación en aplicaciones. Este BLoC facilita la adición, eliminación y limpieza de opciones de menú, así como el control sobre la apertura y cierre del cajón de navegación.

### Parámetros
- `_drawerMainMenu`: Controlador que mantiene una lista de modelos de opciones de menú, cada uno representando una opción en el cajón de navegación.

### Ejemplo de uso en lenguaje natural
Para añadir una opción al menú del cajón principal, se utiliza el método `addMainMenuOption`. Este método permite configurar la acción al presionar, el texto de la etiqueta y el icono asociado con cada opción del menú.


```dart
void main(){
  BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
  blocMainMenuDrawer.addMainMenuOption(
    onPressed: () {
      print("Opción seleccionada");
    },
    label: "Inicio",
    iconData: Icons.home,
  );

}
```
### Ejemplo de uso en lenguaje natural
Para remover una opción específica del menú del cajón principal, se utiliza el método `removeMainMenuOption`. Esto es útil para ajustar dinámicamente las opciones disponibles basándose en cambios en la configuración de la aplicación o en los privilegios del usuario.

```dart
void main(){
  BlocMainMenuDrawer blocMainMenuDrawer = BlocMainMenuDrawer();
  blocMainMenuDrawer.removeMainMenuOption("Inicio");
}
```

### Métodos Principales
- `addMainMenuOption({VoidCallback onPressed, String label, IconData iconData, String description})`: Añade una nueva opción al menú del cajón principal.
- `removeMainMenuOption(String label)`: Elimina una opción del menú del cajón principal basándose en su etiqueta.
- `clearMainDrawer()`: Limpia todas las opciones del menú del cajón principal.

## BlocSecondaryMenuDrawer

### Descripción
`BlocSecondaryMenuDrawer` es un componente que gestiona las opciones del menú secundario en un cajón de navegación para aplicaciones. Este BLoC permite la adición, eliminación y limpieza de opciones del menú, así como el control de la apertura y cierre del cajón de navegación secundario.

### Parámetros
- `_drawerMainMenu`: Controlador que mantiene una lista de modelos de opciones de menú, cada uno representando una opción en el cajón de navegación secundario.

### Ejemplo de uso en lenguaje natural
Para añadir una opción al menú del cajón secundario, se utiliza el método `addMainMenuOption`. Este método permite configurar la acción al presionar, el texto de la etiqueta, el icono asociado con cada opción del menú, y una descripción opcional.

```dart
void main(){
  BlocSecondaryMenuDrawer blocSecondaryMenuDrawer = BlocSecondaryMenuDrawer();
  blocSecondaryMenuDrawer.addMainMenuOption(
      onPressed: () {
        print("Opción secundaria seleccionada");
      },
      label: "Configuración",
      iconData: Icons.settings,
      description: "Ajustes de la aplicación"
  );

  
}
```

### Ejemplo de uso en lenguaje natural
Para remover una opción específica del menú del cajón secundario, se utiliza el método `removeMainMenuOption`. Esto es útil para ajustar dinámicamente las opciones disponibles basándose en cambios en la configuración de la aplicación o en los privilegios del usuario.


```dart
void main(){
  blocSecondaryMenuDrawer.removeMainMenuOption("Configuración");
}
```

### Métodos Principales
- `addMainMenuOption({VoidCallback onPressed, String label, IconData iconData, String description})`: Añade una nueva opción al menú del cajón secundario.
- `removeMainMenuOption(String label)`: Elimina una opción del menú del cajón secundario basándose en su etiqueta.
- `clearMainDrawer()`: Limpia todas las opciones del menú del cajón secundario.












```dart
void main(){
  
}
```
