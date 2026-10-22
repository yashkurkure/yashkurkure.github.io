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
