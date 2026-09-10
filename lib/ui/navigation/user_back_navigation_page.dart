part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Observes the active projection only; PageManager still owns the stack.
class _UserBackRouteObserver extends NavigatorObserver {
  Route<dynamic>? top;

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    top = topRoute;
  }
}

/// Internal projection of the registry page; never owns navigation state.
class _UserBackNavigationPage extends Page<dynamic> {
  _UserBackNavigationPage(this.original, this.delegate)
      : super(
          key: original.key,
          name: original.name,
          arguments: original.arguments,
          restorationId: original.restorationId,
          canPop: original.canPop,
          onPopInvoked: original.onPopInvoked,
        );

  final Page<dynamic> original;
  final MyAppRouterDelegate delegate;

  @override
  Route<dynamic> createRoute(BuildContext context) {
    final Page<dynamic> page = original;
    if (page is MaterialPage<dynamic>) {
      return _UserBackMaterialRoute(this, page);
    }
    if (page is CupertinoPage<dynamic>) {
      return _UserBackCupertinoRoute(this, page);
    }
    if (page is DialogPage<dynamic>) {
      return _UserBackDialogRoute(this, context);
    }
    throw UnsupportedError(
      'UserBackNavigationPolicy requires MaterialPage, CupertinoPage or '
      'DialogPage from PageRegistry.toPage; received ${page.runtimeType}.',
    );
  }
}

mixin _UserBackRoute on ModalRoute<dynamic> {
  bool _approvedPop = false;
  bool _didLeave = false;

  bool _commitPop(dynamic result) {
    _approvedPop = true;
    _didLeave = false;
    try {
      navigator!.pop(result);
      return _didLeave;
    } finally {
      _approvedPop = false;
    }
  }

  @override
  bool didPop(dynamic result) {
    if (willHandlePopInternally) {
      return super.didPop(result);
    }
    if (_approvedPop) {
      return _didLeave = super.didPop(result);
    }
    final _UserBackNavigationPage page = settings as _UserBackNavigationPage;
    if (!page.delegate._protectsPage(page.key)) {
      // The application has already changed the model (including security resets).
      return super.didPop(result);
    }

    // Navigator.pop and Cupertino's gesture commit are synchronous. Refuse the
    // imperative removal first, then decide outside Navigator's locked update.
    final int generation = page.delegate._routeRequest;
    scheduleMicrotask(() {
      if (!isActive) {
        return;
      }
      // A cancelled Cupertino swipe must return fully to the active page.
      controller?.forward();
      if (generation != page.delegate._routeRequest ||
          !page.delegate._isTopPage(page.key)) {
        return;
      }
      page.delegate._requestNavigatorBack(this, result);
    });
    return false;
  }
}

Widget _guardedPageChild(BuildContext context) {
  final _UserBackNavigationPage page =
      ModalRoute.of(context)!.settings as _UserBackNavigationPage;
  final Page<dynamic> original = page.original;
  if (original is MaterialPage<dynamic>) {
    return original.child;
  }
  if (original is CupertinoPage<dynamic>) {
    return original.child;
  }
  return (original as DialogPage<dynamic>).builder(context);
}

class _UserBackMaterialRoute extends MaterialPageRoute<dynamic>
    with _UserBackRoute {
  _UserBackMaterialRoute(
    _UserBackNavigationPage page,
    MaterialPage<dynamic> original,
  ) : super(
          settings: page,
          builder: _guardedPageChild,
          maintainState: original.maintainState,
          fullscreenDialog: original.fullscreenDialog,
          allowSnapshotting: original.allowSnapshotting,
        );
}

class _UserBackCupertinoRoute extends CupertinoPageRoute<dynamic>
    with _UserBackRoute {
  _UserBackCupertinoRoute(
    _UserBackNavigationPage page,
    CupertinoPage<dynamic> original,
  ) : super(
          settings: page,
          builder: _guardedPageChild,
          title: original.title,
          maintainState: original.maintainState,
          fullscreenDialog: original.fullscreenDialog,
          allowSnapshotting: original.allowSnapshotting,
        );
}

class _UserBackDialogRoute extends DialogRoute<dynamic> with _UserBackRoute {
  _UserBackDialogRoute(_UserBackNavigationPage page, BuildContext context)
      : super(settings: page, context: context, builder: _guardedPageChild);
}
