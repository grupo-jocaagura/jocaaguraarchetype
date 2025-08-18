part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A versatile page builder widget that integrates navigation, menus, and responsive layouts.
///
/// The `PageBuilder` is designed to simplify the construction of pages within the
/// Jocaagura framework. It manages the following functionalities:
/// - **Responsive Layouts**: Adapts the page layout to different screen sizes.
/// - **Navigation**: Integrates with `AppManager` to manage navigation and history.
/// - **Loading States**: Displays a loading page when the application is in a loading state.
/// - **Menus**: Handles primary and secondary menus dynamically.
///
/// ## Features
/// - Dynamic menu updates based on the app state.
/// - Responsive design with a flexible work area.
/// - Built-in support for snack bars and notifications.
///
/// ## Example
///
/// ```dart
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
/// import 'package:flutter/material.dart';
///
/// void main() {
///   final AppManager appManager = AppManager();
///   runApp(MaterialApp(
///     home: PageBuilder(
///       page: Center(child: Text('Page Content')),
///     ),
///   ));
/// }
/// ```
///
/// ## Parameters
/// - [page]: The main content of the page. If null, the default work area is displayed.
class PageBuilder extends StatefulWidget {
  /// Creates a `PageBuilder`.
  ///
  /// - [page]: The main content of the page. Optional.
  const PageBuilder({
    super.key,
    this.page,
  });

  /// The main content of the page.
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

    // Listen to screen size changes
    streamSizeSubscription =
        context.appManager.responsive.appScreenSizeStream.listen((Size event) {
      setState(() {});
    });

    // Listen to secondary menu updates
    streamSecondaryMenuSubscription = context
        .appManager.secondaryMenu.listDrawerOptionSizeStream
        .listen((List<ModelMainMenuModel> event) {
      setState(() {});
    });

    // Listen to primary menu updates
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
                  child: ListView(
                    children: <Widget>[
                      const DrawerHeader(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      ...listWidget,
                    ],
                  ),
                )
              : null,
          appBar: appManager.responsive.showAppbar
              ? AppBar(
                  toolbarHeight: appManager.responsive.appBarHeight,
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title: Text(appManager.navigator.title),
                  actions: actions,
                )
              : null,
          body: Stack(
            children: <Widget>[
              WorkAreaWidget(
                columnsNumber: appManager.responsive.columnsNumber,
                drawerWidth: appManager.responsive.drawerWidth,
                screenSizeEnum: appManager.responsive.deviceType,
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
