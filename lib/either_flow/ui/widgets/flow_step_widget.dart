import 'package:flutter/material.dart';

import '../../../jocaaguraarchetype.dart';

class FlowStepWidget extends StatelessWidget {
  const FlowStepWidget({
    required this.flowStep,
    this.stepNumberInPath,
    super.key,
  });

  final ModelFlowStep flowStep;

  /// Optional numbering in simulation path.
  final int? stepNumberInPath;

  @override
  Widget build(BuildContext context) {
    final String header = stepNumberInPath == null
        ? 'Step #${flowStep.index}'
        : 'Path ${stepNumberInPath!} — Step #${flowStep.index}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              header,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              flowStep.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(flowStep.description),
          ],
        ),
      ),
    );
  }
}
