import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class LeadingBackButtonWidget extends StatelessWidget {
  const LeadingBackButtonWidget({
    required this.appManager,
    super.key,
  });

  final AppManager appManager;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: appManager.page.canPopStream,
      initialData: appManager.page.canPop,
      builder: (_, __) {
        final bool show = appManager.page.canPop;
        if (!show) {
          return const SizedBox.shrink();
        }
        return BackButton(
          onPressed: () {
            appManager.page.pop();
          },
        );
      },
    );
  }
}
