part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

extension _GalleryTokens on BuildContext {
  ModelDsExtendedTokens get _galleryTokens =>
      Theme.of(this).extension<DsExtendedTokensExtension>()?.tokens ??
      const ModelDsExtendedTokens();
}

ModelDsGalleryPageEntry _galleryComponentPage(
  ModelDsComponentAnatomy anatomy,
  GalleryPreviewBuilder previewBuilder,
) {
  return ModelDsGalleryPageEntry(
    id: anatomy.id,
    title: anatomy.name,
    section: 'Widgets',
    description: anatomy.description,
    builder:
        (BuildContext context, BlocGallery bloc, ModelDsGalleryState state) {
          return DesignSystemGalleryPage(
            anatomy: anatomy,
            designSystem: state.designSystem,
            previewBuilder: previewBuilder,
          );
        },
  );
}

const ModelDsComponentAnatomy _layeredSurfaceAnatomy = ModelDsComponentAnatomy(
  id: 'ds.widget.layered_surface',
  name: 'DsLayeredSurfaceWidget',
  description: 'Composes a gradient, an organic texture and a translucent overlay behind content.',
  tags: <String>['surface', 'texture'],
  status: ModelDsComponentStatusEnum.stable,
  platforms: ModelDsComponentPlatformEnum.values,
  slots: <ModelDsComponentSlot>[
    ModelDsComponentSlot(
      name: 'Surface',
      role: 'Draws and clips the decorative layers.',
      rules: <String>[
        'Choose a gradient with sufficient contrast behind the child.',
      ],
      tokensUsed: <String>['borderRadiusXXl', 'withAlpha', 'withAlphaSm'],
    ),
    ModelDsComponentSlot(
      name: 'Child',
      role: 'Displays content above the decorative layers.',
      rules: <String>[],
      tokensUsed: <String>[],
    ),
  ],
);

Widget _buildLayeredSurfacePreview(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  final ColorScheme colors = theme.colorScheme;
  return DsLayeredSurfaceWidget(
    gradientColors: <Color>[colors.primaryContainer, colors.tertiaryContainer],
    padding: EdgeInsets.all(context.dsTokens.spacing),
    child: Text(
      'Layered surface',
      textAlign: TextAlign.center,
      style: theme.textTheme.titleMedium?.copyWith(
        color: colors.onPrimaryContainer,
      ),
    ),
  );
}

const ModelDsComponentAnatomy
_interactiveBuilderAnatomy = ModelDsComponentAnatomy(
  id: 'ds.widget.interactive_builder',
  name: 'DsInteractiveBuilder',
  description: 'Selects a widget builder from a controlled interaction state.',
  tags: <String>['interaction', 'state'],
  status: ModelDsComponentStatusEnum.stable,
  platforms: ModelDsComponentPlatformEnum.values,
  slots: <ModelDsComponentSlot>[
    ModelDsComponentSlot(
      name: 'State',
      role: 'Supplies visibility, loading, error, selection and enabled state.',
      rules: <String>['Pass state from the component controller.'],
      tokensUsed: <String>[],
    ),
    ModelDsComponentSlot(
      name: 'Builders',
      role: 'Render variants for each state.',
      rules: <String>['Provide an enabled builder for the default variant.'],
      tokensUsed: <String>[],
    ),
  ],
);

Widget _buildInteractivePreview(BuildContext _) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      for (final ModelInteractiveState state in const <ModelInteractiveState>[
        ModelInteractiveState(),
        ModelInteractiveState(isLoading: true),
        ModelInteractiveState(isEnabled: false),
        ModelInteractiveState(errorText: 'Unavailable'),
      ])
        DsInteractiveBuilder(
          state: state,
          enabledBuilder: (_, _) =>
              FilledButton(onPressed: () {}, child: const Text('Enabled')),
          loadingBuilder: (_, _) =>
              const OutlinedButton(onPressed: null, child: Text('Loading')),
          disabledBuilder: (_, _) =>
              const OutlinedButton(onPressed: null, child: Text('Disabled')),
          errorBuilder: (BuildContext context, ModelInteractiveState state) =>
              Text(
                state.errorText,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
        ),
    ],
  );
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({required this.anatomy});

  final ModelDsComponentAnatomy anatomy;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(anatomy.name, style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(height: tokens.spacingSm),
        _GalleryTagsWrap(tags: anatomy.tags),
      ],
    );
  }
}

class _GalleryTagsWrap extends StatelessWidget {
  const _GalleryTagsWrap({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    return Wrap(
      spacing: tokens.spacingSm,
      runSpacing: tokens.spacingSm,
      children: tags
          .map((String tag) {
            return Chip(label: Text(tag));
          })
          .toList(growable: false),
    );
  }
}

class _GalleryMetadataCard extends StatelessWidget {
  const _GalleryMetadataCard({required this.anatomy});

  final ModelDsComponentAnatomy anatomy;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Metadata', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: tokens.spacingSm),
            Text('Id: ${anatomy.id}'),
            Text('Status: ${anatomy.status.name}'),
            Text('Platforms: ${anatomy.platforms.join(', ')}'),
          ],
        ),
      ),
    );
  }
}

class _GalleryDescriptionCard extends StatelessWidget {
  const _GalleryDescriptionCard({required this.anatomy});

  final ModelDsComponentAnatomy anatomy;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Description', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: tokens.spacingSm),
            Text(anatomy.description),
          ],
        ),
      ),
    );
  }
}

class _GallerySlotsCard extends StatelessWidget {
  const _GallerySlotsCard({required this.anatomy});

  final ModelDsComponentAnatomy anatomy;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Anatomy slots',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spacingSm),
            for (final ModelDsComponentSlot slot in anatomy.slots) ...<Widget>[
              Text(slot.name, style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: tokens.spacingXs),
              Text(slot.role),
              if (slot.rules.isNotEmpty) ...<Widget>[
                SizedBox(height: tokens.spacingXs),
                Text('Rules: ${slot.rules.join(', ')}'),
              ],
              if (slot.tokensUsed.isNotEmpty) ...<Widget>[
                SizedBox(height: tokens.spacingXs),
                Text('Tokens: ${slot.tokensUsed.join(', ')}'),
              ],
              SizedBox(height: tokens.spacingSm),
            ],
          ],
        ),
      ),
    );
  }
}

class _GalleryLinksCard extends StatelessWidget {
  const _GalleryLinksCard({
    required this.anatomy,
    this.onOpenDetailedInfo,
    this.onOpenLink,
  });

  final ModelDsComponentAnatomy anatomy;
  final ValueChanged<ModelDsComponentAnatomy>? onOpenDetailedInfo;
  final ValueChanged<ModelDsComponentLink>? onOpenLink;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    final bool hasDetailedInfo = anatomy.urlDetailedInfo?.isNotEmpty ?? false;
    final bool hasLinks = anatomy.links.isNotEmpty;

    if (!hasDetailedInfo && !hasLinks) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('References', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: tokens.spacingSm),
            if (hasDetailedInfo)
              OutlinedButton(
                onPressed: onOpenDetailedInfo == null
                    ? null
                    : () => onOpenDetailedInfo!(anatomy),
                child: const Text('Open detailed information'),
              ),
            for (final ModelDsComponentLink link in anatomy.links)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(link.label),
                subtitle: Text(link.url),
                trailing: const Icon(Icons.open_in_new),
                onTap: onOpenLink == null ? null : () => onOpenLink!(link),
              ),
          ],
        ),
      ),
    );
  }
}

class _GalleryAssetPreview extends StatelessWidget {
  const _GalleryAssetPreview({
    required this.previewAssetKey,
    this.previewAssetBuilder,
  });

  final String previewAssetKey;
  final GalleryAssetPreviewBuilder? previewAssetBuilder;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    if (previewAssetBuilder != null) {
      return previewAssetBuilder!(context, previewAssetKey);
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing),
        child: Text('Preview asset key: $previewAssetKey'),
      ),
    );
  }
}

class _GalleryUrlImagePreview extends StatelessWidget {
  const _GalleryUrlImagePreview({
    required this.previewUrlImage,
    this.previewUrlImageBuilder,
  });

  final String previewUrlImage;
  final GalleryUrlImagePreviewBuilder? previewUrlImageBuilder;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    if (previewUrlImageBuilder != null) {
      return previewUrlImageBuilder!(context, previewUrlImage);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        previewUrlImage,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
              return Padding(
                padding: EdgeInsets.all(tokens.spacing),
                child: Text('Remote preview unavailable: $previewUrlImage'),
              );
            },
      ),
    );
  }
}

class _DsModelGalleryInfoCard extends StatelessWidget {
  const _DsModelGalleryInfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: tokens.spacingSm),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DsModelGalleryColorSchemeSection extends StatelessWidget {
  const _DsModelGalleryColorSchemeSection({
    required this.title,
    required this.colorScheme,
  });

  final String title;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    final List<_DsModelGalleryColorToken> colors = <_DsModelGalleryColorToken>[
      _DsModelGalleryColorToken('primary', colorScheme.primary),
      _DsModelGalleryColorToken('onPrimary', colorScheme.onPrimary),
      _DsModelGalleryColorToken(
        'primaryContainer',
        colorScheme.primaryContainer,
      ),
      _DsModelGalleryColorToken(
        'onPrimaryContainer',
        colorScheme.onPrimaryContainer,
      ),
      _DsModelGalleryColorToken('secondary', colorScheme.secondary),
      _DsModelGalleryColorToken('onSecondary', colorScheme.onSecondary),
      _DsModelGalleryColorToken('tertiary', colorScheme.tertiary),
      _DsModelGalleryColorToken('onTertiary', colorScheme.onTertiary),
      _DsModelGalleryColorToken('error', colorScheme.error),
      _DsModelGalleryColorToken('onError', colorScheme.onError),
      _DsModelGalleryColorToken('surface', colorScheme.surface),
      _DsModelGalleryColorToken('onSurface', colorScheme.onSurface),
      _DsModelGalleryColorToken('outline', colorScheme.outline),
      _DsModelGalleryColorToken('shadow', colorScheme.shadow),
      _DsModelGalleryColorToken('inverseSurface', colorScheme.inverseSurface),
      _DsModelGalleryColorToken(
        'onInverseSurface',
        colorScheme.onInverseSurface,
      ),
      _DsModelGalleryColorToken('inversePrimary', colorScheme.inversePrimary),
      _DsModelGalleryColorToken('surfaceTint', colorScheme.surfaceTint),
    ];

    return _DsModelGalleryInfoCard(
      title: title,
      children: <Widget>[
        Text('brightness: ${colorScheme.brightness.name}'),
        SizedBox(height: tokens.spacingSm),
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingSm,
          children: colors
              .map((_DsModelGalleryColorToken token) {
                return _DsModelGalleryColorTile(token: token);
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _DsModelGalleryColorTile extends StatelessWidget {
  const _DsModelGalleryColorTile({required this.token});

  final _DsModelGalleryColorToken token;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    final Color textColor = token.color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return Container(
      width: 160,
      padding: EdgeInsets.all(tokens.spacingSm),
      decoration: BoxDecoration(
        color: token.color,
        borderRadius: BorderRadius.circular(tokens.borderRadius),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodySmall!
            .copyWith(color: textColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(token.name),
            SizedBox(height: tokens.spacingXs),
            Text(_colorToHex(token.color)),
          ],
        ),
      ),
    );
  }
}

class _DsModelGalleryTokenScaleSection extends StatelessWidget {
  const _DsModelGalleryTokenScaleSection({
    required this.title,
    required this.items,
    this.maxVisualValue,
  });

  final String title;
  final List<_DsModelGalleryNumberToken> items;
  final double? maxVisualValue;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    final double resolvedMax =
        maxVisualValue ??
        items.fold<double>(0, (
          double previous,
          _DsModelGalleryNumberToken item,
        ) {
          return item.value > previous ? item.value : previous;
        });

    return _DsModelGalleryInfoCard(
      title: title,
      children: items
          .map((_DsModelGalleryNumberToken item) {
            final double widthFactor = resolvedMax <= 0
                ? 0
                : (item.value / resolvedMax).clamp(0.0, 1.0);

            return Padding(
              padding: EdgeInsets.only(bottom: tokens.spacingSm),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 160, child: Text(item.name)),
                  Expanded(child: LinearProgressIndicator(value: widthFactor)),
                  SizedBox(width: tokens.spacingSm),
                  SizedBox(
                    width: 72,
                    child: Text(item.value.toStringAsFixed(2)),
                  ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _DsModelGallerySemanticPair extends StatelessWidget {
  const _DsModelGallerySemanticPair({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: tokens.spacingSm),
      padding: EdgeInsets.all(tokens.spacing),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(tokens.borderRadius),
      ),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!
            .copyWith(color: foreground),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label),
            SizedBox(height: tokens.spacingXs),
            Text('bg: ${_colorToHex(background)}'),
            Text('fg: ${_colorToHex(foreground)}'),
          ],
        ),
      ),
    );
  }
}

class _DsModelGalleryPaletteSection extends StatelessWidget {
  const _DsModelGalleryPaletteSection({
    required this.title,
    required this.colors,
  });

  final String title;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    return _DsModelGalleryInfoCard(
      title: title,
      children: <Widget>[
        Wrap(
          spacing: tokens.spacingSm,
          runSpacing: tokens.spacingSm,
          children: colors
              .asMap()
              .entries
              .map((MapEntry<int, Color> entry) {
                return _DsModelGalleryColorTile(
                  token: _DsModelGalleryColorToken(
                    '$title ${entry.key}',
                    entry.value,
                  ),
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _DsModelGalleryTextStylePreview extends StatelessWidget {
  const _DsModelGalleryTextStylePreview({required this.item});

  final _DsModelGalleryTextStyleItem item;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context._galleryTokens;
    final TextStyle? style = item.style;

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: tokens.spacingSm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(item.name, style: Theme.of(context).textTheme.labelMedium),
              SizedBox(height: tokens.spacingSm),
              Text('The quick brown fox jumps over the lazy dog', style: style),
              SizedBox(height: tokens.spacingSm),
              Text(
                _styleSummary(style),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DsModelGalleryColorToken {
  const _DsModelGalleryColorToken(this.name, this.color);

  final String name;
  final Color color;
}

class _DsModelGalleryNumberToken {
  const _DsModelGalleryNumberToken(this.name, this.value);

  final String name;
  final double value;
}

class _DsModelGalleryTextStyleItem {
  const _DsModelGalleryTextStyleItem({required this.name, required this.style});

  final String name;
  final TextStyle? style;
}

String _colorToHex(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

String _styleSummary(TextStyle? style) {
  if (style == null) {
    return 'null style';
  }

  final String fontSize = style.fontSize == null
      ? 'fontSize: null'
      : 'fontSize: ${style.fontSize!.toStringAsFixed(1)}';

  final String fontWeight = style.fontWeight == null
      ? 'weight: null'
      : 'weight: ${style.fontWeight!.value}';

  final String height = style.height == null
      ? 'height: null'
      : 'height: ${style.height!.toStringAsFixed(2)}';

  return '$fontSize · $fontWeight · $height';
}
