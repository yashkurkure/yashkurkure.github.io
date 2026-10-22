# cellular_automaton_zoo

Pure-Dart cellular automata (Conway's Game of Life, rule B3/S23) with a
terminal CLI. No `dart:io` in `lib/`, so the same library is used by the CLI
and by the Flutter site.

Based on the CS378 Project 1 spec:
https://github.com/yashkurkure/CS378-Project1

## Layout

| File | Contents |
|---|---|
| `lib/src/cell.dart` | `Cell`: x/y coordinates with `==` and `hashCode` |
| `lib/src/grid.dart` | `Grid`: the board; live cells kept in a `Set<Cell>`, seeded random start, bounds checks, neighbor counting (no wrap-around) |
| `lib/src/cellular_automaton.dart` | `abstract class CellularAutomaton extends Grid`: `nextState`, `render`, and `step()` (computes the whole next generation, then applies it) |
| `lib/src/rules.dart` | `mixin ConwayRules`: B3/S23 |
| `lib/src/rendering.dart` | `mixin AsciiRenderable on Grid` (`#` / `.`), `mixin DecoratedRenderable on CellularAutomaton` (adds a `|`/`-` border around `super.render()`) |
| `bin/main.dart` | The CLI (unchanged from the project starter code) |

## Run

From this directory:

```sh
dart run bin/main.dart --species=conway --width=30 --height=15 --generations=100 --fps=8
dart test
```

Dependencies are resolved from the repo root (pub workspace), so
`flutter pub get` at the root is enough.
