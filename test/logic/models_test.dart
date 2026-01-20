import 'package:flutter_test/flutter_test.dart';
import 'package:knights_path/logic/models/position.dart';
import 'package:knights_path/logic/models/piece.dart';
import 'package:knights_path/logic/models/board.dart';
import 'package:knights_path/logic/models/move_calculator.dart';

void main() {
  group('Position Tests', () {
    test('Position validity check', () {
      expect(Position(0, 0).isValid(), true);
      expect(Position(7, 7).isValid(), true);
      expect(Position(-1, 0).isValid(), false);
      expect(Position(8, 0).isValid(), false);
      expect(Position(0, 8).isValid(), false);
    });

    test('Chess notation conversion', () {
      expect(Position(0, 0).toChessNotation(), 'a8');
      expect(Position(7, 7).toChessNotation(), 'h1');
      expect(Position(4, 4).toChessNotation(), 'e4');
    });

    test('Create position from chess notation', () {
      final pos = Position.fromChessNotation('e4');
      expect(pos.row, 4);
      expect(pos.col, 4);
    });

    test('Position equality', () {
      expect(Position(3, 4) == Position(3, 4), true);
      expect(Position(3, 4) == Position(3, 5), false);
    });
  });

  group('ChessPiece Tests', () {
    test('Piece symbols', () {
      expect(ChessPiece(PieceType.knight, PieceColor.white).symbol, '♘');
      expect(ChessPiece(PieceType.knight, PieceColor.black).symbol, '♞');
    });

    test('Piece equality', () {
      final piece1 = ChessPiece(PieceType.knight, PieceColor.white);
      final piece2 = ChessPiece(PieceType.knight, PieceColor.white);
      final piece3 = ChessPiece(PieceType.knight, PieceColor.black);

      expect(piece1 == piece2, true);
      expect(piece1 == piece3, false);
    });
  });

  group('ChessBoard Tests', () {
    test('Place and get piece', () {
      final board = ChessBoard();
      final knight = ChessPiece(PieceType.knight, PieceColor.white);
      final pos = Position(4, 4);

      board.setPieceAt(pos, knight);
      expect(board.getPieceAt(pos), knight);
    });

    test('Remove piece', () {
      final board = ChessBoard();
      final knight = ChessPiece(PieceType.knight, PieceColor.white);
      final pos = Position(4, 4);

      board.setPieceAt(pos, knight);
      board.setPieceAt(pos, null);
      expect(board.getPieceAt(pos), null);
    });

    test('Is square empty', () {
      final board = ChessBoard();
      final pos = Position(4, 4);

      expect(board.isSquareEmpty(pos), true);

      board.setPieceAt(pos, ChessPiece(PieceType.knight, PieceColor.white));
      expect(board.isSquareEmpty(pos), false);
    });

    test('Get pieces by color', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(0, 0),
        ChessPiece(PieceType.knight, PieceColor.white),
      );
      board.setPieceAt(
        Position(1, 1),
        ChessPiece(PieceType.rook, PieceColor.black),
      );

      final whitePieces = board.getPiecesByColor(PieceColor.white);
      expect(whitePieces.length, 1);

      final blackPieces = board.getPiecesByColor(PieceColor.black);
      expect(blackPieces.length, 1);
    });

    test('Board clone', () {
      final board1 = ChessBoard();
      board1.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.knight, PieceColor.white),
      );

      final board2 = board1.clone();
      expect(board2.getPieceAt(Position(4, 4))?.type, PieceType.knight);

      // Değişiklik orijinali etkilememeli
      board2.setPieceAt(Position(4, 4), null);
      expect(board1.getPieceAt(Position(4, 4))?.type, PieceType.knight);
    });
  });

  group('MoveCalculator - Knight Moves', () {
    test('Knight moves from center', () {
      final moves = MoveCalculator.getKnightMoves(Position(4, 4));
      expect(moves.length, 8); // Merkezden 8 hareket

      // Tüm L-şeklindeki hareketler
      expect(moves.contains(Position(2, 3)), true);
      expect(moves.contains(Position(2, 5)), true);
      expect(moves.contains(Position(3, 2)), true);
      expect(moves.contains(Position(3, 6)), true);
      expect(moves.contains(Position(5, 2)), true);
      expect(moves.contains(Position(5, 6)), true);
      expect(moves.contains(Position(6, 3)), true);
      expect(moves.contains(Position(6, 5)), true);
    });

    test('Knight moves from corner', () {
      final moves = MoveCalculator.getKnightMoves(Position(0, 0));
      expect(moves.length, 2); // Köşeden sadece 2 hareket
      expect(moves.contains(Position(1, 2)), true);
      expect(moves.contains(Position(2, 1)), true);
    });

    test('Knight moves from edge', () {
      final moves = MoveCalculator.getKnightMoves(Position(0, 4));
      expect(moves.length, 4); // Kenardan 4 hareket
    });
  });

  group('MoveCalculator - Rook Moves', () {
    test('Rook moves on empty board', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.rook, PieceColor.white),
      );

      final moves = MoveCalculator.getRookMoves(Position(4, 4), board);
      expect(moves.length, 14); // 7 yatay + 7 dikey
    });

    test('Rook moves blocked by piece', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.rook, PieceColor.white),
      );
      board.setPieceAt(
        Position(4, 6),
        ChessPiece(PieceType.pawn, PieceColor.white),
      );

      final moves = MoveCalculator.getRookMoves(Position(4, 4), board);

      // Sağa sadece 1 kare gidebilir (kendi taşı var)
      expect(moves.contains(Position(4, 5)), true);
      expect(moves.contains(Position(4, 6)), false);
      expect(moves.contains(Position(4, 7)), false);
    });

    test('Rook can capture enemy piece', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.rook, PieceColor.white),
      );
      board.setPieceAt(
        Position(4, 6),
        ChessPiece(PieceType.pawn, PieceColor.black),
      );

      final moves = MoveCalculator.getRookMoves(Position(4, 4), board);

      // Rakip taşı yiyebilir
      expect(moves.contains(Position(4, 6)), true);
      expect(moves.contains(Position(4, 7)), false); // Ama geçemez
    });
  });

  group('MoveCalculator - Bishop Moves', () {
    test('Bishop moves on empty board', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.bishop, PieceColor.white),
      );

      final moves = MoveCalculator.getBishopMoves(Position(4, 4), board);
      expect(moves.length, 13); // 4 çapraz yön
    });
  });

  group('MoveCalculator - King Moves', () {
    test('King moves from center', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.king, PieceColor.white),
      );

      final moves = MoveCalculator.getKingMoves(Position(4, 4), board);
      expect(moves.length, 8); // Her yöne 1 kare
    });
  });

  group('MoveCalculator - Pawn Moves', () {
    test('White pawn initial move', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(6, 4),
        ChessPiece(PieceType.pawn, PieceColor.white),
      );

      final moves = MoveCalculator.getPawnMoves(Position(6, 4), board);
      expect(moves.length, 2); // 1 veya 2 kare ileri
      expect(moves.contains(Position(5, 4)), true);
      expect(moves.contains(Position(4, 4)), true);
    });

    test('Pawn capture diagonal', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(6, 4),
        ChessPiece(PieceType.pawn, PieceColor.white),
      );
      board.setPieceAt(
        Position(5, 3),
        ChessPiece(PieceType.pawn, PieceColor.black),
      );

      final moves = MoveCalculator.getPawnMoves(Position(6, 4), board);

      // İleri + çapraz alma
      expect(moves.contains(Position(5, 4)), true); // İleri
      expect(moves.contains(Position(5, 3)), true); // Çapraz alma
    });
  });
}
