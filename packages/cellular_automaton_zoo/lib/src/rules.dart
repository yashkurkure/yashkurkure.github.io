/// Conway's Game of Life, rule B3/S23.
///
/// A dead cell with exactly 3 live neighbors is born; a live cell with 2 or
/// 3 live neighbors survives; every other cell is dead in the next
/// generation.
///
/// Needs no `on` clause: it only looks at its arguments, never at the board.
mixin ConwayRules {
  bool nextState(bool currentlyAlive, int liveNeighborCount) {
    RangeError.checkValueInInterval(
        liveNeighborCount, 0, 8, 'liveNeighborCount');
    if (currentlyAlive) {
      return liveNeighborCount == 2 || liveNeighborCount == 3;
    }
    return liveNeighborCount == 3;
  }
}
