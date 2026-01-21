part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

class ColorPaletteEditWidget extends StatefulWidget {
  const ColorPaletteEditWidget({
    required this.color,
    required this.label,
    required this.onChangeColorAttempt,
    super.key,
  });

  final Color color;
  final String label;
  final void Function(Color color) onChangeColorAttempt;

  @override
  State<ColorPaletteEditWidget> createState() => _ColorPaletteEditWidgetState();
}

class _ColorPaletteEditWidgetState extends State<ColorPaletteEditWidget> {
  late final BlocColor blocColor;
  @override
  void initState() {
    super.initState();
    blocColor = BlocColor(
      widget.color,
      onChangeColorAttempt: (Color c) {
        widget.onChangeColorAttempt(c);
      },
    );
  }

  @override
  void didUpdateWidget(covariant ColorPaletteEditWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      blocColor.onExternalDsChange(widget.color);
    }
  }

  @override
  void dispose() {
    blocColor.dispose();
    super.dispose();
  }

  Widget gapSm(BuildContext context) => SizedBox(
        width: DsExtendedTokensExtension.tokOr(
          context,
          (ModelDsExtendedTokens t) => t.spacingSm,
          8,
        ),
      );
  @override
  Widget build(BuildContext context) {
    final double minTabHeight = DsExtendedTokensExtension.tokOr(
      context,
      (ModelDsExtendedTokens t) => t.spacingLg,
      40,
    );
    final double maxTabHeight = DsExtendedTokensExtension.tokOr(
      context,
      (ModelDsExtendedTokens t) => t.spacingXXl,
      70,
    );

    final double tabHeight = (MediaQuery.of(context).size.width * 0.25)
        .clamp(minTabHeight, maxTabHeight);
    return SizedBox(
      height: tabHeight,
      child: StreamBuilder<ModelFieldState>(
        stream: blocColor.colorStream,
        builder: (_, __) {
          final ModelFieldState state = blocColor.colorState;
          return Row(
            children: <Widget>[
              Semantics(
                label: 'Color ${widget.label}',
                child: Container(
                  height: tabHeight,
                  width: tabHeight,
                  color: blocColor.colorStateValue,
                ),
              ),
              gapSm(context),
              Expanded(
                child: Column(
                  children: <Widget>[
                    JocaaguraAutocompleteInputWidget(
                      label: widget.label,
                      value: state.value,
                      errorText: state.errorTextToInput,
                      onChangedAttempt: blocColor.onColorChangedAttempt,
                      onSubmittedAttempt: blocColor.onColorChangedAttempt,
                      placeholder: '#RRGGBB or #AARRGGBB',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
