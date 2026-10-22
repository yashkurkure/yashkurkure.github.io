import 'package:flutter/material.dart';
import 'package:portfolio/app/router.dart';

void main() => runApp(const PortfolioApp());

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp bundles Material Design essentials (theme, localization,
    // navigator, etc.) into one widget. The .router named constructor is
    // the variant that delegates navigation to a custom NavigationDelegate
    // (our GoRouter) instead of the default Navigator.
    return MaterialApp.router(
      title: 'Yash\'s Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      routerConfig: router,
    );
  }
}