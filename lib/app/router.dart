import 'package:go_router/go_router.dart';
import 'package:portfolio/pages/home.dart';
import 'package:portfolio/pages/conway.dart';

final router = GoRouter(
  routes : [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/conway', builder: (context, state) => const ConwayPage())
  ],
);