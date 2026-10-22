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
