part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class PageBuilder extends StatefulWidget {
  const PageBuilder({super.key, this.page});

  /// Contenido principal de la página.
  final Widget? page;

  @override
  State<PageBuilder> createState() => _PageBuilderState();
}

class _PageBuilderState extends State<PageBuilder> {
  // Suscripciones para re-render ante cambios de tamaño y menús.
  StreamSubscription<Size>? _sizeSub;
  StreamSubscription<void>? _mainMenuSub;
  StreamSubscription<List<ModelMainMenuModel>>? _secondaryMenuSub;

  AppManager? _app; // cache del AppManager
  bool _boundStreams = false; // evita re-suscribir innecesariamente

  @override
  void initState() {
    super.initState();
    // ⚠️ No usar context aquí. Se hace en didChangeDependencies().
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Punto *seguro* para leer InheritedWidgets.
    final AppManager app = context.appManager;

    // Si cambió el provider o nunca nos habíamos enlazado, (re)enlazar streams.
    if (!identical(_app, app) || !_boundStreams) {
      _unbindStreams();
      _app = app;
      _bindStreams(app);
      _boundStreams = true;
    }
  }

  void _bindStreams(AppManager app) {
    _sizeSub = app.responsive.appScreenSizeStream.listen((Size _) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    _mainMenuSub = app.mainMenu.listMenuOptionsStream.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    // Si tu stream del menú secundario emite otro tipo, ajusta el genérico.
    _secondaryMenuSub = app.secondaryMenu.itemsStream.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void _unbindStreams() {
    _sizeSub?.cancel();
    _mainMenuSub?.cancel();
    _secondaryMenuSub?.cancel();
    _sizeSub = null;
    _mainMenuSub = null;
    _secondaryMenuSub = null;
  }

  @override
  void dispose() {
    _unbindStreams();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    final BlocResponsive responsive = app.responsive;

    // Acciones (back) basadas en historial
    final List<Widget> actions = <Widget>[
      if (app.pageManager.canPop)
        IconButton(
          onPressed: app.pop,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Back',
        ),
    ];

    // Drawer (mobile): mapeo a DrawerOptionWidget (API nueva)
    final double gap =
        responsive.gutterWidth.clamp(8.0, 16.0); // cast explícito

    final List<Widget> primaryMenuTiles = <Widget>[
      for (final ModelMainMenuModel it in app.mainMenu.listMenuOptions)
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: gap,
            vertical: (responsive.gutterWidth * 0.25).clamp(4.0, 8.0),
          ),
          child: DrawerOptionWidget(
            responsive: responsive,
            label: it.label,
            icon: it.iconData,
            selected: it.isSelected,
            onTap: () {
              it.onPressed();
              // cerrar el drawer si está abierto
              final ScaffoldState? sc = Scaffold.maybeOf(context);
              if (sc?.isDrawerOpen ?? false) {
                Navigator.of(context).maybePop();
              }
              setState(() {});
            },
          ),
        ),
    ];

    return StreamBuilder<String>(
      stream: app.loading.loadingMsgStream,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (app.loading.loadingMsg.isNotEmpty) {
          return LoadingPage(msg: app.loading.loadingMsg);
        }

        return Scaffold(
          // Drawer colapsable (principalmente para mobile)
          drawer: primaryMenuTiles.isNotEmpty
              ? Drawer(
                  child: SafeArea(
                    child: ListView(
                      padding: EdgeInsets.only(
                        top: responsive.gutterWidth,
                        bottom: responsive.gutterWidth,
                      ),
                      children: <Widget>[
                        DrawerHeader(
                          child: Center(
                            child: Text(
                              app.pageManager.currentTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        ...primaryMenuTiles,
                      ],
                    ),
                  ),
                )
              : null,

          appBar: responsive.showAppbar
              ? AppBar(
                  toolbarHeight: responsive.appBarHeight,
                  title: Text(app.pageManager.currentTitle),
                  actions: actions,
                )
              : null,

          body: Stack(
            children: <Widget>[
              // ⬇️ Tu WorkAreaWidget actual pide 'responsive' y 'content'
              WorkAreaWidget(
                responsive: responsive,
                content: widget.page ?? const SizedBox.shrink(),
              ),

              // ⬇️ Snack/Toast con stream de String (retrocompat)
              Positioned(
                bottom: responsive.gutterWidth,
                left: responsive.marginWidth,
                child: MySnackBarWidget.fromStringStream(
                  responsive: responsive,
                  toastStream: app.notifications.toastStream,
                ),
              ),
            ],
          ),
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
