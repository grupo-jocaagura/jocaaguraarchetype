part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Origin of a request to leave the current page through user navigation.
enum UserBackNavigationSource {
  /// A platform back request delivered through RouterDelegate.popRoute.
  system,

  /// A Navigator pop, including a committed iOS page back gesture.
  navigator,

  /// An incoming browser history entry or external route request.
  browserHistory,

  /// The library's PageAppBar or a custom control identifying itself as such.
  appBar,
}

/// Immutable context for an application-owned back navigation decision.
@immutable
class UserBackNavigationRequest {
  /// Describes one intention to leave [currentPage] through [source].
  const UserBackNavigationRequest({
    required this.source,
    required this.currentPage,
    this.targetPage,
  });

  /// The channel that initiated this back request.
  final UserBackNavigationSource source;

  /// The active application page when the request was captured.
  final PageModel currentPage;

  /// The proposed destination, or null for a request at the stack root.
  /// Browser destinations are parsed route descriptions; their application
  /// metadata may differ from the existing PageManager page.
  final PageModel? targetPage;
}

/// Return true to allow this request, or false to discard it.
///
/// The router performs the mutation. Policies must not pop the stack themselves.
/// Pending decisions are invalidated by stack/dependency changes or disposal.
/// Additional requests during a pending decision are discarded, never queued.
/// Exceptions reject the request and are reported through [FlutterError].
///
/// Unknown external history entries are checked conservatively; known forward
/// entries, initial routes and application-driven stack changes bypass this hook.
/// Local history is consumed by Flutter without consulting this policy, subject
/// to PopScope vetoes when using system back, PageAppBar or Navigator.maybePop.
///
/// Install a policy for the router's lifetime and change its returned decision.
/// Switching between null and a policy can recreate routes and their local state.
///
/// ```dart
/// void main() {
///   bool applicationIsBusy = true;
///   final UserBackNavigationPolicy policy =
///       (UserBackNavigationRequest request) => !applicationIsBusy;
///   final UserBackNavigationRequest request = UserBackNavigationRequest(
///     source: UserBackNavigationSource.system,
///     currentPage: const PageModel(name: 'details'),
///   );
///   assert(policy(request) == false);
///   applicationIsBusy = false;
///   assert(policy(request) == true);
/// }
/// ```
typedef UserBackNavigationPolicy = FutureOr<bool> Function(
  UserBackNavigationRequest request,
);
