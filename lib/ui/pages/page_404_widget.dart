part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Fallback page shown when a route is not found.
///
/// Integrates with the RouterDelegate and PageRegistry defaults.
/// Keep it minimal and accessible.
///
/// ### Example
/// ```dart
/// const Page404Widget(suggestedRouteName: '/home');
/// ```
class Page404Widget extends StatelessWidget {
  const Page404Widget({required this.pageManager, super.key});

  final PageManager pageManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error 404'),
        leading: pageManager.historyNames.length > 1
            ? BackButton(
                onPressed: pageManager.pop,
              )
            : null,
      ),
      body: const Center(
        child: Text('Pagina No encontrada'),
      ),
    );
  }
}
