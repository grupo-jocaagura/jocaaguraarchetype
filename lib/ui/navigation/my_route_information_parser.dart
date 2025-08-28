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
    final Uri uri = routeInformation.uri;

    // "/" → default
    if (uri.pathSegments.isEmpty) {
      return NavStackModel.single(
        PageModel(
          name: defaultRouteName,
          segments: const <String>[],
        ),
      );
    }

    final String slug = uri.pathSegments.first;
    final String name = slugToName?.call(slug) ?? slug;
    final List<String> segments = uri.pathSegments.skip(1).toList();
    final Map<String, String> query = uri.queryParameters.map(
      (String k, dynamic v) => MapEntry<String, String>(
        k,
        Utils.getStringFromDynamic(v),
      ),
    );
    return NavStackModel.single(
      PageModel(name: name, segments: segments, query: query),
    );
  }

  @override
  RouteInformation? restoreRouteInformation(NavStackModel configuration) {
    return RouteInformation(uri: Uri.parse(configuration.top.toUriString()));
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
