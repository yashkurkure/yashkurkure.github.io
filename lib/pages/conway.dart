import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConwayPage extends StatelessWidget {
  const ConwayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Home',
          onPressed: () => context.go('/'),
        ),
        title: const Text("Conway's Game of Life"),
      ),
      body: const Center(child: Text('Coming soon')),
    );
  }
}