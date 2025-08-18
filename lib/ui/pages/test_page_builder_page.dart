part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A simple wrapper for the `PageBuilder` widget.
///
/// The `TestPageBuilderPage` provides a straightforward integration of the
/// `PageBuilder` widget, allowing developers to specify an optional [page].
/// This widget can serve as a basic example or template for using `PageBuilder`.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/test_page_builder_page.dart';
///
/// void main() {
///   runApp(MaterialApp(
///     home: TestPageBuilderPage(
///       page: Center(child: Text('Hello, PageBuilder!')),
///     ),
///   ));
/// }
/// ```
class TestPageBuilderPage extends StatelessWidget {
  /// Creates an instance of `TestPageBuilderPage`.
  ///
  /// - [page]: An optional widget to be displayed by the `PageBuilder`.
  const TestPageBuilderPage({
    super.key,
    this.page,
  });

  /// The name identifier for this page.
  static String name = 'TestPageBuilderPage';

  /// The widget to display within the `PageBuilder`.
  final Widget? page;

  @override
  Widget build(BuildContext context) {
    return PageBuilder(
      page: page,
    );
  }
}
