# Portfolio Site — Build Plan

Reference only. Implement everything yourself in the real project; nothing
here is meant to be copied or imported. Assumes SETUP.md steps 1–5 are done.

---

## 1. Decide the shape first

**Recommended: single scrolling page + project detail pages.**

```
/                 Home: Hero → About → Projects → Experience → Skills → Contact
/projects/:slug   Detail page for one project (optional, add later)
```

Nav bar links scroll to sections on `/`. That keeps v1 small; detail pages are
a phase-2 add.

## 2. Content to gather before coding

- Name, one-line headline ("Software engineer building X")
- Short bio (2–4 sentences), photo or avatar
- 3–6 projects: title, one-line summary, tech tags, image/GIF, links
  (GitHub, live demo)
- Experience: role, company, dates, 2–3 bullets each
- Skills grouped (Languages / Frameworks / Tools)
- Contact: email, GitHub, LinkedIn, résumé PDF

Tip: keep all of this as **data**, not hard-coded in widgets, so updating the
site means editing one file. Two options:
- A Dart file `lib/data/content.dart` with `const` lists of model objects
  (simplest, type-safe), or
- `assets/content.json` loaded at startup (non-Dart edits, slightly more code).

## 3. Project structure

```
lib/
  main.dart                  runApp, MaterialApp.router, theme
  app/
    router.dart              go_router config
    theme.dart               ColorScheme, TextTheme, light/dark
    breakpoints.dart         isMobile/isTablet/isDesktop helpers
  data/
    models.dart              Project, Job, SkillGroup, Profile
    content.dart             the actual content (your data)
  pages/
    home_page.dart           scroll view composing sections
    project_page.dart        (phase 2)
  sections/
    hero_section.dart
    about_section.dart
    projects_section.dart
    experience_section.dart
    skills_section.dart
    contact_section.dart
  widgets/
    nav_bar.dart             top bar desktop, drawer/menu on mobile
    section_container.dart   max-width 1100, consistent padding + title
    project_card.dart
    tag_chip.dart
    footer.dart
assets/
  images/                    project screenshots, avatar (use .webp)
  resume.pdf
```

Register assets in `pubspec.yaml` under `flutter: assets:`.

## 4. Packages

```sh
flutter pub add go_router google_fonts url_launcher
flutter pub add flutter_animate      # optional: fade/slide-in on scroll
flutter pub add visibility_detector  # optional: trigger animations on view
```

## 5. Key implementation notes

**Scroll-to-section nav.** Give each section a `GlobalKey`; nav buttons call
`Scrollable.ensureVisible(key.currentContext!, duration: ..., curve: ...)`.

**Responsive.** `LayoutBuilder` + breakpoints (<600 mobile, <1024 tablet).
Projects grid: 1 / 2 / 3 columns. Hero: stacked on mobile, row on desktop.
Nav: hamburger → `endDrawer` on mobile.

**Theme.** `ColorScheme.fromSeed(seedColor: ...)` for light + dark,
`themeMode: ThemeMode.system`. One accent colour, lots of whitespace.
Pick one font via google_fonts (e.g. Inter, Manrope, Space Grotesk).

**Links.** `url_launcher`'s `launchUrl(Uri.parse(...))` for GitHub/LinkedIn,
`mailto:` for email, and the résumé served as an asset
(`assets/assets/resume.pdf` path on web).

**Text selection.** Wrap the page in `SelectionArea` so visitors can copy
your email, etc.

**Clean URLs.** `usePathUrlStrategy()` in `main()` (see SETUP.md) so
`/projects/foo` works without `#`.

**Performance.** Compress images (WebP, ≤ 200 KB each), use
`Image.asset(..., cacheWidth: ...)`, build with `--wasm`. Customise the
loading screen in `web/index.html` so the first-load wait isn't blank.

**SEO / sharing.** In `web/index.html` set `<title>`,
`<meta name="description">`, and Open Graph tags (`og:title`,
`og:description`, `og:image`) so links preview nicely on LinkedIn etc.

## 6. Build order (milestones)

1. Theme + `SectionContainer` + empty `HomePage` with the six section stubs.
2. Models + `content.dart` with your real data.
3. Hero + About.
4. Projects grid + `ProjectCard` (hover elevation on desktop).
5. Experience timeline + Skills chips.
6. Contact + footer + working links.
7. Nav bar with scroll-to-section; mobile drawer.
8. Responsive pass at 375px, 768px, 1440px widths (Chrome DevTools).
9. Dark mode check, animations (optional), favicon, meta tags.
10. Deploy (below).
11. Phase 2: `/projects/:slug` detail pages, blog, analytics.

Commit after each milestone.

## 7. Deploying

Easiest for a portfolio: **GitHub Pages via GitHub Actions**.
- Repo named `<username>.github.io` → site at `https://<username>.github.io`,
  no `--base-href` needed.
- Otherwise build with `--base-href /<repo-name>/`.
- Workflow: checkout → `subosito/flutter-action` → `flutter build web
  --release --wasm` → `actions/upload-pages-artifact` (path `build/web`) →
  `actions/deploy-pages`.
- For path URLs, copy `build/web/index.html` to `build/web/404.html` in the
  workflow.
- Custom domain: add a `web/CNAME` file containing the domain.

Alternatives: Firebase Hosting or Cloudflare Pages (see SETUP.md).

## 8. Inspiration

- https://wonderous.app/web/ (motion and polish)
- https://itsallwidgets.com (search "portfolio")
- GitHub search: `flutter portfolio website` for open-source examples
