import 'dart:math';

import 'cell.dart';

/// A rectangular board of alive/dead cells.
///
/// Only the live cells are stored, in a [Set] of [Cell]s; every other
/// position on the board is dead. The edges are walls: there is no
/// wrap-around, so a corner cell has 3 neighbors and an edge cell has 5.
class Grid {
  /// Creates a [width] x [height] board with a random starting state.
  ///
  /// The same [seed] always produces the same board. At least one cell is
  /// guaranteed to start alive.
  ///
  /// Throws an [ArgumentError] if [width] or [height] is not positive.
  Grid({required this.width, required this.height, required int seed}) {
    if (width <= 0) {
      throw ArgumentError.value(width, 'width', 'must be positive');
    }
    if (height <= 0) {
      throw ArgumentError.value(height, 'height', 'must be positive');
    }

    final random = Random(seed);
    for (final cell in cells) {
      if (random.nextInt(2) == 1) _alive.add(cell);
    }
    if (_alive.isEmpty) {
      _alive.add(Cell(x: random.nextInt(width), y: random.nextInt(height)));
    }
  }

  final int width;
  final int height;

  final Set<Cell> _alive = {};

  /// The number of live cells.
  int get population => _alive.length;

  /// Every position on the board, row by row from the top-left corner.
  Iterable<Cell> get cells sync* {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        yield Cell(x: x, y: y);
      }
    }
  }

  /// The live cells, in no particular order.
  Iterable<Cell> get aliveCells => _alive;

  /// Whether [cell] lies on the board.
  bool contains(Cell cell) =>
      cell.x >= 0 && cell.x < width && cell.y >= 0 && cell.y < height;

  /// Whether [cell] is alive.
  ///
  /// Throws a [RangeError] if [cell] is not on the board.
  bool isAlive(Cell cell) {
    _checkOnBoard(cell);
    return _alive.contains(cell);
  }

  /// Makes [cell] alive or dead.
  ///
  /// Throws a [RangeError] if [cell] is not on the board.
  void setAlive(Cell cell, bool alive) {
    _checkOnBoard(cell);
    if (alive) {
      _alive.add(cell);
    } else {
      _alive.remove(cell);
    }
  }

  /// Kills every cell, then brings each cell in [alive] to life.
  ///
  /// Throws a [RangeError] if any cell is not on the board; the board is
  /// left unchanged in that case.
  void replaceAll(Iterable<Cell> alive) {
    final next = alive.toSet();
    next.forEach(_checkOnBoard);
    _alive
      ..clear()
      ..addAll(next);
  }

  /// The number of live cells among the up to 8 neighbors of [cell].
  ///
  /// Positions off the board are not neighbors.
  ///
  /// Throws a [RangeError] if [cell] is not on the board.
  int liveNeighborCount(Cell cell) {
    _checkOnBoard(cell);
    var count = 0;
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        if (_alive.contains(Cell(x: cell.x + dx, y: cell.y + dy))) count++;
      }
    }
    return count;
  }

  void _checkOnBoard(Cell cell) {
    if (!contains(cell)) {
      throw RangeError('$cell is outside the ${width}x$height grid');
    }
  }
}
