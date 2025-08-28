part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Signature for building a widget given a [PageModel].
typedef PageWidgetBuilder = Widget Function(
  BuildContext context,
  PageModel page,
);

/// Optional handler when a page name is not found.
/// - Return a Widget to show (custom 404).
/// - Or return `null` to let registry use default fallback/redirect if provided.
typedef NotFoundBuilder = Widget? Function(BuildContext context, PageModel req);

/// Registry mapping `PageModel.name` to a widget builder.
/// Can optionally handle unknown routes with:
///  - [notFoundBuilder] → renders a custom UI, or
///  - [defaultPage] / [defaultStack] → redirects the navigation (post-frame).
class PageRegistry {
  const PageRegistry(
    this._builders, {
    this.notFoundBuilder,
    this.defaultPage,
    this.defaultStack,
  });
  PageRegistry.fromDefs(
    List<PageDef> defs, {
    this.notFoundBuilder,
    this.defaultPage,
    this.defaultStack,
  }) : _builders =
            Map<String, PageWidgetBuilder>.unmodifiable(<dynamic, dynamic>{
          for (final PageDef pageDef in defs)
            pageDef.model.name: pageDef.builder,
        });

  final Map<String, PageWidgetBuilder> _builders;

  /// Custom UI when name is not found (has priority over redirects).
  final NotFoundBuilder? notFoundBuilder;

  /// If provided and name is unknown, we replaceTop with this page.
  final PageModel? defaultPage;

  /// If provided and name is unknown, we replace the whole stack with this one.
  /// (Takes precedence over [defaultPage]).
  final NavStackModel? defaultStack;

  bool contains(String name) => _builders.containsKey(name);

  Widget build(BuildContext context, PageModel page) {
    final PageWidgetBuilder? b = _builders[page.name];
    if (b != null) {
      return b(context, page);
    }

    // 1) Custom not found UI (caller decides visual behaviour)
    final Widget? custom = notFoundBuilder?.call(context, page);
    if (custom != null) {
      return custom;
    }

    // 2) Redirect by replacing stack (strongest)
    if (defaultStack != null) {
      return _RegistryRedirect(stack: defaultStack);
    }

    // 3) Redirect by replacing ONLY the top
    if (defaultPage != null) {
      return _RegistryRedirect(page: defaultPage);
    }

    // 4) Built-in 404 (safe default)
    debugPrint(
      '[PageRegistry] 404 for name="${page.name}", '
      'segments=${page.segments}, known=${_builders.keys.toList()}',
    );
    return _DefaultNotFoundPage(location: page.toUriString());
  }

  /// Builds a materialized `Page` from a [PageModel] using [PageKind].
  Page<dynamic> toPage(PageModel page, {int? position}) {
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
          onTap: () => context.appManager.pageManager.goHome(),
          child: Text('404 — $location'),
        ),
      ),
    );
  }
}

/// Small helper that performs a post-frame navigation redirect.
/// - If [stack] provided → `setStack(stack)`
/// - Else if [page] provided → `replaceTop(page)`
class _RegistryRedirect extends StatelessWidget {
  const _RegistryRedirect({this.page, this.stack});
  final PageModel? page;
  final NavStackModel? stack;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final PageManager pm = context.appManager.pageManager;
      if (stack != null) {
        pm.setStack(stack!);
      } else if (page != null) {
        pm.replaceTop(page!);
      }
    });
    // Render nothing while redirecting.
    return const SizedBox.shrink();
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
