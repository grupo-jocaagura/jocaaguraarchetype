part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

typedef PageWidgetBuilder = Widget Function(
  BuildContext context,
  PageModel page,
);

typedef NotFoundBuilder = Widget? Function(BuildContext context, PageModel req);

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

  final NotFoundBuilder? notFoundBuilder;

  final PageModel? defaultPage;

  final NavStackModel? defaultStack;

  bool contains(String name) => _builders.containsKey(name);

  Widget build(BuildContext context, PageModel page) {
    final PageWidgetBuilder? b = _builders[page.name];
    if (b != null) {
      return b(context, page);
    }

    final Widget? custom = notFoundBuilder?.call(context, page);
    if (custom != null) {
      return custom;
    }

    if (defaultStack != null) {
      return _RegistryRedirect(stack: defaultStack);
    }

    if (defaultPage != null) {
      return _RegistryRedirect(page: defaultPage);
    }

    return _DefaultNotFoundPage(location: page.toUriString());
  }

  Page<dynamic> toPage(PageModel page, {int? position}) {
    Widget child(BuildContext ctx) => build(ctx, page);

    final String pos = position == null ? '' : '$position:';
    final String segs = page.segments.join('/');

    final String canonicalQuery = () {
      if (page.query.isEmpty) {
        return '';
      }
      final List<String> ks = page.query.keys.toList()..sort();
      return ks.map((String k) => '$k=${page.query[k]}').join('&');
    }();

    final LocalKey key = ValueKey<String>(
      'pg:$pos${page.kind}:${page.name}:$segs:$canonicalQuery:${page.requiresAuth}',
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
