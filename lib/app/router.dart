import 'package:go_router/go_router.dart';
import 'package:portfolio/oneko/oneko_overlay.dart';
import 'package:portfolio/pages/home.dart';
import 'package:portfolio/pages/conway.dart';

final router = GoRouter(
  routes : [
    // Pages inside the shell get the oneko cat on top.
    ShellRoute(
      // builder wraps whatever page `child` is with the oneko cat overlay.
      builder: (context, state, child) => OnekoOverlay(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
      ],
    ),
    // Pages outside the shell don't, so the cat never covers the board.
    GoRoute(path: '/conway', builder: (context, state) => const ConwayPage())
  ],
);