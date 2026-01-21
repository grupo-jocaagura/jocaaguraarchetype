import 'package:flutter/material.dart';

class IndexBadgeWidget extends StatelessWidget {
  const IndexBadgeWidget({
    required this.index,
    required this.path,
    super.key,
  });

  final int index;
  final int path;

  @override
  Widget build(BuildContext context) {
    final Color bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    final Color fg = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '#$index',
            style: TextStyle(fontWeight: FontWeight.w700, color: fg),
          ),
          const SizedBox(height: 2),
          Text(
            'Path $path',
            style: TextStyle(fontSize: 11, color: fg),
          ),
        ],
      ),
    );
  }
}
