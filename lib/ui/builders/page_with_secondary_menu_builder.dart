part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Composes a page body with an optional secondary menu, adapting to device size
/// via [BlocResponsive] and [BlocSecondaryMenuDrawer].
///
/// No maneja navegación; sólo layout.
///
/// - Mobile: fila flotante de acciones (cuadradas) en la parte inferior.
/// - Tablet/Desktop/TV: panel lateral con acciones secundarias.
///
/// Las opciones provienen de [AppManager.secondaryMenu].
class PageWithSecondaryMenuBuilder extends StatelessWidget {
  const PageWithSecondaryMenuBuilder({
    required this.app,
    required this.content,
    super.key,
    this.menuItemsOverride,
    this.panelColumns = 2,
    this.secondaryOnRight = true,
    this.animate = true,
    this.backgroundColor,
    this.safeArea = true,
    this.mobileBuilder,
    this.sidePanelBuilder,
  });

  /// AppManager para acceder a responsive y al bloc del secondary menu.
  final AppManager app;

  BlocResponsive get responsive => app.responsive;

  /// Contenido principal de la página.
  final Widget content;

  /// Override opcional de ítems del menú.
  ///
  /// Si es `null`, se usan los de [app.secondaryMenu].
  /// Si es una lista vacía, no se muestra menú.
  final List<ModelMainMenuModel>? menuItemsOverride;

  /// Ancho del panel lateral (tablet/desktop) en columnas.
  final int panelColumns;

  /// Lado del panel lateral.
  final bool secondaryOnRight;

  /// Habilita animación de entrada/salida del menú.
  final bool animate;

  final Color? backgroundColor;
  final bool safeArea;

  /// Builder opcional para layout mobile.
  final SecondaryMenuMobileLayoutBuilder? mobileBuilder;

  /// Builder opcional para layout tablet/desktop.
  final SecondaryMenuSidePanelLayoutBuilder? sidePanelBuilder;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color bg = backgroundColor ?? scheme.surfaceContainerLowest;

    return StreamBuilder<List<ModelMainMenuModel>>(
      stream: app.secondaryMenu.itemsStream,
      initialData: app.secondaryMenu.listMenuOptions,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<ModelMainMenuModel>> snap,
      ) {
        final List<ModelMainMenuModel> fromBloc =
            snap.data ?? const <ModelMainMenuModel>[];

        // Override del implementador > bloc.
        final List<ModelMainMenuModel> items = menuItemsOverride ?? fromBloc;

        final BlocResponsive r = responsive;

        final Widget body = switch (r.deviceType) {
          ScreenSizeEnum.mobile =>
            (mobileBuilder ?? SecondaryMenuMobileLayout.defaultBuilder)(
              context,
              r,
              content,
              items,
              bg,
              animate,
            ),
          ScreenSizeEnum.tablet ||
          ScreenSizeEnum.desktop ||
          ScreenSizeEnum.tv =>
            (sidePanelBuilder ?? SecondaryMenuSidePanelLayout.defaultBuilder)(
              context,
              r,
              content,
              items,
              bg,
              panelColumns,
              secondaryOnRight,
              animate,
            ),
        };

        return safeArea ? SafeArea(child: body) : body;
      },
    );
  }
}
