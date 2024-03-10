import 'package:flutter/material.dart';

import 'column_blueprint_widget.dart';
import 'gutter_blueprint_widget.dart';
import 'margin_blueprint_widget.dart';

class ColumnsBluePrintWidget extends StatelessWidget {
  const ColumnsBluePrintWidget({
    required this.numberOfColumns,
    required this.workAreaSize,
    required this.marginWidth,
    required this.columnWidth,
    required this.gutterWidth,
    super.key,
  });
  final int numberOfColumns;
  final double marginWidth;
  final double columnWidth;
  final double gutterWidth;
  final Size workAreaSize;

  @override
  Widget build(BuildContext context) {
    final List<Widget> columns = <Widget>[];
    final int numberOfGutters = numberOfColumns < 1 ? 0 : numberOfColumns - 1;
    final MarginBlueprintWidget marginWidget = MarginBlueprintWidget(
      width: marginWidth,
      height: workAreaSize.height,
    );
    int gutterAdded = 0;
    columns.add(marginWidget);
    for (int i = 0; i < numberOfColumns; i++) {
      columns.add(
        ColumnBlueprintWidget(
          width: columnWidth,
          height: workAreaSize.height,
        ),
      );
      if (gutterAdded < numberOfGutters) {
        columns.add(
          GutterBlueprintWidget(
            width: gutterWidth,
            height: workAreaSize.height,
          ),
        );
        gutterAdded++;
      }
    }
    columns.add(marginWidget);

    return Center(
      child: SizedBox(
        width: workAreaSize.width,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: columns,
              ),
            ),
            Center(
              child: Text(
                'Columas: $numberOfColumns',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
