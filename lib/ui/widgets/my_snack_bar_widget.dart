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
class MySnackBarWidget extends StatefulWidget {
  const MySnackBarWidget({
    required this.responsive,
    required this.snacks,
    super.key,
    this.duration = const Duration(seconds: 3),
    this.maxWidthColumns,
    this.elevation = 8.0,
    this.dismissible = true,
    this.safeArea = true,
  });

  /// Backwards-compatible factory for `Stream<String>`.
  factory MySnackBarWidget.fromStringStream({
    required BlocResponsive responsive,
    required Stream<String> toastStream,
    Duration duration = const Duration(seconds: 3),
    int? maxWidthColumns,
    double elevation = 8.0,
    bool dismissible = true,
    bool safeArea = true,
    Key? key,
  }) {
    final Stream<AppSnack> mapped = toastStream.map(
      (String msg) => AppSnack.info(msg),
    );
    return MySnackBarWidget(
      key: key,
      responsive: responsive,
      snacks: mapped,
      duration: duration,
      maxWidthColumns: maxWidthColumns,
      elevation: elevation,
      dismissible: dismissible,
      safeArea: safeArea,
    );
  }

  /// Responsive metrics provider.
  final BlocResponsive responsive;

  /// Stream of snacks to show (use [AppSnack] to include variant/action/duration).
  final Stream<AppSnack> snacks;

  /// Default lifetime of a snack (can be overridden per [AppSnack.duration]).
  final Duration duration;

  /// Clamp max width using responsive columns (default: mobile full width,
  /// desktop ~4 columns).
  final int? maxWidthColumns;

  /// Material elevation for the toast surface.
  final double elevation;

  /// If true, renders a close (X) button.
  final bool dismissible;

  /// Wrap with SafeArea paddings.
  final bool safeArea;

  @override
  State<MySnackBarWidget> createState() => _MySnackBarWidgetState();
}

class _MySnackBarWidgetState extends State<MySnackBarWidget> {
  final List<AppSnack> _queue = <AppSnack>[];
  AppSnack? _current;
  bool _visible = false;
  Timer? _timer;
  StreamSubscription<AppSnack>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.snacks.listen(_onSnack);
  }

  @override
  void didUpdateWidget(covariant MySnackBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snacks != widget.snacks) {
      _sub?.cancel();
      _sub = widget.snacks.listen(_onSnack);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _onSnack(AppSnack s) {
    _queue.add(s);
    if (_current == null) {
      _showNext();
    }
  }

  void _showNext() {
    if (_queue.isEmpty || !mounted) {
      setState(() {
        _current = null;
        _visible = false;
      });
      return;
    }
    setState(() {
      _current = _queue.removeAt(0);
      _visible = true;
    });
    _timer?.cancel();
    _timer = Timer(_current?.duration ?? widget.duration, _hideCurrent);
  }

  void _hideCurrent() {
    if (!mounted) {
      return;
    }
    setState(() => _visible = false);
    // wait for slide/fade out then show next
    _timer = Timer(const Duration(milliseconds: 220), _showNext);
  }

  @override
  Widget build(BuildContext context) {
    // Mantener métricas sincronizadas con el contexto
    if (context.mounted) {
      widget.responsive.setSizeFromContext(context);
    }

    final BlocResponsive r = widget.responsive;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final bool isMobile = r.isMobile;
    final double mh = r.marginWidth;
    final double gap = r.gutterWidth.clamp(8.0, 16.0);

    // Max width: full on mobile, clamped on large screens unless overridden.
    final double defaultMax =
        isMobile ? (r.workAreaSize.width - mh * 2) : r.widthByColumns(4);
    final double maxW = widget.maxWidthColumns != null
        ? r.widthByColumns(widget.maxWidthColumns!.clamp(1, r.columnsNumber))
        : defaultMax;

    // Placement
    final Alignment align =
        isMobile ? Alignment.bottomCenter : Alignment.topRight;
    final EdgeInsets outerPad = isMobile
        ? EdgeInsets.only(left: mh, right: mh, bottom: gap)
        : EdgeInsets.only(right: mh, top: gap);

    // Colors/icons per variant
    final _Palette p =
        _paletteFor(_current?.variant ?? AppSnackVariant.info, scheme);

    final Widget toast = _current == null
        ? const SizedBox.shrink()
        : Material(
            elevation: widget.elevation,
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
                    if (_current?.leadingIcon != null)
                      Padding(
                        padding: EdgeInsetsDirectional.only(end: gap * 0.75),
                        child:
                            Icon(_current!.leadingIcon, color: p.fg, size: 20),
                      ),
                    Flexible(
                      child: Text(
                        _current?.message ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: p.fg,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    if (_current?.actionLabel != null &&
                        _current?.onAction != null)
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: gap),
                        child: TextButton(
                          onPressed: () {
                            _current?.onAction?.call();
                            _hideCurrent();
                          },
                          child: Text(
                            _current!.actionLabel!,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: p.action),
                          ),
                        ),
                      ),
                    if (widget.dismissible)
                      IconButton(
                        tooltip: 'Close',
                        onPressed: _hideCurrent,
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

    final Widget animated = AnimatedSlide(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      offset: _visible ? Offset.zero : Offset(0, isMobile ? 0.5 : -0.5),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: _visible ? 1.0 : 0.0,
        child: toast,
      ),
    );

    final Widget body = Align(
      alignment: align,
      child: Padding(
        padding: outerPad,
        child: animated,
      ),
    );

    final Widget withSemantics = Semantics(
      liveRegion: true, // announce changes
      label: 'Notification',
      value: _current?.message,
      child: body,
    );

    return widget.safeArea ? SafeArea(child: withSemantics) : withSemantics;
  }

  _Palette _paletteFor(AppSnackVariant v, ColorScheme s) {
    switch (v) {
      case AppSnackVariant.info:
        return _Palette(
          bg: s.inverseSurface,
          fg: s.inverseSurface,
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
