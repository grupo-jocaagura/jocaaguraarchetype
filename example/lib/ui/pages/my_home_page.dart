import 'package:example/blocs/bloc_counter.dart';
import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {
    BlocCounter blocCounter = context.appManager.blocCore
        .getBlocModule<BlocCounter>(BlocCounter.name);
    blocCounter.add();
  }

  void changeTheme() {
    context.appManager.theme.randomTheme();
  }

  @override
  Widget build(BuildContext context) {
    BlocCounter blocCounter = context.appManager.blocCore
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
                final navigator = context.appManager.navigator;
                navigator.setTitle('my demo page');
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
                  }),
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
