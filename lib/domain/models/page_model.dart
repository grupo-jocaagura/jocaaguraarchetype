part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Claves JSON para [PageModel] (contrato de serialización estable).
///
/// Usar nombres de `enum` evita *magic strings* repartidas por el código y
/// brinda seguridad en compilación para mantenedores.
enum PageModelEnum {
  name,
  segments,
  query,
  fragment,
  kind,
  requiresAuth,
  state,
}

enum PageKind {
  material,
  cupertino,
  dialog,
  fullScreenDialog,
}

/// Describe de forma inmutable una intención de ruta/página dentro de la app.
///
/// El modelo permite **ida y vuelta** con JSON y URI, y es tolerante a entradas
/// levemente mal formadas al construirse desde JSON gracias a coerciones de `Utils`.
///
/// ### Contratos
/// **Identidad (== y hashCode)**: incluye `name`, `segments` (orden-sensible),
/// `query` (pares clave→valor), `fragment`, `kind`, `requiresAuth` y `state`.
///
/// **Mutabilidad**: las colecciones (`segments`, `query`, `state`) se exponen
/// tal cual fueron provistas. Si se modifican desde afuera, se altera la
/// identidad del objeto. Se recomienda **no mutarlas** tras construir la instancia.
///
/// ### Ejemplo mínimo ejecutable
/// ```dart
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
///
/// void main() {
///   final PageModel page = PageModel(
///     name: 'product',
///     segments: <String>['products', '42'],
///     query: <String, String>{'ref': 'home'},
///     kind: PageKind.material,
///     requiresAuth: true,
///     state: <String, dynamic>{'highlight': true},
///   );
///
///   // Round-trip JSON
///   final Map<String, dynamic> json = page.toJson();
///   final PageModel same = PageModel.fromJson(json);
///   assert(same == page);
///
///   // Round-trip URI (ruta + query + fragment)
///   final String uri = page.toUriString();
///   final PageModel fromUri = PageModel.fromUri(Uri.parse(uri), name: page.name, kind: page.kind);
///   assert(fromUri.segments.join('/') == page.segments.join('/'));
///   assert(fromUri.query.toString() == page.query.toString());
/// }
/// ```
@immutable
class PageModel extends Model {
  const PageModel({
    required this.name,
    this.segments = const <String>[],
    this.query = const <String, String>{},
    this.fragment,
    this.kind = PageKind.material,
    this.requiresAuth = false,
    this.state = const <String, dynamic>{},
  });

  /// Crea un [PageModel] a partir de un [Uri] absoluto o relativo.
  ///
  /// - `name`: nombre lógico opcional; si se omite, usa el primer segmento
  ///   no vacío o `'root'` cuando el path esté vacío.
  /// - `kind`: tipo de página (por defecto [PageKind.material]).
  ///
  /// **Postcondición**: `toUriString()` de la instancia resultante produce una
  /// ruta equivalente (path + query + fragment) al `uri` de entrada.
  factory PageModel.fromUri(
    Uri uri, {
    String? name,
    PageKind kind = PageKind.material,
  }) {
    final List<String> segs = uri.pathSegments
        .where((String s) => s.isNotEmpty)
        .map(Uri.decodeComponent)
        .toList(growable: false);
    final Map<String, String> q = Map<String, String>.from(uri.queryParameters);
    return PageModel(
      name: name ?? (segs.isEmpty ? 'root' : segs.first),
      segments: List<String>.unmodifiable(segs),
      query: Map<String, String>.unmodifiable(q),
      fragment: (uri.fragment.isEmpty) ? null : uri.fragment,
      kind: kind,
    );
  }

  /// Deserializa un mapa JSON a [PageModel] con **coerciones defensivas**.
  ///
  /// - `"kind"` desconocido/ inválido ⇒ [PageKind.material].
  /// - `"segments"`: elementos no string se convierten con `Utils.getStringFromDynamic`.
  /// - `"query"`: se fuerza a `Map<String, String>`; claves/valores no string se stringifican.
  /// - `"state"`: se fuerza a `Map<String, dynamic>` seguro.
  /// - Booleans ausentes ⇒ `false`; `fragment` vacío ⇒ `null`;
  ///   `name` vacío ⇒ `'root'`.
  ///
  /// **Precondición**: `json` no debe ser `null`.
  /// **Postcondición**: la instancia respeta el contrato de identidad descrito.
  factory PageModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> safe = Utils.mapFromDynamic(json);

    final String name =
        Utils.getStringFromDynamic(safe[PageModelEnum.name.name]).isEmpty
            ? 'root'
            : Utils.getStringFromDynamic(safe[PageModelEnum.name.name]);

    // kind
    final String kindStr =
        Utils.getStringFromDynamic(safe[PageModelEnum.kind.name]);
    final PageKind k = PageKind.values.firstWhere(
      (PageKind e) => e.name == kindStr,
      orElse: () => PageKind.material,
    );
    // requiresAuth
    final bool requiresAuth =
        Utils.getBoolFromDynamic(safe[PageModelEnum.requiresAuth.name]);

    // fragment (nullable)
    final String fragRaw =
        Utils.getStringFromDynamic(safe[PageModelEnum.fragment.name]);
    final String? fragment = fragRaw.isEmpty ? null : fragRaw;

    // segments -> List<String>
    final dynamic segAny = safe[PageModelEnum.segments.name];
    final List<String> segments = coerceStringList(
      segAny is List ? List<dynamic>.from(segAny) : const <dynamic>[],
    );

    // query -> Map<String, String>
    final Map<String, dynamic> qDyn =
        Utils.mapFromDynamic(safe[PageModelEnum.query.name]);
    final Map<String, String> query = coerceStringMap(qDyn);

    // state -> Map<String, dynamic>
    final Map<String, dynamic> state =
        Utils.mapFromDynamic(safe[PageModelEnum.state.name]);

    return PageModel(
      name: name,
      segments: List<String>.unmodifiable(segments),
      query: Map<String, String>.unmodifiable(query),
      fragment: fragment,
      kind: k,
      requiresAuth: requiresAuth,
      state: Map<String, dynamic>.unmodifiable(state),
    ).copyWith();
  }

  /// Nombre lógico de la página (p. ej., `'home'`, `'product'`).
  final String name;

  /// Segmentos del path (decodificados). Ej.: `['products', '42']`.
  ///
  /// **Nota**: el orden importa en la identidad.
  final List<String> segments;

  /// Parámetros de consulta como pares `String→String`. Ej.: `{'ref':'home'}`.
  final Map<String, String> query;

  /// Fragmento de URL opcional (sin `#`). Vacío equivale a `null`.
  final String? fragment;

  /// Pista de renderizado (Material, Cupertino, Diálogo, Diálogo de pantalla completa).
  final PageKind kind;

  /// Indica si la página requiere sesión autenticada.
  final bool requiresAuth;

  /// Estado arbitrario y serializable, local a la página (hints de UI, transiciones, etc.).
  ///
  /// **Advertencia**: forma parte de la identidad; cambios aquí cambian `==`/`hashCode`.
  final Map<String, dynamic> state;

  /// Codifica `segments`, `query` y `fragment` como un string `Uri` compacto.
  ///
  /// **No** incluye `name`, `kind`, `requiresAuth` ni `state`; estos pertenecen
  /// únicamente al contrato JSON.
  ///
  /// **Postcondición**: los `segments` se codifican con `Uri.encodeComponent`,
  /// `query` se omite si está vacío y `fragment` se omite si es `null`/vacío.
  String toUriString() {
    final String path =
        segments.isEmpty ? '' : segments.map(Uri.encodeComponent).join('/');

    final Uri uri = Uri(
      path: path,
      queryParameters: query.isEmpty ? null : query,
      fragment: (fragment == null || fragment!.isEmpty) ? null : fragment,
    );
    return uri.toString();
  }

  /// Serializa este [PageModel] a un mapa JSON usando claves estables del enum.
  ///
  /// **Garantías**:
  /// - Las listas/mapas se copian (`from(...)`) para evitar aliasing accidental.
  /// - `kind` se serializa por nombre (`enum.name`).
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      PageModelEnum.name.name: name,
      PageModelEnum.segments.name: List<String>.from(segments),
      PageModelEnum.query.name: Map<String, String>.from(query),
      PageModelEnum.fragment.name: fragment,
      PageModelEnum.kind.name: kind.name,
      PageModelEnum.requiresAuth.name: requiresAuth,
      PageModelEnum.state.name: Map<String, dynamic>.from(state),
    };
  }

  /// Crea una copia con los campos provistos sobrescritos.
  ///
  /// **Nota**: las colecciones copiadas se mantienen **mutables** (misma semántica
  /// que el constructor); evita modificarlas si usas la instancia como clave de mapa
  /// o elemento en sets.
  @override
  PageModel copyWith({
    String? name,
    List<String>? segments,
    Map<String, String>? query,
    String? fragment,
    PageKind? kind,
    bool? requiresAuth,
    Map<String, dynamic>? state,
  }) {
    final List<String>? segImmutable =
        (segments == null) ? null : List<String>.unmodifiable(segments);
    final Map<String, String>? queryImmutable =
        (query == null) ? null : Map<String, String>.unmodifiable(query);
    final Map<String, dynamic>? stateImmutable =
        (state == null) ? null : Map<String, dynamic>.unmodifiable(state);

    return PageModel(
      name: name ?? this.name,
      segments: segImmutable ?? this.segments,
      query: queryImmutable ?? this.query,
      fragment: fragment ?? this.fragment,
      kind: kind ?? this.kind,
      requiresAuth: requiresAuth ?? this.requiresAuth,
      state: stateImmutable ?? this.state,
    );
  }

  /// Igualdad profunda sobre todas las propiedades (orden-sensible en `segments`).
  ///
  /// - `segments`: compara longitud y cada elemento en orden.
  /// - `query`/`state`: compara por contenido clave→valor.
  /// - Incluye `requiresAuth` y `fragment` (nullable-aware).
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType || other is! PageModel) {
      return false;
    }

    if (name != other.name ||
        kind != other.kind ||
        fragment != other.fragment ||
        requiresAuth != other.requiresAuth) {
      return false;
    }
    if (segments.length != other.segments.length ||
        query.length != other.query.length ||
        state.length != other.state.length) {
      return false;
    }
    for (int i = 0; i < segments.length; i += 1) {
      if (segments[i] != other.segments[i]) {
        return false;
      }
    }
    for (final MapEntry<String, String> e in query.entries) {
      if (other.query[e.key] != e.value) {
        return false;
      }
    }
    for (final MapEntry<String, dynamic> e in state.entries) {
      if (other.state[e.key] != e.value) {
        return false;
      }
    }
    return true;
  }

  /// Hash estable combinando propiedades escalares y colecciones.
  ///
  /// **Nota**: el hash de `query`/`state` depende del orden de iteración del mapa.
  /// Para claves/valores idénticos insertados en distinto orden, el hash puede
  /// variar aun cuando `==` sea `true`. Evita usarse como clave si el orden de
  /// inserción puede cambiar en tiempo de vida del objeto.
  @override
  int get hashCode {
    int h = name.hashCode ^
        kind.hashCode ^
        (fragment?.hashCode ?? 0) ^
        requiresAuth.hashCode;

    for (final String s in segments) {
      h = 0x1fffffff & (h ^ s.hashCode);
    }

    h = hashUnorderedStringMap(query, h);
    h = hashUnorderedDynamicMap(state, h);

    return h;
  }

  @override
  String toString() =>
      'PageModel(name: $name, segments: $segments, query: $query, fragment: $fragment, kind: $kind, requiresAuth: $requiresAuth, state: $state)';

  // ----- Helpers privados -----------------------------------------------------

  /// Convierte una lista dinámica a `List<String>` usando `Utils.getStringFromDynamic`.
  ///
  /// Entradas vacías se descartan; espacios se recortan.
  static List<String> coerceStringList(List<dynamic> items) {
    final List<String> out = <String>[];
    for (final dynamic it in items) {
      final String v = Utils.getStringFromDynamic(it).trim();
      if (v.isNotEmpty) {
        out.add(v);
      }
    }
    return out;
  }

  static int hashUnorderedStringMap(Map<String, String> map, int seed) {
    final List<String> keys = List<String>.from(map.keys)..sort();
    int h = seed;
    for (final String k in keys) {
      final String v = map[k]!;
      h = 0x1fffffff & (h ^ k.hashCode ^ v.hashCode);
    }
    return h;
  }

// Usa una constante "salt" para null (golden ratio 32-bit).
  static const int _kNullSalt = 0x9e3779b9;

  /// Stable, order-insensitive hash for Map<String, dynamic>.
  /// - Ordenamos las claves para estabilidad.
  /// - Mezclamos cada entrada incluyendo el tipo del valor para evitar colisiones
  ///   comunes (e.g., 0 vs 0.0 vs false).
  /// - `null` usa un salt dedicado.
  static int hashUnorderedDynamicMap(Map<String, dynamic> map, int seed) {
    final List<String> keys = map.keys.map((dynamic k) => k.toString()).toList()
      ..sort();
    int h = seed;
    for (final String k in keys) {
      final dynamic v = map[k];
      final int valueHash = _valueHash(v);
      h = 0x1fffffff & (h ^ k.hashCode ^ valueHash);
    }
    return h;
  }

  /// Hash de valor que discrimina por tipo y evita colisiones triviales:
  /// - `null` -> salt dedicado.
  /// - valor != null -> `hashCode ^ runtimeType.hashCode`.
  static int _valueHash(dynamic v) {
    if (v == null) {
      return _kNullSalt;
    }
    return 0x1fffffff & (v.hashCode ^ v.runtimeType.hashCode);
  }

  /// Hash de identidad de ruta (excluye `state`).
  int routeHash(PageModel m) {
    int h = m.name.hashCode ^
        m.kind.hashCode ^
        (m.fragment?.hashCode ?? 0) ^
        m.requiresAuth.hashCode;
    for (final String s in m.segments) {
      h = 0x1fffffff & (h ^ s.hashCode);
    }
    h = hashUnorderedStringMap(m.query, h);
    return h;
  }

  /// Convierte un mapa dinámico a `Map<String, String>` stringificando claves/valores.
  ///
  /// Claves vacías se omiten; valores nulos se convierten a `''`.
  static Map<String, String> coerceStringMap(Map<String, dynamic> map) {
    final Map<String, String> out = <String, String>{};
    map.forEach((String k, dynamic v) {
      final String key = Utils.getStringFromDynamic(k).trim();
      if (key.isEmpty) {
        return;
      }
      final String val = Utils.getStringFromDynamic(v);
      out[key] = val;
    });
    return out;
  }
}
