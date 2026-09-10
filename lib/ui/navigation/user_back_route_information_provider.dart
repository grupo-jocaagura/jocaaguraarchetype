part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Route information provider paired with [MyRouteInformationParser].
///
/// Tracks the browser cursor and each entry's target index, never a page stack.
/// Forward jumps apply the destination URI; they cannot restore intermediate
/// pages or domain state already discarded by PageManager. This provider does
/// not implement historical stack restoration or retain per-entry snapshots.
/// Rejected history entries are replaced with the router's current URL. This
/// keeps subsequent Back requests usable without queuing the rejected target.
/// Use this provider with a custom MaterialApp.router when supplying a
/// [UserBackNavigationPolicy] directly to [MyAppRouterDelegate].
class UserBackRouteInformationProvider
    extends PlatformRouteInformationProvider {
  /// Seeds the router from [initialRouteInformation]. Set [enabled] to false
  /// when no application back policy is installed.
  UserBackRouteInformationProvider({
    required RouteInformation initialRouteInformation,
    this.enabled = true,
  }) : super(
          initialRouteInformation: enabled
              ? _UserHistoryRouteInformation(
                  uri: initialRouteInformation.uri,
                  state: initialRouteInformation.state,
                )
              : initialRouteInformation,
        );

  /// Disable to retain PlatformRouteInformationProvider's legacy behavior.
  bool enabled;

  static const String _historyKey = '_jocaaguraUserHistory';
  final String _session = UniqueKey().toString();
  int _position = 0;
  bool _platformReportPending = false;

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    if (!enabled) {
      return super.didPushRouteInformation(routeInformation);
    }
    final Object? state = routeInformation.state;
    final Object? metadata =
        state is Map<Object?, Object?> ? state[_historyKey] : null;
    bool? backward;
    int? stackIndex;
    if (metadata is Map<Object?, Object?> && metadata['session'] == _session) {
      final Object? incoming = metadata['position'];
      final Object? targetIndex = metadata['stackIndex'];
      if (incoming is int) {
        backward = incoming < _position;
        _position = incoming;
        if (targetIndex is int) {
          stackIndex = targetIndex;
        }
      }
    }
    _platformReportPending = true;
    return super.didPushRouteInformation(
      _UserHistoryRouteInformation(
        uri: routeInformation.uri,
        state: routeInformation.state,
        backward: backward,
        stackIndex: stackIndex,
      ),
    );
  }

  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    if (!enabled) {
      super.routerReportsNewRouteInformation(routeInformation, type: type);
      return;
    }
    final bool replace = _platformReportPending ||
        type == RouteInformationReportingType.neglect ||
        (type == RouteInformationReportingType.none &&
            routeInformation.uri == value.uri);
    if (!replace) {
      _position++;
    }
    _platformReportPending = false;
    super.routerReportsNewRouteInformation(
      RouteInformation(
        uri: routeInformation.uri,
        state: <String, Object?>{
          'state': routeInformation.state,
          _historyKey: <String, Object?>{
            'session': _session,
            'position': _position,
            if (routeInformation is _UserHistoryRouteInformation)
              'stackIndex': routeInformation.stackIndex,
          },
        },
      ),
      type: replace
          ? RouteInformationReportingType.neglect
          : RouteInformationReportingType.navigate,
    );
  }
}

class _UserHistoryRouteInformation extends RouteInformation {
  const _UserHistoryRouteInformation({
    required super.uri,
    super.state,
    this.backward,
    this.stackIndex,
  });
  final bool? backward;
  final int? stackIndex;
}

class _UserHistoryStack extends NavStackModel {
  _UserHistoryStack(NavStackModel stack, this.backward, {this.stackIndex})
      : super._internal(stack.pages);

  final bool? backward;
  final int? stackIndex;
}
