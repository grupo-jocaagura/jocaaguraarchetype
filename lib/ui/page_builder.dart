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
  late final StreamSubscription<Size> _sizeSub;
  late final StreamSubscription<void> _mainMenuSub;
  late final StreamSubscription<List<ModelMainMenuModel>> _secondaryMenuSub;

  @override
  void initState() {
    super.initState();
    final AppManager app = context.appManager;

    _sizeSub =
        app.responsive.appScreenSizeStream.listen((Size _) => setState(() {}));
    _mainMenuSub =
        app.mainMenu.listMenuOptionsStream.listen((void _) => setState(() {}));
    _secondaryMenuSub = app.secondaryMenu.listDrawerOptionSizeStream
        .listen((List<ModelMainMenuModel> _) => setState(() {}));
  }

  @override
  void dispose() {
    _sizeSub.cancel();
    _mainMenuSub.cancel();
    _secondaryMenuSub.cancel();
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
        responsive.gutterWidth.clamp(8.0, 16.0); // <- cast a double

    final List<Widget> primaryMenuTiles = <Widget>[
      for (final ModelMainMenuModel it in app.mainMenu.listMenuOptions)
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: gap,
            vertical: (responsive.gutterWidth * 0.25).clamp(4.0, 8.0), // cast
          ),
          child: DrawerOptionWidget(
            responsive: responsive,
            label: it.label,
            icon: it.iconData,
            selected: it.isSelected,
            onTap: () {
              it.onPressed();
              // cerrar el drawer si está abierto
              if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
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
///
/// These properties are **UI-only** and are stored via `Expando`, so they do
/// not change the original model nor require codegen/serialization changes.
///
/// ### Provided properties
/// - `selected` / `isSelected` (default: `false`)
/// - `enabled` (default: `true`)
/// - `badgeCount` (default: `null`)
/// - `tooltip` (default: `null`)
///
/// ### Example
/// ```dart
/// final item = ModelMainMenuModel(
///   iconData: Icons.home,
///   onPressed: () {},
///   label: 'Home',
/// )
///   ..selected = true
///   ..badgeCount = 3
///   ..tooltip = 'Go home';
///
/// // Back-compat
/// debugPrint('isSelected? ${item.isSelected}'); // true
/// ```
extension ModelMainMenuModelX on ModelMainMenuModel {
  /// Selection flag for UI.
  bool get selected => _mmSelected[this] ?? false;
  set selected(bool v) => _mmSelected[this] = v;

  /// Backwards-compatible alias used by older code.
  bool get isSelected => selected;

  /// Whether the menu item is enabled/tappable in UI.
  bool get enabled => _mmEnabled[this] ?? true;
  set enabled(bool v) => _mmEnabled[this] = v;

  /// Optional numeric badge (e.g., unread count).
  int? get badgeCount => _mmBadgeCount[this];
  set badgeCount(int? v) => _mmBadgeCount[this] = v;

  /// Optional tooltip text.
  String? get tooltip => _mmTooltip[this];
  set tooltip(String? v) => _mmTooltip[this] = v;

  /// Fluent helper to set multiple UI fields and return `this`.
  ///
  /// ```dart
  /// item.ui(selected: true, badgeCount: 7, tooltip: 'Inbox');
  /// ```
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
