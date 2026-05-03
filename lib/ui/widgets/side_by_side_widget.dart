part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Shows the same preview in light and dark theme side by side.
///
/// This widget is a gallery/preview tool. It creates two independent themed
/// preview areas so consumers can verify how a widget behaves in light and
/// dark modes.
///
/// Important:
/// - This is not an app navigation widget.
/// - This is not intended as a production layout shell.
/// - Use it inside galleries, examples and visual QA pages.
class SideBySideWidget extends StatelessWidget {
  const SideBySideWidget({
    required this.designSystem,
    required this.builder,
    this.lightLabel = 'Light',
    this.darkLabel = 'Dark',
    this.height = 360,
    this.spacing = 16,
    super.key,
  });

  final ModelDesignSystem designSystem;
  final GalleryPreviewBuilder builder;
  final String lightLabel;
  final String darkLabel;
  final double height;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme = designSystem.theme.toThemeData(
      brightness: Brightness.light,
    );
    final ThemeData darkTheme = designSystem.theme.toThemeData(
      brightness: Brightness.dark,
    );

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _SideBySidePreviewPanel(
              label: lightLabel,
              theme: lightTheme,
              builder: builder,
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: _SideBySidePreviewPanel(
              label: darkLabel,
              theme: darkTheme,
              builder: builder,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideBySidePreviewPanel extends StatelessWidget {
  const _SideBySidePreviewPanel({
    required this.label,
    required this.theme,
    required this.builder,
  });

  final String label;
  final ThemeData theme;
  final GalleryPreviewBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Builder(
        builder: (BuildContext previewContext) {
          return Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DefaultTextStyle(
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: theme.colorScheme.onSurface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        label,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: builder(previewContext),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
