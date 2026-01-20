/// Satranç taşı rengi
enum PieceColor {
  white,
  black,
}

/// Satranç taşı tipleri
enum PieceType {
  king,
  queen,
  rook,
  bishop,
  knight,
  pawn,
}

/// Satranç taşını temsil eder
class ChessPiece {
  final PieceType type;
  final PieceColor color;

  const ChessPiece(this.type, this.color);

  /// Taşın sembolünü döndürür (Unicode chess pieces)
  String get symbol {
    const whiteSymbols = {
      PieceType.king: '♔',
      PieceType.queen: '♕',
      PieceType.rook: '♖',
      PieceType.bishop: '♗',
      PieceType.knight: '♘',
      PieceType.pawn: '♙',
    };

    const blackSymbols = {
      PieceType.king: '♚',
      PieceType.queen: '♛',
      PieceType.rook: '♜',
      PieceType.bishop: '♝',
      PieceType.knight: '♞',
      PieceType.pawn: '♟',
    };

    return color == PieceColor.white
        ? whiteSymbols[type]!
        : blackSymbols[type]!;
  }

  @override
  String toString() => '$symbol ${type.name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessPiece &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          color == other.color;

  @override
  int get hashCode => type.hashCode ^ color.hashCode;
}
