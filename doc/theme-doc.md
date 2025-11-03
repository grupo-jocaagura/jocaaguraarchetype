# Theme Reactive Flow — `BlocTheme` (Dart/Flutter, no external packages)

This guide shows how to **implement** and **test** a reactive theming pipeline using:
- **Reactive bus**: `ServiceThemeReact`
- **Gateway**: `GatewayThemeReactImpl` (normalization + smoke tests)
- **Resilient repository**: `RepositoryThemeReactImpl` (absorbs malformed JSON)
- **Use cases**: `ThemeUsecases`, `WatchTheme`
- **Bloc**: `BlocThemeReact`
- **Materialization**: `BuildThemeData`

All using **SDK/Dart/Flutter only**, with `Either<ErrorItem, T>` for error handling.

---

## 1) Overview

The pipeline publishes raw theme JSON into a **bus**, **normalizes/validates** it in the **gateway**, **translates** it to `ThemeState` in the **repository**, and the **Bloc** consumes updates to refresh the UI.

```
UI → Usecases → RepositoryTheme(React) ↔ GatewayThemeReactImpl ↔ ServiceThemeReact(bus)
↑                                     ↑
BuildThemeData                           Fake/Real Service
```

### Event Flow (high-level)

```
[User Action]
└─► Usecase (read → transform → save)
├─► repo.read()  ─► ThemeState
├─► transform(s) ─► ThemeState'
└─► repo.save(ThemeState')
└─► gateway.write(json normalized)
└─► service.updateTheme(json)
└─► stream emits (raw)
gateway.watch() ─(normalize+smoke)─► Right(json') ─► repo.watch() ─(fromJson)─► Right(ThemeState)
└─► BlocThemeReact._apply(Either)
```

---

## 2) Key Contracts

- **ServiceThemeReact**
- Publishes **raw JSON** (shape not validated here).
- **GatewayThemeReactImpl**
- **Normalizes**: `mode`, `seed` (int/HEX/Color), `useM3` default `true`, `textScale` clamp `[0.8, 1.6]`, `preset` default `'brand'`, `overrides`/`textOverrides` as Map or domain objects.
- **Smoke test**: builds `ThemeState` and calls `ServiceTheme.lightTheme/darkTheme`.
- Returns `Either<ErrorItem, Map<String, dynamic>>` for `read/write/watch`.
- **RepositoryThemeReactImpl (resilient)**
- Translates `Map → ThemeState` and **absorbs malformed JSON** (maps to `Left` via `ErrorMapper`).
- `watch()` emits `Either<ErrorItem, ThemeState>` and **does not close** on errors.
- **ThemeUsecases**
- Mutations follow `read → transform → save` (**last write wins**).
- `SetTextScale` clamps `[0.8, 1.6]`; `RandomizeTheme` uses `ServiceTheme.colorRandom()`.
- **BlocThemeReact**
- Subscribes to `WatchTheme()` in the constructor and forwards each event to `_apply`.
- `dispose()` cancels the subscription (non-blocking) and calls `super.dispose()`.

---

## 3) Recommended Wiring

### 3.1 Reactive bus (demo/dev)

```dart
final FakeServiceThemeReact service = FakeServiceThemeReact(
autoStart: false, // you can auto-toggle light/dark if desired
);
```

### 3.2 Gateway

```dart
final GatewayThemeReact gateway = GatewayThemeReactImpl(
service: service,
// Optional: inject a real ServiceTheme
themeService: const FakeServiceJocaaguraArchetypeTheme(),
);
```

### 3.3 Resilient repository

```dart
final RepositoryThemeReact repoReact = RepositoryThemeReactImpl(
gateway: gateway,
errorMapper: const DefaultErrorMapper(), // optional
);
```

### 3.4 Use cases

```dart
final RepositoryTheme repo = repoReact; // implements both RepositoryTheme & RepositoryThemeReact
final ThemeUsecases uc = ThemeUsecases.fromRepo(
repo,
serviceTheme: const FakeServiceJocaaguraArchetypeTheme(),
);
```

### 3.5 Reactive Bloc

```dart
final BlocThemeReact bloc = BlocThemeReact(
themeUsecases: uc,
watchTheme: WatchTheme(repoReact),
);
```

> Cleanup: call `bloc.dispose()` (and `service.dispose()` if applicable).

---

## 4) Typical UI usage (Flutter)

```dart
class MyThemedApp extends StatefulWidget {
const MyThemedApp({super.key});
@override
State<MyThemedApp> createState() => _MyThemedAppState();
}

class _MyThemedAppState extends State<MyThemedApp> {
late final FakeServiceThemeReact service;
late final GatewayThemeReactImpl gateway;
late final RepositoryThemeReactImpl repo;
late final ThemeUsecases uc;
late final BlocThemeReact bloc;
late ThemeData _themeData;

@override
void initState() {
super.initState();
service = FakeServiceThemeReact();
gateway = GatewayThemeReactImpl(service: service);
repo = RepositoryThemeReactImpl(gateway: gateway);
uc = ThemeUsecases.fromRepo(repo);
bloc = BlocThemeReact(themeUsecases: uc, watchTheme: WatchTheme(repo));

_themeData = uc.buildThemeData.fromState(ThemeState.defaults);
}

@override
void dispose() {
bloc.dispose();
service.dispose();
super.dispose();
}

Future<void> _toggleDark() async {
await uc.setMode(ThemeMode.dark);
final Either<ErrorItem, ThemeState> r = await uc.load();
r.fold(
(e) => debugPrint('Error: $e'),
(s) => setState(() => _themeData = uc.buildThemeData.fromState(s)),
);
}

@override
Widget build(BuildContext context) {
return MaterialApp(
theme: _themeData,
home: Scaffold(
appBar: AppBar(title: const Text('Reactive Theme')),
floatingActionButton: FloatingActionButton(
onPressed: _toggleDark,
child: const Icon(Icons.dark_mode),
),
body: const Center(child: Text('Hello!')),
),
);
}
}
```

> If your `BlocTheme` already exposes notifications for UI, wire your widget to that mechanism instead of manually re-building with `setState`.

---

## 5) Error Handling with `Either`

- **Do not throw** from use cases; return `Left<ErrorItem, T>`.
- Gateway maps normalization/smoke-test exceptions to `Left`.
- Resilient repository catches `ThemeState.fromJson` errors and maps to `Left` with `ErrorMapper`.
- Bloc forwards `Left` to `_apply` (stream stays open).

**Example**
```
final Either<ErrorItem, ThemeState> res = await uc.setTextScale(2.5); // clamp → 1.6
res.fold(
(err) => debugPrint('Error: $err'),
(state) => applyTheme(uc.buildThemeData.fromState(state)),
);
```

---

## 6) Concurrency

Mutations are `read → transform → save` and **not transactional**. If simultaneous updates occur, **last write wins**. For critical flows, serialize calls at the UI or introduce optimistic/versioned saves at repository level.

---

## 7) Testing Checklist (≥90% coverage)

- **Service/FakeService**
- Initial emission, `ensureMode`, `textOverrides` non-destructive merge, auto-toggle start/stop/restart, defensive copies.
- **Gateway**
- Normalize: `mode`, `seed` (int/hex/Color + invalid→default), `textScale` clamp, `preset`, `useM3` default, `overrides`/`textOverrides` Map/object.
- Smoke test success/failure; error mapping with `location`.
- `watch()` yielding `Right/Left`.
- **Repository (resilient)**
- Well-formed Map → `Right(ThemeState)`.
- Malformed Map → `Left(ErrorItem)` with correct `location` (`read/save/watch`).
- Propagate gateway `Left` unchanged.
- **Usecases**
- `SetMode/Seed/ToggleM3/ApplyPreset/SetTextScale` (clamp), `ApplyPatch`, `SetFromState`, `Reset`, `Randomize`, `SetTextThemeOverrides` (set/clear), `WatchTheme` `Right/Left`.
- **BuildThemeData**
- Overrides light/dark, `1.0`/`NaN` factors, null fontSize not scaled, `visualDensity` standard.
- **BlocThemeReact**
- Subscribes on construct, cancels on `dispose` (idempotent), tolerates `Right/Left` events.

---

## 8) Best Practices

- **Immutability**: avoid mutating input maps in gateway (copy before applying defaults).
- **Seed format**: pick one canonical output (`int ARGB32` or `#AARRGGBB`) and document it.
- **Null-safety**: avoid `!` unless guaranteed by contract.
- **ErrorItem**: include `location` for traceability (e.g., `GatewayThemeReactImpl.write`).
- **Pure transforms**: keep use case transforms side-effect free; repository handles IO.

---

## 9) Quick Reference Snippets

**Toggle M3**
```
final res = await uc.toggleM3();
res.fold(debugPrint, (s) => applyTheme(uc.buildThemeData.fromState(s)));
```

**Apply Patch**
```
final patch = ThemePatch(textScale: 1.2, mode: ThemeMode.dark);
final res = await uc.applyPatch(patch);
```

**Set/Clear TextThemeOverrides**
```
await uc.setTextThemeOverrides(TextThemeOverrides(
light: const TextTheme(bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Inter')),
));
await uc.setTextThemeOverrides(null); // clear
```

---

## 10) Definition of Done (DoD)

- [ ] Wiring completed (`ServiceThemeReact` → `Gateway` → `Repository` → `Usecases` → `BlocThemeReact`).
- [ ] `BuildThemeData` integrated.
- [ ] Tests ≥90% lines and critical branches covered.
- [ ] `dart analyze` clean (or justified).
- [ ] Errors mapped as `Left` with consistent `location`.
- [ ] Seed format/clamps documented.

---

**Happy theming!**
