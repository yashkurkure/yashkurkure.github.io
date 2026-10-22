# Notes

Conventions and design decisions for this repo, with the reasoning behind
them.

---

## App code in `lib/`, standalone libraries in `packages/`

```
website/
  pubspec.yaml            package "portfolio" (the Flutter site) + workspace list
  lib/                    the site's own code: pages, widgets, oneko overlay
  packages/
    cellular_automaton_zoo/
      pubspec.yaml        its own package: pure Dart, own dependencies
      lib/                what other code can import
      bin/main.dart       terminal CLI
      test/
```

### What a package is
In Dart, a **package** is a folder with its own `pubspec.yaml`. Its `lib/`
folder is its public code, imported as `package:<name>/...`. The website
is one package (`portfolio`); the Game of Life engine is another
(`cellular_automaton_zoo`).

### Why the Game of Life code is its own package, not in `lib/`
1. **Imports stay the same.** `bin/main.dart` imports
   `package:cellular_automaton_zoo/...`. Inside the website's `lib/` that
   would become `package:portfolio/...`, and the CLI would need editing.
2. **Separate dependencies.** The CLI needs `args`, and the tests use
   `package:test`. The website doesn't inherit dependencies it doesn't use.
3. **Pure Dart, no Flutter.** The package can't accidentally import
   widgets or `dart:ui`. So `dart run bin/main.dart` works in a terminal,
   and `dart test` runs in about a second without Flutter's test runner.
4. **One-way dependency.** The website uses the library; the library
   knows nothing about the website. It can later be published to pub.dev,
   moved to its own repo, or reused in another app unchanged.

### Why the folder is named `packages/`
Convention, not a requirement (`pkgs/` is also common). Flutter's own repo,
Melos, and most Dart repos with several packages use `packages/`.

### What makes it work: pub workspaces
The root `pubspec.yaml` has:

```yaml
workspace:
  - packages/cellular_automaton_zoo

dependencies:
  cellular_automaton_zoo:
    path: packages/cellular_automaton_zoo
```

and the package's `pubspec.yaml` has `resolution: workspace`. Result: one
`flutter pub get` at the root resolves everything into a single
`pubspec.lock`, and the app can
`import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';`.

To add a new package: create `packages/<name>/` with a `pubspec.yaml`
containing `resolution: workspace`, add its path to `workspace:` in the
root `pubspec.yaml`, then add it as a dependency if the app uses it.

### Rule of thumb
- **`lib/`**: code only the app uses (pages, widgets, theme, oneko).
  Splitting these into packages just adds setup.
- **`packages/`**: code with its own entry point (CLI), its own
  dependencies, or a life outside the app (reusable or publishable).

### Alternatives considered
- **`lib/game_of_life/` subfolder:** breaks the CLI's imports and adds
  `args` to the app.
- **Separate git repo as a git dependency:** two places to keep in sync
  for code that's developed alongside the site.
