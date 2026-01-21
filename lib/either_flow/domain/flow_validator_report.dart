import 'flow_validation_issue.dart';

/// Report produced by [FlowValidator].
///
/// [errors] contains blocking issues that should prevent execution/simulation.
/// [warnings] contains non-blocking issues that should be reviewed.
///
/// Notes:
/// - This report does not enforce immutability of [errors] and [warnings].
///   Treat them as read-only collections in consumers.
///
/// Functional example:
/// ```dart
/// void main() {
///   final FlowValidationReport report = FlowValidationReport(
///     errors: <FlowValidationIssue>[],
///     warnings: <FlowValidationIssue>[
///       FlowValidationIssue(
///         code: FlowValidationCode.unreachableStep,
///         severity: FlowValidationSeverity.warning,
///         message: 'Step 5 cannot be reached from entry index.',
///         stepIndex: 5,
///       ),
///     ],
///   );
///
///   print(report.isValid); // true
///   print(report.all.length); // 1
/// }
/// ```
class FlowValidationReport {
  /// Creates a [FlowValidationReport].
  const FlowValidationReport({
    required this.errors,
    required this.warnings,
  });

  /// Hydrates a [FlowValidationReport] from JSON.
  ///
  /// This method is lenient and treats missing lists as empty.
  factory FlowValidationReport.fromJson(Map<String, dynamic> json) {
    List<FlowValidationIssue> issues(Object? raw) {
      if (raw is! List) {
        return <FlowValidationIssue>[];
      }
      final List<FlowValidationIssue> out = <FlowValidationIssue>[];
      for (final Object? item in raw) {
        if (item is Map<String, dynamic>) {
          out.add(FlowValidationIssue.fromJson(item));
        } else if (item is Map) {
          out.add(
            FlowValidationIssue.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
      return out;
    }

    return FlowValidationReport(
      errors: issues(json['errors']),
      warnings: issues(json['warnings']),
    );
  }

  /// Blocking issues.
  final List<FlowValidationIssue> errors;

  /// Non-blocking issues.
  final List<FlowValidationIssue> warnings;

  /// Whether the flow is valid enough to proceed.
  bool get isValid => errors.isEmpty;

  /// All issues in a single list (errors first).
  List<FlowValidationIssue> get all {
    return List<FlowValidationIssue>.unmodifiable(<FlowValidationIssue>[
      ...errors,
      ...warnings,
    ]);
  }

  /// Converts this report into a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'errors': errors
          .map((FlowValidationIssue e) => e.toJson())
          .toList(growable: false),
      'warnings': warnings
          .map((FlowValidationIssue e) => e.toJson())
          .toList(growable: false),
    };
  }

  @override
  String toString() => 'FlowValidationReport(isValid=$isValid, '
      'errors=${errors.length}, warnings=${warnings.length})';
}
