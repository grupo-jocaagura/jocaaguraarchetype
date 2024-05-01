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
