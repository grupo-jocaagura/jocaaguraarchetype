part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Shows a compact preview of [ModelThemeData].
class ModelThemeDataPage extends StatelessWidget {
  const ModelThemeDataPage({required this.model, super.key});

  final ModelThemeData model;

  ThemeData _previewTheme(
    Brightness brightness,
    DsExtendedTokensExtension? galleryTokens,
  ) {
    final ThemeData theme = model.toThemeData(brightness: brightness);
    if (galleryTokens == null) {
      return theme;
    }
    return theme.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        ...theme.extensions.values
            .cast<ThemeExtension<ThemeExtension<dynamic>>>(),
        galleryTokens,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final DsExtendedTokensExtension? galleryTokens = Theme.of(context)
        .extension<DsExtendedTokensExtension>();
    final ModelDsExtendedTokens tokens =
        galleryTokens?.tokens ?? const ModelDsExtendedTokens();

    return Scaffold(
      appBar: AppBar(title: const Text('ModelThemeData')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _DsModelGalleryInfoCard(
              title: 'Theme config',
              children: <Widget>[Text('useMaterial3: ${model.useMaterial3}')],
            ),
            SizedBox(height: tokens.spacing),
            _DsModelGalleryColorSchemeSection(
              title: 'Light ColorScheme',
              colorScheme: model.lightScheme,
            ),
            SizedBox(height: tokens.spacing),
            _DsModelGalleryColorSchemeSection(
              title: 'Dark ColorScheme',
              colorScheme: model.darkScheme,
            ),
            SizedBox(height: tokens.spacing),
            Theme(
              data: _previewTheme(Brightness.light, galleryTokens),
              child: TextThemePreviewWidget(
                title: 'Light TextTheme',
                textTheme: model.lightTextTheme,
              ),
            ),
            SizedBox(height: tokens.spacing),
            Theme(
              data: _previewTheme(Brightness.dark, galleryTokens),
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
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing),
        child: TextThemePreviewWidget(title: title, textTheme: textTheme),
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
      children: items
          .map((_DsModelGalleryTextStyleItem item) {
            return _DsModelGalleryTextStylePreview(item: item);
          })
          .toList(growable: false),
    );
  }
}

/// Shows a visual preview of [ModelDsExtendedTokens].
class ModelDsExtendedTokensPage extends StatelessWidget {
  const ModelDsExtendedTokensPage({required this.model, super.key});

  final ModelDsExtendedTokens model;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    return Scaffold(
      appBar: AppBar(title: const Text('ModelDsExtendedTokens')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing),
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
            SizedBox(height: tokens.spacing),
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
                _DsModelGalleryNumberToken('borderRadius', model.borderRadius),
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
            SizedBox(height: tokens.spacing),
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
            SizedBox(height: tokens.spacing),
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
            SizedBox(height: tokens.spacing),
            _DsModelGalleryInfoCard(
              title: 'Animation durations',
              children: <Widget>[
                Text('short: ${model.animationDurationShort.inMilliseconds}ms'),
                Text('regular: ${model.animationDuration.inMilliseconds}ms'),
                Text('long: ${model.animationDurationLong.inMilliseconds}ms'),
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
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing),
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
  const ModelDataVizPalettePage({required this.model, super.key});

  final ModelDataVizPalette model;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    return Scaffold(
      appBar: AppBar(title: const Text('ModelDataVizPalette')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _DsModelGalleryPaletteSection(
              title: 'Categorical',
              colors: model.categorical,
            ),
            SizedBox(height: tokens.spacing),
            _DsModelGalleryPaletteSection(
              title: 'Sequential',
              colors: model.sequential,
            ),
            SizedBox(height: tokens.spacing),
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
