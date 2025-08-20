import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_counter.dart';
import '../widgets/app_bar_back_button.dart';

class ConnectivityPage extends StatelessWidget {
  const ConnectivityPage({super.key});
  static const PageModel pageModel =
      PageModel(name: 'ConnectivityPage', segments: <String>['connectivity']);
  @override
  Widget build(BuildContext context) {
    final AppManager appManager = context.appManager;
    final BlocConnectivity connectivity =
        appManager.blocCore.getBlocModule<BlocConnectivity>('BlocConnectivity');

    final BlocCounter counter =
        appManager.blocCore.getBlocModule<BlocCounter>(BlocCounter.name);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connectivity test'),
        leading: LeadingBackButtonWidget(appManager: appManager),
        actions: <Widget>[
          if (appManager.mainMenu.listMenuOptions.isNotEmpty)
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            width: double.maxFinite,
            height: appManager.responsive.widthByColumns(2),
            child: StreamBuilder<Either<ErrorItem, ConnectivityModel>>(
              stream: connectivity.stream,
              builder: (
                __,
                _,
              ) {
                counter.add();
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(counter.value.toString()),
                      Text(
                        connectivity.value.when(
                          (ErrorItem p0) => p0.toString(),
                          (ConnectivityModel p0) => p0.toString(),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextButton(
                        onPressed: connectivity.refreshSpeed,
                        child: const Text('Update connectivity status'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
