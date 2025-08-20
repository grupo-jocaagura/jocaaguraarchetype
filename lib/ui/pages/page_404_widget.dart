part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

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
