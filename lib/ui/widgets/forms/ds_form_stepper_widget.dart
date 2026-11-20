part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A step in a linear form. Give each step a stable, unique [id].
class DsFormStep {
  const DsFormStep({
    required this.id,
    required this.title,
    required this.content,
  });

  final String id;
  final String title;

  /// Fields for this step, backed by values and errors owned by the consumer.
  final Widget content;
}

/// Displays the active step of a linear form and requests navigation.
///
/// Supply a nonempty list of steps and the [activeStepId] of a step in that
/// list. Update it after accepting an adjacent step request. Keep field data
/// in the consumer so each step can restore its values and errors when mounted.
/// Set [primaryState] to loading before awaiting validation or submission.
/// [DsFormActionsWidget] arranges the step's visible actions at the available
/// width. Allow room for the actions to stack when their labels need it.
class DsFormStepperWidget extends StatefulWidget {
  const DsFormStepperWidget({
    required this.steps,
    required this.activeStepId,
    required this.onStepChangeAttempt,
    required this.onFinishAttempt,
    this.primaryState = const ModelInteractiveState(
      semantic: ModelInteractiveSemantic.primary,
    ),
    this.previousLabel = 'Back',
    this.continueLabel = 'Continue',
    this.finishLabel = 'Finish',
    this.loadingSemanticLabel = 'Loading',
    this.progressLabelBuilder = _defaultProgressLabel,
    super.key,
  });

  final List<DsFormStep> steps;
  final String activeStepId;

  /// Requests the ID of the adjacent step. The consumer decides when to move.
  final ValueChanged<String> onStepChangeAttempt;

  /// Requests submission from the last step.
  final VoidCallback onFinishAttempt;

  /// Controls the primary action. Loading also blocks the previous action.
  ///
  /// Use [ModelInteractiveSemantic.primary] to retain the primary color when
  /// supplying an explicit state.
  final ModelInteractiveState primaryState;

  final String previousLabel;
  final String continueLabel;
  final String finishLabel;
  final String loadingSemanticLabel;

  /// Builds the localized progress text from the one-based step and total.
  final String Function(int step, int total) progressLabelBuilder;

  static String _defaultProgressLabel(int step, int total) =>
      'Step $step of $total';

  @override
  State<DsFormStepperWidget> createState() => _DsFormStepperWidgetState();
}

class _DsFormStepperWidgetState extends State<DsFormStepperWidget> {
  static const double _progressBarMinWidth = 480;
  final FocusNode _headingFocus = FocusNode(debugLabel: 'Form step heading');

  @override
  void didUpdateWidget(covariant DsFormStepperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String activeStepId = widget.activeStepId;
    if (activeStepId != oldWidget.activeStepId) {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted &&
            widget.activeStepId == activeStepId &&
            _headingFocus.context != null) {
          FocusTraversalPolicy.defaultTraversalRequestFocusCallback(
            _headingFocus,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _headingFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DsFormStep> steps = widget.steps;
    if (steps.isEmpty) {
      throw ArgumentError.value(steps, 'steps', 'Provide at least one step.');
    }
    final Set<String> ids = <String>{};
    for (final DsFormStep step in steps) {
      if (step.id.trim().isEmpty || !ids.add(step.id)) {
        throw ArgumentError.value(
          step.id,
          'step.id',
          'Use a unique, nonblank ID.',
        );
      }
      if (step.title.trim().isEmpty) {
        throw ArgumentError.value(step.title, 'step.title', 'Name the step.');
      }
    }
    final int index = steps.indexWhere(
      (DsFormStep step) => step.id == widget.activeStepId,
    );
    if (index < 0) {
      throw ArgumentError.value(
        widget.activeStepId,
        'activeStepId',
        'Choose an ID from steps.',
      );
    }
    final DsFormStep active = steps[index];
    final bool hasPrevious = index > 0;
    final bool isLast = index == steps.length - 1;
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String progress = widget.progressLabelBuilder(
      index + 1,
      steps.length,
    );

    return FocusTraversalGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Focus(
            focusNode: _headingFocus,
            skipTraversal: true,
            includeSemantics: false,
            child: ListenableBuilder(
              listenable: _headingFocus,
              builder: (BuildContext context, Widget? child) => Semantics(
                container: true,
                header: true,
                focusable: true,
                focused: _headingFocus.hasPrimaryFocus,
                onFocus: _headingFocus.requestFocus,
                label: '$progress. ${active.title}',
                child: child,
              ),
              child: ExcludeSemantics(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) =>
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(progress, style: textTheme.labelLarge),
                          SizedBox(height: tokens.spacingXs),
                          Text(active.title, style: textTheme.titleLarge),
                          if (constraints.maxWidth >=
                              _progressBarMinWidth) ...<Widget>[
                            SizedBox(height: tokens.spacingSm),
                            LinearProgressIndicator(
                              value: (index + 1) / steps.length,
                            ),
                          ],
                        ],
                      ),
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.spacing),
          KeyedSubtree(key: ValueKey<String>(active.id), child: active.content),
          if (hasPrevious || widget.primaryState.isVisible) ...<Widget>[
            SizedBox(height: tokens.spacing),
            DsFormActionsWidget(
              primaryLabel: isLast ? widget.finishLabel : widget.continueLabel,
              onPrimary: isLast
                  ? widget.onFinishAttempt
                  : () => widget.onStepChangeAttempt(steps[index + 1].id),
              primaryState: widget.primaryState,
              primaryLoadingSemanticLabel: widget.loadingSemanticLabel,
              secondaryLabel: hasPrevious ? widget.previousLabel : null,
              onSecondary: hasPrevious
                  ? () => widget.onStepChangeAttempt(steps[index - 1].id)
                  : null,
              secondaryState: ModelInteractiveState(
                isEnabled: !widget.primaryState.isLoading,
                semantic: ModelInteractiveSemantic.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
