# Oneko in Flutter — Design Spec

Reference only; implement in the real project yourself. Based on the
original `oneko.js` (https://github.com/adryd325/oneko.js, MIT) that was on
the old site (`git show old-wordpress-site:oneko.js`). Keep an attribution
comment crediting it.

---

## 1. Get the sprite sheet

```sh
mkdir -p assets/images
git show old-wordpress-site:oneko.png > assets/images/oneko.png
```

Register it in `pubspec.yaml`:
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/oneko.png
```

Sheet is **256×128 px = 8 columns × 4 rows of 32×32 frames.**

## 2. Sprite table (column, row)

The JS uses negative CSS background offsets; these are the same values as
positive grid coordinates (`col = -x`, `row = -y`).

| Name | Frames (col,row) |
|---|---|
| idle | (3,3) |
| alert | (7,3) |
| tired | (3,2) |
| sleeping | (2,0) (2,1) |
| scratchSelf | (5,0) (6,0) (7,0) |
| scratchWallN | (0,0) (0,1) |
| scratchWallS | (7,1) (6,2) |
| scratchWallE | (2,2) (2,3) |
| scratchWallW | (4,0) (4,1) |
| N | (1,2) (1,3) |
| NE | (0,2) (0,3) |
| E | (3,0) (3,1) |
| SE | (5,1) (5,2) |
| S | (6,3) (7,2) |
| SW | (5,3) (6,1) |
| W | (4,2) (4,3) |
| NW | (1,0) (1,1) |

Model as `Map<String, List<(int, int)>>` (Dart records) or an enum with a
`frames` field. Pick frame with `frames[i % frames.length]`.

## 3. Behaviour (port of `frame()` / `idle()`)

Constants: `speed = 10` px per tick, tick = **100 ms**, sprite 32 px,
start position (32, 32).

State: `catPos`, `mousePos`, `frameCount`, `idleTime`, `idleAnimation`
(nullable), `idleAnimationFrame`.

Every tick:
1. `frameCount++`. `diff = catPos - mousePos`, `distance = diff.distance`.
2. **If distance < 48 → idle()** and stop.
3. Otherwise clear idle animation (`null`, frame 0).
4. **If idleTime > 1 → show `alert`**, `idleTime = min(idleTime, 7) - 1`,
   stop. (Cat "notices" you for a few ticks before running.)
5. Direction from the unit vector `d = diff / distance`:
   - `d.dy > 0.5` → "N", `d.dy < -0.5` → "S"
   - then `d.dx > 0.5` → "W", `d.dx < -0.5` → "E"
   - concatenate (e.g. "N"+"W" = "NW"). Show that sprite with `frameCount`.
6. Move: `catPos -= d * speed`, then clamp to
   `[16, width-16] × [16, height-16]`.

`idle()`:
- `idleTime++`.
- If `idleTime > 10`, no current idle animation, and a 1-in-200 random roll
  hits (≈ every 20 s): pick randomly from `sleeping`, `scratchSelf`, plus
  `scratchWallW/N/E/S` if within 32 px of the left/top/right/bottom edge.
- `sleeping`: frames 0–7 show `tired`; then `sleeping[idleFrame ~/ 4]`;
  end after frame 192.
- scratch*: show `anim[idleFrame]`; end after frame 9.
- No animation: show `idle` and **don't** increment `idleAnimationFrame`.
- Otherwise `idleAnimationFrame++`.

Use `Random()` from `dart:math`.

## 4. Flutter architecture

```
lib/oneko/
  oneko_sprites.dart     sprite table (section 2)
  oneko_controller.dart  state + tick logic (section 3), no widgets
  oneko_overlay.dart     widget: pointer tracking + timer + rendering
```

### Mount it once, above every page
Use `MaterialApp(builder: ...)` (or `MaterialApp.router(builder: ...)`
later) so the cat sits over all routes, like CSS `position: fixed`:

```
MaterialApp
  builder: (context, child) → OnekoOverlay(child: child!)
```

### OnekoOverlay structure
```
LayoutBuilder                          // gives viewport width/height for clamping
└─ Listener                            // behavior: HitTestBehavior.translucent
   │   onPointerHover / onPointerMove → controller.mousePos = event.position
   └─ Stack
      ├─ child                         // the actual site
      └─ ValueListenableBuilder        // rebuilds ONLY the cat each tick
         └─ Positioned(left: x-16, top: y-16)
            └─ IgnorePointer           // never steal clicks (pointer-events: none)
               └─ ExcludeSemantics     // aria-hidden
                  └─ sprite widget
```

- `translucent` lets the Listener see pointer events while the page below
  still gets them.
- Make it a `StatefulWidget`; start `Timer.periodic(100ms, ...)` in
  `initState`, cancel it in `dispose`.
- Controller can extend `ChangeNotifier` (or expose a
  `ValueNotifier<CatFrame>`) so the page itself never rebuilds per tick.

### Rendering one frame from the sheet
Simplest approach: a 32×32 window onto the full image, shifted:

```
SizedBox(32×32)
└─ ClipRect
   └─ OverflowBox(alignment: topLeft, maxWidth: 256, maxHeight: 128)
      └─ Transform.translate(offset: (-col*32, -row*32))
         └─ Image.asset('assets/images/oneko.png',
                        filterQuality: FilterQuality.none)   // keep pixels crisp
```

Alternative: a `CustomPainter` with `canvas.drawImageRect(...)` using a
`ui.Image` loaded once. Faster but needs async image loading; only worth
it if you see jank.

Optional: scale up with a `scale` param (render at 64×64 on big screens).

## 5. Edge cases

- **Reduced motion:** skip the overlay when
  `MediaQuery.disableAnimationsOf(context)` is true (the original honours
  `prefers-reduced-motion`). Check in the browser that this flag actually
  reflects the OS setting on web; if not, read it via `package:web`
  `window.matchMedia('(prefers-reduced-motion: reduce)')`.
- **Touch devices:** no hover events. Either hide the cat when
  `event.kind == PointerDeviceKind.touch`, or let it chase taps
  (`onPointerDown`). Hiding below the mobile breakpoint is simplest.
- **Pointer leaves the window:** optional `onPointerExit` via a
  `MouseRegion`. The original ignores this (cat stops at last position).
- **Resize:** clamping uses the latest `LayoutBuilder` size, so a shrinking
  window pulls the cat back on-screen on the next tick.
- **Tab hidden:** `Timer.periodic` keeps running in background tabs but
  browsers throttle it; harmless.

## 6. Testing

Keep the logic in `OnekoController` pure (inject `Random` and pass sizes in)
so you can unit-test without widgets:
- mouse far away + idleTime 0 → moves 10 px toward mouse, sprite is a
  direction.
- mouse within 48 px → idle sprite.
- idleTime 5 then mouse far → `alert` for a few ticks before moving.
- position never leaves `[16, w-16]`.

Widget test: pump `OnekoOverlay`, `tester.pump(Duration(milliseconds:
100))`, and check that the `Positioned` moved.

## 7. Build order

1. Asset + sprite table; render a static `idle` frame at (32,32).
2. Pointer tracking (print positions).
3. Timer + chase movement + direction sprites.
4. Alert delay, idle animations, wall scratches.
5. Reduced-motion + touch handling.
6. Unit tests for the controller.
