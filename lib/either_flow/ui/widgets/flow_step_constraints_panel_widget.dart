import 'package:flutter/material.dart';

import '../../domain/model_flow_constraint.dart';

/// Panel that parses and renders constraints with different UI per type:
/// - flags -> Chip
/// - metrics -> Chip (name/value/unit)
/// - urls -> ListTile (navigable badge)
class FlowStepConstraintsPanelWidget extends StatelessWidget {
  const FlowStepConstraintsPanelWidget({
    required this.constraints,
    super.key,
  });

  final List<String> constraints;

  @override
  Widget build(BuildContext context) {
    final List<FlowConstraint> parsed =
        constraints.map((String c) => FlowConstraintUtils.parse(c)).toList();

    final List<FlowConstraint> urls = parsed
        .where((FlowConstraint c) => c.kind == FlowConstraintKind.url)
        .toList();
    final List<FlowConstraint> metrics = parsed
        .where((FlowConstraint c) => c.kind == FlowConstraintKind.metric)
        .toList();
    final List<FlowConstraint> flags = parsed.where((FlowConstraint c) {
      return c.kind == FlowConstraintKind.flag ||
          c.kind == FlowConstraintKind.unknown;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Constraints', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (flags.isNotEmpty) ...<Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: flags.map((FlowConstraint c) {
              final String label = (c.key ?? c.raw).trim().isNotEmpty
                  ? (c.key ?? c.raw)
                  : '(empty)';
              return Chip(
                avatar: const Icon(Icons.flag_outlined, size: 18),
                label: Text(label),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (metrics.isNotEmpty) ...<Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: metrics.map((FlowConstraint c) {
              final String name = c.key ?? 'metric';
              final String unit = c.unit ?? '';
              final String value = c.value?.toString() ?? '?';
              final String text =
                  '$name: $value${unit.isEmpty ? '' : ' $unit'}';

              final bool ok = c.isValidMetric;
              return Chip(
                avatar: Icon(
                  ok ? Icons.straighten_outlined : Icons.help_outline,
                  size: 18,
                ),
                label: Text(text),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (urls.isNotEmpty) ...<Widget>[
          Column(
            children: urls.map((FlowConstraint c) {
              final String label = c.label ?? 'link';
              final String urlText = c.url?.toString() ?? '(invalid url)';
              final bool ok = c.isNavigableUrl;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.link),
                title: Text(label),
                subtitle: Text(urlText),
                trailing: Chip(label: Text(ok ? 'https ok' : 'invalid')),
                onTap: ok ? () {} : null,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
