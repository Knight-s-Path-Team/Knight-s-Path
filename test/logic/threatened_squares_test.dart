import 'package:flutter_test/flutter_test.dart';
import 'package:knights_path/logic/models/position.dart';
import 'package:knights_path/logic/models/piece.dart';
import 'package:knights_path/logic/models/board.dart';
import 'package:knights_path/logic/algorithms/threatened_squares.dart';

void main() {
  group('ThreatenedSquares - Knight Threats', () {
    test('Single knight threatens 8 squares from center', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.knight, PieceColor.black),
      );

      final threatened = ThreatenedSquaresCalculator.calculateThreatenedSquares(
        board,
        PieceColor.black,
      );

      expect(threatened.length, 8);
      expect(threatened.contains(Position(2, 3)), true);
      expect(threatened.contains(Position(2, 5)), true);
      expect(threatened.contains(Position(6, 3)), true);
      expect(threatened.contains(Position(6, 5)), true);
    });

    test('Multiple knights threat zones combine', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(2, 2),
        ChessPiece(PieceType.knight, PieceColor.black),
      );
      board.setPieceAt(
        Position(5, 5),
        ChessPiece(PieceType.knight, PieceColor.black),
      );

      final threatened = ThreatenedSquaresCalculator.calculateThreatenedSquares(
        board,
        PieceColor.black,
      );

      // Her iki knight'ın tehdit ettiği karelerin birleşimi
      expect(threatened.length, greaterThan(0));
    });
  });

  group('ThreatenedSquares - Rook Threats', () {
    test('Rook threatens entire row and column', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.rook, PieceColor.black),
      );

      final threatened = ThreatenedSquaresCalculator.calculateThreatenedSquares(
        board,
        PieceColor.black,
      );

      // 4. satır ve 4. sütun
      expect(threatened.contains(Position(4, 0)), true);
      expect(threatened.contains(Position(4, 7)), true);
      expect(threatened.contains(Position(0, 4)), true);
      expect(threatened.contains(Position(7, 4)), true);

      // Çapraz tehdit yok
      expect(threatened.contains(Position(5, 5)), false);
    });

    test('Rook threat blocked by piece', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.rook, PieceColor.black),
      );
      board.setPieceAt(
        Position(4, 6),
        ChessPiece(PieceType.pawn, PieceColor.black),
      );

      final threatened = ThreatenedSquaresCalculator.calculateThreatenedSquares(
        board,
        PieceColor.black,
      );

      // Piyon ve önceki kareler tehdit altında
      expect(threatened.contains(Position(4, 5)), true);
      expect(threatened.contains(Position(4, 6)), true);
      // Ama arkası tehdit altında değil
      expect(threatened.contains(Position(4, 7)), false);
    });
  });

  group('ThreatenedSquares - Bishop Threats', () {
    test('Bishop threatens diagonals', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.bishop, PieceColor.black),
      );

      final threatened = ThreatenedSquaresCalculator.calculateThreatenedSquares(
        board,
        PieceColor.black,
      );

      // Çapraz kareler
      expect(threatened.contains(Position(3, 3)), true);
      expect(threatened.contains(Position(2, 2)), true);
      expect(threatened.contains(Position(5, 5)), true);
      expect(threatened.contains(Position(6, 6)), true);

      // Düz çizgi tehdit yok
      expect(threatened.contains(Position(4, 5)), false);
      expect(threatened.contains(Position(5, 4)), false);
    });
  });

  group('ThreatenedSquares - Queen Threats', () {
    test('Queen threatens all directions', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.queen, PieceColor.black),
      );

      final threatened = ThreatenedSquaresCalculator.calculateThreatenedSquares(
        board,
        PieceColor.black,
      );

      // Yatay
      expect(threatened.contains(Position(4, 0)), true);
      // Dikey
      expect(threatened.contains(Position(0, 4)), true);
      // Çapraz
      expect(threatened.contains(Position(2, 2)), true);
      expect(threatened.contains(Position(6, 6)), true);
    });
  });

  group('ThreatenedSquares - Pawn Threats', () {
    test('White pawn threatens diagonal squares only', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(6, 4),
        ChessPiece(PieceType.pawn, PieceColor.white),
      );

      final threatened = ThreatenedSquaresCalculator.calculateThreatenedSquares(
        board,
        PieceColor.white,
      );

      // Sadece çapraz kareler tehdit altında
      expect(threatened.contains(Position(5, 3)), true);
      expect(threatened.contains(Position(5, 5)), true);

      // İleri kare tehdit altında değil
      expect(threatened.contains(Position(5, 4)), false);
    });

    test('Black pawn threatens downward diagonals', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(1, 4),
        ChessPiece(PieceType.pawn, PieceColor.black),
      );

      final threatened = ThreatenedSquaresCalculator.calculateThreatenedSquares(
        board,
        PieceColor.black,
      );

      expect(threatened.contains(Position(2, 3)), true);
      expect(threatened.contains(Position(2, 5)), true);
    });
  });

  group('ThreatenedSquares - King Threats', () {
    test('King threatens all 8 adjacent squares', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.king, PieceColor.black),
      );

      final threatened = ThreatenedSquaresCalculator.calculateThreatenedSquares(
        board,
        PieceColor.black,
      );

      expect(threatened.length, 8);
      expect(threatened.contains(Position(3, 3)), true);
      expect(threatened.contains(Position(3, 4)), true);
      expect(threatened.contains(Position(3, 5)), true);
      expect(threatened.contains(Position(4, 3)), true);
      expect(threatened.contains(Position(4, 5)), true);
      expect(threatened.contains(Position(5, 3)), true);
      expect(threatened.contains(Position(5, 4)), true);
      expect(threatened.contains(Position(5, 5)), true);
    });
  });

  group('ThreatenedSquares - Helper Functions', () {
    test('isSquareThreatened returns correct result', () {
      final board = ChessBoard();
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.knight, PieceColor.black),
      );

      expect(
        ThreatenedSquaresCalculator.isSquareThreatened(
          Position(2, 3),
          board,
          PieceColor.black,
        ),
        true,
      );

      expect(
        ThreatenedSquaresCalculator.isSquareThreatened(
          Position(0, 0),
          board,
          PieceColor.black,
        ),
        false,
      );
    });

    test('getSafeKnightMoves filters threatened squares', () {
      final board = ChessBoard();

      // Beyaz knight
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.knight, PieceColor.white),
      );

      // Siyah rook (2,0) konumunda - 2. satır ve 0. sütunu tehdit eder
      board.setPieceAt(
        Position(2, 0),
        ChessPiece(PieceType.rook, PieceColor.black),
      );

      final safeMoves = ThreatenedSquaresCalculator.getSafeKnightMoves(
        Position(4, 4),
        board,
        PieceColor.black,
      );

      // Knight (4,4)'den 8 hareket var
      // (2,3), (2,5) -> 2. satırda, rook tarafından tehdit altında
      // (3,2), (5,2), (6,3) gibi karelerde 0. sütunda değil

      expect(
        safeMoves.contains(Position(2, 3)),
        false,
      ); // 2. satırda, tehdit altında
      expect(
        safeMoves.contains(Position(2, 5)),
        false,
      ); // 2. satırda, tehdit altında
      expect(safeMoves.contains(Position(6, 3)), true); // Güvenli
      expect(safeMoves.contains(Position(6, 5)), true); // Güvenli
    });
  });

  group('ThreatenedSquares - Complex Scenarios', () {
    test('Multiple pieces create complex threat pattern', () {
      final board = ChessBoard();

      // Siyah taşlar
      board.setPieceAt(
        Position(0, 0),
        ChessPiece(PieceType.rook, PieceColor.black),
      );
      board.setPieceAt(
        Position(7, 7),
        ChessPiece(PieceType.bishop, PieceColor.black),
      );
      board.setPieceAt(
        Position(4, 4),
        ChessPiece(PieceType.queen, PieceColor.black),
      );

      final threatened = ThreatenedSquaresCalculator.calculateThreatenedSquares(
        board,
        PieceColor.black,
      );

      // Queen'in merkezi kontrol etmesi
      expect(threatened.contains(Position(4, 0)), true);
      expect(threatened.contains(Position(0, 4)), true);
      expect(threatened.contains(Position(2, 2)), true);

      // Rook'un 0. satırı kontrol etmesi
      expect(threatened.contains(Position(0, 5)), true);

      // Bishop'un çaprazı kontrol etmesi
      expect(threatened.contains(Position(6, 6)), true);
    });

    test('Realistic game scenario', () {
      final board = ChessBoard();

      // Fotoğraftaki gibi bir senaryo: At c7'de, hedef a8
      board.setPieceAt(
        Position.fromChessNotation('c7'),
        ChessPiece(PieceType.knight, PieceColor.white),
      );

      // Siyah vezir b8'de (a8'i tehdit ediyor)
      board.setPieceAt(
        Position.fromChessNotation('b8'),
        ChessPiece(PieceType.queen, PieceColor.black),
      );

      final knightPos = Position.fromChessNotation('c7');
      final targetPos = Position.fromChessNotation('a8');

      final safeMoves = ThreatenedSquaresCalculator.getSafeKnightMoves(
        knightPos,
        board,
        PieceColor.black,
      );

      // a8 tehdit altında olmalı (vezir var)
      expect(safeMoves.contains(targetPos), false);
    });
  });
}
