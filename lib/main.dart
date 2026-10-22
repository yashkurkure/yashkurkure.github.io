import 'package:flutter/material.dart';

import 'package:portfolio/oneko/oneko_overlay.dart';
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
      // TODO: Find out what this line of code actually does?
      builder: (context, child) => OnekoOverlay(child: child!),
      routerConfig: router,
    );
  }
}