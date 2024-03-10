import 'package:flutter/material.dart';

class MySnackBarWidget extends StatelessWidget {
  const MySnackBarWidget({
    required this.gutterWidth,
    required this.marginWidth,
    required this.width,
    required this.toastStream,
    super.key,
  });

  final double gutterWidth;
  final double marginWidth;
  final double width;
  final Stream<String> toastStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: toastStream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        final String msg = snapshot.data ?? '';

        if (msg.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: EdgeInsets.all(gutterWidth),
          width: width - marginWidth * 2,
          height: marginWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).splashColor,
            borderRadius: BorderRadius.circular(
              gutterWidth,
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            color: Theme.of(context).primaryColor,
            child: Text(
              msg,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.background,
                    fontWeight: FontWeight.bold,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}
