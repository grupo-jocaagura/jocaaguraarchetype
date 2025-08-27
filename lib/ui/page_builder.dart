part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class PageBuilder extends StatelessWidget {
  const PageBuilder({super.key, this.page});
  final Widget? page;

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    final BlocResponsive r = app.responsive;
    r.setSizeFromContext(context);

    return StreamBuilder<String>(
      stream: app.loading.loadingMsgStream,
      initialData: app.loading.loadingMsg,
      builder: (_, AsyncSnapshot<String> loadSnap) {
        final String msg = loadSnap.data ?? '';
        if (msg.isNotEmpty) {
          return LoadingPage(msg: msg);
        }

        return StreamBuilder<Size>(
          stream: r.appScreenSizeStream,
          initialData: r.size,
          builder: (BuildContext context, _) {
            final double gap = r.gutterWidth.clamp(8.0, 16.0);

            return StreamBuilder<List<ModelMainMenuModel>>(
              stream: app.mainMenu.listMenuOptionsStream,
              initialData: app.mainMenu.listMenuOptions,
              builder: (
                BuildContext context,
                AsyncSnapshot<List<ModelMainMenuModel>> menuSnap,
              ) {
                final List<ModelMainMenuModel> items =
                    menuSnap.data ?? const <ModelMainMenuModel>[];

                final Widget? drawerWidget = items.isEmpty
                    ? null
                    : Drawer(
                        child: SafeArea(
                          child: ListView(
                            padding: EdgeInsets.only(
                              top: r.gutterWidth,
                              bottom: r.gutterWidth,
                            ),
                            children: <Widget>[
                              DrawerHeader(
                                child: Center(
                                  child: StreamBuilder<String>(
                                    stream: app.pageManager.currentTitleStream,
                                    initialData: app.pageManager.currentTitle,
                                    builder: (
                                      BuildContext context,
                                      AsyncSnapshot<String> tSnap,
                                    ) =>
                                        Text(
                                      tSnap.data ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                ),
                              ),
                              for (final ModelMainMenuModel it in items)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: gap,
                                    vertical:
                                        (r.gutterWidth * 0.25).clamp(4.0, 8.0),
                                  ),
                                  child: DrawerOptionWidget(
                                    responsive: r,
                                    label: it.label,
                                    icon: it.iconData,
                                    selected: it.selected,
                                    onTap: () {
                                      it.onPressed();
                                      final ScaffoldState? sc =
                                          Scaffold.maybeOf(context);
                                      if (sc?.isDrawerOpen ?? false) {
                                        // Cierra el drawer del Scaffold actual
                                        sc!.closeDrawer();
                                      } else {
                                        // Fallback: cierra la ruta del drawer si está en el stack
                                        Navigator.of(context).maybePop();
                                      }
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );

                return StreamBuilder<bool>(
                  stream: r.showAppbarStream,
                  initialData: r.showAppbar,
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> showSnap) {
                    final bool showAppbar = showSnap.data ?? true;

                    PreferredSizeWidget? appBarWidget;
                    if (showAppbar) {
                      appBarWidget = AppBar(
                        // ✅ Fuerza recálculo del leading cuando cambia el drawer
                        key: ValueKey<String>(
                          'appbar_hasDrawer_${drawerWidget != null}',
                        ),
                        toolbarHeight: r.appBarHeight,
                        title: StreamBuilder<String>(
                          stream: app.pageManager.currentTitleStream,
                          initialData: app.pageManager.currentTitle,
                          builder: (
                            BuildContext context,
                            AsyncSnapshot<String> tSnap,
                          ) =>
                              Text(tSnap.data ?? ''),
                        ),
                        actions: <Widget>[
                          StreamBuilder<bool>(
                            stream: app.pageManager.canPopStream,
                            initialData: app.pageManager.canPop,
                            builder: (
                              BuildContext context,
                              AsyncSnapshot<bool> canPopSnap,
                            ) {
                              final bool canPop = canPopSnap.data ?? false;
                              if (!canPop) {
                                return const SizedBox.shrink();
                              }
                              return IconButton(
                                onPressed: app.pop,
                                icon: const Icon(Icons.chevron_left),
                                tooltip: 'Back',
                              );
                            },
                          ),
                        ],
                      );
                    }

                    return Scaffold(
                      drawer: drawerWidget,
                      appBar: appBarWidget,
                      body: Stack(
                        children: <Widget>[
                          WorkAreaWidget(
                            responsive: r,
                            content: page ?? const SizedBox.shrink(),
                          ),
                          MySnackBarWidget.fromStringStream(
                            responsive: r,
                            toastStream: app.notifications.toastStream,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

// Estado UI adjunto a cada instancia de ModelMainMenuModel mediante Expando.
final Expando<bool> _mmSelected = Expando<bool>('mm.selected');
final Expando<bool> _mmEnabled = Expando<bool>('mm.enabled');
final Expando<int> _mmBadgeCount = Expando<int>('mm.badgeCount');
final Expando<String> _mmTooltip = Expando<String>('mm.tooltip');

/// UI extensions for [ModelMainMenuModel] without modifying jocaagura_domain.
extension ModelMainMenuModelX on ModelMainMenuModel {
  bool get selected => _mmSelected[this] ?? false;
  set selected(bool v) => _mmSelected[this] = v;

  bool get isSelected => selected;

  bool get enabled => _mmEnabled[this] ?? true;
  set enabled(bool v) => _mmEnabled[this] = v;

  int? get badgeCount => _mmBadgeCount[this];
  set badgeCount(int? v) => _mmBadgeCount[this] = v;

  String? get tooltip => _mmTooltip[this];
  set tooltip(String? v) => _mmTooltip[this] = v;

  ModelMainMenuModel ui({
    bool? selected,
    bool? enabled,
    int? badgeCount,
    String? tooltip,
  }) {
    if (selected != null) {
      this.selected = selected;
    }
    if (enabled != null) {
      this.enabled = enabled;
    }
    if (badgeCount != null) {
      this.badgeCount = badgeCount;
    }
    if (tooltip != null) {
      this.tooltip = tooltip;
    }
    return this;
  }
}
