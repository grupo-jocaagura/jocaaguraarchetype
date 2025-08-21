part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class ResponsiveNxBase extends StatelessWidget {
  const ResponsiveNxBase({
    required this.responsive,
    required this.columns,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.padding,
    super.key,
  });

  final BlocResponsive responsive;
  final int columns;
  final Widget child;
  final Alignment alignment;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    if (context.mounted) {
      responsive.setSizeFromContext(context);
    }

    final double mh = responsive.marginWidth;
    final double maxW = responsive.workAreaSize.width;
    final double w =
        responsive.widthByColumns(columns.clamp(1, responsive.columnsNumber));

    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: mh)
            .add(padding ?? EdgeInsets.zero),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: w.clamp(0.0, maxW),
          ),
          child: child,
        ),
      ),
    );
  }
}
