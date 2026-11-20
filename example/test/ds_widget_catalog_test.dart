import 'dart:io';

import 'package:example/ds_gallery_example.dart';
import 'package:example/ds_widget_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'assembled gallery matches every documented component exactly once',
    (WidgetTester tester) async {
      final String index = File('../doc/ds-widget-index.md').readAsStringSync();
      final List<RegExpMatch> rows = RegExp(
        r'^\| `([^`]+)`.*\| `(ds\.widget\.[^`]+)` \|$',
        multiLine: true,
      ).allMatches(index.replaceAll('\r\n', '\n')).toList();
      expect(rows, isNotEmpty);
      final List<String> documentedIds = rows
          .map((RegExpMatch row) => row.group(2)!)
          .toList();
      expect(documentedIds.toSet().length, documentedIds.length);

      await tester.pumpWidget(const DsGalleryExampleApp());
      await tester.pump();
      final BlocGallery bloc = tester
          .widget<DsGalleryPage>(find.byType(DsGalleryPage))
          .bloc!;
      final List<ModelDsGalleryPageEntry> pages = bloc.state.pages;
      expect(
        pages.map((ModelDsGalleryPageEntry page) => page.id).toSet().length,
        pages.length,
      );
      expect(
        pages
            .where(
              (ModelDsGalleryPageEntry page) =>
                  page.id.startsWith('ds.widget.'),
            )
            .map((ModelDsGalleryPageEntry page) => page.id),
        unorderedEquals(documentedIds),
      );

      for (final RegExpMatch row in rows) {
        final String name = row.group(1)!;
        final String id = row.group(2)!;
        final ModelDsGalleryPageEntry page = pages.singleWhere(
          (ModelDsGalleryPageEntry page) => page.id == id,
        );
        expect(
          pages.where((ModelDsGalleryPageEntry page) => page.title == name),
          hasLength(1),
          reason: 'Component must not appear under another ID: $name',
        );
        expect(index, contains('id="$id"'));

        bloc.goToIndex();
        await tester.pump();
        final DsGalleryIndexPage galleryIndex = tester
            .widget<DsGalleryIndexPage>(find.byType(DsGalleryIndexPage));
        galleryIndex.onGoTo(galleryIndex.state.indexOfPage(page));
        await tester.pump();
        final DesignSystemGalleryPage rendered = tester
            .widget<DesignSystemGalleryPage>(
              find.byType(DesignSystemGalleryPage),
            );
        expect(rendered.anatomy.id, id);
        expect(rendered.anatomy.name, page.title);
        expect(rendered.anatomy.description, page.description);
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget.runtimeType.toString().split('<').first == name,
          ),
          findsWidgets,
        );
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test('catalog IDs are unique and match pages and documentation anchors', () {
    final String index = File('../doc/ds-widget-index.md').readAsStringSync();
    final List<String> ids = dsWidgetCatalog
        .map((DsWidgetCatalogEntry e) => e.anatomy.id)
        .toList();
    expect(ids.toSet().length, ids.length);
    for (final DsWidgetCatalogEntry entry in dsWidgetCatalog) {
      expect(entry.toPage().id, entry.anatomy.id);
      expect(index, contains('id="${entry.anatomy.id}"'));
      expect(index, contains(entry.anatomy.name));
    }
  });

  testWidgets('each new catalog page renders anatomy and both theme previews', (
    WidgetTester tester,
  ) async {
    final ModelDesignSystem ds = defaultModelDesignSystem();
    final BlocGallery bloc = BlocGallery(designSystem: ds);
    addTearDown(bloc.dispose);
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());
    tester.view.devicePixelRatio = 1;
    for (final double width in <double>[320, 1200]) {
      tester.view.physicalSize = Size(width, 800);
      for (final DsWidgetCatalogEntry entry in dsWidgetCatalog) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ds.toThemeData(brightness: Brightness.light),
            home: Builder(
              builder: (BuildContext context) =>
                  entry.toPage().builder(context, bloc, bloc.state),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.byType(DesignSystemGalleryPage), findsOneWidget);
        expect(find.byType(SideBySideWidget), findsOneWidget);
        expect(find.text('Usage'), findsNWidgets(2));
      }
    }
  });

  for (final String label in <String>[
    'Guardar todos los cambios',
    'Cancelar edición',
  ]) {
    testWidgets('$label cancels pending work after rapid taps and unmount', (
      WidgetTester tester,
    ) async {
      final DsWidgetCatalogEntry entry = dsWidgetCatalog.singleWhere(
        (DsWidgetCatalogEntry entry) =>
            entry.anatomy.id == 'ds.widget.form_actions',
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: defaultModelDesignSystem().toThemeData(
            brightness: Brightness.light,
          ),
          home: Scaffold(body: Builder(builder: entry.preview)),
        ),
      );

      final Finder action = find.text(label);
      await tester.tap(action);
      await tester.tap(action);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 5));

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('example survives rebuild and unmount with its owned gallery', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DsGalleryExampleApp());
    await tester.pump();
    expect(find.byType(DsGalleryPage), findsOneWidget);
    final BlocGallery bloc = tester
        .widget<DsGalleryPage>(find.byType(DsGalleryPage))
        .bloc!;
    bloc.goToIndex();
    await tester.pump();
    tester.element(find.byType(DsGalleryExampleApp)).markNeedsBuild();
    await tester.pump();
    expect(
      tester.widget<DsGalleryPage>(find.byType(DsGalleryPage)).bloc,
      same(bloc),
    );
    expect(bloc.state.currentPage!.id, 'ds.gallery.index');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
