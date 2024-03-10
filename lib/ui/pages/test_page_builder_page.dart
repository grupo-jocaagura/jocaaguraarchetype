import 'package:flutter/material.dart';

import '../page_builder.dart';

class TestPageBuilderPage extends StatelessWidget {
  const TestPageBuilderPage({
    super.key,
    this.page,
  });
  static String name = 'TestPageBuilderPage';

  final Widget? page;

  @override
  Widget build(BuildContext context) {
    return PageBuilder(
      page: page,
    );
  }
}
