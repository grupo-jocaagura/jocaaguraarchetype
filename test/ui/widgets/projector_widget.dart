import 'package:flutter/material.dart';

class ProjectorWidget extends StatelessWidget {
  const ProjectorWidget({
    required this.child,
    this.designWidth = 412,
    this.designHeight = 892,
    super.key,
    this.debug = false,
  });

  final Widget child;
  final double designWidth;
  final double designHeight;
  final bool debug;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;
        final double aspectRatio = designWidth / designHeight;
        double widthScale = screenWidth;
        double heightScale = widthScale / aspectRatio;

        if (heightScale > screenHeight) {
          heightScale = screenHeight;
          widthScale = heightScale * aspectRatio;
        }
        return Center(
          child: SizedBox(
            width: widthScale,
            height: heightScale,
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: FittedBox(
                child: debug
                    ? Container(
                        color: Colors.amber,
                        width: designWidth,
                        height: designHeight,
                        child: child,
                      )
                    : SizedBox(
                        width: designWidth,
                        height: designHeight,
                        child: child,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
