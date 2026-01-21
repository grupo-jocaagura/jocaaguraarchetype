import 'package:flutter/material.dart';

class CostPanelWidget extends StatelessWidget {
  const CostPanelWidget({
    required this.cost,
    super.key,
  });

  final Map<String, double> cost;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, double>> entries = cost.entries.toList()
      ..sort((MapEntry<String, double> a, MapEntry<String, double> b) {
        return a.key.compareTo(b.key);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Cost', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: entries.map((MapEntry<String, double> e) {
            return Chip(label: Text('${e.key}: ${e.value}'));
          }).toList(),
        ),
      ],
    );
  }
}
