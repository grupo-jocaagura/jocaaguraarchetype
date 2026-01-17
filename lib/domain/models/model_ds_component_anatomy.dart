part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Stable JSON keys for Design System catalog models.
///
/// These keys are intended to remain stable across versions to support
/// export/import and offline catalogs.
abstract final class ModelDsComponentAnatomyKeys {
  static const String id = 'id';
  static const String name = 'name';
  static const String description = 'description';

  static const String tags = 'tags';
  static const String status = 'status';
  static const String platforms = 'platforms';

  /// Use as an asset reference key (recommended) to keep catalog offline-ready.
  static const String previewAssetKey = 'previewAssetKey';

  /// Optional. External image URL if teams want online docs.
  static const String previewUrlImage = 'previewUrlImage';

  /// Optional. General documentation URL (e.g. internal wiki, Notion, etc.)
  static const String urlDetailedInfo = 'urlDetailedInfo';

  /// Optional. Extra links with labels.
  static const String links = 'links';

  /// Anatomy slots describe the internal parts of a component (label/icon/container).
  static const String slots = 'slots';
}

/// Stable JSON keys for a component link entry.
abstract final class ModelDsComponentLinkKeys {
  static const String label = 'label';
  static const String url = 'url';
}

/// Stable JSON keys for a component anatomy slot.
abstract final class ModelDsComponentSlotKeys {
  static const String name = 'name';
  static const String role = 'role';
  static const String rules = 'rules';
  static const String tokensUsed = 'tokensUsed';
}

/// Catalog status for documentation lifecycle.
enum ModelDsComponentStatusEnum {
  draft,
  stable,
  deprecated,
}

/// Supported platforms for catalog filtering.
enum ModelDsComponentPlatformEnum {
  android,
  ios,
  web,
  windows,
  macos,
  linux,
}

/// Represents a labeled documentation link.
///
/// This model is intentionally minimal:
/// - `label`: human-readable title (non-empty)
/// - `url`: a non-empty string (format not enforced)
///
/// Throws:
/// - [FormatException] from [fromJson] when fields are missing or invalid.
@immutable
class ModelDsComponentLink {
  const ModelDsComponentLink({
    required this.label,
    required this.url,
  });

  /// Builds a link from strict JSON.
  ///
  /// Expected shape:
  /// ```json
  /// {"label": "API docs", "url": "https://..."}
  /// ```
  ///
  /// Throws:
  /// - [FormatException] if `label` or `url` is missing/empty.
  factory ModelDsComponentLink.fromJson(Map<String, dynamic> json) {
    final Object? labelRaw = json[ModelDsComponentLinkKeys.label];
    final Object? urlRaw = json[ModelDsComponentLinkKeys.url];

    if (labelRaw is! String || labelRaw.trim().isEmpty) {
      throw const FormatException('Invalid link label');
    }
    if (urlRaw is! String || urlRaw.trim().isEmpty) {
      throw const FormatException('Invalid link url');
    }

    return ModelDsComponentLink(
      label: labelRaw,
      url: urlRaw,
    );
  }

  final String label;
  final String url;

  /// Serializes this instance into JSON compatible with [fromJson].
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelDsComponentLinkKeys.label: label,
        ModelDsComponentLinkKeys.url: url,
      };

  void _validate() {
    if (label.trim().isEmpty) {
      throw const FormatException('Link label must not be empty');
    }
    if (url.trim().isEmpty) {
      throw const FormatException('Link url must not be empty');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ModelDsComponentLink &&
        other.label == label &&
        other.url == url;
  }

  @override
  int get hashCode => label.hashCode ^ (url.hashCode * 3);
}

/// Describes an internal “part” of a component (anatomy slot).
///
/// A slot exists to document:
/// - what the part is (`name`)
/// - why it exists (`role`)
/// - how it should behave (`rules`)
/// - which DS tokens control it (`tokensUsed`)
///
/// Throws:
/// - [FormatException] from [fromJson] when the payload is invalid.
@immutable
class ModelDsComponentSlot {
  const ModelDsComponentSlot({
    required this.name,
    required this.role,
    required this.rules,
    required this.tokensUsed,
  });

  /// Builds a slot from strict JSON.
  ///
  /// Expected shape:
  /// ```json
  /// {
  ///   "name": "Container",
  ///   "role": "Defines surface and elevation",
  ///   "rules": ["Must be tappable", "Supports disabled state"],
  ///   "tokensUsed": ["borderRadiusLg", "elevationSm"]
  /// }
  /// ```
  ///
  /// Throws:
  /// - [FormatException] if any required field is missing/empty.
  factory ModelDsComponentSlot.fromJson(Map<String, dynamic> json) {
    final Object? nameRaw = json[ModelDsComponentSlotKeys.name];
    final Object? roleRaw = json[ModelDsComponentSlotKeys.role];
    final Object? rulesRaw = json[ModelDsComponentSlotKeys.rules];
    final Object? tokensRaw = json[ModelDsComponentSlotKeys.tokensUsed];

    if (nameRaw is! String || nameRaw.trim().isEmpty) {
      throw const FormatException('Invalid slot name');
    }
    if (roleRaw is! String || roleRaw.trim().isEmpty) {
      throw const FormatException('Invalid slot role');
    }

    final List<String> rules = _readStringListStrict(rulesRaw, 'rules');
    final List<String> tokens = _readStringListStrict(tokensRaw, 'tokensUsed');

    final ModelDsComponentSlot out = ModelDsComponentSlot(
      name: nameRaw,
      role: roleRaw,
      rules: rules,
      tokensUsed: tokens,
    );

    out._validate();
    return out;
  }

  /// Slot name (e.g. "Container", "Label", "LeadingIcon", "Spinner").
  final String name;

  /// Slot role/purpose in UI (short).
  final String role;

  /// Human-readable rules for this slot (short).
  final List<String> rules;

  /// Token keys referenced by this slot (e.g. "spacingSm", "borderRadiusLg").
  final List<String> tokensUsed;

  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelDsComponentSlotKeys.name: name,
        ModelDsComponentSlotKeys.role: role,
        ModelDsComponentSlotKeys.rules: rules,
        ModelDsComponentSlotKeys.tokensUsed: tokensUsed,
      };

  void _validate() {
    if (name.trim().isEmpty) {
      throw const FormatException('Slot name must not be empty');
    }
    if (role.trim().isEmpty) {
      throw const FormatException('Slot role must not be empty');
    }

    if (rules.isEmpty) {
      throw const FormatException('Slot rules must not be empty');
    }
    if (tokensUsed.isEmpty) {
      throw const FormatException('Slot tokensUsed must not be empty');
    }

    for (final String r in rules) {
      if (r.trim().isEmpty) {
        throw const FormatException('Slot rule must not be empty');
      }
    }
    for (final String t in tokensUsed) {
      if (t.trim().isEmpty) {
        throw const FormatException('Slot token must not be empty');
      }
    }
  }

  static List<String> _readStringListStrict(Object? raw, String fieldName) {
    if (raw is! List<dynamic>) {
      throw FormatException('Expected list for $fieldName');
    }
    final List<String> out = <String>[];
    for (final dynamic item in raw) {
      if (item is! String || item.trim().isEmpty) {
        throw FormatException('Invalid item in $fieldName');
      }
      out.add(item);
    }
    return out;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! ModelDsComponentSlot) {
      return false;
    }
    return other.name == name &&
        other.role == role &&
        Utils.listEquals(other.rules, rules) &&
        Utils.listEquals(other.tokensUsed, tokensUsed);
  }

  @override
  int get hashCode {
    int h = name.hashCode ^ (role.hashCode * 3);
    for (final String r in rules) {
      h ^= r.hashCode * 5;
    }
    for (final String t in tokensUsed) {
      h ^= t.hashCode * 7;
    }
    return h;
  }
}

/// Defines how to document and reconstruct a DS component page in a catalog.
///
/// This model is designed to be:
/// - strict and deterministic (invalid payloads fail fast)
/// - offline-ready (use [previewAssetKey] instead of URLs if desired)
///
/// Functional example:
/// ```dart
/// void main() {
///   final ModelDsComponentAnatomy anatomy = ModelDsComponentAnatomy(
///     id: 'ds.button',
///     name: 'Buttons',
///     description: 'Triggers an action with consistent styling.',
///     tags: const <String>['action', 'input'],
///     status: ModelDsComponentStatusEnum.stable,
///     platforms: const <ModelDsComponentPlatformEnum>[
///       ModelDsComponentPlatformEnum.android,
///       ModelDsComponentPlatformEnum.ios,
///       ModelDsComponentPlatformEnum.web,
///     ],
///     slots: const <ModelDsComponentSlot>[
///       ModelDsComponentSlot(
///         name: 'Container',
///         role: 'Surface and shape',
///         rules: <String>['Uses DS radius tokens'],
///         tokensUsed: <String>['borderRadius', 'spacingSm'],
///       ),
///     ],
///     links: const <ModelDsComponentLink>[
///       ModelDsComponentLink(label: 'Guidelines', url: 'https://internal/wiki'),
///     ],
///   );
///
///   final Map<String, dynamic> json = anatomy.toJson();
///   final ModelDsComponentAnatomy restored = ModelDsComponentAnatomy.fromJson(json);
///   assert(anatomy.id == restored.id);
/// }
/// ```
///
/// Throws:
/// - [FormatException] from [fromJson] when the payload is invalid.
@immutable
class ModelDsComponentAnatomy {
  const ModelDsComponentAnatomy({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    required this.status,
    required this.platforms,
    required this.slots,
    this.previewAssetKey,
    this.previewUrlImage,
    this.urlDetailedInfo,
    this.links = const <ModelDsComponentLink>[],
  });

  /// Strict JSON import.
  ///
  /// Required fields:
  /// - id, name, description: non-empty strings
  /// - tags: non-empty list of non-empty strings
  /// - status: one of [ModelDsComponentStatusEnum.name]
  /// - platforms: non-empty list of [ModelDsComponentPlatformEnum.name]
  /// - slots: non-empty list of slot maps
  ///
  /// Optional fields:
  /// - previewAssetKey, previewUrlImage, urlDetailedInfo: nullable strings (empty -> null)
  /// - links: list of link maps (missing/null -> empty)
  ///
  /// Throws:
  /// - [FormatException] if the payload is missing fields or has invalid values.
  factory ModelDsComponentAnatomy.fromJson(Map<String, dynamic> json) {
    final Object? idRaw = json[ModelDsComponentAnatomyKeys.id];
    final Object? nameRaw = json[ModelDsComponentAnatomyKeys.name];
    final Object? descRaw = json[ModelDsComponentAnatomyKeys.description];

    if (idRaw is! String || idRaw.trim().isEmpty) {
      throw const FormatException('Invalid id');
    }
    if (nameRaw is! String || nameRaw.trim().isEmpty) {
      throw const FormatException('Invalid name');
    }
    if (descRaw is! String || descRaw.trim().isEmpty) {
      throw const FormatException('Invalid description');
    }

    final List<String> tags =
        _readStringListStrict(json[ModelDsComponentAnatomyKeys.tags], 'tags');

    final ModelDsComponentStatusEnum status =
        _readStatusStrict(json[ModelDsComponentAnatomyKeys.status]);

    final List<ModelDsComponentPlatformEnum> platforms =
        _readPlatformsStrict(json[ModelDsComponentAnatomyKeys.platforms]);

    final String? previewAssetKey =
        _readNullableString(json[ModelDsComponentAnatomyKeys.previewAssetKey]);
    final String? previewUrlImage =
        _readNullableString(json[ModelDsComponentAnatomyKeys.previewUrlImage]);
    final String? urlDetailedInfo =
        _readNullableString(json[ModelDsComponentAnatomyKeys.urlDetailedInfo]);

    final List<ModelDsComponentLink> links = _readLinksStrict(
      json[ModelDsComponentAnatomyKeys.links],
    );

    final List<ModelDsComponentSlot> slots = _readSlotsStrict(
      json[ModelDsComponentAnatomyKeys.slots],
    );

    final ModelDsComponentAnatomy out = ModelDsComponentAnatomy(
      id: idRaw,
      name: nameRaw,
      description: descRaw,
      tags: tags,
      status: status,
      platforms: platforms,
      previewAssetKey: previewAssetKey,
      previewUrlImage: previewUrlImage,
      urlDetailedInfo: urlDetailedInfo,
      links: links,
      slots: slots,
    );

    out._validate();
    return out;
  }

  /// Stable identifier (e.g. "ds.button", "ds.text_field").
  final String id;

  /// Display name (e.g. "Buttons", "TextField").
  final String name;

  /// Short description: what it is and when to use.
  final String description;

  /// Tags for search and grouping.
  final List<String> tags;

  /// Lifecycle status (draft/stable/deprecated).
  final ModelDsComponentStatusEnum status;

  /// Supported platforms where this component applies.
  final List<ModelDsComponentPlatformEnum> platforms;

  /// Optional: asset key to render a preview image offline.
  final String? previewAssetKey;

  /// Optional: external preview image URL.
  final String? previewUrlImage;

  /// Optional: detailed documentation URL.
  final String? urlDetailedInfo;

  /// Extra links.
  final List<ModelDsComponentLink> links;

  /// Anatomy slots: internal parts and what tokens control them.
  final List<ModelDsComponentSlot> slots;

  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelDsComponentAnatomyKeys.id: id,
        ModelDsComponentAnatomyKeys.name: name,
        ModelDsComponentAnatomyKeys.description: description,
        ModelDsComponentAnatomyKeys.tags: tags,
        ModelDsComponentAnatomyKeys.status: status.name,
        ModelDsComponentAnatomyKeys.platforms:
            platforms.map((ModelDsComponentPlatformEnum e) => e.name).toList(),
        ModelDsComponentAnatomyKeys.previewAssetKey: previewAssetKey,
        ModelDsComponentAnatomyKeys.previewUrlImage: previewUrlImage,
        ModelDsComponentAnatomyKeys.urlDetailedInfo: urlDetailedInfo,
        ModelDsComponentAnatomyKeys.links:
            links.map((ModelDsComponentLink e) => e.toJson()).toList(),
        ModelDsComponentAnatomyKeys.slots:
            slots.map((ModelDsComponentSlot e) => e.toJson()).toList(),
      };

  void _validate() {
    if (id.trim().isEmpty) {
      throw const FormatException('id must not be empty');
    }
    if (name.trim().isEmpty) {
      throw const FormatException('name must not be empty');
    }
    if (description.trim().isEmpty) {
      throw const FormatException('description must not be empty');
    }

    if (tags.isEmpty) {
      throw const FormatException('tags must not be empty');
    }
    if (platforms.isEmpty) {
      throw const FormatException('platforms must not be empty');
    }
    if (slots.isEmpty) {
      throw const FormatException('slots must not be empty');
    }

    for (final String t in tags) {
      if (t.trim().isEmpty) {
        throw const FormatException('tag must not be empty');
      }
    }

    for (final ModelDsComponentLink l in links) {
      l._validate();
    }
    for (final ModelDsComponentSlot s in slots) {
      s._validate();
    }
  }

  static List<String> _readStringListStrict(Object? raw, String fieldName) {
    if (raw is! List<dynamic>) {
      throw FormatException('Expected list for $fieldName');
    }
    final List<String> out = <String>[];
    for (final dynamic item in raw) {
      if (item is! String || item.trim().isEmpty) {
        throw FormatException('Invalid item in $fieldName');
      }
      out.add(item);
    }
    return out;
  }

  static String? _readNullableString(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is! String) {
      throw const FormatException('Expected string');
    }
    final String v = raw.trim();
    if (v.isEmpty) {
      return null;
    }
    return v;
  }

  static ModelDsComponentStatusEnum _readStatusStrict(Object? raw) {
    if (raw is! String || raw.trim().isEmpty) {
      throw const FormatException('Invalid status');
    }
    for (final ModelDsComponentStatusEnum e
        in ModelDsComponentStatusEnum.values) {
      if (e.name == raw) {
        return e;
      }
    }
    throw FormatException('Unknown status: $raw');
  }

  static List<ModelDsComponentPlatformEnum> _readPlatformsStrict(Object? raw) {
    if (raw is! List<dynamic>) {
      throw const FormatException('Expected list for platforms');
    }
    final List<ModelDsComponentPlatformEnum> out =
        <ModelDsComponentPlatformEnum>[];
    for (final dynamic item in raw) {
      if (item is! String || item.trim().isEmpty) {
        throw const FormatException('Invalid platform item');
      }
      final ModelDsComponentPlatformEnum? match = _platformFromName(item);
      if (match == null) {
        throw FormatException('Unknown platform: $item');
      }
      out.add(match);
    }
    if (out.isEmpty) {
      throw const FormatException('platforms must not be empty');
    }
    return out;
  }

  static ModelDsComponentPlatformEnum? _platformFromName(String name) {
    for (final ModelDsComponentPlatformEnum e
        in ModelDsComponentPlatformEnum.values) {
      if (e.name == name) {
        return e;
      }
    }
    return null;
  }

  static List<ModelDsComponentLink> _readLinksStrict(Object? raw) {
    if (raw == null) {
      return <ModelDsComponentLink>[];
    }
    if (raw is! List<dynamic>) {
      throw const FormatException('Expected list for links');
    }
    final List<ModelDsComponentLink> out = <ModelDsComponentLink>[];
    for (final dynamic item in raw) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid link entry');
      }
      out.add(ModelDsComponentLink.fromJson(item));
    }
    return out;
  }

  static List<ModelDsComponentSlot> _readSlotsStrict(Object? raw) {
    if (raw is! List<dynamic>) {
      throw const FormatException('Expected list for slots');
    }
    final List<ModelDsComponentSlot> out = <ModelDsComponentSlot>[];
    for (final dynamic item in raw) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid slot entry');
      }
      out.add(ModelDsComponentSlot.fromJson(item));
    }
    if (out.isEmpty) {
      throw const FormatException('slots must not be empty');
    }
    return out;
  }
}
