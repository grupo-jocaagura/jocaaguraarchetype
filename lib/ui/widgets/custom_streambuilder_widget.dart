import 'package:flutter/material.dart';

class CustomStreamBuilderWidget<T> extends StatelessWidget {
  const CustomStreamBuilderWidget({
    required this.stream,
    required this.child,
    super.key,
  });
  final Stream<T> stream;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) => child,
    );
  }
}
