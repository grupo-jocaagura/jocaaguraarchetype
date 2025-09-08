part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Kind of visual container to render a [PageModel].
///
/// UI-layer adapter (RouterDelegate) decides which [Page] subclass to use
/// based on this value.
enum PageKind {
  material,
  cupertino,
  dialog,
  fullScreenDialog,
}

/// Immutable, serializable description of a navigable screen (route).
///
/// This **does not** hold widget instances. It is a pure data model that can be:
/// - serialized to JSON,
/// - encoded to a `Uri` string (deep-link),
/// - restored from `Uri` or JSON,
/// - compared for equality (restoration/back-stack diffs).
///
/// ### Example – create & encode to URI
/// ```dart
/// final PageModel details = PageModel(
///   name: 'details',
///   segments: <String>['products', '42'],
///   query: <String, String>{'ref': 'home'},
/// );
///
/// final String location = details.toUriString(); // "/products/42?ref=home"
/// ```
///
/// ### Example – parse from URI
/// ```dart
/// final PageModel parsed = PageModel.fromUri(Uri.parse('/products/42?ref=home'));
/// assert(parsed.segments.last == '42');
/// assert(parsed.query['ref'] == 'home');
/// ```
@immutable
class PageModel extends Model {
  /// Creates an immutable [PageModel].
  const PageModel({
    required this.name,
    required this.segments,
    this.query = const <String, String>{},
    this.fragment,
    this.kind = PageKind.material,
    this.requiresAuth = false,
    this.state = const <String, dynamic>{},
  });

  /// Factory – build a PageModel from a `Uri`.
  ///
  /// If you need a `name`, derive it from your own routing table after parse.
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

  /// JSON deserialization.
  factory PageModel.fromJson(Map<String, dynamic> json) {
    final String kindStr = (json['kind'] as String?) ?? PageKind.material.name;
    final PageKind k = PageKind.values.firstWhere(
      (PageKind e) => e.name == kindStr,
      orElse: () => PageKind.material,
    );
    return PageModel(
      name: json['name'] as String,
      segments: (json['segments'] as List<dynamic>).cast<String>().toList(),
      query:
          ((json['query'] as Map<String, dynamic>?) ?? const <String, String>{})
              .cast<String, String>(),
      fragment: json['fragment'] as String?,
      kind: k,
      requiresAuth: (json['requiresAuth'] as bool?) ?? false,
      state: ((json['state'] as Map<String, dynamic>?) ??
              const <String, dynamic>{})
          .cast<String, dynamic>(),
    );
  }

  /// A stable logical name for the route (e.g., "home", "details").
  final String name;

  /// Path segments composing the location. `['products','42']` → "/products/42".
  final List<String> segments;

  /// Query string key-values. Stored URL-decoded; encoded on `toUriString()`.
  final Map<String, String> query;

  /// Optional URL fragment part (without '#').
  final String? fragment;

  /// Presentation hint for the RouterDelegate → MaterialPage/Cupertino/etc.
  final PageKind kind;

  /// If `true`, delegate can redirect unauthenticated flows.
  final bool requiresAuth;

  /// Opaque UI state (small, serializable). Keep this light.
  final Map<String, dynamic> state;

  /// Convenience – absolute location as a `Uri` string (leading slash).
  String toUriString() {
    final String path = '/${segments.map(Uri.encodeComponent).join('/')}';
    final Uri uri = Uri(
      path: path,
      queryParameters: query.isEmpty ? null : query,
      fragment: fragment?.isEmpty ?? true ? null : fragment,
    );
    return uri.toString();
  }

  /// JSON serialization.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'segments': List<String>.from(segments),
      'query': Map<String, String>.from(query),
      'fragment': fragment,
      'kind': kind.name,
      'requiresAuth': requiresAuth,
      'state': Map<String, dynamic>.from(state),
    };
  }

  /// Copy with overrides.
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

  /// Equality based on navigation identity: name + segments + query + fragment + kind.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    if (other is PageModel) {
      final PageModel o = other;
      if (name != o.name ||
          kind != o.kind ||
          fragment != o.fragment ||
          requiresAuth != o.requiresAuth) {
        return false;
      }
      if (segments.length != o.segments.length ||
          query.length != o.query.length ||
          state.length != o.state.length) {
        return false;
      }
      for (int i = 0; i < segments.length; i += 1) {
        if (segments[i] != o.segments[i]) {
          return false;
        }
      }
      for (final MapEntry<String, String> e in query.entries) {
        if (o.query[e.key] != e.value) {
          return false;
        }
      }
      for (final MapEntry<String, dynamic> e in state.entries) {
        if (o.state[e.key] != e.value) {
          return false;
        }
      }
    } else {
      return false;
    }
    return true;
  }

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
      h = 0x1fffffff & (h ^ e.key.hashCode ^ e.value.hashCode);
    }
    return h;
  }

  @override
  String toString() =>
      'PageModel(name: $name, segments: $segments, query: $query, fragment: $fragment, kind: $kind, requiresAuth: $requiresAuth, state: $state)';
}
