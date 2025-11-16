part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Default mobile layout for [PageWithSecondaryMenuWidget].
///
/// Muestra una fila flotante de botones cuadrados en la parte inferior.
/// Si [items] está vacío, no se muestra menú secundario.
class SecondaryMenuMobileLayout extends StatelessWidget {
  const SecondaryMenuMobileLayout({
    required this.responsive,
    required this.content,
    required this.backgroundColor,
    required this.items,
    this.animate = true,
    super.key,
  });

  final BlocResponsive responsive;
  final Widget content;
  final List<ModelMainMenuModel> items;
  final Color backgroundColor;
  final bool animate;

  static Widget defaultBuilder(
    BuildContext context,
    BlocResponsive responsive,
    Widget content,
    List<ModelMainMenuModel> items,
    Color backgroundColor,
    bool animate,
  ) {
    return SecondaryMenuMobileLayout(
      responsive: responsive,
      content: content,
      items: items,
      backgroundColor: backgroundColor,
      animate: animate,
    );
  }

  bool get _hasActions => items.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final double mh = responsive.marginWidth;
    final double gap = responsive.gutterWidth.clamp(8.0, 16.0);

    final Widget overlay = !_hasActions
        ? const SizedBox.shrink()
        : Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: gap),
              child: _maybeAnimated(
                key: const ValueKey<String>('mobile-secondary'),
                child: _buildActionsBar(context, gap),
              ),
            ),
          );

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Container(
          color: backgroundColor,
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mh),
            child: content,
          ),
        ),
        overlay,
      ],
    );
  }

  Widget _buildActionsBar(BuildContext context, double gap) {
    final double itemSize = (gap * 3).clamp(48.0, 72.0);

    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: gap, vertical: gap * 0.5),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < items.length; i++) ...<Widget>[
                SecondaryMenuSquareButton(
                  item: items[i],
                  size: itemSize,
                ),
                if (i < items.length - 1) SizedBox(width: gap * 0.5),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _maybeAnimated({required Widget child, Key? key}) {
    if (!animate) {
      return child;
    }

    return AnimatedSwitcher(
      key: key,
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: child,
    );
  }
}
