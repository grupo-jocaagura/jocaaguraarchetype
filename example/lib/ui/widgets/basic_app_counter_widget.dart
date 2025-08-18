import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_counter.dart';
import 'horizontal_widget.dart';
import 'one_x_three_widget.dart';
import 'one_x_two_widget.dart';
import 'vertical_widget.dart';

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
        return GeneratorWidget(
          child1x1: Center(
            child: Text('1x1 $blocCounter'),
          ),
          child1x2: OneXTwoWidget(
            child: Row(
              children: <Widget>[
                Text('1x2 $blocCounter'),
                const Icon(Icons.run_circle_outlined),
              ],
            ),
          ),
          child1x3: OneXThreeWidget(
            child: Row(
              children: <Widget>[
                Text('1x3 $blocCounter'),
                const Icon(Icons.run_circle_outlined),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
          childVertical: VerticalWidget(
            child: Column(
              children: <Widget>[
                Text(blocCounter.toString()),
                Row(
                  children: <Widget>[
                    Text('V $blocCounter'),
                    const Icon(Icons.run_circle_outlined),
                  ],
                ),
                MyAppButtonWidget(
                  iconData: Icons.sports_tennis,
                  label: 'Reset',
                  onPressed: () => blocCounter.add(5),
                ),
              ],
            ),
          ),
          childHorizontal: HorizontalWidget(
            child: Row(
              children: <Widget>[
                Text(blocCounter.toString()),
                Column(
                  children: <Widget>[
                    Text('H $blocCounter'),
                    const Icon(Icons.run_circle_outlined),
                  ],
                ),
                MyAppButtonWidget(
                  iconData: Icons.sports_tennis,
                  label: 'Reset',
                  onPressed: () => blocCounter.add(5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
