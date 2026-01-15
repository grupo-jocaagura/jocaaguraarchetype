part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// JSON keys for [ModelDataVizPalette].
///
/// Notes:
/// - Keys are intentionally stable to support export/import.
/// - The JSON payload is strict: both entries must exist and be lists of ARGB ints.
abstract final class ModelDataVizPaletteKeys {
  static const String categorical = 'categorical';
  static const String sequential = 'sequential';

  static const List<String> all = <String>[
    categorical,
    sequential,
  ];
}

/// Defines a data visualization palette with categorical and sequential colors.
///
/// - [categorical] is intended for discrete series (e.g., line/bar series).
/// - [sequential] is intended for continuous values mapped to a gradient-like scale.
///
/// The model is JSON-safe via [toJson] and [fromJson].
///
/// Validation rules:
/// - `categorical` must not be empty.
/// - `sequential` must have at least 2 colors.
///
/// Functional example:
/// ```dart
/// import 'package:flutter/material.dart';
///
/// void main() {
///   final ModelDataVizPalette palette = ModelDataVizPalette.fallback();
///
///   final Color series0 = palette.categoricalAt(0);
///   final Color series11 = palette.categoricalAt(11); // wraps around
///
///   final Color low = palette.sequentialAt(0.0);
///   final Color mid = palette.sequentialAt(0.5);
///   final Color high = palette.sequentialAt(1.0);
///
///   print(series0);
///   print(series11);
///   print(low);
///   print(mid);
///   print(high);
/// }
/// ```
///
/// Throws:
/// - [RangeError] if validation fails.
/// - [FormatException] from [fromJson] when the payload shape is invalid.
@immutable
class ModelDataVizPalette {
  const ModelDataVizPalette({
    required this.categorical,
    required this.sequential,
  });

  /// Returns a recommended default palette.
  ///
  /// Contains:
  /// - 10 categorical colors (discrete series)
  /// - 6 sequential steps (gradient-like)
  ///
  /// Throws:
  /// - [RangeError] if validation fails (should not happen).
  factory ModelDataVizPalette.fallback() {
    const List<Color> categorical = <Color>[
      Color(0xFF1F77B4),
      Color(0xFFFF7F0E),
      Color(0xFF2CA02C),
      Color(0xFFD62728),
      Color(0xFF9467BD),
      Color(0xFF8C564B),
      Color(0xFFE377C2),
      Color(0xFF7F7F7F),
      Color(0xFFBCBD22),
      Color(0xFF17BECF),
    ];

    const List<Color> sequential = <Color>[
      Color(0xFFE3F2FD),
      Color(0xFF90CAF9),
      Color(0xFF42A5F5),
      Color(0xFF1E88E5),
      Color(0xFF1565C0),
      Color(0xFF0D47A1),
    ];

    return const ModelDataVizPalette(
      categorical: categorical,
      sequential: sequential,
    ).._validate();
  }

  /// Builds a palette from a strict JSON payload.
  ///
  /// Both keys in [ModelDataVizPaletteKeys.all] must exist.
  /// Each entry must be a list of ARGB 32-bit integers.
  ///
  /// Throws:
  /// - [FormatException] if a required key is missing or not a list.
  /// - [RangeError] if validation fails.
  factory ModelDataVizPalette.fromJson(Map<String, dynamic> json) {
    for (final String key in ModelDataVizPaletteKeys.all) {
      if (!json.containsKey(key)) {
        throw FormatException('Missing key: $key');
      }
    }

    List<Color> readColors(String key) {
      final Object? raw = json[key];
      if (raw is! List<dynamic>) {
        throw FormatException('Expected list for $key');
      }
      return raw
          .map((dynamic e) => Color(Utils.getIntegerFromDynamic(e)))
          .toList(growable: false);
    }

    final ModelDataVizPalette out = ModelDataVizPalette(
      categorical: readColors(ModelDataVizPaletteKeys.categorical),
      sequential: readColors(ModelDataVizPaletteKeys.sequential),
    );

    out._validate();
    return out;
  }

  /// The categorical palette used for discrete series.
  final List<Color> categorical;

  /// The sequential palette used for continuous values (0..1).
  final List<Color> sequential;

  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelDataVizPaletteKeys.categorical:
            categorical.map((Color c) => c.toARGB32()).toList(growable: false),
        ModelDataVizPaletteKeys.sequential:
            sequential.map((Color c) => c.toARGB32()).toList(growable: false),
      };

  void _validate() {
    if (categorical.isEmpty) {
      throw RangeError('categorical palette must not be empty');
    }
    if (sequential.length < 2) {
      throw RangeError('sequential palette must have at least 2 colors');
    }
  }

  Color categoricalAt(int i) => categorical[i % categorical.length];

  /// t in 0..1 mapped across sequential steps.
  Color sequentialAt(double t) {
    if (t <= 0.0) {
      return sequential.first;
    }
    if (t >= 1.0) {
      return sequential.last;
    }

    final double pos = t * (sequential.length - 1);
    final int idx = pos.floor();
    final int next = (idx + 1).clamp(0, sequential.length - 1);
    final double localT = pos - idx;

    return Color.lerp(sequential[idx], sequential[next], localT) ??
        sequential[idx];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    if (other is! ModelDataVizPalette) {
      return false;
    }

    // Equality by content (simple + deterministic)
    if (categorical.length != other.categorical.length) {
      return false;
    }
    if (sequential.length != other.sequential.length) {
      return false;
    }

    for (int i = 0; i < categorical.length; i++) {
      if (categorical[i] != other.categorical[i]) {
        return false;
      }
    }
    for (int i = 0; i < sequential.length; i++) {
      if (sequential[i] != other.sequential[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    int h = 17;
    for (final Color c in categorical) {
      h = 37 * h ^ c.toARGB32().hashCode;
    }
    for (final Color c in sequential) {
      h = 41 * h ^ c.toARGB32().hashCode;
    }
    return h;
  }
}
