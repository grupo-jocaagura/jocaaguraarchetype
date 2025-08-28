
# JocaaguraArchetype

> ⚠️ **Heads-up:** Documentation is in progress. We’re migrating cross-cutting concerns to [`jocaagura_domain`](https://pub.dev/packages/jocaagura_domain).  
> This archetype stays available as a UI shell and app scaffold. Expect incremental updates.

---

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  // Dev profile: in-memory gateways, fake services, and debug flags on.
  final AppConfig config = AppConfig.dev();

  // Minimal page registry
  final PageRegistry registry = PageRegistry(
    routes: <String, WidgetBuilder>{
      '/': (_) => const MyDemoHomePage(),
      '/onboarding': (_) => const OnboardingPage(steps: <Widget>[], onFinish: null),
    },
    notFoundBuilder: (_) => const Page404Widget(),
  );

  runApp(
    JocaaguraApp.dev(
      config: config,
      registry: registry,
    ),
  );
}
````

### Toggle theme (example)

```dart
void main() async{
// Somewhere in the UI:
  final AppManager app = AppManagerProvider.of(context);

// App-level actions via ThemeUsecases:
  await app.themeUsecases.toggleMaterial3();
  await app.themeUsecases.setSeedColor(const Color(0xFF6750A4));
  await app.themeUsecases.setMode(ThemeMode.dark);
}
```

---

## Architecture

We follow Clean Architecture aligned with `jocaagura_domain`:

```
UI → AppManager → Bloc → UseCase → Repository → Gateway → Service
```

* **BLoCs** use `BlocGeneral<T>` from `jocaagura_domain`.
* **Theme**: `ThemeUsecases` + `RepositoryTheme` + `GatewayTheme` + `ServiceJocaaguraArchetypeTheme`.

Refer to the structure guide:
[https://github.com/grupo-jocaagura/jocaagura\_domain/raw/refs/heads/develop/README\_STRUCTURE.md](https://github.com/grupo-jocaagura/jocaagura_domain/raw/refs/heads/develop/README_STRUCTURE.md)

---

## Lints and style

We adopt the shared rules:
[https://github.com/grupo-jocaagura/jocaagura\_domain/raw/refs/heads/develop/analysis\_options.yaml](https://github.com/grupo-jocaagura/jocaagura_domain/raw/refs/heads/develop/analysis_options.yaml)

* Prefer explicit types in locals (`final List<T> items = <T>[];`).
* Avoid `print`/`debugPrint` in production code; use an injected logger.

---

## Contributing & CI

Branch strategy:

* `develop` for day-to-day work (PR-only).
* `master` for releases (merge from `develop`).

Recommended workflows:

* Validate PR to develop:
  [https://github.com/grupo-jocaagura/jocaagura\_domain/raw/refs/heads/develop/.github/workflows/validate\_pr.yaml](https://github.com/grupo-jocaagura/jocaagura_domain/raw/refs/heads/develop/.github/workflows/validate_pr.yaml)
* Validate PR to master:
  [https://github.com/grupo-jocaagura/jocaagura\_domain/raw/refs/heads/develop/.github/workflows/validate\_pr\_master.yaml](https://github.com/grupo-jocaagura/jocaagura_domain/raw/refs/heads/develop/.github/workflows/validate_pr_master.yaml)

Security & quality:

* CodeQL for `develop` and `master`.
* Signed commits enforced (GitHub bot setup).

> Full docs are being completed. We’ll expand with more samples (routing, PageBuilder, responsive widgets) soon.

---

## License

MIT (c) Jocaagura
