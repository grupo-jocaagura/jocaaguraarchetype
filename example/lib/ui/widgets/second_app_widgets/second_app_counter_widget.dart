import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../../blocs/bloc_counter.dart';
import 'dot_widget.dart';

/// Counter showcase adapted to the new responsive helpers.
/// - Mobile: vertical layout (compact).
/// - Tablet: 1x2 composition.
/// - Desktop: 1x3 composition.
/// - TV: wide/horizontal composition.
class SecondAppCounterWidget extends StatelessWidget {
  const SecondAppCounterWidget({
    required this.blocCounter,
    super.key,
  });

  final BlocCounter blocCounter;

  @override
  Widget build(BuildContext context) {
    final AppManager app = context.appManager;
    final BlocResponsive r = app.responsive;

    // Mantener métricas actualizadas.
    r.setSizeFromContext(context);

    return StreamBuilder<int>(
      stream: blocCounter.counterStream,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        final int value = blocCounter.value;

        return ResponsiveSizeWidget(
          responsive: r,
          // --------- MOBILE: vertical compacto ----------
          mobile: (BuildContext ctx, BlocResponsive rr) =>
              _buildVertical(ctx, rr, value),
          // --------- TABLET: 1x2 ----------
          tablet: (BuildContext ctx, BlocResponsive rr) => Column(
            children: <Widget>[
              SizedBox(height: rr.gutterWidth),
              Responsive1x2Widget(
                responsive: rr,
                child: _tile1x2(ctx, rr, value),
              ),
              SizedBox(height: rr.gutterWidth),
              Responsive1x1Widget(
                responsive: rr,
                child: _counterBig(ctx, rr, value),
              ),
              SizedBox(height: rr.gutterWidth),
              _cta(ctx, rr),
            ],
          ),
          // --------- DESKTOP: 1x3 ----------
          desktop: (BuildContext ctx, BlocResponsive rr) => Column(
            children: <Widget>[
              SizedBox(height: rr.gutterWidth),
              Responsive1x3Widget(
                responsive: rr,
                child: _tile1x3(ctx, rr, value),
              ),
              SizedBox(height: rr.gutterWidth),
              Responsive1x1Widget(
                responsive: rr,
                child: _counterBig(ctx, rr, value),
              ),
              SizedBox(height: rr.gutterWidth),
              _cta(ctx, rr),
            ],
          ),
          // --------- TV: horizontal ancho ----------
          tv: (BuildContext ctx, BlocResponsive rr) =>
              _buildHorizontal(ctx, rr, value),
          // Si quieres un plan B:
          fallback: (BuildContext ctx, BlocResponsive rr) =>
              _buildVertical(ctx, rr, value),
        );
      },
    );
  }

  // ========== Pieces ==========

  /// Counter grande + dos puntos (pares/impares)
  Widget _counterBig(BuildContext context, BlocResponsive r, int value) {
    final double w = r.widthByColumns(1);
    final double numberSize = (w * 0.62).clamp(70.0, 125.0);
    final double dot = (w * 0.16).clamp(12.0, 30.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: numberSize + 35,
          width: w,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: numberSize,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        SizedBox(height: r.gutterWidth * 0.5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DotWidget(isActive: value.isOdd, width: dot),
            SizedBox(width: (r.gutterWidth * 0.4).clamp(4.0, 8.0)),
            DotWidget(isActive: value.isEven, width: dot),
          ],
        ),
      ],
    );
  }

  /// Composición 1x2 (dos bloques de 100x100 aprox, rojo y púrpura).
  Widget _tile1x2(BuildContext context, BlocResponsive r, int value) {
    final double side = (r.columnWidth * 0.95).clamp(90.0, 120.0);
    final double font = (side * 0.7).clamp(40.0, 70.0);
    final double dot = (side * 0.22).clamp(10.0, 15.0);

    Widget blockCounter(Color color) => Container(
          width: side,
          height: side,
          color: color,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: side * 0.8,
                width: side,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: font,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  DotWidget(isActive: value.isOdd, width: dot),
                  SizedBox(width: (r.gutterWidth * 0.3).clamp(3.0, 6.0)),
                  DotWidget(isActive: value.isEven, width: dot),
                ],
              ),
            ],
          ),
        );

    Widget blockIcon(Color color, IconData icon) => Container(
          width: side,
          height: side,
          color: color,
          child: Center(
            child: Icon(icon, size: (side * 0.7).clamp(40.0, 70.0)),
          ),
        );

    return Row(
      children: <Widget>[
        blockCounter(Colors.red),
        SizedBox(width: r.gutterWidth),
        blockIcon(
          Colors.purple,
          value.isEven ? Icons.scatter_plot : Icons.scatter_plot_outlined,
        ),
      ],
    );
  }

  /// Composición 1x3 (tres bloques 100x100 aprox)
  Widget _tile1x3(BuildContext context, BlocResponsive r, int value) {
    final double side = (r.columnWidth * 0.95).clamp(90.0, 120.0);
    final double font = (side * 0.7).clamp(40.0, 70.0);

    Widget box(Widget child) =>
        SizedBox(width: side, height: side, child: child);

    return Row(
      children: <Widget>[
        box(
          Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: font,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        SizedBox(width: r.gutterWidth),
        box(
          Center(
            child: Icon(
              value.isEven
                  ? Icons.directions_run_outlined
                  : Icons.directions_run,
              size: font,
            ),
          ),
        ),
        SizedBox(width: r.gutterWidth),
        box(
          Center(
            child: Text(
              'Pasos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: (side * 0.28).clamp(16.0, 24.0),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  /// Layout vertical (mobile) con reset como CTA.
  Widget _buildVertical(BuildContext context, BlocResponsive r, int value) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: r.gutterWidth),
          Responsive1x1Widget(
            responsive: r,
            child: _counterBig(context, r, value),
          ),
          SizedBox(height: r.gutterWidth),
          Responsive1x2Widget(
            responsive: r,
            child: _tile1x2(context, r, value),
          ),
          SizedBox(height: r.gutterWidth),
          _cta(context, r),
        ],
      ),
    );
  }

  /// Layout horizontal ancho (tv)
  Widget _buildHorizontal(BuildContext context, BlocResponsive r, int value) {
    final double panelW = r.widthByColumns(3);
    final double panelH = (panelW * 0.66).clamp(260.0, 420.0);

    return SizedBox(
      width: r.workAreaSize.width,
      child: Center(
        child: SizedBox(
          width: panelW * 2 + r.gutterWidth, // dos paneles + gap
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Panel izquierdo: número grande
              SizedBox(
                width: panelW,
                height: panelH,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: panelH * 0.14,
                      left: panelW * 0.08,
                      width: panelW * 0.84,
                      child: Text(
                        '$value',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontSize: (panelH * 0.48).clamp(120.0, 220.0),
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    Positioned(
                      bottom: r.gutterWidth * 0.6,
                      left: panelW * 0.08,
                      right: panelW * 0.08,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.add),
                            iconSize: (panelH * 0.22).clamp(64.0, 120.0),
                            onPressed: blocCounter.add,
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            iconSize: (panelH * 0.22).clamp(64.0, 120.0),
                            onPressed: blocCounter.decrement,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: r.gutterWidth),
              // Panel derecho: gráfico/ícono + CTA
              SizedBox(
                width: panelW,
                height: panelH,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: r.gutterWidth * 0.8,
                      right: r.gutterWidth,
                      left: r.gutterWidth,
                      child: const Icon(Icons.auto_graph, size: 200),
                    ),
                    Positioned(
                      bottom: r.gutterWidth * 0.6,
                      right: r.gutterWidth,
                      left: r.gutterWidth,
                      child: _cta(context, r),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Botón de acción principal (Reset por defecto).
  Widget _cta(BuildContext context, BlocResponsive r) {
    return MyAppButtonWidget(
      responsive: r,
      label: 'Reset',
      leadingIcon: Icons.restart_alt,
      onPressed: blocCounter.reset,
      fullWidth: r.isMobile, // ancho completo en mobile
      maxWidthColumns: 2, // hasta 2 columnas en pantallas amplias
    );
  }
}
