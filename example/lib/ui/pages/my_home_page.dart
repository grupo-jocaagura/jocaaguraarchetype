import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../blocs/bloc_counter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
  static const PageModel pageModel =
      PageModel(name: 'home', segments: <String>['home']);
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {
    final BlocCounter blocCounter = context.appManager.blocCore
        .getBlocModule<BlocCounter>(BlocCounter.name);
    blocCounter.add();
  }

  void changeTheme() {
    context.appManager.theme.randomTheme();
  }

  @override
  Widget build(BuildContext context) {
    final BlocCounter blocCounter = context.appManager.blocCore
        .getBlocModule<BlocCounter>(BlocCounter.name);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () {
                final PageManager navigator = context.appManager.page;
                navigator.pushNamed(
                  title: 'Index',
                  'index-app',
                );
              },
              child: const Text(
                'Go to demo:',
              ),
            ),
            InkWell(
              onTap: () {
                final PageManager navigator = context.appManager.page;
                // navigator.setTitle('my demo page');
                navigator.pushNamed('MyDemoHomePage');
              },
              child: const Text(
                'You have pushed the button this many times:',
              ),
            ),
            InkWell(
              onTap: changeTheme,
              child: StreamBuilder<int>(
                stream: blocCounter.counterStream,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  return Text(
                    '${blocCounter.value}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
