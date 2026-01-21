part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Panel transversal para editar DataViz (usa dsBloc.patchDataViz).
///
/// ✅ A prueba de fallos:
/// - Usa dsBloc.requireDs() (que cae al lastGoodDs si el DS está en Left).
/// - Mantiene estado local (palette) para que el editor nunca dependa de extensions.
/// - DRY-RUN: construye la paleta antes de commitear.
/// - Muestra error local sin tumbar UI.
/// - Listener key único por instancia.
///
/// Nota: Asume que tu ModelDataVizPalette valida tamaños y rangos internamente.
/// Si no valida, igual el panel es seguro porque no rompe el DS si algo truena.
class DsDataVizEditorWidget extends StatefulWidget {
  const DsDataVizEditorWidget({
    required this.dsBloc,
    super.key,
    this.maxCategorical = 10,
    this.sequentialSteps = 8,
  });

  final BlocDesignSystem dsBloc;

  /// Cantidad de swatches categóricos a mostrar/editar.
  final int maxCategorical;

  /// Cantidad de pasos que se muestran en la barra de escala secuencial.
  final int sequentialSteps;

  @override
  State<DsDataVizEditorWidget> createState() => _DsDataVizEditorWidgetState();
}

class _DsDataVizEditorWidgetState extends State<DsDataVizEditorWidget> {
  late final String _listenerKey;

  late ModelDataVizPalette _palette;
  ErrorItem? _localError;

  @override
  void initState() {
    super.initState();

    _listenerKey = 'DsDataVizEditorWidget.${identityHashCode(this)}';
    _palette = widget.dsBloc.requireDs().dataViz;

    widget.dsBloc.addDsListener(
      _listenerKey,
      (ModelDesignSystem ds) {
        if (!mounted) {
          return;
        }
        if (ds.dataViz == _palette) {
          return;
        }
        setState(() {
          _palette = ds.dataViz;
          _localError = null;
        });
      },
      true,
    );
  }

  @override
  void dispose() {
    if (widget.dsBloc.hasListener(_listenerKey)) {
      widget.dsBloc.removeListener(_listenerKey);
    }
    super.dispose();
  }

  void _commitPalette({
    List<Color>? categorical,
    List<Color>? sequential,
  }) {
    final ModelDataVizPalette base = _palette;

    try {
      // DRY-RUN: construimos la paleta final antes de commitear.
      final ModelDataVizPalette next = ModelDataVizPalette(
        categorical: categorical ?? base.categorical,
        sequential: sequential ?? base.sequential,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _palette = next;
        _localError = null;
      });

      widget.dsBloc.patchDataViz(
        categorical: next.categorical,
        sequential: next.sequential,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _localError = ErrorItem(
          title: 'Invalid DataViz values',
          code: 'DS_DATAVIZ_INVALID',
          description: e.toString(),
          errorLevel: ErrorLevelEnum.warning,
        );
      });
    }
  }

  void _setCategoricalAt(int index, Color color) {
    final List<Color> next = List<Color>.from(_palette.categorical);
    // Asegura longitud mínima
    while (next.length <= index) {
      next.add(Colors.grey);
    }
    next[index] = color;
    _commitPalette(categorical: next);
  }

  void _setSequentialAt(int index, Color color) {
    final List<Color> next = List<Color>.from(_palette.sequential);
    while (next.length <= index) {
      next.add(Colors.grey);
    }
    next[index] = color;
    _commitPalette(sequential: next);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final ColorScheme cs = t.colorScheme;

    final ModelDsExtendedTokens tok = context.dsTokens;

    final int catCount = widget.maxCategorical.clamp(1, 32); // guardia visual
    final int seqCount = widget.sequentialSteps.clamp(2, 32);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tok.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('DataViz editor', style: t.textTheme.titleLarge),
            SizedBox(height: tok.spacingXs),
            Text(
              'Edita paletas para gráficas: categorical (series) y sequential (escala 0..1).',
              style: t.textTheme.bodySmall,
            ),
            SizedBox(height: tok.spacingSm),

            if (_localError != null)
              Card(
                color: cs.errorContainer,
                child: Padding(
                  padding: EdgeInsets.all(tok.spacingSm),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: cs.onErrorContainer),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.warning_amber_rounded,
                          color: cs.onErrorContainer,
                        ),
                        SizedBox(width: tok.spacingSm),
                        Expanded(
                          child: Text(
                            _localError!.description,
                            style: t.textTheme.bodySmall
                                ?.copyWith(color: cs.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            SizedBox(height: tok.spacing),

            // ----------------------------------------------------------------
            // PREVIEW
            // ----------------------------------------------------------------
            _DsDataVizPreview(
              palette: _palette,
              categoricalCount: catCount,
              sequentialSteps: seqCount,
            ),

            SizedBox(height: tok.spacing),

            // ----------------------------------------------------------------
            // EDITOR: CATEGORICAL
            // ----------------------------------------------------------------
            const _SectionHeader(title: 'Categorical (series colors)'),
            SizedBox(height: tok.spacingXs),
            Wrap(
              spacing: tok.spacingSm,
              runSpacing: tok.spacingSm,
              children: List<Widget>.generate(catCount, (int i) {
                final Color c = _safeCat(i);
                return DsColorSwatchEditWidget(
                  label: 'cat[$i]',
                  color: c,
                  onChangeColorAttempt: (Color next) =>
                      _setCategoricalAt(i, next),
                );
              }),
            ),

            SizedBox(height: tok.spacing),

            // ----------------------------------------------------------------
            // EDITOR: SEQUENTIAL
            // ----------------------------------------------------------------
            const _SectionHeader(title: 'Sequential (scale stops)'),
            SizedBox(height: tok.spacingXs),
            Wrap(
              spacing: tok.spacingSm,
              runSpacing: tok.spacingSm,
              children: List<Widget>.generate(seqCount, (int i) {
                final Color c = _safeSeq(i);
                return DsColorSwatchEditWidget(
                  label: 'seq[$i]',
                  color: c,
                  onChangeColorAttempt: (Color next) =>
                      _setSequentialAt(i, next),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Color _safeCat(int i) {
    if (i < 0) {
      return Colors.grey;
    }
    if (i >= _palette.categorical.length) {
      return Colors.grey;
    }
    return _palette.categorical[i];
  }

  Color _safeSeq(int i) {
    if (i < 0) {
      return Colors.grey;
    }
    if (i >= _palette.sequential.length) {
      return Colors.grey;
    }
    return _palette.sequential[i];
  }
}

/// ---------------------------------------------------------------------------
/// PREVIEW: mini chart + barras + escala
/// ---------------------------------------------------------------------------

class _DsDataVizPreview extends StatelessWidget {
  const _DsDataVizPreview({
    required this.palette,
    required this.categoricalCount,
    required this.sequentialSteps,
  });

  final ModelDataVizPalette palette;
  final int categoricalCount;
  final int sequentialSteps;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tok = context.dsTokens;

    final List<double> values = <double>[0.2, 0.55, 0.35, 0.8, 0.6];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionHeader(title: 'Preview'),
        SizedBox(height: tok.spacingXs),

        // Categorical swatches preview
        Wrap(
          spacing: tok.spacingXs,
          runSpacing: tok.spacingXs,
          children: List<Widget>.generate(
            categoricalCount,
            (int i) => _Swatch(color: _catOrGrey(palette, i)),
          ),
        ),

        SizedBox(height: tok.spacingSm),

        // Sequential scale preview
        Row(
          children: List<Widget>.generate(sequentialSteps, (int i) {
            final double v =
                (sequentialSteps <= 1) ? 0 : i / (sequentialSteps - 1);
            // Preferimos usar sequentialAt si existe; si no, usamos stops directos.
            final Color c = _sequentialAtOrStop(palette, v, i);
            return Expanded(
              child: Container(
                height: tok.spacingLg,
                color: c,
              ),
            );
          }),
        ),

        SizedBox(height: tok.spacingSm),

        // Mini bar chart (categorical)
        Card(
          child: Padding(
            padding: EdgeInsets.all(tok.spacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List<Widget>.generate(values.length, (int i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: tok.spacingXs),
                    child: Container(
                      height: 120 * values[i],
                      decoration: BoxDecoration(
                        color: _catOrGrey(palette, i),
                        borderRadius: BorderRadius.circular(tok.borderRadiusSm),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  static Color _catOrGrey(ModelDataVizPalette p, int i) {
    if (i < 0 || i >= p.categorical.length) {
      return Colors.grey;
    }
    return p.categorical[i];
  }

  static Color _sequentialAtOrStop(
    ModelDataVizPalette p,
    double t,
    int stopIndex,
  ) {
    // Si el modelo tiene sequentialAt(double), úsalo.
    // Si no, cae al stop index.
    try {
      // ignore: unnecessary_cast
      return (p as dynamic).sequentialAt(t) as Color;
    } catch (_) {
      if (stopIndex < 0 || stopIndex >= p.sequential.length) {
        return Colors.grey;
      }
      return p.sequential[stopIndex];
    }
  }
}

/// ---------------------------------------------------------------------------
/// Editable swatch (usa tu BlocColor + hex input reutilizable)
/// ---------------------------------------------------------------------------

class DsColorSwatchEditWidget extends StatelessWidget {
  const DsColorSwatchEditWidget({
    required this.label,
    required this.color,
    required this.onChangeColorAttempt,
    super.key,
  });

  final String label;
  final Color color;
  final void Function(Color color) onChangeColorAttempt;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tok = context.dsTokens;

    return SizedBox(
      width: 260,
      child: Row(
        children: <Widget>[
          _Swatch(color: color),
          SizedBox(width: tok.spacingSm),
          Expanded(
            child: ColorPaletteEditWidget(
              label: label,
              color: color,
              onChangeColorAttempt: onChangeColorAttempt,
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tok = context.dsTokens;

    return Container(
      width: 28,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(tok.borderRadiusSm),
      ),
    );
  }
}
