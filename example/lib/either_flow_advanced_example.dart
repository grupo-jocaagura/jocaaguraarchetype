// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ------------------------------------------------------------
/// EitherFlow – Refined Demo (Single File)
///
/// Included:
/// - Responsive UI (two-pane on wide screens, single-pane on narrow)
/// - Flow map bar (chips by index) + Tooltip with step title
/// - Focus/inspect a step (details panel on wide)
/// - Global override: "force failure on decision steps"
/// - Per-step decision toggles (only when branching exists)
/// - JSON Center (bottom sheet): Export / Import + Save/Load (fake)
/// - CRUD of steps in-example:
///   - Add step (FAB)
///   - Edit / Delete step (per-step menu)
/// - Aggregated cost chips
///
/// Still:
/// - No external packages
/// - Fake storage only (in-memory)
/// - No extra business logic beyond simulation + JSON roundtrip
/// ------------------------------------------------------------

void main() {
  runApp(const EitherFlowDemoApp());
}

class EitherFlowDemoApp extends StatelessWidget {
  const EitherFlowDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EitherFlow Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      home: const EitherFlowAdvancedExampleApp(),
    );
  }
}

/// ------------------------------------------------------------
/// Demo data: Lemonade flow
/// ------------------------------------------------------------

final ModelCompleteFlow kLemonadeFlow = ModelCompleteFlow(
  name: 'Lemonade',
  description: 'Unidimensional flow to prepare lemonade with a taste decision.',
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
/// App (stateful) – controls simulation + JSON + focus + CRUD steps
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

  /// Per-step outcomes for decision steps (true = success, false = failure).
  final Map<int, bool> _outcomeByStep = <int, bool>{};

  /// Global override for decision steps.
  bool _forceFailureOnDecisions = false;

  int _startIndex = 0;
  int _maxHops = 50;

  /// Focused step (for details panel and highlighting).
  int? _focusedStepIndex;

  @override
  void initState() {
    super.initState();
    _seedOutcomesFromFlow(_flow);
    _focusedStepIndex = _startIndex;
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
    return step.nextOnSuccessIndex != step.nextOnFailureIndex;
  }

  bool _resolveOutcomeForStep(ModelFlowStep step) {
    if (_isDecisionStep(step) && _forceFailureOnDecisions) {
      return false;
    }
    return _outcomeByStep[step.index] ?? true;
  }

  void _setFocus(int index) {
    setState(() => _focusedStepIndex = index);
  }

  ModelFlowStep? _focusedStep() {
    final int? idx = _focusedStepIndex;
    if (idx == null) {
      return null;
    }
    return _flow.stepsByIndex[idx];
  }

  void _showSnack(String msg) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _openJsonCenter() async {
    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return JsonCenterSheet(
          flow: _flow,
          storage: _storage,
          onImported: (ModelCompleteFlow parsed) {
            setState(() {
              _flow = parsed;
              _startIndex = _bestStartIndex(parsed);
              _focusedStepIndex = _startIndex;
              _outcomeByStep.clear();
              _seedOutcomesFromFlow(_flow);
            });
            _showSnack('Imported ✅');
          },
          onSaved: () => _showSnack('Saved to fake storage ✅'),
          onLoaded: (ModelCompleteFlow parsed) {
            setState(() {
              _flow = parsed;
              _startIndex = _bestStartIndex(parsed);
              _focusedStepIndex = _startIndex;
              _outcomeByStep.clear();
              _seedOutcomesFromFlow(_flow);
            });
            _showSnack('Loaded ✅');
          },
          onError: (String msg) => _showSnack(msg),
        );
      },
    );
  }

  int _bestStartIndex(ModelCompleteFlow flow) {
    final List<int> keys = flow.stepsByIndex.keys.toList()..sort();
    if (keys.isEmpty) {
      return 0;
    }
    return keys.first;
  }

  void _resetToDefault() {
    setState(() {
      _flow = kLemonadeFlow;
      _startIndex = 0;
      _maxHops = 50;
      _focusedStepIndex = 0;
      _forceFailureOnDecisions = false;
      _outcomeByStep.clear();
      _seedOutcomesFromFlow(_flow);
    });
    _showSnack('Reset to default flow');
  }

  /// ---------------------------
  /// CRUD Steps (Example-side)
  /// ---------------------------

  Future<void> _createNewStep() async {
    final int nextIndex = _suggestNewIndex(_flow);
    final ModelFlowStep draft = ModelFlowStep.immutable(
      index: nextIndex,
      title: 'New step',
      description: 'Describe what this step does.',
      failureCode: 'FLOW.STEP_$nextIndex',
      nextOnSuccessIndex: -1,
      nextOnFailureIndex: -1,
    );

    final ModelFlowStep? created = await showModalBottomSheet<ModelFlowStep?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StepEditorSheet(
          title: 'Create step',
          initial: draft,
          existingIndexes: _flow.stepsByIndex.keys.toSet(),
        );
      },
    );

    if (created == null) {
      return;
    }

    setState(() {
      final Map<int, ModelFlowStep> next =
          Map<int, ModelFlowStep>.from(_flow.stepsByIndex);
      next[created.index] = created;

      _flow = ModelCompleteFlow(
        name: _flow.name,
        description: _flow.description,
        stepsByIndex: next,
      );

      _focusedStepIndex = created.index;
      _seedOutcomesFromFlow(_flow);
    });

    _showSnack('Step #${created.index} created ✅');
  }

  int _suggestNewIndex(ModelCompleteFlow flow) {
    final List<int> keys = flow.stepsByIndex.keys.toList()..sort();
    if (keys.isEmpty) {
      return 0;
    }
    // simplest: max + 1
    return keys.last + 1;
  }

  Future<void> _editStep(ModelFlowStep step) async {
    final ModelFlowStep? edited = await showModalBottomSheet<ModelFlowStep?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StepEditorSheet(
          title: 'Edit step #${step.index}',
          initial: step,
          existingIndexes: _flow.stepsByIndex.keys.toSet(),
          editingIndex: step.index,
        );
      },
    );

    if (edited == null) {
      return;
    }

    setState(() {
      final Map<int, ModelFlowStep> next =
          Map<int, ModelFlowStep>.from(_flow.stepsByIndex);

      // If index changed, remove old entry.
      if (edited.index != step.index) {
        next.remove(step.index);
        _outcomeByStep.remove(step.index);
      }

      next[edited.index] = edited;

      _flow = ModelCompleteFlow(
        name: _flow.name,
        description: _flow.description,
        stepsByIndex: next,
      );

      _focusedStepIndex = edited.index;
      _seedOutcomesFromFlow(_flow);
    });

    _showSnack('Step updated ✅');
  }

  Future<void> _deleteStep(ModelFlowStep step) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete step #${step.index}?'),
          content: const Text(
            'This only removes the step from stepsByIndex. '
            'Other steps that reference this index will remain unchanged.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (ok != true) {
      return;
    }

    setState(() {
      final Map<int, ModelFlowStep> next =
          Map<int, ModelFlowStep>.from(_flow.stepsByIndex);
      next.remove(step.index);
      _outcomeByStep.remove(step.index);

      _flow = ModelCompleteFlow(
        name: _flow.name,
        description: _flow.description,
        stepsByIndex: next,
      );

      // Adjust focus
      final List<int> keys = _flow.stepsByIndex.keys.toList()..sort();
      _focusedStepIndex = keys.isEmpty ? null : keys.first;
      _startIndex = keys.isEmpty ? 0 : keys.first;

      _seedOutcomesFromFlow(_flow);
    });

    _showSnack('Step deleted ✅');
  }

  @override
  Widget build(BuildContext context) {
    final FlowSimulationResult result = FlowSimulator.simulate(
      completeFlow: _flow,
      startIndex: _startIndex,
      maxHops: _maxHops,
      resolveOutcomeForStep: _resolveOutcomeForStep,
    );

    // Ensure focus exists
    final ModelFlowStep? focus = _focusedStep();
    if (_focusedStepIndex != null && focus == null) {
      _focusedStepIndex = _startIndex;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('EitherFlow – Simulator Demo'),
        actions: <Widget>[
          IconButton(
            tooltip: 'JSON Center (Export/Import + Save/Load)',
            onPressed: _openJsonCenter,
            icon: const Icon(Icons.data_object_outlined),
          ),
          IconButton(
            tooltip: 'Reset',
            onPressed: _resetToDefault,
            icon: const Icon(Icons.restart_alt_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewStep,
        icon: const Icon(Icons.add),
        label: const Text('Add step'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final bool wide = c.maxWidth >= 980;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                FlowHeaderWidget(
                  flow: _flow,
                  startIndex: _startIndex,
                  maxHops: _maxHops,
                  visitedCount: result.visitedSteps.length,
                  aggregatedCost: result.aggregatedCost,
                  forceFailureOnDecisions: _forceFailureOnDecisions,
                  onForceFailureChanged: (bool v) {
                    setState(() => _forceFailureOnDecisions = v);
                  },
                  onStartIndexChanged: (int v) {
                    setState(() {
                      _startIndex = v;
                      _focusedStepIndex ??= v;
                    });
                  },
                  onMaxHopsChanged: (int v) => setState(() => _maxHops = v),
                ),
                const SizedBox(height: 12),
                FlowMapBarWidget(
                  flow: _flow,
                  focusedIndex: _focusedStepIndex,
                  onSelect: _setFocus,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: wide
                      ? _WideBody(
                          flow: _flow,
                          simulation: result,
                          focusedIndex: _focusedStepIndex,
                          resolveOutcomeForStep: _resolveOutcomeForStep,
                          isDecisionStep: _isDecisionStep,
                          onFocus: _setFocus,
                          onOutcomeChanged: (int stepIndex, bool outcome) {
                            setState(() => _outcomeByStep[stepIndex] = outcome);
                          },
                          onEdit: _editStep,
                          onDelete: _deleteStep,
                        )
                      : _NarrowBody(
                          flow: _flow,
                          simulation: result,
                          focusedIndex: _focusedStepIndex,
                          resolveOutcomeForStep: _resolveOutcomeForStep,
                          isDecisionStep: _isDecisionStep,
                          onFocus: _setFocus,
                          onOutcomeChanged: (int stepIndex, bool outcome) {
                            setState(() => _outcomeByStep[stepIndex] = outcome);
                          },
                          onEdit: _editStep,
                          onDelete: _deleteStep,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Responsive bodies
/// ------------------------------------------------------------

class _WideBody extends StatelessWidget {
  const _WideBody({
    required this.flow,
    required this.simulation,
    required this.focusedIndex,
    required this.resolveOutcomeForStep,
    required this.isDecisionStep,
    required this.onFocus,
    required this.onOutcomeChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final ModelCompleteFlow flow;
  final FlowSimulationResult simulation;
  final int? focusedIndex;

  final bool Function(ModelFlowStep step) resolveOutcomeForStep;
  final bool Function(ModelFlowStep step) isDecisionStep;

  final ValueChanged<int> onFocus;
  final void Function(int stepIndex, bool outcome) onOutcomeChanged;

  final ValueChanged<ModelFlowStep> onEdit;
  final ValueChanged<ModelFlowStep> onDelete;

  @override
  Widget build(BuildContext context) {
    final ModelFlowStep? focused =
        focusedIndex == null ? null : flow.stepsByIndex[focusedIndex!];

    return Row(
      children: <Widget>[
        SizedBox(
          width: 420,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _SimulationList(
                steps: simulation.visitedSteps,
                focusedIndex: focusedIndex,
                onFocus: onFocus,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: focused == null
                  ? const Center(child: Text('Select a step to inspect'))
                  : FlowStepWidget(
                      flowStep: focused,
                      stepNumberInPath: _pathNumber(
                        simulation.visitedSteps,
                        focused.index,
                      ),
                      isDecision: isDecisionStep(focused),
                      outcomeIsSuccess: resolveOutcomeForStep(focused),
                      onOutcomeChanged: isDecisionStep(focused)
                          ? (bool v) => onOutcomeChanged(focused.index, v)
                          : null,
                      highlight: true,
                      onEdit: () => onEdit(focused),
                      onDelete: () => onDelete(focused),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  int _pathNumber(List<ModelFlowStep> visited, int index) {
    for (int i = 0; i < visited.length; i++) {
      if (visited[i].index == index) {
        return i + 1;
      }
    }
    return 0;
  }
}

class _NarrowBody extends StatelessWidget {
  const _NarrowBody({
    required this.flow,
    required this.simulation,
    required this.focusedIndex,
    required this.resolveOutcomeForStep,
    required this.isDecisionStep,
    required this.onFocus,
    required this.onOutcomeChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final ModelCompleteFlow flow;
  final FlowSimulationResult simulation;
  final int? focusedIndex;

  final bool Function(ModelFlowStep step) resolveOutcomeForStep;
  final bool Function(ModelFlowStep step) isDecisionStep;

  final ValueChanged<int> onFocus;
  final void Function(int stepIndex, bool outcome) onOutcomeChanged;

  final ValueChanged<ModelFlowStep> onEdit;
  final ValueChanged<ModelFlowStep> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: simulation.visitedSteps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int i) {
        final ModelFlowStep step = simulation.visitedSteps[i];
        final bool isDecision = isDecisionStep(step);
        final bool outcome = resolveOutcomeForStep(step);
        final bool highlight = step.index == focusedIndex;

        return GestureDetector(
          onTap: () => onFocus(step.index),
          child: FlowStepWidget(
            flowStep: step,
            stepNumberInPath: i + 1,
            isDecision: isDecision,
            outcomeIsSuccess: outcome,
            onOutcomeChanged:
                isDecision ? (bool v) => onOutcomeChanged(step.index, v) : null,
            highlight: highlight,
            onEdit: () => onEdit(step),
            onDelete: () => onDelete(step),
          ),
        );
      },
    );
  }
}

class _SimulationList extends StatelessWidget {
  const _SimulationList({
    required this.steps,
    required this.focusedIndex,
    required this.onFocus,
  });

  final List<ModelFlowStep> steps;
  final int? focusedIndex;
  final ValueChanged<int> onFocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Simulated path', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: steps.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int i) {
              final ModelFlowStep s = steps[i];
              final bool selected = s.index == focusedIndex;

              return ListTile(
                dense: true,
                selected: selected,
                title: Text('Step #${s.index} — ${s.title}'),
                subtitle: Text(
                  s.failureCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: selected ? const Icon(Icons.chevron_right) : null,
                onTap: () => onFocus(s.index),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// Flow map bar (jump to any step) + tooltip with title
/// ------------------------------------------------------------

class FlowMapBarWidget extends StatelessWidget {
  const FlowMapBarWidget({
    required this.flow,
    required this.focusedIndex,
    required this.onSelect,
    super.key,
  });

  final ModelCompleteFlow flow;
  final int? focusedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final List<ModelFlowStep> ordered = flow.stepsByIndex.values.toList()
      ..sort((ModelFlowStep a, ModelFlowStep b) => a.index.compareTo(b.index));

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ordered.map((ModelFlowStep s) {
              final bool selected = s.index == focusedIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tooltip(
                  message: s.title,
                  child: ChoiceChip(
                    selected: selected,
                    label: Text('#${s.index}'),
                    avatar: selected
                        ? const Icon(Icons.visibility_outlined, size: 18)
                        : const Icon(Icons.circle_outlined, size: 18),
                    onSelected: (_) => onSelect(s.index),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
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
    required this.forceFailureOnDecisions,
    required this.onForceFailureChanged,
    required this.onStartIndexChanged,
    required this.onMaxHopsChanged,
    super.key,
  });

  final ModelCompleteFlow flow;
  final int startIndex;
  final int maxHops;
  final int visitedCount;
  final Map<String, double> aggregatedCost;

  final bool forceFailureOnDecisions;
  final ValueChanged<bool> onForceFailureChanged;

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
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        flow.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(flow.description),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _InfoPill(
                  icon: Icons.route_outlined,
                  label: 'Visited: $visitedCount',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _LabeledDropdown<int>(
                    label: 'Start index',
                    value: indices.contains(startIndex)
                        ? startIndex
                        : (indices.isEmpty ? 0 : indices.first),
                    items: indices.isEmpty ? const <int>[0] : indices,
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
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: forceFailureOnDecisions,
              onChanged: onForceFailureChanged,
              title: const Text('Force failure on decision steps'),
              subtitle: const Text(
                'Overrides per-step toggles (useful to demo alt paths).',
              ),
            ),
            const Divider(height: 20),
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
/// Step UI + Constraints panel + menu (edit/delete)
/// ------------------------------------------------------------

class FlowStepWidget extends StatelessWidget {
  const FlowStepWidget({
    required this.flowStep,
    required this.stepNumberInPath,
    required this.isDecision,
    required this.outcomeIsSuccess,
    required this.onOutcomeChanged,
    required this.onEdit,
    required this.onDelete,
    this.highlight = false,
    super.key,
  });

  final ModelFlowStep flowStep;
  final int stepNumberInPath;

  final bool isDecision;
  final bool outcomeIsSuccess;
  final ValueChanged<bool>? onOutcomeChanged;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final String success = flowStep.nextOnSuccessIndex == -1
        ? 'END'
        : '${flowStep.nextOnSuccessIndex}';
    final String failure = flowStep.nextOnFailureIndex == -1
        ? 'END'
        : '${flowStep.nextOnFailureIndex}';

    final Color border = Theme.of(context).dividerColor;
    final Color bg = highlight
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.94)
        : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(14),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _IndexBadge(index: flowStep.index, path: stepNumberInPath),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        flowStep.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        flowStep.failureCode,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<_StepMenuAction>(
                  tooltip: 'Step actions',
                  onSelected: (_StepMenuAction a) {
                    switch (a) {
                      case _StepMenuAction.edit:
                        onEdit();
                      case _StepMenuAction.delete:
                        onDelete();
                    }
                  },
                  itemBuilder: (_) => <PopupMenuEntry<_StepMenuAction>>[
                    const PopupMenuItem<_StepMenuAction>(
                      value: _StepMenuAction.edit,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<_StepMenuAction>(
                      value: _StepMenuAction.delete,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.delete_outline),
                          SizedBox(width: 10),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(flowStep.description),
            const SizedBox(height: 12),
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
            if (isDecision && onOutcomeChanged != null) ...<Widget>[
              const SizedBox(height: 6),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Decision outcome'),
                subtitle: Text(
                  outcomeIsSuccess ? 'Success (Right)' : 'Failure (Left)',
                ),
                value: outcomeIsSuccess,
                onChanged: onOutcomeChanged,
              ),
            ],
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

enum _StepMenuAction { edit, delete }

class _IndexBadge extends StatelessWidget {
  const _IndexBadge({
    required this.index,
    required this.path,
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
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.90)
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
/// JSON codec (example-side)
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
/// Simulator (pure, deterministic)
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

      // If the next step doesn't exist, stop (no business auto-fix).
      if (!completeFlow.stepsByIndex.containsKey(next)) {
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
/// JSON Center (Bottom Sheet)
/// ------------------------------------------------------------

class JsonCenterSheet extends StatefulWidget {
  const JsonCenterSheet({
    required this.flow,
    required this.storage,
    required this.onImported,
    required this.onSaved,
    required this.onLoaded,
    required this.onError,
    super.key,
  });

  final ModelCompleteFlow flow;
  final FakeFlowStorageService storage;

  final ValueChanged<ModelCompleteFlow> onImported;
  final VoidCallback onSaved;
  final ValueChanged<ModelCompleteFlow> onLoaded;
  final ValueChanged<String> onError;

  @override
  State<JsonCenterSheet> createState() => _JsonCenterSheetState();
}

class _JsonCenterSheetState extends State<JsonCenterSheet> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: _pretty(widget.flow));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _pretty(ModelCompleteFlow flow) {
    final Map<String, dynamic> jsonMap = FlowJsonCodec.encodeCompleteFlow(flow);
    return const JsonEncoder.withIndent('  ').convert(jsonMap);
  }

  Map<String, dynamic>? _tryDecodeObject(String raw) {
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        top: 8,
      ),
      child: SizedBox(
        height: h * 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('JSON Center', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Export, edit, import, or use fake save/load.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _c,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: () {
                    _c.text = _pretty(widget.flow);
                  },
                  icon: const Icon(Icons.refresh_outlined),
                  label: const Text('Re-export'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final Map<String, dynamic>? obj = _tryDecodeObject(_c.text);
                    if (obj == null) {
                      widget.onError('Invalid JSON: expected an object');
                      return;
                    }
                    try {
                      final ModelCompleteFlow parsed =
                          FlowJsonCodec.decodeCompleteFlow(obj);
                      widget.onImported(parsed);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      widget.onError('Import failed: $e');
                    }
                  },
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Import'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await widget.storage.save(_c.text);
                    widget.onSaved();
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save (fake)'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final String? raw = await widget.storage.load();
                    if (raw == null || raw.trim().isEmpty) {
                      widget.onError('Nothing saved yet');
                      return;
                    }
                    final Map<String, dynamic>? obj = _tryDecodeObject(raw);
                    if (obj == null) {
                      widget.onError('Saved data is not a JSON object');
                      return;
                    }
                    try {
                      final ModelCompleteFlow parsed =
                          FlowJsonCodec.decodeCompleteFlow(obj);
                      widget.onLoaded(parsed);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      widget.onError('Load failed: $e');
                    }
                  },
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Load (fake)'),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Step Editor (Bottom Sheet)
///
/// Formats:
/// - Constraints: one per line (raw)
/// - Cost: one per line as `key=value` (value double)
/// ------------------------------------------------------------

class StepEditorSheet extends StatefulWidget {
  const StepEditorSheet({
    required this.title,
    required this.initial,
    required this.existingIndexes,
    this.editingIndex,
    super.key,
  });

  final String title;
  final ModelFlowStep initial;

  /// Used to prevent duplicated indexes.
  final Set<int> existingIndexes;

  /// When editing, allow keeping the same index.
  final int? editingIndex;

  @override
  State<StepEditorSheet> createState() => _StepEditorSheetState();
}

class _StepEditorSheetState extends State<StepEditorSheet> {
  late final TextEditingController _indexC;
  late final TextEditingController _titleC;
  late final TextEditingController _descC;
  late final TextEditingController _failureC;
  late final TextEditingController _succC;
  late final TextEditingController _failC;
  late final TextEditingController _constraintsC;
  late final TextEditingController _costC;

  String? _error;

  @override
  void initState() {
    super.initState();
    final ModelFlowStep s = widget.initial;

    _indexC = TextEditingController(text: s.index.toString());
    _titleC = TextEditingController(text: s.title);
    _descC = TextEditingController(text: s.description);
    _failureC = TextEditingController(text: s.failureCode);
    _succC = TextEditingController(text: s.nextOnSuccessIndex.toString());
    _failC = TextEditingController(text: s.nextOnFailureIndex.toString());

    _constraintsC = TextEditingController(text: s.constraints.join('\n'));

    final List<String> costLines = <String>[];
    final List<MapEntry<String, double>> entries = s.cost.entries.toList()
      ..sort((MapEntry<String, double> a, MapEntry<String, double> b) {
        return a.key.compareTo(b.key);
      });
    for (final MapEntry<String, double> e in entries) {
      costLines.add('${e.key}=${e.value}');
    }
    _costC = TextEditingController(text: costLines.join('\n'));
  }

  @override
  void dispose() {
    _indexC.dispose();
    _titleC.dispose();
    _descC.dispose();
    _failureC.dispose();
    _succC.dispose();
    _failC.dispose();
    _constraintsC.dispose();
    _costC.dispose();
    super.dispose();
  }

  int? _parseInt(String s) => int.tryParse(s.trim());

  Map<String, double> _parseCost(String raw) {
    final Map<String, double> out = <String, double>{};
    final List<String> lines = raw.split('\n');
    for (final String line in lines) {
      final String t = line.trim();
      if (t.isEmpty) {
        continue;
      }
      final int eq = t.indexOf('=');
      if (eq <= 0) {
        continue;
      }
      final String key = t.substring(0, eq).trim();
      final String valStr = t.substring(eq + 1).trim();
      final double? v = double.tryParse(valStr);
      if (key.isEmpty || v == null || !v.isFinite || v < 0) {
        continue;
      }
      out[key] = v;
    }
    return out;
  }

  List<String> _parseConstraints(String raw) {
    final List<String> out = <String>[];
    final List<String> lines = raw.split('\n');
    for (final String line in lines) {
      final String t = line.trim();
      if (t.isEmpty) {
        continue;
      }
      out.add(t);
    }
    return out;
  }

  void _save() {
    setState(() => _error = null);

    final int? idx = _parseInt(_indexC.text);
    final int? succ = _parseInt(_succC.text);
    final int? fail = _parseInt(_failC.text);

    if (idx == null) {
      setState(() => _error = 'Index must be an integer');
      return;
    }
    if (succ == null || fail == null) {
      setState(() => _error = 'Next indices must be integers');
      return;
    }

    final bool indexTaken = widget.existingIndexes.contains(idx) &&
        (widget.editingIndex == null || widget.editingIndex != idx);
    if (indexTaken) {
      setState(() => _error = 'Index #$idx already exists');
      return;
    }

    final String title = _titleC.text.trim();
    final String desc = _descC.text.trim();
    final String failureCode = _failureC.text.trim();

    if (title.isEmpty) {
      setState(() => _error = 'Title is required');
      return;
    }
    if (failureCode.isEmpty) {
      setState(() => _error = 'Failure code is required');
      return;
    }

    final List<String> constraints = _parseConstraints(_constraintsC.text);
    final Map<String, double> cost = _parseCost(_costC.text);

    final ModelFlowStep next = ModelFlowStep.immutable(
      index: idx,
      title: title,
      description: desc,
      failureCode: failureCode,
      nextOnSuccessIndex: succ,
      nextOnFailureIndex: fail,
      constraints: constraints,
      cost: cost,
    );

    Navigator.of(context).pop(next);
  }

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        top: 8,
      ),
      child: SizedBox(
        height: h * 0.90,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Constraints: one per line.\nCost: one per line as key=value.\n'
              'Note: Changing indexes does not auto-rewire other steps.',
            ),
            const SizedBox(height: 12),
            if (_error != null) ...<Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.60),
                  ),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: ListView(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _indexC,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Index',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _failureC,
                          decoration: const InputDecoration(
                            labelText: 'Failure code',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleC,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descC,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _succC,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Next on success',
                            helperText: '-1 means END',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _failC,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Next on failure',
                            helperText: '-1 means END',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _constraintsC,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Constraints (one per line)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _costC,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Cost (key=value per line)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
