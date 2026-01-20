import '../models/board.dart';
import '../models/piece.dart';
import '../models/position.dart';
import '../models/move_calculator.dart';
import '../algorithms/threatened_squares.dart';

/// Hamle doğrulama sonucu
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult.valid() : isValid = true, errorMessage = null;
  
  const ValidationResult.invalid(this.errorMessage) : isValid = false;

  @override
  String toString() => isValid 
      ? 'Valid move' 
      : 'Invalid move: $errorMessage';
}

/// Satranç hamleleri için doğrulama sınıfı
/// Knight's Path oyunu için özel kurallar içerir
class MoveValidator {
  /// Bir hamlenin geçerli olup olmadığını kontrol eder
  /// 
  /// Knight's Path kuralları:
  /// 1. Taş Knight olmalı
  /// 2. Hareket L-şeklinde olmalı
  /// 3. Hedef kare tehdit altında olmamalı (oyunun ana kuralı!)
  /// 4. Hedef karede kendi renginden taş olmamalı
  static ValidationResult validateMove(
    Position from,
    Position to,
    ChessBoard board, {
    required PieceColor enemyColor,
    bool checkThreats = true,
  }) {
    // Başlangıç karesinde taş var mı?
    final piece = board.getPieceAt(from);
    if (piece == null) {
      return const ValidationResult.invalid('Başlangıç karesinde taş yok');
    }

    // Knight kontrolü (Knight's Path için)
    if (piece.type != PieceType.knight) {
      return const ValidationResult.invalid('Sadece Knight (At) hareket edebilir');
    }

    // Hedef kare geçerli mi?
    if (!to.isValid(boardSize: board.size)) {
      return const ValidationResult.invalid('Hedef kare tahta dışında');
    }

    // Kendi taşını yiyemez
    final targetPiece = board.getPieceAt(to);
    if (targetPiece != null && targetPiece.color == piece.color) {
      return const ValidationResult.invalid('Kendi taşınızı yiyemezsiniz');
    }

    // L-şeklinde hareket kontrolü
    if (!_isValidKnightMove(from, to)) {
      return const ValidationResult.invalid(
        'Knight sadece L-şeklinde hareket edebilir (2+1 kare)'
      );
    }

    // Tehdit kontrolü (Knight's Path'in ana kuralı!)
    if (checkThreats) {
      final isThreatened = ThreatenedSquaresCalculator.isSquareThreatened(
        to,
        board,
        enemyColor,
      );

      if (isThreatened) {
        return const ValidationResult.invalid(
          'Bu kare düşman taşlar tarafından tehdit altında! Buraya gidemezsiniz.'
        );
      }
    }

    return const ValidationResult.valid();
  }

  /// Knight'ın L-şeklinde hareket edip etmediğini kontrol eder
  /// L-şekli: 2 kare bir yönde + 1 kare dik yönde
  static bool _isValidKnightMove(Position from, Position to) {
    final rowDiff = (from.row - to.row).abs();
    final colDiff = (from.col - to.col).abs();

    // L-şekli: (2,1) veya (1,2)
    return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);
  }

  /// Knight için tüm geçerli ve güvenli hareketleri döndürür
  static List<Position> getValidMoves(
    Position from,
    ChessBoard board,
    PieceColor enemyColor, {
    bool checkThreats = true,
  }) {
    final piece = board.getPieceAt(from);
    if (piece == null || piece.type != PieceType.knight) {
      return [];
    }

    // Tüm olası Knight hareketlerini al
    final possibleMoves = MoveCalculator.getKnightMoves(
      from,
      boardSize: board.size,
    );

    // Her hareketi doğrula
    final validMoves = <Position>[];
    for (final move in possibleMoves) {
      final result = validateMove(
        from,
        move,
        board,
        enemyColor: enemyColor,
        checkThreats: checkThreats,
      );

      if (result.isValid) {
        validMoves.add(move);
      }
    }

    return validMoves;
  }

  /// Oyuncunun hareket edebileceği herhangi bir geçerli hamle olup olmadığını kontrol eder
  /// Mat durumu veya oyun bitişi için kullanılabilir
  static bool hasAnyValidMove(
    Position knightPosition,
    ChessBoard board,
    PieceColor enemyColor,
  ) {
    final validMoves = getValidMoves(
      knightPosition,
      board,
      enemyColor,
    );

    return validMoves.isNotEmpty;
  }

  /// Hedef kareye ulaşılıp ulaşılamayacağını kontrol eder
  static bool canReachTarget(
    Position knightPosition,
    Position targetPosition,
    ChessBoard board,
    PieceColor enemyColor,
  ) {
    final validMoves = getValidMoves(
      knightPosition,
      board,
      enemyColor,
    );

    return validMoves.contains(targetPosition);
  }
}
