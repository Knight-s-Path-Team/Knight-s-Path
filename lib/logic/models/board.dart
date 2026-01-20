import 'package:flutter/foundation.dart';
import 'position.dart';
import 'piece.dart';

/// Satranç tahtasını temsil eder
class ChessBoard {
  final int size;
  final Map<Position, ChessPiece> _pieces;

  ChessBoard({this.size = 8}) : _pieces = {};

  /// Belirli bir pozisyondaki taşı döndürür
  ChessPiece? getPieceAt(Position pos) => _pieces[pos];

  /// Belirli bir pozisyona taş yerleştirir
  void setPieceAt(Position pos, ChessPiece? piece) {
    if (!pos.isValid(boardSize: size)) {
      throw ArgumentError('Invalid position: $pos');
    }

    if (piece == null) {
      _pieces.remove(pos);
    } else {
      _pieces[pos] = piece;
    }
  }

  /// Tahtadaki tüm taşları döndürür
  Map<Position, ChessPiece> get pieces => Map.unmodifiable(_pieces);

  /// Belirli bir renkteki tüm taşları döndürür
  Map<Position, ChessPiece> getPiecesByColor(PieceColor color) {
    return Map.fromEntries(
      _pieces.entries.where((entry) => entry.value.color == color),
    );
  }

  /// Belirli bir tipteki tüm taşları döndürür
  Map<Position, ChessPiece> getPiecesByType(PieceType type) {
    return Map.fromEntries(
      _pieces.entries.where((entry) => entry.value.type == type),
    );
  }

  /// Pozisyon boş mu kontrol eder
  bool isSquareEmpty(Position pos) => !_pieces.containsKey(pos);

  /// Pozisyonda rakip taş var mı kontrol eder
  bool hasEnemyPiece(Position pos, PieceColor friendlyColor) {
    final piece = getPieceAt(pos);
    return piece != null && piece.color != friendlyColor;
  }

  /// Tahtayı temizler
  void clear() {
    _pieces.clear();
  }

  /// Tahtanın bir kopyasını oluşturur
  ChessBoard clone() {
    final newBoard = ChessBoard(size: size);
    _pieces.forEach((pos, piece) {
      newBoard.setPieceAt(pos, piece);
    });
    return newBoard;
  }

  /// Tahtayı yazdırır (debug için)
  void printBoard() {
    for (int row = 0; row < size; row++) {
      String line = '';
      for (int col = 0; col < size; col++) {
        final piece = getPieceAt(Position(row, col));
        line += piece != null ? piece.symbol : '·';
        line += ' ';
      }
      // ignore: avoid_print
      debugPrint(line);
    }
  }

  @override
  String toString() => 'ChessBoard(size: $size, pieces: ${_pieces.length})';
}
