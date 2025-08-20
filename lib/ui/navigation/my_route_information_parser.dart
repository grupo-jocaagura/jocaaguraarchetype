// my_route_information_parser.dart
part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class MyRouteInformationParser extends RouteInformationParser<NavStackModel> {
  const MyRouteInformationParser({
    this.defaultRouteName = 'home',
    this.slugToName,
  });

  /// Si la URL es "/" → usar esta ruta por defecto.
  final String defaultRouteName;

  /// Mapa opcional para traducir el primer segmento (slug) → name lógico (clave del registry).
  /// Ej: {'index-app': 'indexApp', 'home': 'home'}
  final String Function(String slug)? slugToName;

  @override
  Future<NavStackModel> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final Uri uri = Uri.parse(routeInformation.location);

    // "/" → default
    if (uri.pathSegments.isEmpty) {
      final PageModel home = PageModel(
        name: defaultRouteName,
        segments: <String>[defaultRouteName],
      );
      return NavStackModel.single(home);
    }

    final List<String> segs =
        uri.pathSegments.where((String s) => s.isNotEmpty).toList();
    final String first = segs.first;

    // 👇 clave: si te pasan "/index-app", el name lógico debe ser "indexApp"
    final String name = slugToName?.call(first) ?? kebabToCamel(first);

    final PageModel page = PageModel.fromUri(uri, name: name);
    return NavStackModel.single(page);
  }

  @override
  RouteInformation? restoreRouteInformation(NavStackModel configuration) {
    return RouteInformation(location: configuration.top.toUriString());
  }

  // Utilidad simple para kebab-case → camelCase: "index-app" → "indexApp"
  static String kebabToCamel(String s) {
    final List<String> parts = s.split('-');
    if (parts.isEmpty) {
      return s;
    }
    final String head = parts.first;
    final Iterable<String> tail = parts.skip(1).map(
          (String p) =>
              p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}',
        );
    return <String>[head, ...tail].join();
  }
}
