import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

import 'ds_widget_catalog.dart';

void main() {
  runApp(const DsGalleryExampleApp());
}

class DsGalleryExampleApp extends StatefulWidget {
  const DsGalleryExampleApp({super.key});

  @override
  State<DsGalleryExampleApp> createState() => _DsGalleryExampleAppState();
}

class _DsGalleryExampleAppState extends State<DsGalleryExampleApp> {
  final ModelDesignSystem designSystem = defaultModelDesignSystem();
  late final BlocGallery galleryBloc = BlocGallery(
    designSystem: designSystem,
    pages: <ModelDsGalleryPageEntry>[
      ...BlocGallery.defaultPages(designSystem: designSystem),
      ...dsWidgetCatalog.map((DsWidgetCatalogEntry entry) => entry.toPage()),
      ..._exampleWidgetPages(),
    ],
  );

  @override
  void dispose() {
    galleryBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      title: 'Example-only buttons',
      section: 'Local demonstrations',
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
    name: 'Example-only buttons',
    description: 'Local button demonstrations; these classes are not public package APIs.',
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
