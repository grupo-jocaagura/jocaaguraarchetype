import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_counter.dart';
import 'basic_app_counter_widget.dart';

class BasicCounterApp extends StatelessWidget {
  const BasicCounterApp({super.key});

  static const PageModel pageModel = PageModel(
    name: 'BasicCounterApp',
    segments: <String>['basic-counter-app'],
  );

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    final BlocResponsive r = app.responsive;
    final BlocCounter blocCounter =
        app.blocCore.getBlocModule<BlocCounter>(BlocCounter.name);

    final Widget grid = ResponsiveGeneratorWidget(
      responsive: r,
      itemCount: 4,
      spanForIndex: (int i, _) => <int>[1, 2, 2, 2][i],
      itemBuilder: (_, int i, __) {
        final double h = <double>[100, 100, 162, 288][i];
        return SizedBox(
          height: h,
          child: BasicAppCounterWidget(blocCounter: blocCounter),
        );
      },
    );

    final Widget cta = Padding(
      padding: EdgeInsets.only(bottom: r.gutterWidth),
      child: MyAppButtonWidget(
        responsive: r,
        label: 'Paso',
        leadingIcon: Icons.sports_football,
        onPressed: blocCounter.add,
      ),
    );

    return PageBuilder(
      page: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: r.gutterWidth),
            Responsive1x1Widget(
              responsive: r,
              child: BasicAppCounterWidget(blocCounter: blocCounter),
            ),
            SizedBox(height: r.gutterWidth),
            grid,
            SizedBox(height: r.gutterWidth),
            cta,
          ],
        ),
      ),
    );
  }
}
