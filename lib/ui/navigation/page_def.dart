part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Immutable page definition used by PageRegistry.
///
/// Couples the logical route (PageModel) with the widget builder
/// without forcing UI to inherit from a wrapper widget.
///
/// ### Example
/// ```dart
/// final defs = <PageDef>[
///   PageDef(
///     model: HomePage.pageModel,
///     builder: (ctx, page) => const HomePage(),
///   ),
///   PageDef(
///     model: DetailsPage.pageModel,
///     builder: (ctx, page) => DetailsPage(id: page.segments.elementAtOrNull(0)),
///   ),
/// ];
/// final registry = PageRegistry.fromDefs(defs, defaultPage: HomePage.pageModel);
/// ```
class PageDef {
  const PageDef({required this.model, required this.builder});

  /// Associated logical page route.
  final PageModel model;

  /// UI builder for that logical page.
  final PageWidgetBuilder builder;
}
