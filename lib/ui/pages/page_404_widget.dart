import 'package:flutter/material.dart';

import '../../navigator/page_manager.dart';

class Page404Widget extends StatelessWidget {
  const Page404Widget({required this.pageManager, super.key});

  final PageManager pageManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error 404'),
        leading: pageManager.historyPagesCount > 1
            ? BackButton(
                onPressed: pageManager.back,
              )
            : null,
      ),
      body: Center(
        child:
            Text('Pagina No encontrada ${pageManager.currentPage.arguments}'),
      ),
    );
  }
}
