part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class SecondaryMenuSquareButton extends StatelessWidget {
  const SecondaryMenuSquareButton({
    required this.item,
    required this.size,
    super.key,
  });

  final ModelMainMenuModel item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final BorderRadius radius = BorderRadius.circular(16);
    final String tooltip =
        (item.description.isNotEmpty) ? item.description : item.label;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: scheme.primaryContainer,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: item.onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(
                item.iconData,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
