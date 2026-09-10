# Application-owned user back navigation

Pass an optional `userBackNavigationPolicy` to `JocaaguraApp`,
`JocaaguraApp.dev`, `JocaaguraAppWithSession` or its `.dev` factory:

```dart
JocaaguraApp(
  appManager: app,
  registry: registry,
  userBackNavigationPolicy: (request) => !applicationIsBusy,
);
```

The callback receives a `UserBackNavigationRequest` with `source`,
`currentPage` and an optional `targetPage`. Return `bool` or `Future<bool>`.
Return `false` to discard the request. Return `true` to let the router perform
the navigation; the callback must not call `pop` itself.

## Contract

- With no policy, existing navigation retains its behavior and timing.
- System/Android back, Navigator pop, Material/Cupertino iOS gestures and the
  library's `PageAppBar` pass through the policy before changing `PageManager`.
- A rejected `popRoute` returns `true`: the event was consumed, so it must not
  fall through to application exit. This is distinct from `PageManager.pop()`.
- `PageManager.canPop` continues to describe stack structure only.
- Local history (for example a `LocalHistoryEntry`) is consumed by Flutter
  before leaving a page, subject to Flutter's `popDisposition`. A `PopScope`
  veto also retains local history. Closing allowed internal state does not
  consult the application policy or pop a page. `Page.canPop: false` alone
  still permits consuming local history, following Flutter's own rules.
- With a policy installed, system back and `PageAppBar` respect Flutter's
  `PopScope` and `Page.canPop` before consulting the application policy, and
  check them again after async approval. A Flutter veto consumes the request
  and reports `didPop: false`. Without a policy, legacy behavior is unchanged.
  `Navigator.maybePop` keeps Flutter's own veto behavior; explicit
  `Navigator.pop` keeps its imperative semantics, subject to the application
  policy. Incoming browser routes are decided by the application policy.
- An approved `Navigator.pop(result)` completes the original route and its pop
  callback with that result, then reconciles `PageManager` exactly once.
  Rejected and invalidated requests never deliver their result to another pop.
- Additional requests while a decision is pending are discarded. Rejected
  requests are not retried when application state changes.
- Changing the stack, manager, registry, policy, or disposing the delegate
  invalidates pending decisions. Session/security resets take precedence.
- Exceptions reject the request and are reported through `FlutterError`.
- `PageManager` mutations and the delegate's synchronous `pop()` remain
  programmatic operations. Use them for application-driven reset/replacement;
  use `requestUserBack()` for custom user back controls.

The guarded routes retain the current page until approval. A Cupertino swipe
that reaches its commit point is first cancelled back to that page; approval
then completes the Navigator pop and reconciles the model. Rejection leaves the route active.
This does not promise a predictive transition while an asynchronous decision
is unresolved.

## Custom router setup

When constructing `MaterialApp.router` directly, use all three components:

```dart
final delegate = MyAppRouterDelegate(
  registry: registry,
  pageManager: app.pageManager,
  userBackNavigationPolicy: (request) => !applicationIsBusy,
);
final provider = UserBackRouteInformationProvider(
  initialRouteInformation: RouteInformation(uri: Uri.parse('/home')),
);

MaterialApp.router(
  routerDelegate: delegate,
  routeInformationParser: const MyRouteInformationParser(),
  routeInformationProvider: provider,
);
```

Dispose the delegate and provider with the owning widget. When changing the
optional delegate policy dynamically, also set `provider.enabled` accordingly.
The high-level app wrappers do this automatically.

Install the policy for the lifetime of the router and change the decision it
returns instead of repeatedly enabling and disabling it. Replacing a non-null
policy preserves the page routes and widget state. Switching `null → policy`
or `policy → null` changes the projected Page type and can recreate routes,
losing their local widget state; stack contents are retained. State preservation
across those null transitions is not part of this API's contract.
Re-supplying an equal method tear-off from the same instance does not change
the policy or invalidate a pending decision. A different receiver or a new,
unequal closure is a policy change.

The provider stores a history position, session marker and target stack index
in the browser entry state. The page stack remains exclusively in `PageManager`. The parser
preserves the full URI (including query and fragment) for these provider events.
Known forward entries bypass the policy. Entries without recognized metadata
(including history predating this provider) are conservatively checked, since
their direction cannot be established from a URL alone.

For recognized entries whose indexed destination is still present, the target
index distinguishes repeated URIs, including same-URI entries explicitly created
with `Router.navigate`. If that index is unavailable or no longer matches after
an application stack change, navigation falls back to the last matching URI.
Old or foreign entries cannot identify a particular occurrence of a repeated URI.

### Multi-entry Forward limitation

Browser history is not a saved copy of the application stack. After Back has
discarded pages, a Forward jump across several entries applies the destination
URI to the current stack; it does not reconstruct skipped pages or their domain
state. For example, `[home, a, b, c] → Back to a → Forward directly to c`
produces `[home, a, c]`. The active page and URL agree, but the former stack
structure is not restored. Subsequent navigation to a discarded destination
uses normal route application when no matching page exists in PageManager.

Adjacent Forward visits can rebuild the visited destinations in order, but do
not promise restoration of discarded domain metadata. Full historical stack
restoration, including `history.go(n)` jumps, is outside this adapter's contract.
No per-entry stack snapshots are retained, preserving the single-stack design.

On rejection, the current history entry is **replaced** with the current
application URL. No rejected destination is queued, and no extra history entry
is pushed to restore the URL. The rejected entry's former URL is consequently
overwritten; subsequent Back uses the preceding browser entry. The policy
covers in-application history delivered to Flutter, not closing a tab or leaving
the document for another site.

The standard `PageRegistry` Material, Cupertino, full-screen and dialog pages
are supported without changing `toPage` or adding feature guards. A custom
registry returning a different `Page` type must provide a compatible page when
opting into this policy; unsupported types fail explicitly rather than silently
bypassing the guard. Forced imperative `Navigator.removeRoute`/replacement
operations are not user back events; application stack changes should go through
`PageManager` so the model and its projection remain consistent.

## Example

From `example/`, run:

```sh
flutter run -d chrome -t lib/user_back_navigation_example.dart
```

Open the next pages with the switch enabled. Try Back in the UI and browser,
then disable the switch and make a new Back request. The reset button works in
both states. On iOS, the same example also exercises the page back gesture.
