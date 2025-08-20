part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Signature for building a widget given a [PageModel].
typedef PageWidgetBuilder = Widget Function(
  BuildContext context,
  PageModel page,
);

/// Registry mapping `PageModel.name` to a `PageBuilder`.
///
/// Keeps UI wiring concentrated and testable.
class PageRegistry {
  const PageRegistry(
    this._builders,
  );

  final Map<String, PageWidgetBuilder> _builders;

  bool contains(String name) => _builders.containsKey(name);

  Widget build(BuildContext context, PageModel page) {
    final PageWidgetBuilder? b = _builders[page.name];
    if (b == null) {
      // 👇 LOG CLAVE
      debugPrint(
        '[PageRegistry] 404 for name="${page.name}", segments=${page.segments}, known=${_builders.keys.toList()}',
      );
      return _DefaultNotFoundPage(location: page.toUriString());
    }
    return b(context, page);
  }

  /// Builds a materialized `Page` from a [PageModel] using [PageKind].
  Page<dynamic> toPage(
    PageModel page, {
    int? position,
  }) {
    Widget child(BuildContext ctx) => build(ctx, page);
    final LocalKey key = ValueKey<String>(
      'pg:${position ?? 0}:${page.name}:${page.segments.join('/')}:'
      '${page.query.hashCode}:${page.kind}:${page.requiresAuth}',
    );
    switch (page.kind) {
      case PageKind.cupertino:
        return CupertinoPage<dynamic>(
          key: key,
          name: page.name,
          child: Builder(builder: child),
        );
      case PageKind.dialog:
        return DialogPage<dynamic>(key: key, name: page.name, builder: child);
      case PageKind.fullScreenDialog:
        return MaterialPage<dynamic>(
          key: key,
          name: page.name,
          child: Builder(builder: child),
          fullscreenDialog: true,
        );
      case PageKind.material:
        return MaterialPage<dynamic>(
          key: key,
          name: page.name,
          child: Builder(builder: child),
        );
    }
  }
}

/// Minimal fallback "Not Found" page.
class _DefaultNotFoundPage extends StatelessWidget {
  const _DefaultNotFoundPage({required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () {
            context.appManager.page.goHome();
          },
          child: Text('404 — $location'),
        ),
      ),
    );
  }
}

/// Simple dialog page wrapper to support [PageKind.dialog] without boilerplate.
class DialogPage<T> extends Page<T> {
  const DialogPage({required this.builder, super.key, super.name});
  final WidgetBuilder builder;

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(
      context: context,
      builder: builder,
      settings: this,
    );
  }
}
