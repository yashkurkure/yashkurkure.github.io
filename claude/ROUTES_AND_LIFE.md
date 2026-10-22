# Routes + Game of Life — Full Guide

You type everything below into the real project. Each step ends with a
checkpoint: run it, check it, commit, then move on. If something breaks,
stop there and we debug it together.

Where we end up:

```
MaterialApp.router ──▶ GoRouter
                        ├─ ShellRoute (OnekoOverlay)      ← cat lives here
                        │    └─ "/"      HomePage
                        ├─ "/life"       LifePage          ← outside the shell: no cat
                        └─ errorBuilder  NotFoundPage
```

```
lib/
  main.dart                 MaterialApp.router (no more builder:)
  app/router.dart           all routes in one place
  pages/home_page.dart
  pages/life_page.dart      the Game of Life screen
  pages/not_found_page.dart
  life/conway_life.dart     composes the library's mixins
  life/grid_view_board.dart step 4: one widget per cell (simple, slow)
  life/painted_board.dart   step 5: one CustomPainter for the whole board (fast)
  oneko/...                 unchanged
```

---

## Step 1 — Two pages, two URLs

**Concept.** A *route* maps a URL path to a page. `GoRouter` holds the
list of routes; `MaterialApp.router` asks it which page to show for the
current URL, instead of using `home:`.

### 1a. Add the package
```sh
flutter pub add go_router
```

### 1b. `lib/pages/home_page.dart`
```dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Hello, world!')),
    );
  }
}
```

### 1c. `lib/pages/life_page.dart` (placeholder for now)
```dart
import 'package:flutter/material.dart';

class LifePage extends StatelessWidget {
  const LifePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conway's Game of Life")),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
```

### 1d. `lib/app/router.dart`
```dart
import 'package:go_router/go_router.dart';
import 'package:portfolio/pages/home_page.dart';
import 'package:portfolio/pages/life_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/life', builder: (context, state) => const LifePage()),
  ],
);
```

### 1e. `lib/main.dart`
- `import 'package:portfolio/app/router.dart';`
- `MaterialApp(` → `MaterialApp.router(`
- delete the `home: const Scaffold(...)` block
- add `routerConfig: router,`
- keep `builder:` for now (step 2 moves it)

### ✅ Checkpoint 1
```sh
flutter run -d chrome
```
- "Hello, world!" + cat in the corner.
- Add `#/life` to the URL → "Conway's Game of Life" app bar.
  (The cat is still there — fixed in step 2.)
- Browser Back → Hello World.
- `flutter analyze && flutter test` pass.
- `git commit -am "Add go_router with / and /life"` (add `git add lib` first
  for the new files).

---

## Step 2 — Keep the cat off the Game of Life page

**Concept.** `MaterialApp.builder` wraps *every* page, so it can't leave
one out. A `ShellRoute` wraps only the routes listed inside it. Put the
pages that should have the cat inside the shell, and `/life` outside it.

### 2a. `lib/main.dart`
Delete the `builder: (context, child) => OnekoOverlay(child: child!),`
line and the `oneko_overlay.dart` import. Final file:

```dart
import 'package:flutter/material.dart';
import 'package:portfolio/app/router.dart';

void main() => runApp(const PortfolioApp());

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Yash\'s Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      routerConfig: router,
    );
  }
}
```

### 2b. `lib/app/router.dart`
```dart
import 'package:go_router/go_router.dart';
import 'package:portfolio/oneko/oneko_overlay.dart';
import 'package:portfolio/pages/home_page.dart';
import 'package:portfolio/pages/life_page.dart';

final router = GoRouter(
  routes: [
    // Pages inside the shell get the oneko cat on top.
    ShellRoute(
      builder: (context, state, child) => OnekoOverlay(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
      ],
    ),
    // Pages outside the shell don't, so the cat never covers the board.
    GoRoute(path: '/life', builder: (context, state) => const LifePage()),
  ],
);
```

Notice `child` instead of `child!`: ShellRoute's `child` is never null.

### ✅ Checkpoint 2
- `/` → cat visible. `#/life` → **no cat**. Back → cat again.
- `flutter analyze && flutter test` pass. Commit.

---

## Step 3 — Navigate with buttons

**Concept.** `context.go('/life')` changes the URL; the router rebuilds
the matching page. It's an extension method from go_router, so files
that call it need `import 'package:go_router/go_router.dart';`.

### 3a. `HomePage`: button to the game
Replace the `body:` with:
```dart
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hello, world!'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/life'),
              child: const Text("Play Conway's Game of Life"),
            ),
          ],
        ),
      ),
```
Drop the `const` before `Scaffold` (the button's callback isn't const).

### 3b. `LifePage`: back button to home
`/life` isn't nested under `/`, so the AppBar won't add a back arrow by
itself. Give it one:
```dart
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Home',
          onPressed: () => context.go('/'),
        ),
        title: const Text("Conway's Game of Life"),
      ),
```

### ✅ Checkpoint 3
- Click the button → game page, URL ends in `#/life`, no cat.
- Click the arrow → home, cat back.
- Browser Back/Forward also work. Commit.

---

## Step 4 — Game of Life with GridView

**Concept.** The library already runs the simulation. The page only has
to (1) hold one simulation object, (2) call `step()` on a timer, and
(3) draw the board. In this step the board is a `GridView`: **one small
widget per cell**, colored by `isAlive`. It's the most straightforward
way to draw a grid in Flutter, and a good baseline to measure against.

| Piece | Job |
|---|---|
| `ConwayLife` | A concrete automaton: the library's classes and mixins composed together |
| `GridViewBoard` | Draws the board as a `GridView` of colored boxes |
| `_LifePageState` | Owns the simulation and the `Timer`; Play/Pause, Step, New board |

The board is its own widget that takes `sim`, so in step 5 you can swap
in a different renderer without touching the rest of the page.

### 4a. `lib/life/conway_life.dart`
Same composition as the CLI's `Conway` class. `AsciiRenderable` is there
because `CellularAutomaton` requires a `render()`; the page doesn't use it.
```dart
import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';

class ConwayLife extends CellularAutomaton with ConwayRules, AsciiRenderable {
  ConwayLife({required super.width, required super.height, required super.seed});
}
```

### 4b. `lib/life/grid_view_board.dart`
```dart
import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';
import 'package:flutter/material.dart';

/// Draws [sim] as a GridView with one colored box per cell.
class GridViewBoard extends StatelessWidget {
  const GridViewBoard({super.key, required this.sim});

  final CellularAutomaton sim;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GridView.builder(
      // The board fits on screen; it shouldn't scroll.
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: sim.width,
      ),
      itemCount: sim.width * sim.height,
      itemBuilder: (context, index) {
        // GridView counts cells 0, 1, 2, ... row by row.
        // Turn that index back into a column (x) and row (y).
        final cell = Cell(x: index % sim.width, y: index ~/ sim.width);
        return ColoredBox(
          color: sim.isAlive(cell) ? colors.primary : colors.surfaceContainerHighest,
        );
      },
    );
  }
}
```

### 4c. `lib/pages/life_page.dart` (replace the placeholder)
It becomes a `StatefulWidget`, because it holds things that change: the
simulation and whether the timer is running.

```dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/life/conway_life.dart';
import 'package:portfolio/life/grid_view_board.dart';

class LifePage extends StatefulWidget {
  const LifePage({super.key});

  @override
  State<LifePage> createState() => _LifePageState();
}

class _LifePageState extends State<LifePage> {
  static const _boardWidth = 60;
  static const _boardHeight = 40;
  static const _tick = Duration(milliseconds: 100);

  final _random = Random();
  late ConwayLife _sim = _newSim();
  Timer? _timer;

  bool get _running => _timer != null;

  ConwayLife _newSim() => ConwayLife(
        width: _boardWidth,
        height: _boardHeight,
        seed: _random.nextInt(1 << 31),
      );

  void _togglePlay() {
    setState(() {
      if (_running) {
        _timer!.cancel();
        _timer = null;
      } else {
        _timer = Timer.periodic(_tick, (_) => setState(_sim.step));
      }
    });
  }

  void _step() => setState(_sim.step);

  void _newBoard() => setState(() => _sim = _newSim());

  @override
  void dispose() {
    // Leaving the page must stop the timer, or it keeps calling setState
    // on a widget that no longer exists.
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Home',
          onPressed: () => context.go('/'),
        ),
        title: const Text("Conway's Game of Life"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Generation ${_sim.generation}  ·  Population ${_sim.population}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _togglePlay,
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                  label: Text(_running ? 'Pause' : 'Play'),
                ),
                OutlinedButton.icon(
                  onPressed: _running ? null : _step,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Step'),
                ),
                OutlinedButton.icon(
                  onPressed: _newBoard,
                  icon: const Icon(Icons.casino),
                  label: const Text('New board'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _boardWidth / _boardHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outline),
                    ),
                    child: GridViewBoard(sim: _sim),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

How the pieces work together:
- `late ConwayLife _sim = _newSim();` creates the board the first time
  it's used.
- `Timer.periodic(_tick, (_) => setState(_sim.step))`: every 100 ms,
  advance one generation and tell Flutter to rebuild.
- `setState(...)` → `build` runs again → `GridViewBoard` rebuilds → every
  cell's `ColoredBox` is rebuilt with its new color.
- `Expanded` + `Center` + `AspectRatio` makes the board as large as
  fits while keeping its 60:40 shape, so every cell is square.

### ✅ Checkpoint 4
- Home → button → a random board appears, generation 0.
- **Step** advances by one; **Play** animates; **Pause** stops;
  **New board** reshuffles.
- Go Home while it's playing, then come back: no errors in the terminal
  (proves `dispose` cancels the timer).
- Resize the window: the board stays 60:40 and fits.
- `flutter analyze && flutter test` pass. Commit.

**Feel the cost.** Temporarily change `_boardWidth`/`_boardHeight` to
`150`/`100` and press Play. That's 15,000 widgets rebuilt 10 times a
second. Note how smooth (or not) it is, then set the size back. Keep that
in mind for step 5.

---

## Step 5 — The same board with CustomPainter

**Why GridView is slow here.** Every tick, `GridView` builds, lays out and
paints one widget per cell (2,400 at 60×40), even dead ones and ones
that didn't change. A `CustomPainter` is **one** widget with a `paint`
method that draws straight onto a canvas: no per-cell widgets, and it
only draws the live cells.

You'll add a second board widget with the same shape as `GridViewBoard`
(it takes `sim`), plus a toggle on the page to switch between them while
it's running.

### 5a. `lib/life/painted_board.dart`
```dart
import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';
import 'package:flutter/material.dart';

/// Draws [sim] with a single CustomPainter.
class PaintedBoard extends StatelessWidget {
  const PaintedBoard({super.key, required this.sim});

  final CellularAutomaton sim;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: CustomPaint(
        painter: LifePainter(
          sim: sim,
          generation: sim.generation,
          color: colors.primary,
        ),
        // Without a child, CustomPaint is zero-sized. This makes the
        // canvas fill the board area.
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Paints one square per live cell of [sim], scaled to fill the canvas.
class LifePainter extends CustomPainter {
  LifePainter({required this.sim, required this.generation, required this.color});

  final CellularAutomaton sim;
  final int generation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / sim.width;
    final cellHeight = size.height / sim.height;
    final paint = Paint()..color = color;
    for (final cell in sim.aliveCells) {
      canvas.drawRect(
        Rect.fromLTWH(cell.x * cellWidth, cell.y * cellHeight, cellWidth, cellHeight),
        paint,
      );
    }
  }

  // The simulation changes in place, so the same `sim` object comes back
  // every tick. Compare the generation number (and the object, for
  // "New board") to know when the picture is out of date.
  @override
  bool shouldRepaint(LifePainter oldDelegate) =>
      oldDelegate.generation != generation ||
      oldDelegate.sim != sim ||
      oldDelegate.color != color;
}
```

### 5b. `lib/pages/life_page.dart`: add a renderer toggle
1. Import `package:portfolio/life/painted_board.dart`.
2. Add a field to `_LifePageState`:
   ```dart
   bool _useGridView = true;
   ```
3. Add a `SegmentedButton` as another child of the `Wrap`:
   ```dart
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('GridView')),
                    ButtonSegment(value: false, label: Text('CustomPainter')),
                  ],
                  selected: {_useGridView},
                  onSelectionChanged: (selection) =>
                      setState(() => _useGridView = selection.first),
                ),
   ```
4. Replace `child: GridViewBoard(sim: _sim),` with:
   ```dart
                    child: _useGridView
                        ? GridViewBoard(sim: _sim)
                        : PaintedBoard(sim: _sim),
   ```

### ✅ Checkpoint 5
- Switching between GridView and CustomPainter while playing looks the
  same and keeps running from the same generation (both draw the same
  `_sim`).
- Repeat the 150×100 experiment and switch between them.
- **Measure, don't guess:** add `showPerformanceOverlay: true,` to
  `MaterialApp.router` in `main.dart`. Two graphs appear at the top:
  - top = raster (GPU) thread, bottom = UI thread (build + layout + paint)
  - a frame under the green line fits 60 fps; red bars are dropped frames

  Compare the UI graph for both renderers at 150×100. For real numbers,
  run `flutter run -d chrome --profile` and open DevTools → Performance.
  Remove the overlay line when done.
- `flutter analyze && flutter test` pass. Commit.

---

## Step 6 — Making it faster still (optional, measure each change)

With step 5 in place, where does the time go now? Every tick still calls
`setState` on the **whole page**: the AppBar, buttons and text rebuild,
then the board repaints. Below are the next improvements, in the order
worth trying. After each, re-check the performance overlay at a large
board size; keep the change only if it helps.

### 6a. Repaint the board without rebuilding the page
Give the painter a `Listenable` to watch. When it fires, Flutter calls
`paint` directly, skipping `build` entirely.

- In `_LifePageState`, add `final _generation = ValueNotifier<int>(0);`
  (and `_generation.dispose();` in `dispose`).
- The timer stops calling `setState`:
  ```dart
  _timer = Timer.periodic(_tick, (_) {
    _sim.step();
    _generation.value = _sim.generation;
  });
  ```
  Do the same in `_step`. In `_newBoard`, keep `setState` (it's a new
  object) and reset `_generation.value = 0`.
- `LifePainter` takes the notifier and passes it to `super`:
  ```dart
  LifePainter({required this.sim, required this.color, required Listenable repaint})
      : super(repaint: repaint);

  @override
  bool shouldRepaint(LifePainter oldDelegate) =>
      oldDelegate.sim != sim || oldDelegate.color != color;
  ```
  (the `generation` field goes away; `repaint` now triggers redraws).
- The counter text listens to the same notifier, so only it rebuilds:
  ```dart
  ValueListenableBuilder<int>(
    valueListenable: _generation,
    builder: (context, generation, _) =>
        Text('Generation $generation  ·  Population ${_sim.population}'),
  ),
  ```
- `PaintedBoard` needs a `repaint` parameter to pass through.

Note: `GridViewBoard` can't use this trick (it has to rebuild widgets to
change colors). If you keep the toggle, it needs its own
`ValueListenableBuilder` around it. That asymmetry is the point:
painters can redraw without rebuilding; widget trees can't.

### 6b. `RepaintBoundary` around the board
Wrap `PaintedBoard` in `RepaintBoundary(child: ...)`. The board then gets
its own layer, so repainting it doesn't repaint the buttons and text
around it (and vice versa). Turn on
`debugRepaintRainbowEnabled = true;` (from `package:flutter/rendering.dart`,
in `main()`) to see which areas repaint: each repaint cycles a colored
border.

### 6c. Fewer draw calls
`drawRect` once per live cell is ~1,000 calls per frame at 60×40. Instead,
add every rectangle to one `Path` and call `canvas.drawPath` once:
```dart
final path = Path();
for (final cell in sim.aliveCells) {
  path.addRect(Rect.fromLTWH(...));
}
canvas.drawPath(path, paint);
```

### 6d. Sync with the screen: `Ticker` instead of `Timer`
`Timer.periodic` fires on its own schedule, not the screen's. A `Ticker`
(via `SingleTickerProviderStateMixin`) fires once per frame, pauses when
the tab is hidden, and is what Flutter animations use. Step the
simulation when at least `_tick` has passed since the last step.

### 6e. The library itself
At large sizes the simulation, not the drawing, becomes the bottleneck:
`step()` creates a `Cell` object for every position and does 8 `Set`
lookups each. A flat `Uint8List` of `width * height` (index
`y * width + x`) avoids those allocations. That's a change inside
`packages/cellular_automaton_zoo`; its tests tell you whether the
behavior stayed the same.

### ✅ Checkpoint 6
For each change you kept: before/after observation from the performance
overlay at a big board size. Commit after each one, so any change that
doesn't help is easy to revert.

---

## Step 7 — Clean URLs and a 404 page

**Concept.** By default Flutter web URLs look like `/#/life`. The *path*
strategy gives `/life`. GitHub Pages then needs `404.html` (your workflow
already copies it) so that opening `/life` directly still loads the app.

### 5a. Add the web plugins package
```sh
flutter pub add flutter_web_plugins --sdk=flutter
```

### 5b. `lib/main.dart`
```dart
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  runApp(const PortfolioApp());
}
```

### 5c. `lib/pages/not_found_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Page not found'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 5d. `lib/app/router.dart`
Add the import and one parameter to `GoRouter(...)`:
```dart
  errorBuilder: (context, state) => const NotFoundPage(),
```

### ✅ Checkpoint 7
- URLs are now `http://localhost:xxxx/life` (no `#`).
- Visit `/nope` → "Page not found" → Go home works.
- Refreshing on `/life` reloads the game page.
- Commit, push, and check https://yashkurkure.github.io/life opened
  directly (not just via the button).

---

## Optional extras (after it all works)
- **Tap to toggle cells:** wrap the `CustomPaint` in a `GestureDetector`,
  turn `details.localPosition` into a `Cell`, call `_sim.setAlive(...)`.
- **Speed slider:** a `Slider` that restarts the timer with a new
  `Duration`.
- **Widget test** for navigation: pump `PortfolioApp`, tap the button,
  `await tester.pumpAndSettle()`, expect `find.text("Conway's Game of Life")`.
- **Cat on the game page but not over the board:** instead of keeping
  `/life` outside the shell, put it inside and make `OnekoOverlay` take a
  "keep out" rectangle it won't walk into. More work; worth it only if you
  want the cat there.
