# Flutter Website — Setup Guide

Reference notes only. Nothing in `claude/` is meant to be imported, copied
into, or depended on by the project. Run every command yourself from the repo
root (`/Users/yash/git/website`).

Verified on 2026-10-21 with Flutter 3.47.3 (stable), macOS, Chrome detected.

---

## 0. Toolchain status (already OK)

`flutter doctor` shows:
- ✓ Flutter stable 3.47.3
- ✓ Chrome (web target)
- ! Android / Xcode: irrelevant for a website, ignore.

Optional: `flutter upgrade` (a newer version is available).

## 1. Make it a git repo

```sh
git init
git branch -M main
```

## 2. Create the Flutter project (web only)

```sh
flutter config --enable-web          # already effectively on; harmless
flutter create . --platforms web --org com.yourname --project-name website
```

- `.` creates in the current folder; the existing `claude/` dir is left alone.
- `--platforms web` keeps only `web/` (no android/ios/macos folders). You can
  add more later with `flutter create . --platforms android,ios`.
- Replace `com.yourname` with your reverse domain.
- This generates `.gitignore`, `pubspec.yaml`, `lib/main.dart`,
  `test/widget_test.dart`, `web/index.html`, `analysis_options.yaml`.

Optional: keep `claude/` out of git by adding `claude/` to `.gitignore`.

## 3. Run it

```sh
flutter run -d chrome                # dev, hot reload (press r / R)
flutter run -d web-server --web-port 8080   # serve without launching Chrome
```

## 4. Sanity checks

```sh
flutter analyze
flutter test
flutter build web --release          # output in build/web/
```

Preview the release build locally:

```sh
python3 -m http.server 8000 --directory build/web
# open http://localhost:8000
```

Try the WebAssembly build too (faster, needs modern browsers):

```sh
flutter build web --release --wasm
```

## 5. First commit

```sh
git add .
git commit -m "Initial Flutter web project"
```

---

## Suggested next steps

### Packages worth adding
```sh
flutter pub add go_router            # URL-based routing (/about, /blog/x)
flutter pub add google_fonts         # fonts
flutter pub add url_launcher         # open external links
flutter pub add flutter_lints --dev  # usually already present
```

### Clean URLs (no `#/` in paths)
Flutter web uses hash URLs (`/#/about`) by default. For path URLs
(`/about`), call `usePathUrlStrategy()` from
`package:flutter_web_plugins/url_strategy.dart` before `runApp`, and add
`flutter_web_plugins: { sdk: flutter }` to `pubspec.yaml` dependencies.
Your host must then rewrite all routes to `index.html` (see hosting below).

### Suggested `lib/` layout
```
lib/
  main.dart            # runApp, theme, router
  app/router.dart
  app/theme.dart
  pages/               # home_page.dart, about_page.dart, ...
  widgets/             # shared UI (nav bar, footer)
  data/                # static content / models
```

### Responsive design
Use `LayoutBuilder` or `MediaQuery.sizeOf(context).width` with breakpoints
(e.g. <600 mobile, <1024 tablet, else desktop). Wrap page content in a
`ConstrainedBox(maxWidth: 1100)` centred so it doesn't stretch on wide
screens.

### Edit `web/index.html`
Set `<title>`, `<meta name="description">`, and the favicon / icons in
`web/icons/`, `web/manifest.json`.

---

## Hosting options

| Host | Command / notes |
|---|---|
| **Firebase Hosting** | `npm i -g firebase-tools`, `firebase init hosting` (public dir `build/web`, SPA rewrite: yes), `firebase deploy` |
| **GitHub Pages** | Build with `flutter build web --release --base-href /<repo-name>/` (omit for a user/org site or custom domain). Deploy `build/web` via a GitHub Action. Add a `404.html` copy of `index.html` for path URLs. |
| **Netlify / Vercel / Cloudflare Pages** | Build command `flutter build web --release`, output dir `build/web`. Add an SPA rewrite `/* → /index.html 200`. These hosts don't ship Flutter, so build in CI or upload the built folder. |

---

## Things to know about Flutter web

- **SEO is weak.** Content is drawn on a canvas, so search engines see little
  text. Fine for portfolios and apps; for a content- or blog-heavy site where
  search ranking matters, consider a static site generator (or Jaspr, a
  Dart framework that outputs real HTML).
- **First load is heavy** (~2 MB+ for CanvasKit). `--wasm` and keeping
  assets small help.
- Text selection isn't on by default; wrap text in `SelectionArea` if you
  want it.
