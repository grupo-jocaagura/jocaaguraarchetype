part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Display a lightweight responsive notification overlay driven by a stream.
///
/// Positions the notification at the bottom center on mobile layouts and at
/// the top right on tablet and desktop layouts.
///
/// The notification exposes a live semantics region only while it is visible.
/// Its semantics bounds are limited to the visible notification so controls
/// outside the notification remain interactive.
///
/// A `null` snack or a snack with an empty message hides the notification and
/// does not expose a `Notification` semantics node.
///
/// The owner of [snacks] controls the notification lifecycle. When
/// [onDismissRequested] is invoked, the owner is responsible for emitting a
/// value that hides the current notification.
///
/// Place this widget inside a [Stack] when using it as an overlay.
///
/// Functional example:
///
/// ```dart
/// void main() {
///   runApp(const MaterialApp(home: SnackExample()));
/// }
///
/// class SnackExample extends StatefulWidget {
///   const SnackExample({super.key});
///
///   @override
///   State<SnackExample> createState() => _SnackExampleState();
/// }
///
/// class _SnackExampleState extends State<SnackExample> {
///   final StreamController<AppSnack?> _controller =
///       StreamController<AppSnack?>();
///   final BlocResponsive _responsive = BlocResponsive();
///
///   @override
///   void dispose() {
///     _controller.close();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     _responsive.setSizeFromContext(context);
///
///     return Scaffold(
///       body: Stack(
///         children: <Widget>[
///           Center(
///             child: ElevatedButton(
///               onPressed: () {
///                 _controller.add(AppSnack.info('Saved!'));
///               },
///               child: const Text('Show notification'),
///             ),
///           ),
///           MySnackBarWidget(
///             responsive: _responsive,
///             snacks: _controller.stream,
///             onDismissRequested: () {
///               _controller.add(null);
///             },
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
///
/// See [AppSnack] and [AppSnackVariant].
class MySnackBarWidget extends StatelessWidget {
  const MySnackBarWidget({
    required this.responsive,
    required this.snacks,
    super.key,
    this.maxWidthColumns,
    this.elevation = 8.0,
    this.dismissible = true,
    this.safeArea = true,
    this.onDismissRequested,
  });

  /// Adapt a legacy string stream to an [AppSnack] stream.
  ///
  /// Every emitted string is converted to an informational [AppSnack].
  ///
  /// An empty string produces a hidden notification because
  /// [MySnackBarWidget] only displays snacks with non-empty messages.
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
    final Stream<AppSnack?> mapped = toastStream.map<AppSnack?>(
      (String message) => AppSnack.info(message),
    );

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

  /// Provide responsive metrics used to size and position the notification.
  final BlocResponsive responsive;

  /// Provide the notifications to display.
  ///
  /// Emit `null` to hide the current notification.
  ///
  /// A snack whose message is empty is also treated as hidden.
  final Stream<AppSnack?> snacks;

  /// Limit the notification width using responsive layout columns.
  ///
  /// When `null`, the widget derives its maximum width from the current
  /// responsive layout.
  final int? maxWidthColumns;

  /// Set the Material elevation of the visible notification.
  final double elevation;

  /// Show the close button when dismissal is available.
  ///
  /// The close button is rendered only when this value is `true` and
  /// [onDismissRequested] is not `null`.
  final bool dismissible;

  /// Wrap the notification overlay in a [SafeArea] when `true`.
  final bool safeArea;

  /// Request dismissal of the current notification.
  ///
  /// This callback does not mutate [snacks]. The owner must update the stream
  /// to hide the notification, typically by emitting `null`.
  final VoidCallback? onDismissRequested;

  @override
  Widget build(BuildContext context) {
    final BlocResponsive r = responsive;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final bool isMobile = r.isMobile;
    final double marginWidth = r.marginWidth;
    final double gap = r.gutterWidth.clamp(8.0, 16.0);

    final double defaultMaxWidth = max(
      0.0,
      isMobile ? r.workAreaSize.width - (marginWidth * 2) : r.widthByColumns(4),
    );

    final double maxWidth = max(
      0.0,
      maxWidthColumns != null
          ? r.widthByColumns(
              maxWidthColumns!.clamp(1, r.columnsNumber),
            )
          : defaultMaxWidth,
    );

    final Alignment alignment =
        isMobile ? Alignment.bottomCenter : Alignment.topRight;

    final EdgeInsets outerPadding = isMobile
        ? EdgeInsets.only(
            left: marginWidth,
            right: marginWidth,
            bottom: gap,
          )
        : EdgeInsets.only(
            right: marginWidth,
            top: gap,
          );

    return StreamBuilder<AppSnack?>(
      stream: snacks,
      builder: (
        BuildContext context,
        AsyncSnapshot<AppSnack?> snapshot,
      ) {
        final AppSnack? snack = snapshot.data;
        final bool show = snack != null && snack.message.isNotEmpty;

        final _Palette palette = _paletteFor(
          snack?.variant ?? AppSnackVariant.info,
          scheme,
        );

        final Widget toast = !show
            ? const SizedBox.shrink()
            : Material(
                elevation: elevation,
                color: palette.bg,
                surfaceTintColor: palette.tint,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: EdgeInsets.all(gap),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (snack.leadingIcon != null)
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: gap * 0.75,
                            ),
                            child: Icon(
                              snack.leadingIcon,
                              color: palette.fg,
                              size: 20,
                            ),
                          ),
                        Flexible(
                          child: Text(
                            snack.message,
                            key: const ValueKey<String>('snack-text'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: palette.fg,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (snack.actionLabel != null && snack.onAction != null)
                          Padding(
                            padding: EdgeInsetsDirectional.only(start: gap),
                            child: TextButton(
                              onPressed: () {
                                snack.onAction?.call();
                                onDismissRequested?.call();
                              },
                              child: Text(
                                snack.actionLabel!,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: palette.action,
                                    ),
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
                              color: palette.fg.withValues(alpha: 0.85),
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
                  child: Semantics(
                    liveRegion: true,
                    label: 'Notification',
                    value: snack.message,
                    child: toast,
                  ),
                )
              : const SizedBox(
                  key: ValueKey<String>('snack-off'),
                ),
        );

        final Widget body = Align(
          alignment: alignment,
          child: Padding(
            padding: outerPadding,
            child: animated,
          ),
        );

        return safeArea ? SafeArea(child: body) : body;
      },
    );
  }

  _Palette _paletteFor(
    AppSnackVariant variant,
    ColorScheme scheme,
  ) {
    switch (variant) {
      case AppSnackVariant.info:
        return _Palette(
          bg: scheme.inverseSurface,
          fg: scheme.onInverseSurface,
          action: scheme.inversePrimary,
          tint: scheme.inverseSurface,
        );
      case AppSnackVariant.success:
        return _Palette(
          bg: scheme.tertiaryContainer,
          fg: scheme.onTertiaryContainer,
          action: scheme.tertiary,
          tint: scheme.tertiaryContainer,
        );
      case AppSnackVariant.warning:
        return _Palette(
          bg: scheme.secondaryContainer,
          fg: scheme.onSecondaryContainer,
          action: scheme.secondary,
          tint: scheme.secondaryContainer,
        );
      case AppSnackVariant.error:
        return _Palette(
          bg: scheme.errorContainer,
          fg: scheme.onErrorContainer,
          action: scheme.error,
          tint: scheme.errorContainer,
        );
    }
  }
}

/// Describe a notification displayed by [MySnackBarWidget].
///
/// Use [AppSnack.info], [AppSnack.success], [AppSnack.warning], or
/// [AppSnack.error] to create common notification variants.
///
/// [duration] is notification metadata only. [MySnackBarWidget] does not
/// schedule automatic dismissal; the owner of the notification stream remains
/// responsible for its lifecycle.
class AppSnack {
  const AppSnack({
    required this.message,
    this.variant = AppSnackVariant.info,
    this.actionLabel,
    this.onAction,
    this.leadingIcon,
    this.duration,
  });

  /// Create an informational notification.
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

  /// Create a success notification.
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

  /// Create a warning notification.
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

  /// Create an error notification.
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

  /// Provide the notification message.
  final String message;

  /// Define the visual notification variant.
  final AppSnackVariant variant;

  /// Provide the optional label for the primary action.
  ///
  /// The action is displayed only when both [actionLabel] and [onAction] are
  /// provided.
  final String? actionLabel;

  /// Handle activation of the optional primary action.
  final VoidCallback? onAction;

  /// Provide an optional leading icon.
  final IconData? leadingIcon;

  /// Describe the preferred notification display duration.
  ///
  /// [MySnackBarWidget] does not automatically dismiss notifications based on
  /// this value.
  final Duration? duration;
}

/// Define the visual style of an [AppSnack].
enum AppSnackVariant {
  info,
  success,
  warning,
  error,
}

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
