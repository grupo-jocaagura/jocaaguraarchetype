part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A bottom secondary menu for mobile layouts with slide/fade animation.
///
/// - Width and paddings derive from [BlocResponsive].
/// - Uses [SafeArea] and elevation to float over content.
/// - Accepts a typed list of items to render consistently.
///
/// ## Example
/// ```dart
/// final BlocResponsive resp = BlocResponsive()..setSizeForTesting(const Size(390, 844));
/// return MobileSecondaryMenuWidget(
///   responsive: resp,
///   items: <SecondaryMenuItem>[
///     SecondaryMenuItem(Icons.home, 'Home', onTap: () {} ),
///     SecondaryMenuItem(Icons.search, 'Search', onTap: () {} ),
///   ],
///   visible: true,
/// );
/// ```
///
/// See also: [MobileSecondaryOptionWidget].
class MobileSecondaryMenuWidget extends StatelessWidget {
  const MobileSecondaryMenuWidget({
    required this.items,
    required this.responsive,
    super.key,
    this.visible = true,
    this.elevation = 8.0,
  });

  final List<SecondaryMenuItem> items;
  final BlocResponsive responsive;
  final bool visible;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final double width = responsive.workAreaSize.width.clamp(240.0, 720.0);
    final double gap = responsive.gutterWidth.clamp(8.0, 16.0);

    final Widget bar = SafeArea(
      minimum: EdgeInsets.only(bottom: gap, left: gap, right: gap),
      child: Center(
        child: Material(
          elevation: elevation,
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: gap, vertical: gap * 0.5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final SecondaryMenuItem it in items) ...<Widget>[
                    Flexible(
                      child: MobileSecondaryOptionWidget(
                        icon: it.icon,
                        label: it.label,
                        responsive: responsive,
                        onPressed: it.onTap,
                        tooltip: it.tooltip,
                        selected: it.selected,
                        semanticsLabel: it.semanticsLabel,
                      ),
                    ),
                    SizedBox(width: gap),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      offset: visible ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: visible ? 1.0 : 0.0,
        child: bar,
      ),
    );
  }
}

/// Typed data for secondary menu items.
class SecondaryMenuItem {
  const SecondaryMenuItem(
    this.icon,
    this.label, {
    required this.onTap,
    this.tooltip,
    this.selected = false,
    this.semanticsLabel,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool selected;
  final String? semanticsLabel;
}
