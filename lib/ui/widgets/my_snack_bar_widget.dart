part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A lightweight, responsive toast/snack overlay driven by a stream.
///
/// - Uses [BlocResponsive] to size & place the toast (bottom-center on mobile,
///   top-right on tablet/desktop).
/// - Queues incoming snacks and shows them one by one.
/// - Auto-dismisses after [duration] (can be overridden per snack).
/// - Optional action button and close (X).
///
/// ### Usage (recommended)
/// ```dart
/// final BlocResponsive resp = BlocResponsive()..setSizeFromContext(context);
/// final StreamController<AppSnack> ctrl = StreamController<AppSnack>();
///
/// // Somewhere in your code:
/// ctrl.add(AppSnack.info('Saved!'));
///
/// // Overlay:
/// Stack(
///   children: [
///     page,
///     Align(
///       alignment: Alignment.topCenter,
///       child: MySnackBarWidget(
///         responsive: resp,
///         snacks: ctrl.stream,
///       ),
///     ),
///   ],
/// )
/// ```
///
/// ### Legacy (string stream)
/// ```dart
/// MySnackBarWidget.fromStringStream(
///   responsive: resp,
///   toastStream: myStringStream,
/// );
/// ```
///
/// This widget paints inside its own box; place it in a `Stack` for an overlay.
///
/// See: [AppSnack], [AppSnackVariant].
class MySnackBarWidget extends StatelessWidget {
  const MySnackBarWidget({
    required this.responsive,
    required this.snacks, // Stream<AppSnack?>: null = oculto, AppSnack = visible
    super.key,
    this.maxWidthColumns,
    this.elevation = 8.0,
    this.dismissible = true,
    this.safeArea = true,
    this.onDismissRequested,
  });

  /// Backwards-compatible factory para `Stream<String>`.
  factory MySnackBarWidget.fromStringStream({
    required BlocResponsive responsive,
    required Stream<String> toastStream,
    int? maxWidthColumns,
    double elevation = 8.0,
    bool dismissible = true,
    bool safeArea = true,
    VoidCallback? onDismissRequested,
    Key? key,
  }) {
    final Stream<AppSnack?> mapped =
        toastStream.map<AppSnack?>((String msg) => AppSnack.info(msg));
    return MySnackBarWidget(
      key: key,
      responsive: responsive,
      snacks: mapped,
      maxWidthColumns: maxWidthColumns,
      elevation: elevation,
      dismissible: dismissible,
      safeArea: safeArea,
      onDismissRequested: onDismissRequested,
    );
  }

  /// Responsive metrics provider.
  final BlocResponsive responsive;

  /// Stream reactivo: `null` oculta, `AppSnack` muestra.
  final Stream<AppSnack?> snacks;

  /// Clamp max width usando columnas responsivas.
  final int? maxWidthColumns;

  /// Material elevation.
  final double elevation;

  /// Si `true`, muestra botón de cierre (X) **si** hay `onDismissRequested`.
  final bool dismissible;

  /// Envuelve en SafeArea.
  final bool safeArea;

  /// Pedido de cierre: el padre debe ocultar emitiendo `null` en el stream.
  final VoidCallback? onDismissRequested;

  @override
  Widget build(BuildContext context) {
    if (context.mounted) {
      responsive.setSizeFromContext(context);
    }
    final BlocResponsive r = responsive;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final bool isMobile = r.isMobile;
    final double mh = r.marginWidth;
    final double gap = r.gutterWidth.clamp(8.0, 16.0);

    final double defaultMax =
        isMobile ? (r.workAreaSize.width - mh * 2) : r.widthByColumns(4);
    final double maxW = maxWidthColumns != null
        ? r.widthByColumns(maxWidthColumns!.clamp(1, r.columnsNumber))
        : defaultMax;

    final Alignment align =
        isMobile ? Alignment.bottomCenter : Alignment.topRight;
    final EdgeInsets outerPad = isMobile
        ? EdgeInsets.only(left: mh, right: mh, bottom: gap)
        : EdgeInsets.only(right: mh, top: gap);

    return StreamBuilder<AppSnack?>(
      stream: snacks,
      builder: (BuildContext context, AsyncSnapshot<AppSnack?> snap) {
        final AppSnack? s = snap.data;
        final bool show = s != null && s.message.isNotEmpty;
        final _Palette p =
            _paletteFor(s?.variant ?? AppSnackVariant.info, scheme);

        final Widget toast = !show
            ? const SizedBox.shrink()
            : Material(
                elevation: elevation,
                color: p.bg,
                surfaceTintColor: p.tint,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: Padding(
                    padding: EdgeInsets.all(gap),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (s.leadingIcon != null)
                          Padding(
                            padding:
                                EdgeInsetsDirectional.only(end: gap * 0.75),
                            child: Icon(s.leadingIcon, color: p.fg, size: 20),
                          ),
                        Flexible(
                          child: Text(
                            s.message,
                            key: const ValueKey<String>('snack-text'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: p.fg,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (s.actionLabel != null && s.onAction != null)
                          Padding(
                            padding: EdgeInsetsDirectional.only(start: gap),
                            child: TextButton(
                              onPressed: () {
                                s.onAction?.call();
                                onDismissRequested?.call();
                              },
                              child: Text(
                                s.actionLabel!,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: p.action),
                              ),
                            ),
                          ),
                        if (dismissible && onDismissRequested != null)
                          IconButton(
                            tooltip: 'Close',
                            onPressed: onDismissRequested,
                            icon: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: p.fg.withValues(alpha: 0.85),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );

        final Widget animated = AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: show
              ? KeyedSubtree(
                  key: const ValueKey<String>('snack-on'),
                  child: toast,
                )
              : const SizedBox(key: ValueKey<String>('snack-off')),
        );

        final Widget body = Align(
          alignment: align,
          child: Padding(padding: outerPad, child: animated),
        );

        final Widget withSemantics = Semantics(
          liveRegion: true,
          label: 'Notification',
          value: s?.message,
          child: body,
        );

        return safeArea ? SafeArea(child: withSemantics) : withSemantics;
      },
    );
  }

  _Palette _paletteFor(AppSnackVariant v, ColorScheme s) {
    switch (v) {
      case AppSnackVariant.info:
        return _Palette(
          bg: s.inverseSurface,
          fg: s.onInverseSurface, // <- corregido: texto legible
          action: s.inversePrimary,
          tint: s.inverseSurface,
        );
      case AppSnackVariant.success:
        return _Palette(
          bg: s.tertiaryContainer,
          fg: s.onTertiaryContainer,
          action: s.tertiary,
          tint: s.tertiaryContainer,
        );
      case AppSnackVariant.warning:
        return _Palette(
          bg: s.secondaryContainer,
          fg: s.onSecondaryContainer,
          action: s.secondary,
          tint: s.secondaryContainer,
        );
      case AppSnackVariant.error:
        return _Palette(
          bg: s.errorContainer,
          fg: s.onErrorContainer,
          action: s.error,
          tint: s.errorContainer,
        );
    }
  }
}

/// Payload for [MySnackBarWidget].
///
/// Use factories for quick creation:
/// - [AppSnack.info], [AppSnack.success], [AppSnack.warning], [AppSnack.error]
class AppSnack {
  const AppSnack({
    required this.message,
    this.variant = AppSnackVariant.info,
    this.actionLabel,
    this.onAction,
    this.leadingIcon,
    this.duration,
  });

  factory AppSnack.info(
    String msg, {
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    Duration? duration,
  }) =>
      AppSnack(
        message: msg,
        actionLabel: actionLabel,
        onAction: onAction,
        leadingIcon: icon,
        duration: duration,
      );

  factory AppSnack.success(
    String msg, {
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    Duration? duration,
  }) =>
      AppSnack(
        message: msg,
        variant: AppSnackVariant.success,
        actionLabel: actionLabel,
        onAction: onAction,
        leadingIcon: icon ?? Icons.check_circle_rounded,
        duration: duration,
      );

  factory AppSnack.warning(
    String msg, {
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    Duration? duration,
  }) =>
      AppSnack(
        message: msg,
        variant: AppSnackVariant.warning,
        actionLabel: actionLabel,
        onAction: onAction,
        leadingIcon: icon ?? Icons.warning_amber_rounded,
        duration: duration,
      );

  factory AppSnack.error(
    String msg, {
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    Duration? duration,
  }) =>
      AppSnack(
        message: msg,
        variant: AppSnackVariant.error,
        actionLabel: actionLabel,
        onAction: onAction,
        leadingIcon: icon ?? Icons.error_outline_rounded,
        duration: duration,
      );

  final String message;
  final AppSnackVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? leadingIcon;
  final Duration? duration;
}

/// Visual style for a snack variant.
enum AppSnackVariant { info, success, warning, error }

class _Palette {
  const _Palette({
    required this.bg,
    required this.fg,
    required this.action,
    required this.tint,
  });
  final Color bg;
  final Color fg;
  final Color action;
  final Color tint;
}
