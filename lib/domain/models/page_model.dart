part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// JSON keys for [PageModel] (stable serialization contract).
///
/// Using enum names avoids magic strings spread across the codebase and
/// provides compile-time safety for maintainers.
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

@immutable
class PageModel extends Model {
  /// Immutable description of a route/page intention within the app.
  ///
  /// The model is JSON/URI round-trippable and resilient to slightly malformed
  /// inputs when constructed from JSON thanks to `Utils` coercions.
  ///
  /// ### Example
  /// ```dart
  /// // Create a page and serialize to JSON
  /// final PageModel page = PageModel(
  ///   name: 'product',
  ///   segments: <String>['products', '42'],
  ///   query: <String, String>{'ref': 'home'},
  ///   kind: PageKind.material,
  ///   requiresAuth: true,
  ///   state: <String, dynamic>{'highlight': true},
  /// );
  /// final Map<String, dynamic> json = page.toJson();
  ///
  /// // Deserialize back (round-trip)
  /// final PageModel same = PageModel.fromJson(json);
  /// assert(same == page);
  ///
  /// // URI round-trip (path + query + fragment only)
  /// final String uri = page.toUriString();
  /// final PageModel fromUri = PageModel.fromUri(Uri.parse(uri), name: page.name, kind: page.kind);
  /// assert(fromUri.segments.join('/') == page.segments.join('/'));
  /// assert(fromUri.query.toString() == page.query.toString());
  /// ```
  const PageModel({
    required this.name,
    this.segments = const <String>[],
    this.query = const <String, String>{},
    this.fragment,
    this.kind = PageKind.material,
    this.requiresAuth = false,
    this.state = const <String, dynamic>{},
  });

  /// Creates a [PageModel] from an absolute or relative [Uri].
  ///
  /// * `name`: optional logical page name; when omitted, it defaults to the
  ///   first non-empty segment or `'root'` if the path is empty.
  /// * `kind`: optional page kind (defaults to [PageKind.material]).
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
      segments: segs,
      query: q,
      fragment: (uri.fragment.isEmpty) ? null : uri.fragment,
      kind: kind,
    );
  }

  /// Deserializes a JSON map into a [PageModel] with defensive coercions.
  ///
  /// - Unknown or invalid `"kind"` falls back to [PageKind.material].
  /// - `"segments"` tolerates non-string entries by coercing via `Utils.getStringFromDynamic`.
  /// - `"query"` is coerced to `Map<String, String>`; non-string keys/values are stringified.
  /// - `"state"` is coerced to `Map<String, dynamic>` safely.
  /// - Missing booleans default to `false`, missing strings to `''` (unless documented).
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
      segments: segments,
      query: query,
      fragment: fragment,
      kind: k,
      requiresAuth: requiresAuth,
      state: state,
    );
  }

  /// Logical page name (e.g., `'home'`, `'product'`).
  final String name;

  /// Path segments of the location (decoded). Example: `['products', '42']`.
  final List<String> segments;

  /// Query parameters as string pairs. Example: `{'ref':'home'}`.
  final Map<String, String> query;

  /// Optional URL fragment (without `#`). Empty/blank is treated as `null`.
  final String? fragment;

  /// Rendering kind (Material, Cupertino, Dialog, Full-screen Dialog).
  final PageKind kind;

  /// Whether this page requires an authenticated session.
  final bool requiresAuth;

  /// Arbitrary page-local state for UI hints, transitions, etc.
  final Map<String, dynamic> state;

  /// Encodes `segments`, `query`, and `fragment` as a compact URI string.
  ///
  /// Note: `name`, `kind`, `requiresAuth`, and `state` are **not** included in
  /// the URI; those are part of the JSON contract only.
  String toUriString() {
    final String path = '/${segments.map(Uri.encodeComponent).join('/')}';
    final Uri uri = Uri(
      path: path,
      queryParameters: query.isEmpty ? null : query,
      fragment: (fragment == null || fragment!.isEmpty) ? null : fragment,
    );
    return uri.toString();
  }

  /// Serializes this [PageModel] into a JSON map using stable enum keys.
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

  /// Creates a copy with selectively overridden fields.
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
    return PageModel(
      name: name ?? this.name,
      segments: segments ?? this.segments,
      query: query ?? this.query,
      fragment: fragment ?? this.fragment,
      kind: kind ?? this.kind,
      requiresAuth: requiresAuth ?? this.requiresAuth,
      state: state ?? this.state,
    );
  }

  /// Deep equality across all properties (order-sensitive for segments).
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

  /// Stable hash using a fold over collections.
  @override
  int get hashCode {
    int h = name.hashCode ^
        kind.hashCode ^
        (fragment?.hashCode ?? 0) ^
        requiresAuth.hashCode;
    for (final String s in segments) {
      h = 0x1fffffff & (h ^ s.hashCode);
    }
    for (final MapEntry<String, String> e in query.entries) {
      h = 0x1fffffff & (h ^ e.key.hashCode ^ e.value.hashCode);
    }
    for (final MapEntry<String, dynamic> e in state.entries) {
      h = 0x1fffffff & (h ^ e.key.hashCode ^ (e.value?.hashCode ?? 0));
    }
    return h;
  }

  @override
  String toString() =>
      'PageModel(name: $name, segments: $segments, query: $query, fragment: $fragment, kind: $kind, requiresAuth: $requiresAuth, state: $state)';

  // ----- Private helpers -----------------------------------------------------

  /// Coerces a dynamic list into `List<String>` using `Utils.getStringFromDynamic`.
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

  /// Coerces a dynamic map into `Map<String, String>` by stringifying keys/values.
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
