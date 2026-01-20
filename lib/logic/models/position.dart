/// Satranç tahtasında bir pozisyonu temsil eder
/// (0,0) = a8, (7,7) = h1 (standart satranç notasyonu)
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  /// Pozisyonun tahta sınırları içinde olup olmadığını kontrol eder
  bool isValid({int boardSize = 8}) {
    return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
  }

  /// Satranç notasyonuna çevirir (örn: "e4")
  String toChessNotation() {
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    final rank = 8 - row;
    return '${files[col]}$rank';
  }

  /// Satranç notasyonundan Position oluşturur
  factory Position.fromChessNotation(String notation) {
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    final col = files.indexOf(notation[0]);
    final row = 8 - int.parse(notation[1]);
    return Position(row, col);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Position($row, $col) [${toChessNotation()}]';

  /// Yeni bir pozisyon oluşturur (offset ile)
  Position offset(int rowDelta, int colDelta) {
    return Position(row + rowDelta, col + colDelta);
  }
}
