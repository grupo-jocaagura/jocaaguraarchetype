part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Bottom controls for the internal DS gallery flow.
class DsGalleryNavigationControls extends StatelessWidget {
  const DsGalleryNavigationControls({
    required this.state,
    required this.onPrevious,
    required this.onIndex,
    required this.onNext,
    super.key,
  });

  final ModelDsGalleryState state;
  final VoidCallback onPrevious;
  final VoidCallback onIndex;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = state.designSystem.tokens;
    return SafeArea(
      top: false,
      child: Material(
        elevation: tokens.elevationXl,
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingSm),
          child: Row(
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: state.canGoPrevious ? onPrevious : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Previous'),
              ),
              SizedBox(width: tokens.spacingSm),
              OutlinedButton.icon(
                onPressed: onIndex,
                icon: const Icon(Icons.list),
                label: const Text('Index'),
              ),
              SizedBox(width: tokens.spacingSm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      state.currentPage?.title ?? 'Gallery',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: tokens.spacingXs),
                    Text(
                      state.pageIndicatorLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              SizedBox(width: tokens.spacingSm),
              FilledButton.icon(
                onPressed: state.canGoNext ? onNext : null,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
