import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text('Hello, world!'),
            SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/conway'),
              child: Text("Play Conway's Game of Life"),
            ),
          ],
        ),
      ),
    );  
  }
}