import 'package:flutter/material.dart';

class RoutePillWidget extends StatelessWidget {
  const RoutePillWidget({
    required this.label,
    required this.icon,
    required this.isActive,
    super.key,
    this.hasWarning = false,
    this.tooltip,
  });

  final String label;
  final IconData icon;
  final bool isActive;

  final bool hasWarning;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Color border = Theme.of(context).dividerColor;
    final Color bg = isActive
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.90)
        : Colors.transparent;

    final Widget inner = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          if (hasWarning) ...<Widget>[
            const SizedBox(width: 8),
            const Icon(Icons.warning_amber_outlined, size: 18),
          ],
        ],
      ),
    );

    if (tooltip == null) {
      return inner;
    }

    return Tooltip(message: tooltip, child: inner);
  }
}
