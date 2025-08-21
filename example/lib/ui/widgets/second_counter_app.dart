import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_counter.dart';
import 'basic_app_counter_widget.dart';

class SecondCounterApp extends StatelessWidget {
  const SecondCounterApp({super.key});

  static const PageModel pageModel = PageModel(
    name: 'SecondCounterApp',
    segments: <String>['second-counter-app'],
  );

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    final BlocResponsive r = app.responsive;
    final BlocCounter blocCounter =
        app.blocCore.getBlocModule<BlocCounter>(BlocCounter.name);

    Widget counters() {
      // Grilla responsive por columnas (1..3) con alturas variadas.
      return ResponsiveGeneratorWidget(
        responsive: r,
        itemCount: 5,
        spanForIndex: (int i, BlocResponsive _) => <int>[1, 2, 3, 2, 2][i],
        itemBuilder: (BuildContext _, int i, BlocResponsive rr) {
          final double h = <double>[
            // alturas de ejemplo
            100, 100, 100, 162, 288,
          ][i];
          return SizedBox(
            height: h,
            child: BasicAppCounterWidget(blocCounter: blocCounter),
          );
        },
      );
    }

    final Widget cta = Padding(
      padding: EdgeInsets.only(bottom: r.gutterWidth),
      child: MyAppButtonWidget(
        responsive: r,
        label: 'Paso',
        leadingIcon: Icons.sports_football,
        onPressed: blocCounter.add,
      ),
    );

    // PageBuilder se encarga de AppBar, Drawer, Snack y menú secundario.
    return PageBuilder(
      page: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: r.gutterWidth),
            // ejemplo: un widget en 1 columna exacta
            Responsive1x1Widget(
              responsive: r,
              child: BasicAppCounterWidget(blocCounter: blocCounter),
            ),
            SizedBox(height: r.gutterWidth),
            counters(),
            SizedBox(height: r.gutterWidth),
            cta,
          ],
        ),
      ),
    );
  }
}
