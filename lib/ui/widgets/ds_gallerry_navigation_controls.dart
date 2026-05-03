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
    return SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: state.canGoPrevious ? onPrevious : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Previous'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onIndex,
                icon: const Icon(Icons.list),
                label: const Text('Index'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      state.currentPage?.title ?? 'Gallery',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.pageIndicatorLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
