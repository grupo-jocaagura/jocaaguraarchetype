import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class ShowToastPage extends StatelessWidget {
  const ShowToastPage({
    super.key,
  });
  static const PageModel pageModel =
      PageModel(name: 'ShowToastPage', segments: <String>['show-toast']);
  static final String name = pageModel.name;

  @override
  Widget build(BuildContext context) {
    final BlocUserNotifications blocUserNotification =
        context.appManager.blocUserNotifications;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: context.appManager.page.pop,
        ),
        title: const Text('Show toast test'),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {
                final String msg = 'Last toast ${Random().nextInt(10)}';
                debugPrint(msg);
                blocUserNotification.showToast(msg);
              },
              child: const Text('Test me'),
            ),
            Positioned(
              bottom: 10.0,
              child: StreamBuilder<String>(
                stream: blocUserNotification.toastStream,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (blocUserNotification.msg.isNotEmpty) {
                    return Card(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: kToolbarHeight,
                        child: Center(child: Text(blocUserNotification.msg)),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
