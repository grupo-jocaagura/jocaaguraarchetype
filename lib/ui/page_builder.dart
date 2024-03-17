import 'dart:async';

import 'package:flutter/material.dart';

import '../jocaaguraarchetype.dart';
import 'pages/loading_page.dart';
import 'widgets/drawer_option_widget.dart';
import 'widgets/my_snack_bar_widget.dart';
import 'widgets/work_area_widget.dart';

class PageBuilder extends StatefulWidget {
  const PageBuilder({
    super.key,
    this.page,
  });

  final Widget? page;

  @override
  State<PageBuilder> createState() => _PageBuilderState();
}

class _PageBuilderState extends State<PageBuilder> {
  final List<Widget> listWidget = <Widget>[];
  final List<Widget> actions = <Widget>[];
  late StreamSubscription<List<ModelMainMenuModel>> streamSubscription;
  late StreamSubscription<Size> streamSizeSubscription;
  late StreamSubscription<List<ModelMainMenuModel>>
      streamSecondaryMenuSubscription;
  @override
  void initState() {
    super.initState();
    streamSizeSubscription =
        context.appManager.responsive.appScreenSizeStream.listen((Size event) {
      setState(() {});
    });
    streamSecondaryMenuSubscription = context
        .appManager.secondaryMenu.listDrawerOptionSizeStream
        .listen((List<ModelMainMenuModel> event) {
      setState(() {});
    });
    streamSubscription = context.appManager.mainMenu.listDrawerOptionSizeStream
        .listen((void event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    streamSizeSubscription.cancel();
    streamSecondaryMenuSubscription.cancel();
    streamSubscription.cancel();
    super.dispose();
  }

  void update() {
    listWidget.clear();
    for (final ModelMainMenuModel element
        in context.appManager.mainMenu.listMenuOptions) {
      listWidget.add(
        DrawerOptionWidget(
          onPressed: () {
            setState(() {
              element.onPressed();
            });
          },
          label: element.label,
          icondata: element.iconData,
        ),
      );
    }
    actions.clear();
    if (context.appManager.navigator.historyPageLength > 1) {
      actions.add(
        IconButton(
          onPressed: () {
            context.appManager.navigator.back();
          },
          icon: const Icon(Icons.chevron_left),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppManager appManager = context.appManager;
    // TODO(albertjjimenezp): revisar y extraer el codigo de este lugar para
    update();
    return StreamBuilder<String>(
      stream: appManager.loading.loadingMsgStream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (appManager.loading.loadingMsg.isNotEmpty) {
          return LoadingPage(msg: appManager.loading.loadingMsg);
        }
        return Scaffold(
          drawer: listWidget.isNotEmpty
              ? Drawer(
                  child: StreamBuilder<List<ModelMainMenuModel>>(
                    stream: appManager.mainMenu.listDrawerOptionSizeStream,
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<List<ModelMainMenuModel>> snapshot,
                    ) {
                      return ListView(
                        children: <Widget>[
                          const DrawerHeader(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          ...listWidget,
                        ],
                      );
                    },
                  ),
                )
              : null,
          appBar: appManager.responsive.showAppbar
              ? AppBar(
                  toolbarHeight: appManager.responsive.appBarHeight,
                  leading: listWidget.isEmpty ? const Text('') : null,
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title: Text(context.appManager.navigator.title),
                  actions: actions,
                )
              : null,
          body: Stack(
            children: <Widget>[
              WorkAreaWidget(
                columnsNumber: appManager.responsive.columnsNumber,
                drawerWidth: appManager.responsive.drawerWidth,
                screenSizeEnum: appManager.responsive.getDeviceType,
                columnWidth: appManager.responsive.columnWidth,
                gutterWidth: appManager.responsive.gutterWidth,
                listMenuOptions: appManager.mainMenu.listMenuOptions,
                marginWidth: appManager.responsive.marginWidth,
                workAreaSize: appManager.responsive.workAreaSize,
                page: widget.page,
                listSecondaryMenuOptions:
                    appManager.secondaryMenu.listMenuOptions,
              ),
              Positioned(
                bottom: appManager.responsive.gutterWidth,
                left: appManager.responsive.marginWidth,
                child: MySnackBarWidget(
                  gutterWidth: appManager.responsive.gutterWidth,
                  marginWidth: appManager.responsive.marginWidth,
                  width: appManager.responsive.size.width,
                  toastStream: appManager.blocUserNotifications.toastStream,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
