part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Demo page that builds its UI from navigation data (PageModel).
///
/// - Prefer constructing via [TestPageBuilderPage.fromPageModel].
/// - The `title` usually comes from `page.state['title']`.
/// - You can switch simple content via `page.query['content']`.
///
/// ### Example – push and build via registry
/// ```dart
/// // push:
/// context.appManager.pushNamed(
///   TestPageBuilderPage.name,
///   title: 'TestPage',
///   query: <String,String>{'content':'hello'},
/// );
///
/// // registry:
/// final PageRegistry registry = PageRegistry(<String, PageWidgetBuilder>{
///   TestPageBuilderPage.name: (ctx, page) => TestPageBuilderPage.fromPageModel(page),
/// });
/// ```
///
/// ### Backward compatibility
/// If you still pass a widget directly, use the deprecated `legacyPage` parameter
/// temporarily; it will be shown as the body. Prefer removing it and using PageModel data.
class TestPageBuilderPage extends StatelessWidget {
  const TestPageBuilderPage({
    required this.title,
    super.key,
    this.contentKey,
    @Deprecated('Pass data via PageModel and use fromPageModel instead.')
    this.legacyPage,
  });

  /// Factory to build the page from a [PageModel].
  factory TestPageBuilderPage.fromPageModel(PageModel page) {
    final String title = (page.state['title'] as String?) ?? 'TestPage';
    final String? content = page.query['content'];
    return TestPageBuilderPage(title: title, contentKey: content);
  }

  /// Route name used in the PageRegistry.
  static const String name = 'TestPageBuilderPage';

  /// Title to show in the page (typically from PageModel.state['title']).
  final String title;

  /// Optional content switch (e.g., PageModel.query['content']).
  final String? contentKey;

  /// (Deprecated) Old-style body widget passed directly.
  @Deprecated('Prefer data-driven UI; remove this once migrated.')
  final Widget? legacyPage;

  @override
  Widget build(BuildContext context) {
    // Si tienes un layout propio "PageBuilder", seguimos usándolo como contenedor.
    // En caso contrario, reemplázalo por un Scaffold aquí.
    return PageBuilder(
      page: legacyPage ?? _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(_contentFor(contentKey), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              context.appManager.goTo(
                TestPageBuilderPage.name,
              );
            },
            child: const Text('Push again'),
          ),
        ],
      ),
    );
  }

  static String _contentFor(String? key) {
    switch (key) {
      case 'hello':
        return 'Hello, PageModel!';
      case 'pushed':
        return 'You pushed from TestPageBuilderPage.';
      default:
        return 'This is TestPageBuilderPage content.';
    }
  }
}
