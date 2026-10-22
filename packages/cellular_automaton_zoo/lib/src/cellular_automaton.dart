import 'cell.dart';
import 'grid.dart';

/// A [Grid] that evolves over discrete time steps.
///
/// Subclasses choose the rules by implementing [nextState] (usually with a
/// rules mixin such as `ConwayRules`) and the output by implementing
/// [render] (usually with `AsciiRenderable`).
abstract class CellularAutomaton extends Grid {
  CellularAutomaton({
    required super.width,
    required super.height,
    required super.seed,
  });

  /// How many times [step] has been called.
  int generation = 0;

  /// Whether a cell is alive in the next generation, given whether it is
  /// [currentlyAlive] and how many of its neighbors are alive.
  bool nextState(bool currentlyAlive, int liveNeighborCount);

  /// The board drawn as text.
  String render();

  /// Advances the board by one generation.
  ///
  /// Every cell's next state is computed from the current board before any
  /// cell changes, so cells never see a half-updated board.
  void step() {
    final next = <Cell>{
      for (final cell in cells)
        if (nextState(isAlive(cell), liveNeighborCount(cell))) cell,
    };
    replaceAll(next);
    generation++;
  }
}
