import 'package:flutter/foundation.dart';
import 'models/board.dart';
import 'models/piece.dart';
import 'models/position.dart';
import 'validators/move_validator.dart';
import 'algorithms/threatened_squares.dart';

/// ========================================
/// GAME ENGINE - OYUN MOTORU
/// ========================================
/// 🎮 ANA KONTROL MERKEZİ - HER ŞEYİ YÖNETİR! 🎮
/// 
/// BU SINIF NE YAPAR:
/// Tüm parçaları birleştirir ve oyunu yönetir (orkestra şefi gibi)
/// 
/// SORUMLULUKLAR:
/// 1. Oyun durumunu yönetir (başladı mı, kazandı mı, kaybetti mi)
/// 2. At'ın pozisyonunu takip eder
/// 3. Hedef pozisyonu bilir
/// 4. Hamle yapılmasını kontrol eder
/// 5. Undo/Redo işlemlerini yönetir
/// 6. Tehdit hesaplamalarını yapar
/// 7. Geçerli hamleleri listeler
/// 8. Minimum hamle hesabı yapar (BFS algoritması)
/// 
/// UI (Person B) BU SINIFI KULLANACAK:
/// engine = GameEngine()
/// engine.initializeLevel(levelData)  // Oyunu başlat
/// engine.makeMove(position)          // Hamle yap
/// engine.getValidMoves()             // Gidebileceğin yerler
/// engine.undoMove()                  // Geri al
/// engine.gameState                   // Kazandın mı?
/// ========================================

/// Oyun durumu
enum GameState {
  playing,      // Oyun devam ediyor
  won,          // Oyuncu kazandı (hedefe ulaştı) 🎉
  lost,         // Oyuncu kaybetti (hareket edemiyor) 😢
  notStarted,   // Oyun henüz başlamadı
}

/// Level verisi - UI/Data ekibi level tasarlarken bunu kullanacak
/// 
/// ÖRNEK LEVEL:
/// LevelData(
///   boardSize: 8,
///   levelNumber: 1,
///   knightStartPosition: Position.fromChessNotation('b1'),  // At b1'de başlar
///   targetPosition: Position.fromChessNotation('h8'),       // Hedef h8
///   enemyPieces: {
///     Position.fromChessNotation('d4'): ChessPiece(PieceType.rook, PieceColor.black),
///   },  // d4'te kale var
///   description: 'Kale Tuzağı',
/// )
class LevelData {
  final int boardSize;                          // Tahta boyutu (8x8)
  final Position knightStartPosition;           // At nerede başlar
  final Position targetPosition;                // Hedefe nerede ulaşmalısın
  final Map<Position, ChessPiece> enemyPieces;  // Düşman taşlar nerede
  final int levelNumber;                        // Level numarası
  final String? description;                    // Level açıklaması (opsiyonel)

  const LevelData({
    required this.boardSize,
    required this.knightStartPosition,
    required this.targetPosition,
    required this.enemyPieces,
    required this.levelNumber,
    this.description,
  });
}

/// Knight's Path oyun motoru
/// Tüm oyun mantığını yöneten ana sınıf - UI buradan komut alır
class GameEngine {
  late ChessBoard _board;            // Satranç tahtası
  late Position _knightPosition;     // At'ın şu anki pozisyonu
  late Position _targetPosition;     // Hedef pozisyon
  GameState _gameState = GameState.notStarted;
  int _moveCount = 0;
  final List<Position> _moveHistory = [];

  // Getters
  ChessBoard get board => _board;
  Position get knightPosition => _knightPosition;
  Position get targetPosition => _targetPosition;
  GameState get gameState => _gameState;
  int get moveCount => _moveCount;
  List<Position> get moveHistory => List.unmodifiable(_moveHistory);

  /// Yeni bir seviye başlatır
  void initializeLevel(LevelData levelData) {
    _board = ChessBoard(size: levelData.boardSize);
    _knightPosition = levelData.knightStartPosition;
    _targetPosition = levelData.targetPosition;
    _moveCount = 0;
    _moveHistory.clear();

    // Knight'ı yerleştir (beyaz)
    _board.setPieceAt(
      _knightPosition,
      const ChessPiece(PieceType.knight, PieceColor.white),
    );

    // Düşman taşları yerleştir (siyah)
    levelData.enemyPieces.forEach((position, piece) {
      _board.setPieceAt(position, piece);
    });

    _gameState = GameState.playing;
  }

  /// Knight'ı hareket ettirir
  /// Returns: Hamle başarılı olursa true, aksi halde false
  bool makeMove(Position to) {
    if (_gameState != GameState.playing) {
      return false;
    }

    // Hamleyi doğrula
    final validationResult = MoveValidator.validateMove(
      _knightPosition,
      to,
      _board,
      enemyColor: PieceColor.black,
    );

    if (!validationResult.isValid) {
      return false;
    }

    // Hareketi yap
    final knight = _board.getPieceAt(_knightPosition);
    _board.setPieceAt(_knightPosition, null); // Eski pozisyonu temizle
    _board.setPieceAt(to, knight); // Yeni pozisyona taşı

    _moveHistory.add(_knightPosition);
    _knightPosition = to;
    _moveCount++;

    // Oyun durumunu kontrol et
    _checkGameState();

    return true;
  }

  /// Hamleyi geri alır (undo)
  bool undoMove() {
    if (_moveHistory.isEmpty) {
      return false;
    }

    final previousPosition = _moveHistory.removeLast();
    final knight = _board.getPieceAt(_knightPosition);

    _board.setPieceAt(_knightPosition, null);
    _board.setPieceAt(previousPosition, knight);

    _knightPosition = previousPosition;
    _moveCount--;

    // Oyun durumunu yeniden kontrol et
    if (_gameState == GameState.lost) {
      _gameState = GameState.playing;
    }

    return true;
  }

  /// Geçerli tüm hareketleri döndürür
  List<Position> getValidMoves() {
    if (_gameState != GameState.playing) {
      return [];
    }

    return MoveValidator.getValidMoves(
      _knightPosition,
      _board,
      PieceColor.black,
    );
  }

  /// Tehdit altındaki kareleri döndürür
  Set<Position> getThreatenedSquares() {
    return ThreatenedSquaresCalculator.calculateThreatenedSquares(
      _board,
      PieceColor.black,
    );
  }

  /// Belirli bir karenin tehdit altında olup olmadığını kontrol eder
  bool isSquareThreatened(Position position) {
    return ThreatenedSquaresCalculator.isSquareThreatened(
      position,
      _board,
      PieceColor.black,
    );
  }

  /// Hedefe ulaşılıp ulaşılamayacağını kontrol eder
  bool canReachTarget() {
    return MoveValidator.canReachTarget(
      _knightPosition,
      _targetPosition,
      _board,
      PieceColor.black,
    );
  }

  /// Oyun durumunu kontrol eder
  void _checkGameState() {
    // Hedefe ulaşıldı mı?
    if (_knightPosition == _targetPosition) {
      _gameState = GameState.won;
      return;
    }

    // Geçerli hamle kaldı mı?
    if (!MoveValidator.hasAnyValidMove(
      _knightPosition,
      _board,
      PieceColor.black,
    )) {
      _gameState = GameState.lost;
      return;
    }

    _gameState = GameState.playing;
  }

  /// Oyunu sıfırlar
  void reset() {
    _gameState = GameState.notStarted;
    _moveCount = 0;
    _moveHistory.clear();
  }

  /// Minimum hamle sayısını hesaplar (BFS algoritması ile)
  /// Bu, level tasarımı için faydalı olabilir
  int? calculateMinimumMoves() {
    if (_gameState == GameState.notStarted) {
      return null;
    }

    final queue = <({Position pos, int moves})>[
      (pos: _knightPosition, moves: 0),
    ];
    final visited = <Position>{_knightPosition};

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      if (current.pos == _targetPosition) {
        return current.moves;
      }

      final validMoves = MoveValidator.getValidMoves(
        current.pos,
        _board,
        PieceColor.black,
      );

      for (final move in validMoves) {
        if (!visited.contains(move)) {
          visited.add(move);
          queue.add((pos: move, moves: current.moves + 1));
        }
      }
    }

    return null; // Hedefe ulaşılamıyor
  }

  /// Debug için oyun durumunu yazdırır
  void printGameState() {
    // ignore: avoid_print
    debugPrint('=== Knight\'s Path - Game State ===');
    // ignore: avoid_print
    debugPrint('State: $_gameState');
    // ignore: avoid_print
    debugPrint('Move Count: $_moveCount');
    // ignore: avoid_print
    debugPrint('Knight Position: $_knightPosition');
    // ignore: avoid_print
    debugPrint('Target Position: $_targetPosition');
    // ignore: avoid_print
    debugPrint('Valid Moves: ${getValidMoves().length}');
    // ignore: avoid_print
    debugPrint('\nBoard:');
    _board.printBoard();
    // ignore: avoid_print
    debugPrint('===================================');
  }
}
