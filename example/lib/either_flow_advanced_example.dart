// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ------------------------------------------------------------
/// EitherFlow – Complete Demo (Single File)
///
/// What you get in this example:
/// - A complete unidimensional flow (Lemonade recipe) with success/failure routing
/// - Constraints rendered as widgets (flag / metric / url) using FlowConstraintUtils.parse
/// - Deterministic simulation (path + aggregated cost)
/// - Fake "Save / Load" (icons) + "Export / Import JSON" (dialogs)
///
/// Notes:
/// - No external packages (no url_launcher, no clipboard plugin)
/// - Save/Load is simulated with an in-memory fake service
/// - The extra widgets live in this file; later you can extract them transversal
/// ------------------------------------------------------------

void main() {
  runApp(const MaterialApp(home: EitherFlowAdvancedExampleApp()));
}

/// ------------------------------------------------------------
/// Demo data: Lemonade flow
/// ------------------------------------------------------------

final ModelCompleteFlow kLemonadeFlow = ModelCompleteFlow(
  name: 'Lemonade',
  description:
      'A unidimensional flow to prepare lemonade with a taste decision.',
  stepsByIndex: <int, ModelFlowStep>{
    0: const ModelFlowStep(
      index: 0,
      title: 'Gather ingredients',
      description: 'Get water, lemons, sugar, a glass, and a spoon.',
      failureCode: 'LEMONADE.GATHER',
      nextOnSuccessIndex: 1,
      nextOnFailureIndex: -1,
      constraints: <String>[
        'requiresKitchen',
        'requiresWaterAvailable',
      ],
      cost: <String, double>{
        'timeMin': 2,
      },
    ),
    1: const ModelFlowStep(
      index: 1,
      title: 'Add 1 liter of water',
      description: 'Pour 1 liter of water into a pitcher.',
      failureCode: 'LEMONADE.WATER',
      nextOnSuccessIndex: 2,
      nextOnFailureIndex: -1,
      constraints: <String>[
        'requiresCleanPitcher',
      ],
      cost: <String, double>{
        'timeMin': 1,
      },
    ).withMetricConstraint(
      name: 'water',
      value: 1,
      unit: 'l',
    ),
    2: const ModelFlowStep(
      index: 2,
      title: 'Squeeze 4 lemons',
      description: 'Squeeze lemons and add the juice to the pitcher.',
      failureCode: 'LEMONADE.LEMONS',
      nextOnSuccessIndex: 3,
      nextOnFailureIndex: -1,
      constraints: <String>[
        'requiresLemons',
        'requiresKnifeOrSqueezer',
      ],
      cost: <String, double>{
        'timeMin': 4,
      },
    ).withMetricConstraint(
      name: 'lemons',
      value: 4,
      unit: 'pcs',
    ),
    3: const ModelFlowStep(
      index: 3,
      title: 'Add sugar + taste',
      description:
          'Add 2 tbsp of sugar, stir, and taste. If not sweet enough → add more sugar.',
      failureCode: 'LEMONADE.TASTE_1',
      nextOnSuccessIndex: 5,
      nextOnFailureIndex: 4,
      constraints: <String>[
        'requiresStirring',
        // Legacy markdown-like constraint kept to show backward compatibility:
        '(url Recipe)[https://example.com/lemonade]',
      ],
      cost: <String, double>{
        'timeMin': 2,
      },
    )
        .withMetricConstraint(name: 'sugar', value: 2, unit: 'tbsp')
        .withUrlConstraint(
          label: 'figma',
          url: Uri.parse(
            'https://www.figma.com/design/UDdYgEQwYXzliB8BawkllW/Bienvenido',
          ),
        ),
    4: const ModelFlowStep(
      index: 4,
      title: 'Add more sugar + taste',
      description:
          'Add 2 more tbsp of sugar, stir, and taste again. If still not ok → END.',
      failureCode: 'LEMONADE.TASTE_2',
      nextOnSuccessIndex: 5,
      nextOnFailureIndex: -1,
      constraints: <String>[
        'requiresStirring',
      ],
      cost: <String, double>{
        'timeMin': 2,
      },
    ).withMetricConstraint(name: 'sugar', value: 2, unit: 'tbsp'),
    5: const ModelFlowStep(
      index: 5,
      title: 'Serve lemonade',
      description: 'Pour into a glass and serve. Done.',
      failureCode: 'LEMONADE.SERVE',
      nextOnSuccessIndex: -1,
      nextOnFailureIndex: -1,
      constraints: <String>[
        'requiresGlass',
      ],
      cost: <String, double>{
        'timeMin': 1,
      },
    ),
  },
);

/// ------------------------------------------------------------
/// App
/// ------------------------------------------------------------

class EitherFlowAdvancedExampleApp extends StatefulWidget {
  const EitherFlowAdvancedExampleApp({super.key});

  @override
  State<EitherFlowAdvancedExampleApp> createState() =>
      _EitherFlowAdvancedExampleAppState();
}

class _EitherFlowAdvancedExampleAppState
    extends State<EitherFlowAdvancedExampleApp> {
  final FakeFlowStorageService _storage = FakeFlowStorageService();

  late ModelCompleteFlow _flow = kLemonadeFlow;
  final Map<int, bool> _outcomeByStep = <int, bool>{};

  int _startIndex = 0;
  int _maxHops = 50;

  @override
  void initState() {
    super.initState();

    // Default decision outcomes (success) for steps that actually branch.
    _seedOutcomesFromFlow(_flow);
  }

  void _seedOutcomesFromFlow(ModelCompleteFlow flow) {
    for (final ModelFlowStep step in flow.stepsByIndex.values) {
      final bool branches = _isDecisionStep(step);
      if (branches && !_outcomeByStep.containsKey(step.index)) {
        _outcomeByStep[step.index] = true;
      }
    }
  }

  bool _isDecisionStep(ModelFlowStep step) {
    if (step.nextOnSuccessIndex == step.nextOnFailureIndex) {
      return false;
    }
    // If one path is END and the other isn't, it's still a decision.
    return true;
  }

  bool _resolveOutcomeForStep(ModelFlowStep step) {
    return _outcomeByStep[step.index] ?? true;
  }

  Future<void> _onExportJson() async {
    final Map<String, dynamic> jsonMap =
        FlowJsonCodec.encodeCompleteFlow(_flow);
    final String pretty = const JsonEncoder.withIndent('  ').convert(jsonMap);

    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return _JsonDialog(
          title: 'Export JSON',
          initialText: pretty,
          readOnly: true,
          primaryLabel: 'Close',
          onPrimaryPressed: () => Navigator.of(context).pop(),
          secondaryLabel: 'Save (fake)',
          onSecondaryPressed: () async {
            await _storage.save(pretty);
            if (context.mounted) {
              Navigator.of(context).pop();
              _showSnack('Saved to fake storage ✅');
            }
          },
        );
      },
    );
  }

  Future<void> _onImportJson() async {
    final Map<String, dynamic> current =
        FlowJsonCodec.encodeCompleteFlow(_flow);
    final String seed = const JsonEncoder.withIndent('  ').convert(current);

    final String? result = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return _JsonDialog(
          title: 'Import JSON',
          initialText: seed,
          readOnly: false,
          primaryLabel: 'Import',
          onPrimaryPressed: () {},
          secondaryLabel: 'Cancel',
          onSecondaryPressed: () => Navigator.of(context).pop(),
          returnTextOnPrimary: true,
        );
      },
    );

    if (result == null) {
      return;
    }

    try {
      final Object? decoded = jsonDecode(result);
      if (decoded is! Map<String, dynamic>) {
        _showSnack('Invalid JSON (expected object)');
        return;
      }

      final ModelCompleteFlow parsed =
          FlowJsonCodec.decodeCompleteFlow(decoded);
      setState(() {
        _flow = parsed;
        _startIndex = 0;
        _outcomeByStep.clear();
        _seedOutcomesFromFlow(_flow);
      });
      _showSnack('Imported ✅');
    } catch (e) {
      _showSnack('Import failed: $e');
    }
  }

  Future<void> _onSaveFake() async {
    final Map<String, dynamic> jsonMap =
        FlowJsonCodec.encodeCompleteFlow(_flow);
    final String raw = jsonEncode(jsonMap);
    await _storage.save(raw);
    _showSnack('Saved to fake storage ✅');
  }

  Future<void> _onLoadFake() async {
    final String? raw = await _storage.load();
    if (raw == null || raw.trim().isEmpty) {
      _showSnack('Nothing saved yet');
      return;
    }

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        _showSnack('Saved data is not a JSON object');
        return;
      }
      final ModelCompleteFlow parsed =
          FlowJsonCodec.decodeCompleteFlow(decoded);

      setState(() {
        _flow = parsed;
        _startIndex = 0;
        _outcomeByStep.clear();
        _seedOutcomesFromFlow(_flow);
      });
      _showSnack('Loaded ✅');
    } catch (e) {
      _showSnack('Load failed: $e');
    }
  }

  void _onResetToDefault() {
    setState(() {
      _flow = kLemonadeFlow;
      _startIndex = 0;
      _maxHops = 50;
      _outcomeByStep.clear();
      _seedOutcomesFromFlow(_flow);
    });
    _showSnack('Reset to default flow');
  }

  void _showSnack(String msg) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FlowSimulationResult result = FlowSimulator.simulate(
      completeFlow: _flow,
      startIndex: _startIndex,
      maxHops: _maxHops,
      resolveOutcomeForStep: _resolveOutcomeForStep,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('EitherFlow – Simulator Demo'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Save (fake)',
            onPressed: _onSaveFake,
            icon: const Icon(Icons.save_outlined),
          ),
          IconButton(
            tooltip: 'Load (fake)',
            onPressed: _onLoadFake,
            icon: const Icon(Icons.folder_open_outlined),
          ),
          IconButton(
            tooltip: 'Export JSON',
            onPressed: _onExportJson,
            icon: const Icon(Icons.upload_file_outlined),
          ),
          IconButton(
            tooltip: 'Import JSON',
            onPressed: _onImportJson,
            icon: const Icon(Icons.download_outlined),
          ),
          IconButton(
            tooltip: 'Reset',
            onPressed: _onResetToDefault,
            icon: const Icon(Icons.restart_alt_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            FlowHeaderWidget(
              flow: _flow,
              startIndex: _startIndex,
              maxHops: _maxHops,
              visitedCount: result.visitedSteps.length,
              aggregatedCost: result.aggregatedCost,
              onStartIndexChanged: (int v) => setState(() => _startIndex = v),
              onMaxHopsChanged: (int v) => setState(() => _maxHops = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: result.visitedSteps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int i) {
                  final ModelFlowStep step = result.visitedSteps[i];
                  final bool isDecision = _isDecisionStep(step);
                  final bool outcome = _resolveOutcomeForStep(step);

                  return FlowStepWidget(
                    flowStep: step,
                    stepNumberInPath: i + 1,
                    isDecision: isDecision,
                    outcomeIsSuccess: outcome,
                    onOutcomeChanged: isDecision
                        ? (bool v) {
                            setState(() => _outcomeByStep[step.index] = v);
                          }
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Fake storage service
/// ------------------------------------------------------------

class FakeFlowStorageService {
  String? _stored;

  Future<void> save(String json) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    _stored = json;
  }

  Future<String?> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _stored;
  }
}

/// ------------------------------------------------------------
/// JSON codec (example-side, safe & independent)
/// ------------------------------------------------------------

abstract final class FlowJsonCodec {
  static Map<String, dynamic> encodeCompleteFlow(ModelCompleteFlow flow) {
    final Map<String, dynamic> stepsJson = <String, dynamic>{};
    for (final MapEntry<int, ModelFlowStep> e in flow.stepsByIndex.entries) {
      stepsJson[e.key.toString()] = e.value.toJson();
    }

    return <String, dynamic>{
      'name': flow.name,
      'description': flow.description,
      'stepsByIndex': stepsJson,
    };
  }

  static ModelCompleteFlow decodeCompleteFlow(Map<String, dynamic> json) {
    final String name = _string(json['name']);
    final String description = _string(json['description']);

    final Map<int, ModelFlowStep> steps = <int, ModelFlowStep>{};
    final Object? rawSteps = json['stepsByIndex'];
    if (rawSteps is Map) {
      for (final MapEntry<dynamic, dynamic> e in rawSteps.entries) {
        final int? key = int.tryParse(e.key.toString());
        if (key == null) {
          continue;
        }
        final Object? v = e.value;
        if (v is Map<String, dynamic>) {
          steps[key] = ModelFlowStep.fromJson(v);
        } else if (v is Map) {
          steps[key] = ModelFlowStep.fromJson(v.cast<String, dynamic>());
        }
      }
    }

    return ModelCompleteFlow(
      name: name.isEmpty ? 'Flow' : name,
      description: description,
      stepsByIndex: steps,
    );
  }

  static String _string(Object? v) => v?.toString() ?? '';
}

/// ------------------------------------------------------------
/// Simulator (pure, deterministic, UI-friendly)
/// ------------------------------------------------------------

abstract final class FlowSimulator {
  static FlowSimulationResult simulate({
    required ModelCompleteFlow completeFlow,
    required int startIndex,
    required int maxHops,
    required bool Function(ModelFlowStep step) resolveOutcomeForStep,
  }) {
    final List<ModelFlowStep> visited = <ModelFlowStep>[];
    final Map<String, double> aggregatedCost = <String, double>{};

    int hops = 0;
    int current = startIndex;

    while (hops < maxHops) {
      final ModelFlowStep? step = completeFlow.stepsByIndex[current];
      if (step == null) {
        break;
      }

      visited.add(step);

      for (final MapEntry<String, double> e in step.cost.entries) {
        final String k = e.key;
        final double v = e.value;
        aggregatedCost[k] = (aggregatedCost[k] ?? 0.0) + v;
      }

      final bool isSuccess = resolveOutcomeForStep(step);
      final int next =
          isSuccess ? step.nextOnSuccessIndex : step.nextOnFailureIndex;

      if (next == -1) {
        break;
      }

      final bool wouldLoop = visited.any((ModelFlowStep s) => s.index == next);
      if (wouldLoop) {
        break;
      }

      current = next;
      hops++;
    }

    return FlowSimulationResult(
      visitedSteps: visited,
      aggregatedCost: aggregatedCost,
    );
  }
}

@immutable
class FlowSimulationResult {
  const FlowSimulationResult({
    required this.visitedSteps,
    required this.aggregatedCost,
  });

  final List<ModelFlowStep> visitedSteps;
  final Map<String, double> aggregatedCost;
}

/// ------------------------------------------------------------
/// Header UI (flow + controls + aggregated cost)
/// ------------------------------------------------------------

class FlowHeaderWidget extends StatelessWidget {
  const FlowHeaderWidget({
    required this.flow,
    required this.startIndex,
    required this.maxHops,
    required this.visitedCount,
    required this.aggregatedCost,
    required this.onStartIndexChanged,
    required this.onMaxHopsChanged,
    super.key,
  });

  final ModelCompleteFlow flow;
  final int startIndex;
  final int maxHops;
  final int visitedCount;
  final Map<String, double> aggregatedCost;

  final ValueChanged<int> onStartIndexChanged;
  final ValueChanged<int> onMaxHopsChanged;

  @override
  Widget build(BuildContext context) {
    final List<int> indices = flow.stepsByIndex.keys.toList()..sort();
    final List<MapEntry<String, double>> costEntries =
        aggregatedCost.entries.toList()
          ..sort((MapEntry<String, double> a, MapEntry<String, double> b) {
            return a.key.compareTo(b.key);
          });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(flow.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(flow.description),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _LabeledDropdown<int>(
                    label: 'Start index',
                    value: indices.contains(startIndex)
                        ? startIndex
                        : indices.first,
                    items: indices,
                    itemLabel: (int v) => v.toString(),
                    onChanged: onStartIndexChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LabeledDropdown<int>(
                    label: 'Max hops',
                    value: maxHops,
                    items: const <int>[10, 25, 50, 100],
                    itemLabel: (int v) => v.toString(),
                    onChanged: onMaxHopsChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                _InfoPill(
                  icon: Icons.route_outlined,
                  label: 'Visited: $visitedCount',
                ),
                const SizedBox(width: 8),
                _InfoPill(
                  icon: Icons.account_tree_outlined,
                  label: 'Steps: ${flow.stepsByIndex.length}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (costEntries.isEmpty)
              const Text('Aggregated cost: (none)')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: costEntries.map((MapEntry<String, double> e) {
                  return Chip(
                    label: Text('${e.key}: ${_formatDouble(e.value)}'),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  static String _formatDouble(double v) {
    final String s = v.toStringAsFixed(2);
    if (s.endsWith('.00')) {
      return s.substring(0, s.length - 3);
    }
    return s;
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items.map((T v) {
            return DropdownMenuItem<T>(
              value: v,
              child: Text(itemLabel(v)),
            );
          }).toList(),
          onChanged: (T? v) {
            if (v == null) {
              return;
            }
            onChanged(v);
          },
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Step UI + Constraints panel
/// ------------------------------------------------------------

class FlowStepWidget extends StatelessWidget {
  const FlowStepWidget({
    required this.flowStep,
    required this.stepNumberInPath,
    required this.isDecision,
    required this.outcomeIsSuccess,
    required this.onOutcomeChanged,
    super.key,
  });

  final ModelFlowStep flowStep;
  final int stepNumberInPath;

  final bool isDecision;
  final bool outcomeIsSuccess;
  final ValueChanged<bool>? onOutcomeChanged;

  @override
  Widget build(BuildContext context) {
    final String success = flowStep.nextOnSuccessIndex == -1
        ? 'END'
        : '${flowStep.nextOnSuccessIndex}';
    final String failure = flowStep.nextOnFailureIndex == -1
        ? 'END'
        : '${flowStep.nextOnFailureIndex}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Path $stepNumberInPath — Step #${flowStep.index}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              flowStep.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(flowStep.description),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: _RoutePill(
                    label: 'Success → $success',
                    icon: Icons.check_circle_outline,
                    isActive: outcomeIsSuccess,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _RoutePill(
                    label: 'Failure → $failure',
                    icon: Icons.error_outline,
                    isActive: !outcomeIsSuccess,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isDecision && onOutcomeChanged != null)
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Decision outcome'),
                subtitle: Text(
                  outcomeIsSuccess ? 'Success (Right)' : 'Failure (Left)',
                ),
                value: outcomeIsSuccess,
                onChanged: onOutcomeChanged,
              ),
            const Divider(height: 22),
            if (flowStep.constraints.isEmpty)
              const Text('No constraints')
            else
              FlowStepConstraintsPanelWidget(constraints: flowStep.constraints),
            if (flowStep.cost.isNotEmpty) ...<Widget>[
              const Divider(height: 22),
              _CostPanel(cost: flowStep.cost),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoutePill extends StatelessWidget {
  const _RoutePill({
    required this.label,
    required this.icon,
    required this.isActive,
  });

  final String label;
  final IconData icon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color border = Theme.of(context).dividerColor;
    final Color bg = isActive
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.92)
        : Colors.transparent;

    return Container(
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
        ],
      ),
    );
  }
}

class _CostPanel extends StatelessWidget {
  const _CostPanel({required this.cost});

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
              final String label = (c.key ?? c.raw).trim().isEmpty
                  ? '(empty)'
                  : (c.key ?? c.raw);
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
                onTap: ok
                    ? () {
                        // Hook for the example:
                        // If you later want this interactive, use url_launcher in the example app.
                      }
                    : null,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// ------------------------------------------------------------
/// JSON Dialog (import/export UX)
/// ------------------------------------------------------------

class _JsonDialog extends StatefulWidget {
  const _JsonDialog({
    required this.title,
    required this.initialText,
    required this.readOnly,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    required this.secondaryLabel,
    required this.onSecondaryPressed,
    this.returnTextOnPrimary = false,
  });

  final String title;
  final String initialText;
  final bool readOnly;

  final String primaryLabel;
  final VoidCallback onPrimaryPressed;

  final String secondaryLabel;
  final VoidCallback onSecondaryPressed;

  /// When true, the dialog pops with the current text on primary action.
  final bool returnTextOnPrimary;

  @override
  State<_JsonDialog> createState() => _JsonDialogState();
}

class _JsonDialogState extends State<_JsonDialog> {
  late final TextEditingController _c =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 720,
        child: TextField(
          controller: _c,
          readOnly: widget.readOnly,
          maxLines: 18,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: widget.onSecondaryPressed,
          child: Text(widget.secondaryLabel),
        ),
        FilledButton(
          onPressed: () {
            widget.onPrimaryPressed();
            if (widget.returnTextOnPrimary) {
              Navigator.of(context).pop(_c.text);
              return;
            }
            // If not returning text, primary callback should decide navigation.
          },
          child: Text(widget.primaryLabel),
        ),
      ],
    );
  }
}
