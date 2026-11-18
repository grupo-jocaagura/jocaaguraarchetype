import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

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
        ..._exampleWidgetPages(),
      ],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jocaagura DS Gallery',
      theme: designSystem.toThemeData(brightness: Brightness.light),
      darkTheme: designSystem.toThemeData(brightness: Brightness.dark),
      home: DsGalleryPage(designSystem: designSystem, bloc: galleryBloc),
    );
  }
}

List<ModelDsGalleryPageEntry> _exampleWidgetPages() {
  return <ModelDsGalleryPageEntry>[
    ModelDsGalleryPageEntry(
      id: 'example.ds.widgets.buttons',
      title: 'DS Buttons',
      section: 'Widgets',
      description: 'Primary and secondary button examples.',
      builder:
          (BuildContext context, BlocGallery bloc, ModelDsGalleryState state) {
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
      id: 'example.ds.widgets.typography',
      title: 'DS Typography Widgets',
      section: 'Widgets',
      description: 'Text widgets using the active ThemeData.',
      builder:
          (BuildContext context, BlocGallery bloc, ModelDsGalleryState state) {
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
      builder:
          (BuildContext context, BlocGallery bloc, ModelDsGalleryState state) {
            return Scaffold(
              appBar: AppBar(title: const Text('SideBySideWidget usage')),
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
                                  style: Theme.of(previewContext)
                                      .textTheme
                                      .bodyMedium,
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

ModelDsComponentAnatomy _buttonsAnatomy() {
  return const ModelDsComponentAnatomy(
    id: 'example.ds.widgets.buttons',
    name: 'DS Buttons',
    description:
        'Shows primary, secondary and loading button states using DS widgets.',
    tags: <String>['buttons', 'actions', 'design-system'],
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
        tokensUsed: <String>['colorScheme.primary', 'textTheme.labelLarge'],
      ),
      ModelDsComponentSlot(
        name: 'SecondaryButton',
        role: 'Represents an alternative or secondary action.',
        rules: <String>[
          'Use for secondary actions.',
          'Must not compete visually with the primary action.',
        ],
        tokensUsed: <String>['colorScheme.outline', 'textTheme.labelLarge'],
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
    tags: <String>['typography', 'text', 'theme'],
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
        tokensUsed: <String>['textTheme'],
      ),
    ],
  );
}

class DsTextHeadlineMediumWidget extends StatelessWidget {
  const DsTextHeadlineMediumWidget({required this.label, super.key});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.headlineMedium);
  }
}

class DsTextTitleLargeWidget extends StatelessWidget {
  const DsTextTitleLargeWidget({required this.label, super.key});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleLarge);
  }
}

class DsTextBodyMediumWidget extends StatelessWidget {
  const DsTextBodyMediumWidget({required this.label, super.key});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.bodyMedium);
  }
}

class DsTextLabelSmallWidget extends StatelessWidget {
  const DsTextLabelSmallWidget({required this.label, super.key});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.bodySmall);
  }
}
