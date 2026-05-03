import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  runApp(const DsGalleryExampleApp());
}

class DsGalleryExampleApp extends StatelessWidget {
  const DsGalleryExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ModelDesignSystem designSystem = defaultModelDesignSystem();

    final BlocGallery galleryBloc = BlocGallery(
      designSystem: designSystem,
      pages: <ModelDsGalleryPageEntry>[
        ...BlocGallery.defaultPages(designSystem: designSystem),
        ..._exampleWidgetPages(designSystem),
      ],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jocaagura DS Gallery',
      theme: designSystem.theme.toThemeData(brightness: Brightness.light),
      darkTheme: designSystem.theme.toThemeData(brightness: Brightness.dark),
      home: DsGalleryPage(
        designSystem: designSystem,
        bloc: galleryBloc,
      ),
    );
  }
}

List<ModelDsGalleryPageEntry> _exampleWidgetPages(
  ModelDesignSystem designSystem,
) {
  return <ModelDsGalleryPageEntry>[
    ModelDsGalleryPageEntry(
      id: 'example.ds.widgets.buttons',
      title: 'DS Buttons',
      section: 'Widgets',
      description: 'Primary and secondary button examples.',
      builder: (
        BuildContext context,
        BlocGallery bloc,
        ModelDsGalleryState state,
      ) {
        return DesignSystemGalleryPage(
          anatomy: _buttonsAnatomy(),
          designSystem: state.designSystem,
          previewBuilder: (BuildContext previewContext) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DsPrimaryButtonWidget(
                  label: 'Primary action',
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                DsSecondaryButtonWidget(
                  label: 'Secondary action',
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                const DsPrimaryButtonWidget(
                  label: 'Loading action',
                  isLoading: true,
                ),
              ],
            );
          },
        );
      },
    ),
    ModelDsGalleryPageEntry(
      id: 'example.ds.widgets.interactive_builder',
      title: 'DsInteractiveBuilder',
      section: 'Widgets',
      description: 'Interactive state rendering examples.',
      builder: (
        BuildContext context,
        BlocGallery bloc,
        ModelDsGalleryState state,
      ) {
        return DesignSystemGalleryPage(
          anatomy: _interactiveBuilderAnatomy(),
          designSystem: state.designSystem,
          previewBuilder: (BuildContext previewContext) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _ExampleInteractiveButton(
                  label: 'Enabled',
                  state: ModelInteractiveState(
                    semantic: ModelInteractiveSemantic.primary,
                  ),
                ),
                SizedBox(height: 12),
                _ExampleInteractiveButton(
                  label: 'Loading',
                  state: ModelInteractiveState(
                    isEnabled: false,
                    isLoading: true,
                    reasonText: 'Processing...',
                    semantic: ModelInteractiveSemantic.primary,
                  ),
                ),
                SizedBox(height: 12),
                _ExampleInteractiveButton(
                  label: 'Disabled',
                  state: ModelInteractiveState(
                    isEnabled: false,
                    reasonText: 'Missing required data',
                    semantic: ModelInteractiveSemantic.warning,
                  ),
                ),
                SizedBox(height: 12),
                _ExampleInteractiveButton(
                  label: 'Error',
                  state: ModelInteractiveState(
                    isEnabled: false,
                    errorText: 'Action unavailable',
                    semantic: ModelInteractiveSemantic.danger,
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
    ModelDsGalleryPageEntry(
      id: 'example.ds.widgets.typography',
      title: 'DS Typography Widgets',
      section: 'Widgets',
      description: 'Text widgets using the active ThemeData.',
      builder: (
        BuildContext context,
        BlocGallery bloc,
        ModelDsGalleryState state,
      ) {
        return DesignSystemGalleryPage(
          anatomy: _typographyAnatomy(),
          designSystem: state.designSystem,
          previewBuilder: (BuildContext previewContext) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DsTextHeadlineMediumWidget(label: 'Headline medium'),
                SizedBox(height: 8),
                DsTextTitleLargeWidget(label: 'Title large'),
                SizedBox(height: 8),
                DsTextBodyMediumWidget(
                  label: 'Body medium text rendered from DS typography.',
                ),
                SizedBox(height: 8),
                DsTextLabelSmallWidget(label: 'Label small'),
              ],
            );
          },
        );
      },
    ),
    ModelDsGalleryPageEntry(
      id: 'example.ds.widgets.side_by_side',
      title: 'SideBySideWidget',
      section: 'Gallery Tools',
      description: 'Compares one widget in light and dark theme.',
      builder: (
        BuildContext context,
        BlocGallery bloc,
        ModelDsGalleryState state,
      ) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('SideBySideWidget usage'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'SideBySideWidget renders the same preview with two independent '
                  'Theme trees: one light and one dark.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                SideBySideWidget(
                  designSystem: state.designSystem,
                  builder: (BuildContext previewContext) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Preview card',
                              style: Theme.of(previewContext)
                                  .textTheme
                                  .titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This card is rendered with the local preview theme.',
                              style:
                                  Theme.of(previewContext).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () {},
                              child: const Text('Action'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    ),
  ];
}

class DsPrimaryButtonWidget extends StatelessWidget {
  const DsPrimaryButtonWidget({
    super.key,
    this.label = 'None',
    this.isLoading = false,
    this.onPressed,
  });

  final String label;
  final bool isLoading;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: isLoading ? const CircularProgressIndicator() : Text(label),
    );
  }
}

class DsSecondaryButtonWidget extends StatelessWidget {
  const DsSecondaryButtonWidget({
    super.key,
    this.label = 'None',
    this.isLoading = false,
    this.onPressed,
  });

  final String label;
  final bool isLoading;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: isLoading ? const CircularProgressIndicator() : Text(label),
    );
  }
}

class _ExampleInteractiveButton extends StatelessWidget {
  const _ExampleInteractiveButton({
    required this.label,
    required this.state,
  });

  final String label;
  final ModelInteractiveState state;

  @override
  Widget build(BuildContext context) {
    return DsInteractiveBuilder(
      state: state,
      loadingBuilder: (
        BuildContext context,
        ModelInteractiveState state,
      ) {
        return DsPrimaryButtonWidget(
          label: state.reasonText.isEmpty ? label : state.reasonText,
          isLoading: true,
        );
      },
      errorBuilder: (
        BuildContext context,
        ModelInteractiveState state,
      ) {
        return DsSecondaryButtonWidget(
          label: state.errorText,
        );
      },
      disabledBuilder: (
        BuildContext context,
        ModelInteractiveState state,
      ) {
        return DsSecondaryButtonWidget(
          label: state.reasonText.isEmpty ? label : state.reasonText,
        );
      },
      enabledBuilder: (
        BuildContext context,
        ModelInteractiveState state,
      ) {
        return DsPrimaryButtonWidget(
          label: label,
          onPressed: () {},
        );
      },
    );
  }
}

ModelDsComponentAnatomy _buttonsAnatomy() {
  return const ModelDsComponentAnatomy(
    id: 'example.ds.widgets.buttons',
    name: 'DS Buttons',
    description:
        'Shows primary, secondary and loading button states using DS widgets.',
    tags: <String>[
      'buttons',
      'actions',
      'design-system',
    ],
    status: ModelDsComponentStatusEnum.stable,
    platforms: <ModelDsComponentPlatformEnum>[
      ModelDsComponentPlatformEnum.android,
      ModelDsComponentPlatformEnum.ios,
      ModelDsComponentPlatformEnum.web,
      ModelDsComponentPlatformEnum.windows,
      ModelDsComponentPlatformEnum.macos,
      ModelDsComponentPlatformEnum.linux,
    ],
    slots: <ModelDsComponentSlot>[
      ModelDsComponentSlot(
        name: 'PrimaryButton',
        role: 'Represents the main action.',
        rules: <String>[
          'Use for the most important action in a section.',
          'Must support disabled and loading states.',
        ],
        tokensUsed: <String>[
          'colorScheme.primary',
          'textTheme.labelLarge',
        ],
      ),
      ModelDsComponentSlot(
        name: 'SecondaryButton',
        role: 'Represents an alternative or secondary action.',
        rules: <String>[
          'Use for secondary actions.',
          'Must not compete visually with the primary action.',
        ],
        tokensUsed: <String>[
          'colorScheme.outline',
          'textTheme.labelLarge',
        ],
      ),
    ],
  );
}

ModelDsComponentAnatomy _interactiveBuilderAnatomy() {
  return const ModelDsComponentAnatomy(
    id: 'example.ds.widgets.interactive_builder',
    name: 'DsInteractiveBuilder',
    description:
        'Shows how ModelInteractiveState can be interpreted by reusable UI builders.',
    tags: <String>[
      'interactive',
      'bloc',
      'state',
      'builder',
    ],
    status: ModelDsComponentStatusEnum.draft,
    platforms: <ModelDsComponentPlatformEnum>[
      ModelDsComponentPlatformEnum.android,
      ModelDsComponentPlatformEnum.ios,
      ModelDsComponentPlatformEnum.web,
      ModelDsComponentPlatformEnum.windows,
      ModelDsComponentPlatformEnum.macos,
      ModelDsComponentPlatformEnum.linux,
    ],
    slots: <ModelDsComponentSlot>[
      ModelDsComponentSlot(
        name: 'State',
        role: 'Carries the interaction intent emitted by a BLoC.',
        rules: <String>[
          'The widget must interpret the state, not decide business rules.',
          'The BLoC owns enabled, loading, error and visibility decisions.',
        ],
        tokensUsed: <String>[
          'ModelInteractiveState',
        ],
      ),
      ModelDsComponentSlot(
        name: 'Builders',
        role:
            'Render variants for loading, error, disabled and enabled states.',
        rules: <String>[
          'Use fallback builders when a specific state builder is omitted.',
        ],
        tokensUsed: <String>[
          'InteractiveWidgetBuilder',
        ],
      ),
    ],
  );
}

ModelDsComponentAnatomy _typographyAnatomy() {
  return const ModelDsComponentAnatomy(
    id: 'example.ds.widgets.typography',
    name: 'DS Typography Widgets',
    description:
        'Shows typography widgets that read styles from the active ThemeData.',
    tags: <String>[
      'typography',
      'text',
      'theme',
    ],
    status: ModelDsComponentStatusEnum.stable,
    platforms: <ModelDsComponentPlatformEnum>[
      ModelDsComponentPlatformEnum.android,
      ModelDsComponentPlatformEnum.ios,
      ModelDsComponentPlatformEnum.web,
      ModelDsComponentPlatformEnum.windows,
      ModelDsComponentPlatformEnum.macos,
      ModelDsComponentPlatformEnum.linux,
    ],
    slots: <ModelDsComponentSlot>[
      ModelDsComponentSlot(
        name: 'TextScale',
        role: 'Represents Material text styles through DS text widgets.',
        rules: <String>[
          'Do not hardcode text styles in consumers.',
          'Prefer DS text widgets or Theme.of(context).textTheme with criteria.',
        ],
        tokensUsed: <String>[
          'textTheme',
        ],
      ),
    ],
  );
}

class DsTextHeadlineMediumWidget extends StatelessWidget {
  const DsTextHeadlineMediumWidget({
    required this.label,
    super.key,
  });
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class DsTextTitleLargeWidget extends StatelessWidget {
  const DsTextTitleLargeWidget({
    required this.label,
    super.key,
  });
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class DsTextBodyMediumWidget extends StatelessWidget {
  const DsTextBodyMediumWidget({
    required this.label,
    super.key,
  });
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class DsTextLabelSmallWidget extends StatelessWidget {
  const DsTextLabelSmallWidget({
    required this.label,
    super.key,
  });
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
