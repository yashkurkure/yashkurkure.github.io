/// The coordinates of a single cell on a [Grid].
///
/// `x` is the column (0 at the left) and `y` is the row (0 at the top).
/// Two cells are equal when their coordinates are equal, so cells can be
/// stored in a [Set] or used as [Map] keys.
class Cell {
  const Cell({required this.x, required this.y});

  final int x;
  final int y;

  @override
  bool operator ==(Object other) =>
      other is Cell && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Cell(x: $x, y: $y)';
}
