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
