import 'package:cellular_automaton_zoo/cellular_automaton_zoo.dart';
import 'package:test/test.dart';

class Conway extends CellularAutomaton
    with ConwayRules, AsciiRenderable, DecoratedRenderable {
  Conway({required super.width, required super.height, required super.seed});
}

class PlainConway extends CellularAutomaton with ConwayRules, AsciiRenderable {
  PlainConway({
    required super.width,
    required super.height,
    required super.seed,
  });
}

/// A board with exactly the cells in [alive] alive.
PlainConway board(int width, int height, List<Cell> alive) =>
    PlainConway(width: width, height: height, seed: 0)..replaceAll(alive);

class _RulesOnly with ConwayRules {}

void main() {
  group('Cell', () {
    test('equal coordinates are equal and hash the same', () {
      expect(const Cell(x: 1, y: 2), const Cell(x: 1, y: 2));
      expect(const Cell(x: 1, y: 2).hashCode, const Cell(x: 1, y: 2).hashCode);
      expect(const Cell(x: 1, y: 2), isNot(const Cell(x: 2, y: 1)));
      final cells = <Cell>{}
        ..add(Cell(x: 0, y: 0))
        ..add(Cell(x: 0, y: 0));
      expect(cells, hasLength(1));
    });
  });

  group('Grid', () {
    test('same seed gives the same board', () {
      final a = Grid(width: 20, height: 10, seed: 42);
      final b = Grid(width: 20, height: 10, seed: 42);
      expect(a.aliveCells.toSet(), b.aliveCells.toSet());
    });

    test('different seeds usually give different boards', () {
      final a = Grid(width: 20, height: 10, seed: 1);
      final b = Grid(width: 20, height: 10, seed: 2);
      expect(a.aliveCells.toSet(), isNot(b.aliveCells.toSet()));
    });

    test('starts with at least one live cell, even when tiny', () {
      for (var seed = 0; seed < 50; seed++) {
        expect(Grid(width: 1, height: 1, seed: seed).population, 1);
      }
    });

    test('population counts live cells', () {
      final grid = board(3, 3, const [Cell(x: 0, y: 0), Cell(x: 2, y: 2)]);
      expect(grid.population, 2);
    });

    test('rejects non-positive width and height', () {
      expect(() => Grid(width: 0, height: 5, seed: 0), throwsArgumentError);
      expect(() => Grid(width: 5, height: -1, seed: 0), throwsArgumentError);
    });

    test('out-of-bounds access throws', () {
      final grid = Grid(width: 3, height: 3, seed: 0);
      expect(() => grid.isAlive(const Cell(x: 3, y: 0)), throwsRangeError);
      expect(() => grid.isAlive(const Cell(x: 0, y: -1)), throwsRangeError);
      expect(
        () => grid.setAlive(const Cell(x: -1, y: 0), true),
        throwsRangeError,
      );
      expect(
        () => grid.liveNeighborCount(const Cell(x: 0, y: 3)),
        throwsRangeError,
      );
    });

    test('replaceAll with an off-board cell leaves the board unchanged', () {
      final grid = board(3, 3, const [Cell(x: 1, y: 1)]);
      expect(
        () => grid.replaceAll(const [Cell(x: 0, y: 0), Cell(x: 5, y: 5)]),
        throwsRangeError,
      );
      expect(grid.aliveCells.toSet(), {const Cell(x: 1, y: 1)});
    });

    test('corners see 3 neighbors, edges 5, middle 8 (no wrap-around)', () {
      final full = PlainConway(width: 3, height: 3, seed: 0)
        ..replaceAll(PlainConway(width: 3, height: 3, seed: 0).cells);
      expect(full.liveNeighborCount(const Cell(x: 0, y: 0)), 3);
      expect(full.liveNeighborCount(const Cell(x: 2, y: 2)), 3);
      expect(full.liveNeighborCount(const Cell(x: 1, y: 0)), 5);
      expect(full.liveNeighborCount(const Cell(x: 0, y: 1)), 5);
      expect(full.liveNeighborCount(const Cell(x: 1, y: 1)), 8);
    });
  });

  group('ConwayRules', () {
    final rules = _RulesOnly();

    test('B3/S23', () {
      for (var n = 0; n <= 8; n++) {
        expect(rules.nextState(false, n), n == 3, reason: 'dead, $n');
        expect(rules.nextState(true, n), n == 2 || n == 3, reason: 'alive, $n');
      }
    });

    test('rejects impossible neighbor counts', () {
      expect(() => rules.nextState(true, -1), throwsRangeError);
      expect(() => rules.nextState(true, 9), throwsRangeError);
    });
  });

  group('CellularAutomaton.step', () {
    test('blinker flips between horizontal and vertical', () {
      final horizontal = {
        const Cell(x: 1, y: 2),
        const Cell(x: 2, y: 2),
        const Cell(x: 3, y: 2),
      };
      final vertical = {
        const Cell(x: 2, y: 1),
        const Cell(x: 2, y: 2),
        const Cell(x: 2, y: 3),
      };
      final sim = board(5, 5, horizontal.toList());

      sim.step();
      expect(sim.aliveCells.toSet(), vertical);
      sim.step();
      expect(sim.aliveCells.toSet(), horizontal);
    });

    test('block in a corner is stable', () {
      final block = {
        const Cell(x: 0, y: 0),
        const Cell(x: 1, y: 0),
        const Cell(x: 0, y: 1),
        const Cell(x: 1, y: 1),
      };
      final sim = board(4, 4, block.toList())..step();
      expect(sim.aliveCells.toSet(), block);
    });

    test('increments generation', () {
      final sim = Conway(width: 10, height: 10, seed: 7);
      expect(sim.generation, 0);
      sim
        ..step()
        ..step();
      expect(sim.generation, 2);
    });
  });

  group('rendering', () {
    final glider = board(4, 3, const [
      Cell(x: 1, y: 0),
      Cell(x: 2, y: 1),
      Cell(x: 0, y: 2),
    ]);

    test('AsciiRenderable uses # and . with a newline per row', () {
      expect(glider.render(), '.#..\n..#.\n#...\n');
    });

    test('DecoratedRenderable adds a border around the ascii board', () {
      final sim = Conway(width: 4, height: 3, seed: 0)
        ..replaceAll(glider.aliveCells);
      expect(
        sim.render(),
        '------\n'
        '|.#..|\n'
        '|..#.|\n'
        '|#...|\n'
        '------\n',
      );
    });
  });
}
