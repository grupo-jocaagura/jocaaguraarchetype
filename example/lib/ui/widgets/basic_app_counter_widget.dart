import 'package:flutter/material.dart';

import '../../blocs/bloc_counter.dart';

class BasicAppCounterWidget extends StatelessWidget {
  const BasicAppCounterWidget({
    required this.blocCounter,
    super.key,
  });

  final BlocCounter blocCounter;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: blocCounter.counterStream,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        return Center(
          child: Text(
            blocCounter.value.toString(),
          ),
        );
      },
    );
  }
}
