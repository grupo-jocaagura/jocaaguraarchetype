import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:jocaaguraarchetype/ui/widgets/my_app_button_widget.dart';

import '../../../blocs/bloc_counter.dart';
import '../horizontal_widget.dart';
import '../one_x_one_widget.dart';
import '../one_x_three_widget.dart';
import '../one_x_two_widget.dart';
import '../vertical_widget.dart';
import 'dot_widget.dart';

class SecondAppCounterWidget extends StatelessWidget {
  const SecondAppCounterWidget({
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
          child1x1: OneXOneWidget(
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 160,
                  width: 200,
                  child: Text(
                    '${blocCounter.value}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 125.0,
                        ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DotWidget(
                      isActive: blocCounter.value.isOdd,
                      width: 30.0,
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    DotWidget(
                      isActive: blocCounter.value.isEven,
                      width: 30.0,
                    ),
                  ],
                )
              ],
            ),
          ),
          child1x2: OneXTwoWidget(
            child: Row(
              children: <Widget>[
                Container(
                  width: 100.0,
                  height: 100.0,
                  color: Colors.red,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 80,
                        width: 100,
                        child: Text(
                          '${blocCounter.value}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontSize: 70.0,
                              ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DotWidget(
                            isActive: blocCounter.value.isOdd,
                            width: 15.0,
                          ),
                          const SizedBox(
                            width: 3.0,
                          ),
                          DotWidget(
                            isActive: blocCounter.value.isEven,
                            width: 15.0,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  width: 100.0,
                  height: 100.0,
                  color: Colors.purple,
                  child: Center(
                    child: Icon(
                      blocCounter.value.isEven
                          ? Icons.scatter_plot
                          : Icons.scatter_plot_outlined,
                      size: 70.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          child1x3: OneXThreeWidget(
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 100.0,
                  height: 100.0,
                  child: Text(
                    '${blocCounter.value}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 70.0,
                        ),
                  ),
                ),
                SizedBox(
                  width: 100.0,
                  height: 100.0,
                  child: Center(
                    child: Icon(
                      blocCounter.value.isEven
                          ? Icons.directions_run_outlined
                          : Icons.directions_run,
                      size: 70.0,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100.0,
                  height: 100.0,
                  child: Center(
                    child: Text(
                      'Pasos',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 20.0,
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          childVertical: VerticalWidget(
            size: Size(300, 400),
            child: SizedBox(
              width: 300,
              height: 400,
              child: Stack(
                children: [
                  Positioned(
                    left: 15.0,
                    top: 25.0,
                    child: Icon(
                      Icons.headset_mic,
                      size: 150.0,
                    ),
                  ),
                  Positioned(
                    right: 10.0,
                    top: 60.0,
                    child: Text(
                      '${blocCounter.value}',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 200.0,
                              ),
                    ),
                  ),
                  Positioned(
                    bottom: 20.0,
                    left: 10,
                    width: 280,
                    child: MyAppButtonWidget(
                      iconData: Icons.restart_alt,
                      label: 'Reset',
                      onPressed: blocCounter.reset,
                    ),
                  )
                ],
              ),
            ),
          ),
          childHorizontal: HorizontalWidget(
            size: const Size(600, 400),
            child: SizedBox(
              width: 600,
              height: 400,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 50,
                    left: 25,
                    width: 280,
                    height: 280,
                    child: Text(
                      '${blocCounter.value}',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 200.0,
                              ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 25,
                    width: 280,
                    height: 280,
                    child: Icon(
                      Icons.auto_graph,
                      size: 200,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 25,
                    width: 280,
                    height: 100,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            size: 100,
                          ),
                          onPressed: blocCounter.add,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.remove,
                            size: 100,
                          ),
                          onPressed: blocCounter.decrement,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
