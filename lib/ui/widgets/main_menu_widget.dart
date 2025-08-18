part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class MainMenuWidget extends StatelessWidget {
  const MainMenuWidget({
    required this.listMenuOptions,
    required this.drawerWidth,
    super.key,
  });

  final List<ModelMainMenuModel> listMenuOptions;
  final double drawerWidth;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    for (final ModelMainMenuModel option in listMenuOptions) {
      children.add(
        MainMenuOptionWidget(option: option),
      );
    }

    if (listMenuOptions.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: drawerWidth,
      child: ListView(
        children: children,
      ),
    );
  }
}
