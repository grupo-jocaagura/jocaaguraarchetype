/// Deterministic analysis result for a [ModelCompleteFlow].
class FlowAnalysisReport {
  /// Creates a [FlowAnalysisReport].
  ///
  /// All collections are defensively wrapped as unmodifiable.
  FlowAnalysisReport({
    required this.entryIndex,
    required List<int> reachable,
    required List<int> unreachable,
    required List<List<int>> cycles,
    required List<int> terminalSteps,
    required Map<String, double> costByMetric,
  })  : reachable = List<int>.unmodifiable(reachable),
        unreachable = List<int>.unmodifiable(unreachable),
        cycles = List<List<int>>.unmodifiable(
          cycles.map((List<int> c) => List<int>.unmodifiable(c)),
        ),
        terminalSteps = List<int>.unmodifiable(terminalSteps),
        costByMetric = Map<String, double>.unmodifiable(costByMetric);

  /// Hydrates a [FlowAnalysisReport] from JSON.
  ///
  /// This method is lenient and uses safe fallbacks.
  factory FlowAnalysisReport.fromJson(Map<String, dynamic> json) {
    int value(Object? v, {int fallback = -1}) {
      if (v is int) {
        return v;
      }
      return int.tryParse((v ?? '').toString()) ?? fallback;
    }

    List<int> intList(Object? v) {
      if (v is! List) {
        return <int>[];
      }
      final List<int> out = <int>[];
      for (final Object? item in v) {
        final int? parsed = int.tryParse((item ?? '').toString());
        if (item is int) {
          out.add(item);
        } else if (parsed != null) {
          out.add(parsed);
        }
      }
      return out;
    }

    List<List<int>> cycles(Object? v) {
      if (v is! List) {
        return <List<int>>[];
      }
      final List<List<int>> out = <List<int>>[];
      for (final Object? item in v) {
        out.add(intList(item));
      }
      return out;
    }

    Map<String, double> cost(Object? v) {
      if (v is! Map) {
        return <String, double>{};
      }
      final Map<String, double> out = <String, double>{};
      v.forEach((Object? k, Object? val) {
        final String key = (k ?? '').toString();
        if (key.isEmpty) {
          return;
        }
        if (val is num) {
          out[key] = val.toDouble();
          return;
        }
        final double? parsed = double.tryParse((val ?? '').toString());
        if (parsed != null) {
          out[key] = parsed;
        }
      });
      return out;
    }

    return FlowAnalysisReport(
      entryIndex: value(json['entryIndex']),
      reachable: intList(json['reachable']),
      unreachable: intList(json['unreachable']),
      cycles: cycles(json['cycles']),
      terminalSteps: intList(json['terminalSteps']),
      costByMetric: cost(json['costByMetric']),
    );
  }

  /// Entry index used for analysis.
  final int entryIndex;

  /// Steps reachable from [entryIndex].
  final List<int> reachable;

  /// Steps not reachable from [entryIndex].
  final List<int> unreachable;

  /// Detected cycles (each cycle is represented as a path of indices).
  final List<List<int>> cycles;

  /// Steps considered terminal (both next indices are END).
  final List<int> terminalSteps;

  /// Aggregated cost by metric (reachable steps only).
  final Map<String, double> costByMetric;

  /// Converts this report to JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'entryIndex': entryIndex,
      'reachable': reachable,
      'unreachable': unreachable,
      'cycles': cycles,
      'terminalSteps': terminalSteps,
      'costByMetric': costByMetric,
    };
  }

  @override
  String toString() => 'FlowAnalysisReport('
      'entryIndex=$entryIndex, '
      'reachable=${reachable.length}, '
      'unreachable=${unreachable.length}, '
      'cycles=${cycles.length}, '
      'terminalSteps=${terminalSteps.length}, '
      'costByMetric=${costByMetric.length}'
      ')';
}
