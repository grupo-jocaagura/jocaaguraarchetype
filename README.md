# JocaaguraArchetype

This package is designed to ensure that the cross-functional features of applications developed by Jocaagura are addressed at the start of each project. It provides a uniform and robust foundation for development teams, facilitating the integration and scaling of new features and functionalities.
![Coverage](https://img.shields.io/badge/coverage-86%25-brightgreen)
![Author](https://img.shields.io/badge/Author-@albertjjimenezp-brightgreen) 🐱‍👤

## Documentation Index

- [JocaaguraArchetype](#jocaaguraarchetype)
- [Documentation Index](#documentation-index)
  - [LabColor](#labcolor)
  - [ProviderTheme](#providertheme)
  - [ServiceTheme](#servicetheme)
  - [BlocTheme](#bloctheme)
  - [BlocLoading](#blocloading)
  - [BlocResponsive](#blocresponsive)


## LabColor

### Description
`LabColor` is a utility class that provides methods to convert colors between different color spaces, specifically RGB and Lab (CIELAB). These methods are useful for precise color manipulations needed in custom themes, data visualization, and more.

### Parameters
- `lightness`: The brightness of the color.
- `a`: Component a in the CIELAB color space.
- `b`: Component b in the CIELAB color space.

### Example in Dart Code
```dart
Color colorRGB = Color.fromARGB(255, 255, 0, 0); // Red color
List<double> labColor = LabColor.colorToLab(colorRGB);
LabColor lab = LabColor(labColor[0], labColor[1], labColor[2]);
LabColor adjustedLab = lab.withLightness(50.0);
```

## ProviderTheme

### Description
`ProviderTheme` acts as an intermediary between theme services and UI interfaces that consume these themes. It simplifies the application of custom themes and color manipulations at the app level, ensuring a seamless and consistent visual design.

### Example in Dart Code
```dart
ColorScheme colorScheme = ColorScheme.light(primary: Color(0xFF00FF00));
TextTheme textTheme = TextTheme(bodyText1: TextStyle(color: Color(0xFF000000)));
ProviderTheme providerTheme = ProviderTheme(ServiceTheme());
ThemeData customTheme = providerTheme.customThemeFromColorScheme(colorScheme, textTheme);
```

## ServiceTheme

### Description
`ServiceTheme` provides a range of methods for creating and manipulating themes and colors. It includes functions to convert RGB colors to `MaterialColor`, darken and lighten colors, and generate custom themes from color schemes. This is fundamental for managing the visual appearance of applications.

### Example in Dart Code
```dart
ServiceTheme serviceTheme = ServiceTheme();
MaterialColor materialColor = serviceTheme.materialColorFromRGB(255, 0, 0); // Red color
```

## BlocTheme

### Description
`BlocTheme` is a BLoC (Business Logic Component) module that manages the theme state within the application. It enables dynamic theme updates, allowing the UI to adapt to user preferences or specific conditions, such as switching between light and dark modes.

### Example in Dart Code
```dart
void main() {
  ColorScheme lightScheme = ColorScheme.light();
  ColorScheme darkScheme = ColorScheme.dark();
  TextTheme textTheme = TextTheme(bodyText1: TextStyle(color: Colors.white));

  bool isDarkMode = true; // User preference
  ThemeData themeToUpdate = isDarkMode
      ? blocTheme.providerTheme.serviceTheme.customThemeFromColorScheme(darkScheme, textTheme, true)
      : blocTheme.providerTheme.serviceTheme.customThemeFromColorScheme(lightScheme, textTheme, false);

  blocTheme._themeDataController.value = themeToUpdate;
}
```

## BlocLoading

### Description
`BlocLoading` is a BLoC component that manages loading messages within the application. It provides a centralized way to display and update loading status messages, which is useful for informing users about ongoing operations.

### Example in Dart Code
```dart
void main() async {
  await blocLoading.loadingMsgWithFuture(
      "Loading data...",
      () async {
        await Future.delayed(Duration(seconds: 2)); // Simulated data loading operation
      });
}
```

## BlocResponsive

### Description
`BlocResponsive` is a crucial component for managing adaptive UI in an application. This BLoC facilitates handling screen sizes and component visibility, ensuring the app adjusts optimally to different resolutions and devices.

### Example in Dart Code
```dart
Widget responsiveWidget = AspectRatio(
  aspectRatio: 16 / 9,
  child: Container(
    width: blocResponsive.widthByColumns(4),
    decoration: BoxDecoration(color: Colors.blue),
  ),
);
```

---

This README has been restructured and translated to provide a comprehensive yet concise guide to the **JocaaguraArchetype** package for its audience on **pub.dev**.
If additional sections or examples are required, they can be added based on specific needs. 🐱‍👤
