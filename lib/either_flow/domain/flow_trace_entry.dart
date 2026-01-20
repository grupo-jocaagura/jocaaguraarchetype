import 'flow_simulation_plan.dart';

/// Single step execution record produced by [FlowSimulator].
///
/// This record is deterministic and safe to store/serialize.
/// It does not include timestamps to keep simulations reproducible.
///
/// Example:
/// ```dart
/// final FlowAuditSnapshot snap = FlowSimulator().simulate(flow);
/// for (final FlowTraceEntry e in snap.trace) {
///   print('${e.stepIndex} -> ${e.nextIndex} (${e.branch})');
/// }
/// ```
class FlowTraceEntry {
  /// Creates a [FlowTraceEntry].
  ///
  /// All collections are defensively wrapped as unmodifiable.
  FlowTraceEntry({
    required this.stepIndex,
    required this.branch,
    required this.nextIndex,
    required this.wasForced,
    required this.effectiveFailureCode,
    required Map<String, double> costAddedByMetric,
  }) : costAddedByMetric = Map<String, double>.unmodifiable(
            <String, double>{...costAddedByMetric});

  /// Hydrates a [FlowTraceEntry] from JSON.
  ///
  /// This is lenient and uses safe fallbacks for unknown enum names.
  factory FlowTraceEntry.fromJson(Map<String, dynamic> json) {
    FlowBranch branch(Object? v) {
      final String s = (v ?? '').toString();
      return FlowBranch.values
              .where((FlowBranch e) => e.name == s)
              .cast<FlowBranch?>()
              .firstWhere((FlowBranch? _) => true, orElse: () => null) ??
          FlowBranch.success;
    }

    int intValue(Object? v, {int fallback = -1}) {
      if (v is int) {
        return v;
      }
      return int.tryParse((v ?? '').toString()) ?? fallback;
    }

    bool boolValue(Object? v) {
      if (v is bool) {
        return v;
      }
      final String s = (v ?? '').toString().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
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

    return FlowTraceEntry(
      stepIndex: intValue(json['stepIndex']),
      branch: branch(json['branch']),
      nextIndex: intValue(json['nextIndex']),
      wasForced: boolValue(json['wasForced']),
      effectiveFailureCode:
          (json['effectiveFailureCode'] ?? '').toString().trim().isEmpty
              ? null
              : (json['effectiveFailureCode'] ?? '').toString(),
      costAddedByMetric: cost(json['costAddedByMetric']),
    );
  }

  /// Index of the executed step.
  final int stepIndex;

  /// Selected branch.
  final FlowBranch branch;

  /// Next step index (`-1` means END).
  final int nextIndex;

  /// Whether the branch decision came from a [FlowSimulationPlan].
  final bool wasForced;

  /// Effective failure code for this step.
  ///
  /// - When [branch] is [FlowBranch.failure], this is the failure code stored
  ///   in the trace entry.
  /// - When [branch] is [FlowBranch.success], this is `null`.
  final String? effectiveFailureCode;

  /// Cost contributed by this step (normalized, per metric).
  final Map<String, double> costAddedByMetric;

  /// Converts this entry into a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stepIndex': stepIndex,
      'branch': branch.name,
      'nextIndex': nextIndex,
      'wasForced': wasForced,
      'effectiveFailureCode': effectiveFailureCode,
      'costAddedByMetric': costAddedByMetric,
    };
  }

  @override
  String toString() => '${toJson()}';
}
