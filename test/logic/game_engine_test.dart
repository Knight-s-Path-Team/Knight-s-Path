import 'package:flutter_test/flutter_test.dart';
import 'package:knights_path/logic/game_engine.dart';
import 'package:knights_path/logic/models/position.dart';
import 'package:knights_path/logic/models/piece.dart';

void main() {
  group('GameEngine - Basic Functionality', () {
    test('Initialize level correctly', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(7, 1), // b1
        targetPosition: Position(0, 0), // a8
        enemyPieces: {
          Position(4, 4): ChessPiece(PieceType.rook, PieceColor.black),
        },
        levelNumber: 1,
        description: 'Test Level',
      );

      engine.initializeLevel(levelData);

      expect(engine.gameState, GameState.playing);
      expect(engine.knightPosition, Position(7, 1));
      expect(engine.targetPosition, Position(0, 0));
      expect(engine.moveCount, 0);
    });

    test('Make valid move', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(7, 1),
        targetPosition: Position(0, 0),
        enemyPieces: {},
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      // Knight b1'den c3'e (valid L-move)
      final moved = engine.makeMove(Position(5, 2));
      expect(moved, true);
      expect(engine.knightPosition, Position(5, 2));
      expect(engine.moveCount, 1);
    });

    test('Reject invalid move', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(7, 1),
        targetPosition: Position(0, 0),
        enemyPieces: {},
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      // Invalid move (not L-shape)
      final moved = engine.makeMove(Position(6, 1));
      expect(moved, false);
      expect(engine.knightPosition, Position(7, 1)); // Unchanged
      expect(engine.moveCount, 0);
    });

    test('Reject move to threatened square', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(4, 4), // e4
        targetPosition: Position(0, 0),
        enemyPieces: {
          Position(2, 0): ChessPiece(PieceType.rook, PieceColor.black), // a6
        },
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      // Try to move to (2,3) - threatened by rook on row 2
      final moved = engine.makeMove(Position(2, 3));
      expect(moved, false);
      expect(engine.knightPosition, Position(4, 4)); // Unchanged
    });

    test('Win when reaching target', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(1, 2), // c7
        targetPosition: Position(0, 0), // a8
        enemyPieces: {},
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      // Move to target
      final moved = engine.makeMove(Position(0, 0));
      expect(moved, true);
      expect(engine.gameState, GameState.won);
    });

    test('Lose when no valid moves available', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(0, 0), // a8 (corner)
        targetPosition: Position(7, 7), // h1
        enemyPieces: {
          // Surround the knight with threats
          Position(1, 0): ChessPiece(PieceType.rook, PieceColor.black),
          Position(0, 1): ChessPiece(PieceType.rook, PieceColor.black),
        },
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      // Both possible knight moves from a8 are threatened
      // Game should recognize this after initialization
      expect(engine.getValidMoves().isEmpty, true);
    });
  });

  group('GameEngine - Move History', () {
    test('Undo move correctly', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(7, 1),
        targetPosition: Position(0, 0),
        enemyPieces: {},
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      // Make a move
      engine.makeMove(Position(5, 2));
      expect(engine.knightPosition, Position(5, 2));
      expect(engine.moveCount, 1);

      // Undo
      final undone = engine.undoMove();
      expect(undone, true);
      expect(engine.knightPosition, Position(7, 1));
      expect(engine.moveCount, 0);
    });

    test('Cannot undo when no moves made', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(7, 1),
        targetPosition: Position(0, 0),
        enemyPieces: {},
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      final undone = engine.undoMove();
      expect(undone, false);
    });

    test('Move history tracks correctly', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(7, 1),
        targetPosition: Position(0, 0),
        enemyPieces: {},
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      engine.makeMove(Position(5, 2));
      engine.makeMove(Position(3, 3));

      expect(engine.moveHistory.length, 2);
      expect(engine.moveHistory[0], Position(7, 1));
      expect(engine.moveHistory[1], Position(5, 2));
    });
  });

  group('GameEngine - Helper Functions', () {
    test('getValidMoves returns correct moves', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(4, 4),
        targetPosition: Position(0, 0),
        enemyPieces: {},
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      final validMoves = engine.getValidMoves();
      expect(validMoves.length, 8); // All 8 L-moves from center
    });

    test('getThreatenedSquares returns correct threats', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(7, 1),
        targetPosition: Position(0, 0),
        enemyPieces: {
          Position(4, 4): ChessPiece(PieceType.rook, PieceColor.black),
        },
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      final threatened = engine.getThreatenedSquares();

      // Rook threatens entire row and column
      expect(threatened.contains(Position(4, 0)), true);
      expect(threatened.contains(Position(0, 4)), true);
    });

    test('canReachTarget checks if target is reachable', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(1, 2),
        targetPosition: Position(0, 0),
        enemyPieces: {},
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      expect(engine.canReachTarget(), true);
    });

    test('canReachTarget returns false when target threatened', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(1, 2),
        targetPosition: Position(0, 0),
        enemyPieces: {
          Position(0, 5): ChessPiece(PieceType.rook, PieceColor.black),
        },
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      expect(engine.canReachTarget(), false);
    });
  });

  group('GameEngine - Minimum Moves Calculation', () {
    test('Calculate minimum moves for simple path', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(7, 1), // b1
        targetPosition: Position(5, 2), // c3
        enemyPieces: {},
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      final minMoves = engine.calculateMinimumMoves();
      expect(minMoves, 1); // Direct L-move
    });

    test('Calculate minimum moves returns null when unreachable', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(0, 0),
        targetPosition: Position(7, 7),
        enemyPieces: {
          // Completely surround knight
          Position(1, 0): ChessPiece(PieceType.queen, PieceColor.black),
          Position(0, 1): ChessPiece(PieceType.queen, PieceColor.black),
          Position(1, 1): ChessPiece(PieceType.queen, PieceColor.black),
          Position(2, 1): ChessPiece(PieceType.queen, PieceColor.black),
          Position(1, 2): ChessPiece(PieceType.queen, PieceColor.black),
        },
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);

      final minMoves = engine.calculateMinimumMoves();
      expect(minMoves, null); // Unreachable
    });
  });

  group('GameEngine - Reset', () {
    test('Reset clears game state', () {
      final engine = GameEngine();
      final levelData = LevelData(
        boardSize: 8,
        knightStartPosition: Position(7, 1),
        targetPosition: Position(0, 0),
        enemyPieces: {},
        levelNumber: 1,
      );

      engine.initializeLevel(levelData);
      engine.makeMove(Position(5, 2));

      engine.reset();

      expect(engine.gameState, GameState.notStarted);
      expect(engine.moveCount, 0);
      expect(engine.moveHistory.isEmpty, true);
    });
  });
}
