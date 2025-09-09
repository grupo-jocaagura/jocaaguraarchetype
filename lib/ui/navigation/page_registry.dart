part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Construye un [Widget] a partir de un [PageModel].
///
/// Se recomienda que el builder sea **puro**: sin efectos secundarios, idempotente
/// para el mismo [page].
typedef PageWidgetBuilder = Widget Function(
  BuildContext context,
  PageModel page,
);

/// Builder opcional para páginas no registradas.
///
/// Si retorna un [Widget] no nulo, se usará como "not found" personalizado.
/// Si retorna `null`, se aplicarán los fallbacks de [PageRegistry] (`defaultStack`
/// y/o `defaultPage`) y finalmente la 404 por defecto.
typedef NotFoundBuilder = Widget? Function(BuildContext context, PageModel req);

/// Registro inmutable de páginas para construir UI y crear [Page]s de Navigator 2.0.
///
/// - Usa un `Map<String, PageWidgetBuilder>` inmutable donde la **clave** es
///   [PageModel.name].
/// - Provee `build` para obtener el [Widget] asociado, o aplicar **fallbacks**:
///   [notFoundBuilder], [defaultStack], [defaultPage] o 404 mínima.
/// - Provee `toPage` para materializar un [Page] con **clave canónica** estable.
///   La clave incluye: `kind`, `name`, `segments` (unidos por `/`), **query ordenada
///   por clave** y `requiresAuth`.
///
/// ### Ejemplo mínimo
/// ```dart
/// void main() {
///   final PageRegistry registry = PageRegistry.fromDefs(<PageDef>[
///     PageDef(
///       model: PageModel.material('home'),
///       builder: (context, page) => const Scaffold(body: Center(child: Text('Home'))),
///     ),
///   ], defaultPage: PageModel.material('home'));
///
///   runApp(MaterialApp(
///     home: Navigator(
///       pages: <Page<dynamic>>[
///         registry.toPage(PageModel.material('home')),
///       ],
///       onPopPage: (route, result) => route.didPop(result),
///     ),
///   ));
/// }
/// ```
///
/// ### Contratos
/// - **Precondición:** Los nombres de página ([PageModel.name]) deben ser **únicos** en el registro.
/// - **Postcondición:** Si no existe builder, se intentará `notFoundBuilder` y/o
///   redirección por defecto; si nada aplica, se mostrará una 404 mínima.
/// - `toPage` genera claves **estables** para evitar reconstrucciones innecesarias.
///
/// ### Limitaciones
/// - No realiza navegación por sí mismo; delega en [PageManager] a través
///   de [AppManager].
class PageRegistry {
  /// Crea un registro a partir de un mapa de builders.
  ///
  /// El mapa se copia y vuelve **inmutable**.
  ///
  /// - [notFoundBuilder]: permite personalizar la página 404.
  /// - [defaultPage]: si no hay builder y no hay `notFoundBuilder`, redirige a esta página.
  /// - [defaultStack]: si no hay builder y no hay `notFoundBuilder`, redirige a este stack.
  PageRegistry(
    Map<String, PageWidgetBuilder> builders, {
    this.notFoundBuilder,
    this.defaultPage,
    this.defaultStack,
  }) : _builders = Map<String, PageWidgetBuilder>.unmodifiable(
          Map<String, PageWidgetBuilder>.from(builders),
        );

  /// Crea un registro a partir de una lista de definiciones de página.
  ///
  /// La **clave** en el registro es [PageDef.model.name].
  PageRegistry.fromDefs(
    List<PageDef> defs, {
    this.notFoundBuilder,
    this.defaultPage,
    this.defaultStack,
  }) : _builders = Map<String, PageWidgetBuilder>.unmodifiable(
          <String, PageWidgetBuilder>{
            for (final PageDef pageDef in defs)
              pageDef.model.name: pageDef.builder,
          },
        );

  /// Mapa inmutable `name -> PageWidgetBuilder`.
  final Map<String, PageWidgetBuilder> _builders;

  /// Builder opcional para manejar casos de "página no encontrada".
  final NotFoundBuilder? notFoundBuilder;

  /// Página por defecto a la que se redirige si no existe builder.
  final PageModel? defaultPage;

  /// Stack por defecto al que se redirige si no existe builder.
  final NavStackModel? defaultStack;

  /// Indica si existe un builder registrado para [name].
  bool contains(String name) => _builders.containsKey(name);

  /// Construye el [Widget] asociado a [page], aplicando fallbacks si no hay builder.
  ///
  /// Orden de resolución:
  /// 1. Builder registrado.
  /// 2. `notFoundBuilder` (si retorna no nulo).
  /// 3. Redirección a [defaultStack] (si existe).
  /// 4. Redirección a [defaultPage] (si existe).
  /// 5. Página 404 mínima.
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

  /// Crea una [Page] concreta desde [page] respetando su [PageKind].
  ///
  /// - Usa una **clave canónica** que incluye: `position` (si se provee),
  ///   `kind`, `name`, `segments` unidos por `/`, `query` con **claves ordenadas**
  ///   y `requiresAuth`. Esto estabiliza el árbol de navegación.
  /// - [position] es opcional y solo se usa para generar la clave.
  ///
  /// Retorna:
  /// - [CupertinoPage] si `page.kind == PageKind.cupertino`.
  /// - [MaterialPage] si `PageKind.material` o `PageKind.fullScreenDialog` (con
  ///   `fullscreenDialog: true`).
  /// - [DialogPage] si `PageKind.dialog`.
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

/// Página 404 mínima mostrada cuando no hay coincidencia y no aplica fallback.
///
/// Toca para volver al **home** vía `context.appManager.pageManager.goHome()`.
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

/// Widget auxiliar que **redirige post-frame** a un stack o página por defecto.
///
/// Usa [WidgetsBinding.instance.addPostFrameCallback] para diferir la navegación
/// hasta después del build. Si no encuentra un [AppManager] en el `context`,
/// en **debug** registra un mensaje y en **release** no hace nada.
///
/// ### Notas de prueba
/// - En tests, envolver con `AppManagerProvider` o un *fake* equivalente para
///   que la redirección sea efectiva.
/// - Evitar trabajos pesados en este callback.
class _RegistryRedirect extends StatelessWidget {
  const _RegistryRedirect({this.page, this.stack});
  final PageModel? page;
  final NavStackModel? stack;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AppManager? am = AppManagerProvider.maybeOf(context);
      if (am == null) {
        assert(() {
          debugPrint(
            '[PageRegistry] No AppManager found in context during redirect. '
            'Wrap the widget tree with AppManagerProvider / FakeAppManager in tests.',
          );
          return true;
        }());
        return;
      }

      final PageManager pm = am.pageManager;

      if (stack != null) {
        pm.setStack(stack!);
      } else if (page != null) {
        pm.replaceTop(page!);
      }
    });
    return const SizedBox.shrink();
  }
}

/// [Page] de conveniencia que crea un [DialogRoute] a partir de un [WidgetBuilder].
///
/// Útil para diálogos declarativos dentro de Navigator 2.0.
///
/// ### Ejemplo
/// ```dart
/// final Page<dynamic> dialogPage = DialogPage(
///   name: 'confirm',
///   builder: (context) => const AlertDialog(
///     title: Text('Confirm'),
///     content: Text('Proceed?'),
///   ),
/// );
/// ```
class DialogPage<T> extends Page<T> {
  /// Crea una página de diálogo con el [builder] proporcionado.
  const DialogPage({required this.builder, super.key, super.name});

  /// Builder del contenido del diálogo.
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
