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
