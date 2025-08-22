import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../blocs/bloc_counter.dart';
import '../support/example_services.dart';

/// Responsive Counter page using a simple breakpoint.
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final BlocCounter _bloc = BlocCounter();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;

    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isWide =
              constraints.maxWidth >= 720; // md breakpoint aprox
          final Widget counter = StreamBuilder<int>(
            stream: _bloc.stream,
            initialData: _bloc.value,
            builder: (BuildContext context, AsyncSnapshot<int> snap) => Text(
              'Count: ${snap.data}',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          );

          final Widget controls = Wrap(
            spacing: 8,
            children: <Widget>[
              ElevatedButton(onPressed: _bloc.inc, child: const Text('+1')),
              ElevatedButton(onPressed: _bloc.dec, child: const Text('-1')),
              OutlinedButton(
                onPressed: _bloc.reset,
                child: const Text('Reset'),
              ),
            ],
          );

          final Widget connectivityBanner = StreamBuilder<bool>(
            stream: ExampleConnectivity.instance.stream(),
            initialData: true,
            builder: (BuildContext context, AsyncSnapshot<bool> snap) {
              final bool online = snap.data ?? true;
              return Container(
                padding: const EdgeInsets.all(8),
                color: online ? Colors.green.shade100 : Colors.red.shade100,
                child: Text(online ? 'Online' : 'Offline'),
              );
            },
          );

          final Widget content = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              connectivityBanner,
              const SizedBox(height: 12),
              counter,
              const SizedBox(height: 24),
              controls,
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => app.clearAndGoHome(),
                child: const Text('Back to Home'),
              ),
            ],
          );

          if (isWide) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(child: Center(child: content)),
                const Expanded(child: Placeholder()), // side panel demo
              ],
            );
          }
          return Center(child: content);
        },
      ),
    );
  }
}
