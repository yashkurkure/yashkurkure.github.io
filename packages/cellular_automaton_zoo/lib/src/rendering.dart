import 'cell.dart';
import 'cellular_automaton.dart';
import 'grid.dart';

/// Draws a [Grid] as text: `#` for a live cell, `.` for a dead one.
///
/// Each row ends with a newline, including the last one.
mixin AsciiRenderable on Grid {
  String render() {
    final buffer = StringBuffer();
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        buffer.write(isAlive(Cell(x: x, y: y)) ? '#' : '.');
      }
      buffer.write('\n');
    }
    return buffer.toString();
  }
}

/// Adds a border around whatever an earlier mixin's [render] returns.
///
/// Must come after a mixin that implements [render], such as
/// [AsciiRenderable]:
///
/// ```dart
/// class Conway extends CellularAutomaton
///     with ConwayRules, AsciiRenderable, DecoratedRenderable { ... }
/// ```
///
/// Rows are wrapped in `|`, and `-` lines run along the top and bottom.
mixin DecoratedRenderable on CellularAutomaton {
  @override
  String render() {
    final rows = super.render().split('\n');
    // Every row ends with '\n', which leaves an empty string at the end.
    if (rows.isNotEmpty && rows.last.isEmpty) rows.removeLast();

    final edge = '-' * (width + 2);
    final buffer = StringBuffer()..writeln(edge);
    for (final row in rows) {
      buffer.writeln('|$row|');
    }
    buffer.writeln(edge);
    return buffer.toString();
  }
}
