part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Demo page that builds its UI from navigation data (**PageModel**).
///
/// This page follows the Jocaagura Archetype navigation contract:
/// - Exposes a **static [name]** and a **static [page]** (base `PageModel`).
/// - Provides a **factory** to build from a `PageModel` ([fromPageModel]).
/// - Provides a **static [builder]** to be used in a `PageRegistry`.
/// - Provides **helpers** to generate a configured `PageModel` ([make])
///   and convenience navigation methods ([pushOnce], [open], [replaceTop]).
///
/// ### Registry example
/// ```dart
/// final PageRegistry registry = PageRegistry(<String, PageWidgetBuilder>{
///   TestPageBuilderPage.name: TestPageBuilderPage.builder,
/// });
/// ```
///
/// ### Push examples (prefer data-driven)
/// ```dart
/// // Using a model you control (safer for UI-domain independence):
/// context.appManager.pageManager.pushOnce(
///   TestPageBuilderPage.make(title: 'Test A', content: 'hello'),
/// );
///
/// // Or convenience method:
/// TestPageBuilderPage.open(context, title: 'Test B', content: 'pushed');
/// ```
class TestPageBuilderPage extends StatelessWidget {
  const TestPageBuilderPage({
    required this.title,
    super.key,
    this.contentKey,
    @Deprecated('Pass data via PageModel and use fromPageModel instead.')
    this.legacyPage,
  });

  /// Factory to build the page from a [PageModel].
  factory TestPageBuilderPage.fromPageModel(PageModel p) {
    final String title = (p.state['title'] as String?) ?? 'TestPage';
    final String? content = p.query['content'];
    return TestPageBuilderPage(title: title, contentKey: content);
  }

  /// **Route name** used in the PageRegistry.
  static const String name = 'TestPageBuilderPage';

  /// **Base PageModel** to keep navigation declarative and UI-domain independent.
  static const PageModel pageModel = PageModel(
    name: name,
    segments: <String>['test'],
  );

  /// **Registry builder** that instantiates this page from a `PageModel`.
  static PageWidgetBuilder builder() {
    return (BuildContext ctx, PageModel p) =>
        TestPageBuilderPage.fromPageModel(p);
  }

  /// Title to show in the page (typically from `PageModel.state['title']`).
  final String title;

  /// Optional content switch (e.g., `PageModel.query['content']`).
  final String? contentKey;

  /// (Deprecated) Old-style body widget passed directly.
  @Deprecated('Prefer data-driven UI; remove this once migrated.')
  final Widget? legacyPage;

  /// Helper to create a **configured** `PageModel` for this page.
  ///
  /// Supply `title` and/or `content` and it will place them into the
  /// `state` and `query` maps respectively.
  static PageModel make({String? title, String? content}) {
    final Map<String, Object?> state = <String, Object?>{};
    final Map<String, String> query = <String, String>{};
    if (title != null) {
      state['title'] = title;
    }
    if (content != null) {
      query['content'] = content;
    }
    return pageModel.copyWith(state: state, query: query);
  }

  /// Convenience navigation using `pushOnce`.
  static void pushOnce(BuildContext context, {String? title, String? content}) {
    context.appManager.pageManager
        .pushOnce(make(title: title, content: content));
  }

  /// Convenience navigation using `pushOnce` (alias `open`).
  static void open(BuildContext context, {String? title, String? content}) =>
      pushOnce(context, title: title, content: content);

  /// Replace the top page using `AppManager.replaceTopNamed`.
  static void replaceTop(
    BuildContext context, {
    String? title,
    String? content,
    bool allowNoop = false,
  }) {
    context.appManager.replaceTopNamed(
      name,
      segments: const <String>['test'],
      query: <String, String>{if (content != null) 'content': content},
      state: <String, Object?>{if (title != null) 'title': title},
      allowNoop: allowNoop,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => TestPageBuilderPage.open(
              context,
              title: 'Repushed',
              content: 'pushed',
            ),
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
