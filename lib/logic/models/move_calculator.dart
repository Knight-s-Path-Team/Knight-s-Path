import 'position.dart';
import 'piece.dart';
import 'board.dart';

/// Satranç taşlarının geçerli hareketlerini hesaplar
class MoveCalculator {
  /// Knight (At) için geçerli L-şeklindeki tüm hareketleri döndürür
  /// Knight 2 kare bir yöne, 1 kare dik yöne hareket eder
  static List<Position> getKnightMoves(Position from, {int boardSize = 8}) {
    // L-şeklindeki 8 olası hareket
    final List<List<int>> knightOffsets = [
      [-2, -1], // 2 yukarı, 1 sol
      [-2, 1],  // 2 yukarı, 1 sağ
      [-1, -2], // 1 yukarı, 2 sol
      [-1, 2],  // 1 yukarı, 2 sağ
      [1, -2],  // 1 aşağı, 2 sol
      [1, 2],   // 1 aşağı, 2 sağ
      [2, -1],  // 2 aşağı, 1 sol
      [2, 1],   // 2 aşağı, 1 sağ
    ];

    final possibleMoves = <Position>[];

    for (final offset in knightOffsets) {
      final newPos = Position(from.row + offset[0], from.col + offset[1]);
      if (newPos.isValid(boardSize: boardSize)) {
        possibleMoves.add(newPos);
      }
    }

    return possibleMoves;
  }

  /// Rook (Kale) için geçerli hareketleri döndürür (yatay ve dikey)
  static List<Position> getRookMoves(
    Position from,
    ChessBoard board,
  ) {
    final moves = <Position>[];
    final piece = board.getPieceAt(from);
    if (piece == null) return moves;

    // Dört yön: yukarı, aşağı, sol, sağ
    final directions = [
      [-1, 0], // yukarı
      [1, 0],  // aşağı
      [0, -1], // sol
      [0, 1],  // sağ
    ];

    for (final dir in directions) {
      int row = from.row + dir[0];
      int col = from.col + dir[1];

      while (true) {
        final pos = Position(row, col);
        if (!pos.isValid(boardSize: board.size)) break;

        final targetPiece = board.getPieceAt(pos);
        if (targetPiece == null) {
          moves.add(pos);
        } else {
          if (targetPiece.color != piece.color) {
            moves.add(pos);
          }
          break; // Taş var, daha ileri gidemez
        }

        row += dir[0];
        col += dir[1];
      }
    }

    return moves;
  }

  /// Bishop (Fil) için geçerli hareketleri döndürür (çapraz)
  static List<Position> getBishopMoves(
    Position from,
    ChessBoard board,
  ) {
    final moves = <Position>[];
    final piece = board.getPieceAt(from);
    if (piece == null) return moves;

    // Dört çapraz yön
    final directions = [
      [-1, -1], // sol üst
      [-1, 1],  // sağ üst
      [1, -1],  // sol alt
      [1, 1],   // sağ alt
    ];

    for (final dir in directions) {
      int row = from.row + dir[0];
      int col = from.col + dir[1];

      while (true) {
        final pos = Position(row, col);
        if (!pos.isValid(boardSize: board.size)) break;

        final targetPiece = board.getPieceAt(pos);
        if (targetPiece == null) {
          moves.add(pos);
        } else {
          if (targetPiece.color != piece.color) {
            moves.add(pos);
          }
          break;
        }

        row += dir[0];
        col += dir[1];
      }
    }

    return moves;
  }

  /// Queen (Vezir) için geçerli hareketleri döndürür (rook + bishop)
  static List<Position> getQueenMoves(
    Position from,
    ChessBoard board,
  ) {
    return [
      ...getRookMoves(from, board),
      ...getBishopMoves(from, board),
    ];
  }

  /// King (Şah) için geçerli hareketleri döndürür (her yöne 1 kare)
  static List<Position> getKingMoves(
    Position from,
    ChessBoard board,
  ) {
    final moves = <Position>[];
    final piece = board.getPieceAt(from);
    if (piece == null) return moves;

    // 8 yön
    final directions = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1],
    ];

    for (final dir in directions) {
      final pos = Position(from.row + dir[0], from.col + dir[1]);
      if (!pos.isValid(boardSize: board.size)) continue;

      final targetPiece = board.getPieceAt(pos);
      if (targetPiece == null || targetPiece.color != piece.color) {
        moves.add(pos);
      }
    }

    return moves;
  }

  /// Pawn (Piyon) için geçerli hareketleri döndürür
  static List<Position> getPawnMoves(
    Position from,
    ChessBoard board,
  ) {
    final moves = <Position>[];
    final piece = board.getPieceAt(from);
    if (piece == null) return moves;

    final direction = piece.color == PieceColor.white ? -1 : 1;
    final startRow = piece.color == PieceColor.white ? 6 : 1;

    // 1 kare ileri
    final oneForward = Position(from.row + direction, from.col);
    if (oneForward.isValid(boardSize: board.size) &&
        board.isSquareEmpty(oneForward)) {
      moves.add(oneForward);

      // 2 kare ileri (başlangıç pozisyonundan)
      if (from.row == startRow) {
        final twoForward = Position(from.row + 2 * direction, from.col);
        if (board.isSquareEmpty(twoForward)) {
          moves.add(twoForward);
        }
      }
    }

    // Çapraz alma
    final captureOffsets = [-1, 1];
    for (final colOffset in captureOffsets) {
      final capturePos = Position(from.row + direction, from.col + colOffset);
      if (capturePos.isValid(boardSize: board.size) &&
          board.hasEnemyPiece(capturePos, piece.color)) {
        moves.add(capturePos);
      }
    }

    return moves;
  }

  /// Herhangi bir taş için geçerli hareketleri hesaplar
  static List<Position> getPossibleMoves(
    Position from,
    ChessBoard board,
  ) {
    final piece = board.getPieceAt(from);
    if (piece == null) return [];

    switch (piece.type) {
      case PieceType.knight:
        return getKnightMoves(from, boardSize: board.size);
      case PieceType.rook:
        return getRookMoves(from, board);
      case PieceType.bishop:
        return getBishopMoves(from, board);
      case PieceType.queen:
        return getQueenMoves(from, board);
      case PieceType.king:
        return getKingMoves(from, board);
      case PieceType.pawn:
        return getPawnMoves(from, board);
    }
  }
}
