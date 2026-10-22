# Progress Log

Notes only — Claude's record of where we are. Nothing here is used by the
project.

## Checkpoint — 2026-10-21 (commit `1f5b419` "Oneko port start", pushed)

### Done
- Flutter 3.47.3 web project (`portfolio` package), Hello World page.
- Deployed to https://yashkurkure.github.io via GitHub Actions
  (`.github/workflows/deploy.yml`, triggers on `master`, `--wasm` build).
  Pages source = GitHub Actions. Old WordPress site backed up in tag
  `old-wordpress-site`.
- Site metadata: title "Yash's Portfolio" in `web/index.html`,
  `web/manifest.json`, `MaterialApp.title`. README rewritten.
- Oneko port, step 1 written:
  - `assets/images/oneko.png` (256×128, 8×4 frames of 32px), registered
    in `pubspec.yaml`.
  - `lib/oneko/oneko_overlay.dart`: `OnekoOverlay` StatelessWidget,
    Stack + Positioned(16,16) + IgnorePointer + ClipRect + OverflowBox +
    Transform.translate showing idle frame (3,3).
  - Mounted via `MaterialApp(builder: (context, child) => OnekoOverlay(child: child!))`.
  - `oneko_controller.dart`, `oneko_sprites.dart`: empty placeholders.
  - `flutter analyze` clean, `flutter test` passes.

## Checkpoint — 2026-10-22 (uncommitted)

### Done (one-time exception: Claude wrote this code at Yash's request)
- `packages/cellular_automaton_zoo/`: pure-Dart implementation of the
  CS378 Project 1 spec (github.com/yashkurkure/CS378-Project1). Cell,
  Grid (Set<Cell> of live cells), CellularAutomaton.step (double buffer),
  ConwayRules, AsciiRenderable on Grid, DecoratedRenderable on
  CellularAutomaton. `bin/main.dart` copied unchanged and runs.
  16 tests in `test/`, all passing.
- Root `pubspec.yaml`: `workspace: [packages/cellular_automaton_zoo]` +
  path dependency, so the Flutter app can `import
  'package:cellular_automaton_zoo/cellular_automaton_zoo.dart'`.
- CI: added `dart test` step for the package.
- Flagged: this is a full solution to a course assignment Yash authored;
  the website repo is public. Yash decides whether to push.

### Status 2026-10-22 (later): steps 1–3 done
Committed through `60fd095`. Yash's naming differs from the plan: route
`/conway`, `ConwayPage` in `lib/pages/conway.dart`, files
`lib/conway/game.dart` (ConwayLife), `grid_view.dart` (GridViewBoard),
`painter.dart` (PaintedBoard/LifePainter), `lib/pages/not_found.dart`
(all empty). Uncommitted: explanatory comments in `router.dart`,
`main.dart`. Now on step 4a.

### Next: routes + Game of Life (Yash writes the code)
Yash asked for the whole plan up front: `claude/ROUTES_AND_LIFE.md`
(7 steps with checkpoints). Not started as of 2026-10-22.
Yash wants GridView first, then CustomPainter / faster methods.
1. go_router, `/` and `/life`.
2. Oneko only on some pages: move `OnekoOverlay` from
   `MaterialApp.builder` into a `ShellRoute`; `/life` sits outside it.
3. Buttons: `context.go('/life')`, explicit back arrow on LifePage.
4. LifePage with `GridViewBoard` (one ColoredBox per cell), `ConwayLife`
   composition, `Timer.periodic`, Play/Pause/Step/New board, `dispose`.
5. `PaintedBoard` + `LifePainter`; SegmentedButton toggles renderers;
   compare with `showPerformanceOverlay` at 150×100.
6. Optional speedups: painter `repaint:` ValueNotifier (no page
   setState), RepaintBoundary, single Path, Ticker, Uint8List in library.
7. `usePathUrlStrategy`, `NotFoundPage` via `errorBuilder`.

## Earlier

### Not yet confirmed
- Whether the static cat actually appears in the top-left in Chrome
  (step 1 visual check). Ask first thing next session.

### Next
1. Confirm step 1 visually; debug if needed.
2. Step 2: cat knows where the mouse is (`StatefulWidget`, `Listener`
   with `HitTestBehavior.translucent`, `onPointerHover`; print positions).
3. Step 3: `Timer.periodic(100ms)` + chase movement + direction sprites
   (move sprite table into `oneko_sprites.dart`, logic into
   `oneko_controller.dart`).
4. Step 4: alert delay, idle animations (sleep, scratch, wall scratch).
5. Step 5: reduced motion + touch devices; controller unit tests.
Full spec: `claude/ONEKO.md`. After oneko: portfolio milestone 1
(`claude/PORTFOLIO_PLAN.md`).

### Open learning questions (from Yash's code comments)
Explain these as they come up, ideally before step 2:
- What is `super.key`? (`oneko_overlay.dart`)
- Stack, IgnorePointer, ClipRect, OverflowBox, Transform, Image /
  how image assets work.
- `MaterialApp.builder` — answered in chat; the TODO on
  `lib/main.dart:16` can be replaced with a short comment.

### Side topics parked
- University LiteLLM endpoint (`https://sage200.evl.uic.edu`,
  OpenAI-compatible, model `gemma4`) for use in VS Code via
  Continue/Cline/Copilot BYOK. User hasn't run the curl checks yet.

### How we work
User writes all code. Claude explains one step at a time, user runs it,
debug together. Claude only writes inside `claude/`.
