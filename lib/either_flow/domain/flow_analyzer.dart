import 'dart:collection';

import 'package:jocaagura_domain/jocaagura_domain.dart';

import 'flow_analysis_report.dart';

/// Pure analyzer for Either-based flows.
class FlowAnalyzer {
  /// Analyzes [flow] using its [ModelCompleteFlow.entryIndex].
  ///
  /// Notes:
  /// - END is represented by `-1` targets, not by real steps.
  /// - If entryIndex is `-1`, reachability is empty.
  FlowAnalysisReport analyze(ModelCompleteFlow flow) {
    final int entryIndex = flow.entryIndex; // smallest key or -1
    final Set<int> all = flow.stepsByIndex.keys.cast<int>().toSet();

    final Set<int> reachable = <int>{};
    final List<List<int>> cycles = <List<int>>[];

    if (entryIndex >= 0 && all.contains(entryIndex)) {
      _walkReachable(flow: flow, entry: entryIndex, outReachable: reachable);
      _findCycles(flow: flow, entry: entryIndex, outCycles: cycles);
    }

    final List<int> reachableSorted = reachable.toList()..sort();
    final List<int> unreachable = <int>[
      for (final int i in all)
        if (!reachable.contains(i)) i,
    ]..sort();

    final List<int> terminalSteps = <int>[
      for (final int i in reachable)
        if (_isTerminal(flow.stepAt(i))) i,
    ]..sort();

    final Map<String, double> costByMetric = <String, double>{};
    for (final int i in reachable) {
      final ModelFlowStep? step = flow.stepAt(i);
      if (step == null) {
        continue;
      }

      for (final MapEntry<String, double> e in step.cost.entries) {
        costByMetric[e.key] = (costByMetric[e.key] ?? 0.0) + e.value;
      }
    }

    return FlowAnalysisReport(
      entryIndex: entryIndex,
      reachable: List<int>.unmodifiable(reachableSorted),
      unreachable: List<int>.unmodifiable(unreachable),
      cycles: List<List<int>>.unmodifiable(
        cycles.map((List<int> c) => List<int>.unmodifiable(c)),
      ),
      terminalSteps: List<int>.unmodifiable(terminalSteps),
      costByMetric: Map<String, double>.unmodifiable(costByMetric),
    );
  }

  void _walkReachable({
    required ModelCompleteFlow flow,
    required int entry,
    required Set<int> outReachable,
  }) {
    final Queue<int> q = Queue<int>()..add(entry);
    while (q.isNotEmpty) {
      final int current = q.removeFirst();
      if (!outReachable.add(current)) {
        continue;
      }

      final ModelFlowStep? step = flow.stepAt(current);
      if (step == null) {
        continue;
      }

      final List<int> next = <int>[
        step.nextOnSuccessIndex,
        step.nextOnFailureIndex,
      ];
      for (final int n in next) {
        if (n >= 0 && flow.stepAt(n) != null && !outReachable.contains(n)) {
          q.add(n);
        }
      }
    }
  }

  void _findCycles({
    required ModelCompleteFlow flow,
    required int entry,
    required List<List<int>> outCycles,
  }) {
    final Map<int, int> color = <int, int>{};
    final List<int> stack = <int>[];
    final Set<String> seen = <String>{};

    void dfs(int u) {
      color[u] = 1;
      stack.add(u);

      final ModelFlowStep? step = flow.stepAt(u);
      if (step != null) {
        final List<int> next = <int>[
          step.nextOnSuccessIndex,
          step.nextOnFailureIndex,
        ];
        for (final int v in next) {
          if (v < 0) {
            continue; // END
          }
          if (flow.stepAt(v) == null) {
            continue; // dangling handled by validator
          }

          final int c = color[v] ?? 0;
          if (c == 0) {
            dfs(v);
          } else if (c == 1) {
            final int start = stack.indexOf(v);
            if (start >= 0) {
              final List<int> cycle = stack.sublist(start);
              final String key = _cycleKey(cycle);
              if (seen.add(key)) {
                outCycles.add(cycle);
              }
            }
          }
        }
      }

      stack.removeLast();
      color[u] = 2;
    }

    dfs(entry);
  }

  String _cycleKey(List<int> cycle) {
    if (cycle.isEmpty) {
      return '';
    }
    int minPos = 0;
    for (int i = 1; i < cycle.length; i++) {
      if (cycle[i] < cycle[minPos]) {
        minPos = i;
      }
    }
    final List<int> rotated = <int>[
      ...cycle.sublist(minPos),
      ...cycle.sublist(0, minPos),
    ];
    return rotated.join(',');
  }

  bool _isTerminal(ModelFlowStep? step) {
    if (step == null) {
      return false;
    }
    return step.nextOnSuccessIndex == -1 && step.nextOnFailureIndex == -1;
  }
}
