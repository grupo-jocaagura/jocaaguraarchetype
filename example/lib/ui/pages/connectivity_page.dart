import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_counter.dart';

class ConnectivityPage extends StatelessWidget {
  const ConnectivityPage({super.key});
  @override
  Widget build(BuildContext context) {
    final AppManager appManager = context.appManager;
    final BlocConnectivity connectivity = appManager.blocCore
        .getBlocModule<BlocConnectivity>(BlocConnectivity.name);

    final BlocCounter counter =
        appManager.blocCore.getBlocModule<BlocCounter>(BlocCounter.name);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connectivity test'),
        leading: appManager.navigator.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => appManager.navigator.back(),
              )
            : null,
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
            child: StreamBuilder<Either<String, ConnectivityModel>>(
              stream: connectivity.connectivityStatusStream,
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
                        connectivity.connectivityStatus.when(
                          (String p0) => p0,
                          (ConnectivityModel p0) => p0.toString(),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextButton(
                        onPressed: connectivity.updateConnectionStatus,
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
