part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class MobileSecondaryOptionWidget extends StatelessWidget {
  const MobileSecondaryOptionWidget({
    required this.onPressed,
    required this.label,
    required this.icondata,
    required this.width,
    this.description = '',
    super.key,
  });
  final VoidCallback onPressed;
  final String label, description;
  final IconData icondata;
  final double width;

  @override
  Widget build(BuildContext context) {
    final double iconSize = width * 0.65;

    return Responsive1x1Widget(
      width: width,
      child: MaterialButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Tooltip(
          message: description,
          child: Container(
            width: width,
            height: width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(width * 0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(
                  icondata,
                  size: iconSize,
                  color: Theme.of(context).canvasColor,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).canvasColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
