part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Shows a compact preview of [ModelThemeData].
class ModelThemeDataPage extends StatelessWidget {
  const ModelThemeDataPage({
    required this.model,
    super.key,
  });

  final ModelThemeData model;

  @override
  Widget build(BuildContext context) {
    final ThemeData lightTheme =
        model.toThemeData(brightness: Brightness.light);
    final ThemeData darkTheme = model.toThemeData(brightness: Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ModelThemeData'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _DsModelGalleryInfoCard(
              title: 'Theme config',
              children: <Widget>[
                Text('useMaterial3: ${model.useMaterial3}'),
              ],
            ),
            const SizedBox(height: 16),
            _DsModelGalleryColorSchemeSection(
              title: 'Light ColorScheme',
              colorScheme: model.lightScheme,
            ),
            const SizedBox(height: 16),
            _DsModelGalleryColorSchemeSection(
              title: 'Dark ColorScheme',
              colorScheme: model.darkScheme,
            ),
            const SizedBox(height: 16),
            Theme(
              data: lightTheme,
              child: TextThemePreviewWidget(
                title: 'Light TextTheme',
                textTheme: model.lightTextTheme,
              ),
            ),
            const SizedBox(height: 16),
            Theme(
              data: darkTheme,
              child: TextThemePreviewWidget(
                title: 'Dark TextTheme',
                textTheme: model.darkTextTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a full preview of a [TextTheme].
class TextThemePage extends StatelessWidget {
  const TextThemePage({
    required this.textTheme,
    this.title = 'TextTheme',
    super.key,
  });

  final TextTheme textTheme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TextThemePreviewWidget(
          title: title,
          textTheme: textTheme,
        ),
      ),
    );
  }
}

/// Reusable preview for [TextTheme].
class TextThemePreviewWidget extends StatelessWidget {
  const TextThemePreviewWidget({
    required this.textTheme,
    required this.title,
    super.key,
  });

  final TextTheme textTheme;
  final String title;

  @override
  Widget build(BuildContext context) {
    final List<_DsModelGalleryTextStyleItem> items =
        <_DsModelGalleryTextStyleItem>[
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.displayLarge,
        style: textTheme.displayLarge,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.displayMedium,
        style: textTheme.displayMedium,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.displaySmall,
        style: textTheme.displaySmall,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.headlineLarge,
        style: textTheme.headlineLarge,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.headlineMedium,
        style: textTheme.headlineMedium,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.headlineSmall,
        style: textTheme.headlineSmall,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.titleLarge,
        style: textTheme.titleLarge,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.titleMedium,
        style: textTheme.titleMedium,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.titleSmall,
        style: textTheme.titleSmall,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.bodyLarge,
        style: textTheme.bodyLarge,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.bodyMedium,
        style: textTheme.bodyMedium,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.bodySmall,
        style: textTheme.bodySmall,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.labelLarge,
        style: textTheme.labelLarge,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.labelMedium,
        style: textTheme.labelMedium,
      ),
      _DsModelGalleryTextStyleItem(
        name: TextThemeKeys.labelSmall,
        style: textTheme.labelSmall,
      ),
    ];

    return _DsModelGalleryInfoCard(
      title: title,
      children: items.map((_DsModelGalleryTextStyleItem item) {
        return _DsModelGalleryTextStylePreview(item: item);
      }).toList(growable: false),
    );
  }
}

/// Shows a visual preview of [ModelDsExtendedTokens].
class ModelDsExtendedTokensPage extends StatelessWidget {
  const ModelDsExtendedTokensPage({
    required this.model,
    super.key,
  });

  final ModelDsExtendedTokens model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModelDsExtendedTokens'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _DsModelGalleryTokenScaleSection(
              title: 'Spacing',
              items: <_DsModelGalleryNumberToken>[
                _DsModelGalleryNumberToken('spacingXs', model.spacingXs),
                _DsModelGalleryNumberToken('spacingSm', model.spacingSm),
                _DsModelGalleryNumberToken('spacing', model.spacing),
                _DsModelGalleryNumberToken('spacingLg', model.spacingLg),
                _DsModelGalleryNumberToken('spacingXl', model.spacingXl),
                _DsModelGalleryNumberToken('spacingXXl', model.spacingXXl),
              ],
            ),
            const SizedBox(height: 16),
            _DsModelGalleryTokenScaleSection(
              title: 'Border radius',
              items: <_DsModelGalleryNumberToken>[
                _DsModelGalleryNumberToken(
                  'borderRadiusXs',
                  model.borderRadiusXs,
                ),
                _DsModelGalleryNumberToken(
                  'borderRadiusSm',
                  model.borderRadiusSm,
                ),
                _DsModelGalleryNumberToken(
                  'borderRadius',
                  model.borderRadius,
                ),
                _DsModelGalleryNumberToken(
                  'borderRadiusLg',
                  model.borderRadiusLg,
                ),
                _DsModelGalleryNumberToken(
                  'borderRadiusXl',
                  model.borderRadiusXl,
                ),
                _DsModelGalleryNumberToken(
                  'borderRadiusXXl',
                  model.borderRadiusXXl,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DsModelGalleryTokenScaleSection(
              title: 'Elevation',
              items: <_DsModelGalleryNumberToken>[
                _DsModelGalleryNumberToken('elevationXs', model.elevationXs),
                _DsModelGalleryNumberToken('elevationSm', model.elevationSm),
                _DsModelGalleryNumberToken('elevation', model.elevation),
                _DsModelGalleryNumberToken('elevationLg', model.elevationLg),
                _DsModelGalleryNumberToken('elevationXl', model.elevationXl),
                _DsModelGalleryNumberToken('elevationXXl', model.elevationXXl),
              ],
            ),
            const SizedBox(height: 16),
            _DsModelGalleryTokenScaleSection(
              title: 'Alpha',
              items: <_DsModelGalleryNumberToken>[
                _DsModelGalleryNumberToken('withAlphaXs', model.withAlphaXs),
                _DsModelGalleryNumberToken('withAlphaSm', model.withAlphaSm),
                _DsModelGalleryNumberToken('withAlpha', model.withAlpha),
                _DsModelGalleryNumberToken('withAlphaLg', model.withAlphaLg),
                _DsModelGalleryNumberToken('withAlphaXl', model.withAlphaXl),
                _DsModelGalleryNumberToken('withAlphaXXl', model.withAlphaXXl),
              ],
              maxVisualValue: 1.0,
            ),
            const SizedBox(height: 16),
            _DsModelGalleryInfoCard(
              title: 'Animation durations',
              children: <Widget>[
                Text(
                  'short: ${model.animationDurationShort.inMilliseconds}ms',
                ),
                Text(
                  'regular: ${model.animationDuration.inMilliseconds}ms',
                ),
                Text(
                  'long: ${model.animationDurationLong.inMilliseconds}ms',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a visual preview of [ModelSemanticColors].
class ModelSemanticColorsPage extends StatelessWidget {
  const ModelSemanticColorsPage({
    required this.model,
    this.title = 'ModelSemanticColors',
    super.key,
  });

  final ModelSemanticColors model;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _DsModelGalleryInfoCard(
          title: title,
          children: <Widget>[
            _DsModelGallerySemanticPair(
              label: 'success',
              background: model.success,
              foreground: model.onSuccess,
            ),
            _DsModelGallerySemanticPair(
              label: 'successContainer',
              background: model.successContainer,
              foreground: model.onSuccessContainer,
            ),
            _DsModelGallerySemanticPair(
              label: 'warning',
              background: model.warning,
              foreground: model.onWarning,
            ),
            _DsModelGallerySemanticPair(
              label: 'warningContainer',
              background: model.warningContainer,
              foreground: model.onWarningContainer,
            ),
            _DsModelGallerySemanticPair(
              label: 'info',
              background: model.info,
              foreground: model.onInfo,
            ),
            _DsModelGallerySemanticPair(
              label: 'infoContainer',
              background: model.infoContainer,
              foreground: model.onInfoContainer,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a visual preview of [ModelDataVizPalette].
class ModelDataVizPalettePage extends StatelessWidget {
  const ModelDataVizPalettePage({
    required this.model,
    super.key,
  });

  final ModelDataVizPalette model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ModelDataVizPalette'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _DsModelGalleryPaletteSection(
              title: 'Categorical',
              colors: model.categorical,
            ),
            const SizedBox(height: 16),
            _DsModelGalleryPaletteSection(
              title: 'Sequential',
              colors: model.sequential,
            ),
            const SizedBox(height: 16),
            _DsModelGalleryInfoCard(
              title: 'Palette helpers',
              children: <Widget>[
                Text(
                  'categoricalAt(0): ${UtilsForTheme.colorToHex(model.categoricalAt(0))}',
                ),
                Text(
                  'sequentialAt(0.0): ${UtilsForTheme.colorToHex(model.sequentialAt(0.0))}',
                ),
                Text(
                  'sequentialAt(0.5): ${UtilsForTheme.colorToHex(model.sequentialAt(0.5))}',
                ),
                Text(
                  'sequentialAt(1.0): ${UtilsForTheme.colorToHex(model.sequentialAt(1.0))}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
