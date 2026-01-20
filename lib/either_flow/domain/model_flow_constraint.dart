import 'package:flutter/material.dart';

import '../../jocaaguraarchetype.dart';

/// Supported kinds of flow constraints.
///
/// A constraint is stored as a string inside [ModelFlowStep.constraints] and can be
/// parsed into a typed representation via [FlowConstraintUtils.parse].
///
/// Known encodings:
/// - `flag:<name>`
/// - `url:<label>|<absoluteUrl>`
/// - `metric:<name>|<value>|<unit>`
///
/// Any raw string without a known prefix is treated as a backward-compatible [flag].
enum FlowConstraintKind {
  /// Boolean-like constraints (e.g., `requiresInternet`).
  flag,

  /// URL references (e.g., `figma`, `docs`, `jira`).
  url,

  /// Metric-like values with unit (e.g., `sugar 2 tbsp`).
  metric,

  /// Anything that doesn't match known formats.
  unknown,
}

/// A parsed constraint value intended for UI rendering.
///
/// This object is a typed view of a raw string stored in [ModelFlowStep.constraints].
/// Not all fields are always populated; the meaning depends on [kind].
///
/// Example:
/// ```dart
/// void main() {
///   final FlowConstraint c = FlowConstraintUtils.parse('metric:sugar|2|tbsp');
///   assert(c.kind == FlowConstraintKind.metric);
///   assert(c.key == 'sugar');
///   assert(c.value == 2.0);
///   assert(c.unit == 'tbsp');
/// }
/// ```
@immutable
class FlowConstraint {
  /// Creates a parsed [FlowConstraint].
  ///
  /// - [raw] must be the original (trimmed) source string.
  /// - Optional fields should be provided according to [kind].
  const FlowConstraint({
    required this.kind,
    required this.raw,
    this.key,
    this.label,
    this.url,
    this.value,
    this.unit,
  });

  /// Constraint kind.
  final FlowConstraintKind kind;

  /// Original (trimmed) string representation.
  final String raw;

  /// Key/name (e.g., `requiresInternet`, `sugar`, `power`).
  ///
  /// Typically used by [FlowConstraintKind.flag] and [FlowConstraintKind.metric].
  final String? key;

  /// Optional label (mainly for URL constraints).
  final String? label;

  /// Parsed URL when [kind] is [FlowConstraintKind.url].
  ///
  /// May be `null` when parsing fails or the input URL is empty.
  final Uri? url;

  /// Numeric value when [kind] is [FlowConstraintKind.metric].
  ///
  /// May be `null` when parsing fails.
  final double? value;

  /// Unit when [kind] is [FlowConstraintKind.metric].
  final String? unit;

  /// Returns true when this constraint contains a safe, navigable absolute URL.
  bool get isNavigableUrl {
    final Uri? u = url;
    if (kind != FlowConstraintKind.url || u == null) {
      return false;
    }
    if (!u.hasScheme || !u.isAbsolute) {
      return false;
    }
    // Optional hardening:
    if (u.scheme != 'https') {
      return false;
    }
    return true;
  }

  /// Returns true when metric has key, value and unit.
  bool get isValidMetric {
    if (kind != FlowConstraintKind.metric) {
      return false;
    }
    final bool hasName = (key ?? '').trim().isNotEmpty;
    final bool hasUnit = (unit ?? '').trim().isNotEmpty;
    final double? v = value;
    final bool hasValue = v != null && v.isFinite;
    return hasName && hasUnit && hasValue;
  }
}

/// Helpers to format and parse constraints stored in [ModelFlowStep.constraints].
///
/// This utility defines a small, stable encoding to store typed constraints as strings:
///
/// - URL: `url:<label>|<absoluteUrl>`
/// - Metric: `metric:<name>|<value>|<unit>`
/// - Flag: `flag:<name>`
///
/// Backward compatibility:
/// - Any string without a known prefix is treated as a [FlowConstraintKind.flag].
abstract final class FlowConstraintUtils {
  /// Formats a URL constraint as `url:<label>|<absoluteUrl>`.
  ///
  /// The label is trimmed and lowercased.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   final String c = FlowConstraintUtils.formatUrl(
  ///     label: 'figma',
  ///     url: Uri.parse('https://www.figma.com/design/abc'),
  ///   );
  ///   assert(c.startsWith('url:figma|'));
  /// }
  /// ```
  static String formatUrl({
    required String label,
    required Uri url,
  }) {
    final String safeLabel = label.trim().toLowerCase();
    final String urlString = url.toString().trim();
    if (safeLabel.isEmpty || urlString.isEmpty) {
      return 'url:unknown|';
    }
    return 'url:$safeLabel|$urlString';
  }

  /// Formats a metric constraint as `metric:<name>|<value>|<unit>`.
  ///
  /// The name and unit are trimmed and lowercased.
  /// Non-finite values are normalized to `0.0`.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   final String c = FlowConstraintUtils.formatMetric(
  ///     name: 'sugar',
  ///     value: 2,
  ///     unit: 'tbsp',
  ///   );
  ///   assert(c == 'metric:sugar|2.0|tbsp');
  /// }
  /// ```
  static String formatMetric({
    required String name,
    required double value,
    required String unit,
  }) {
    final String safeName = name.trim().toLowerCase();
    final String safeUnit = unit.trim().toLowerCase();
    final double normalized = value.isFinite ? value : 0.0;
    return 'metric:$safeName|$normalized|$safeUnit';
  }

  /// Parses a raw constraint string using the mini-DSL.
  ///
  /// Supported forms:
  /// - `url:<label>|<url>`
  /// - `metric:<name>|<value>|<unit>`
  /// - `flag:<name>`
  ///
  /// Backward compatibility:
  /// - If the string has no known prefix, it is treated as a [flag] with [key] == raw.
  ///
  /// Empty input returns [FlowConstraintKind.unknown].
  static FlowConstraint parse(String raw) {
    final String s = raw.trim();
    if (s.isEmpty) {
      return const FlowConstraint(kind: FlowConstraintKind.unknown, raw: '');
    }

    if (s.startsWith('url:')) {
      final String rest = s.substring(4);
      final List<String> parts = rest.split('|');
      final String label = parts.isNotEmpty ? parts[0].trim() : '';
      final String urlStr = parts.length >= 2 ? parts[1].trim() : '';
      final Uri? uri = Uri.tryParse(urlStr);
      return FlowConstraint(
        kind: FlowConstraintKind.url,
        raw: s,
        label: label.isEmpty ? null : label,
        url: uri,
      );
    }

    if (s.startsWith('metric:')) {
      final String rest = s.substring(7);
      final List<String> parts = rest.split('|');
      final String name = parts.isNotEmpty ? parts[0].trim() : '';
      final String valueStr = parts.length >= 2 ? parts[1].trim() : '';
      final String unit = parts.length >= 3 ? parts[2].trim() : '';
      final double? value = double.tryParse(valueStr);
      return FlowConstraint(
        kind: FlowConstraintKind.metric,
        raw: s,
        key: name.isEmpty ? null : name,
        value: value,
        unit: unit.isEmpty ? null : unit,
      );
    }

    if (s.startsWith('flag:')) {
      final String name = s.substring(5).trim();
      return FlowConstraint(
        kind: FlowConstraintKind.flag,
        raw: s,
        key: name.isEmpty ? null : name,
      );
    }

    return FlowConstraint(
      kind: FlowConstraintKind.flag,
      raw: s,
      key: s,
    );
  }

  /// Returns true if [raw] already exists in [constraints] (exact string match).
  static bool containsExact({
    required List<String> constraints,
    required String raw,
  }) {
    for (final String c in constraints) {
      if (c == raw) {
        return true;
      }
    }
    return false;
  }
}

/// Typed helpers to add constraints to a [ModelFlowStep] without duplicating exact matches.
extension ModelFlowStepConstraintsX on ModelFlowStep {
  /// Returns a copy with a formatted URL constraint.
  ///
  /// - Does not add the constraint when the exact formatted string already exists.
  /// - Returns a new deeply immutable instance thanks to [ModelFlowStep.copyWith].
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   final ModelFlowStep step = ModelFlowStep.immutable(
  ///     index: 0,
  ///     title: 'Start',
  ///     description: '...',
  ///     failureCode: 'UNKNOWN',
  ///     nextOnSuccessIndex: -1,
  ///     nextOnFailureIndex: -1,
  ///   );
  ///
  ///   final ModelFlowStep updated = step.withUrlConstraint(
  ///     label: 'figma',
  ///     url: Uri.parse('https://www.figma.com/design/UDdYgEQwYXzliB8BawkllW/Bienvenido'),
  ///   );
  ///
  ///   assert(updated.constraints.length == 1);
  /// }
  /// ```
  ModelFlowStep withUrlConstraint({
    required String label,
    required Uri url,
  }) {
    final String formatted =
        FlowConstraintUtils.formatUrl(label: label, url: url);
    final List<String> next = List<String>.from(constraints);

    if (!FlowConstraintUtils.containsExact(constraints: next, raw: formatted)) {
      next.add(formatted);
    }

    return copyWith(constraints: next);
  }

  /// Returns a copy with a formatted metric constraint.
  ///
  /// - Does not add the constraint when the exact formatted string already exists.
  /// - Returns a new deeply immutable instance thanks to [ModelFlowStep.copyWith].
  ModelFlowStep withMetricConstraint({
    required String name,
    required double value,
    required String unit,
  }) {
    final String formatted =
        FlowConstraintUtils.formatMetric(name: name, value: value, unit: unit);
    final List<String> next = List<String>.from(constraints);

    if (!FlowConstraintUtils.containsExact(constraints: next, raw: formatted)) {
      next.add(formatted);
    }

    return copyWith(constraints: next);
  }
}
