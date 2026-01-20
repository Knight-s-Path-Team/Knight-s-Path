import '../models/board.dart';
import '../models/piece.dart';
import '../models/position.dart';
import '../models/move_calculator.dart';

/// Tehdit altındaki kareleri hesaplayan ana algoritma sınıfı
/// Bu, Knight's Path oyununun en kritik bileşenidir!
class ThreatenedSquaresCalculator {
  /// Belirli bir rengin kontrol ettiği tüm kareleri hesaplar
  /// 
  /// Bu algoritma:
  /// 1. Tahtadaki belirli renkteki tüm taşları bulur
  /// 2. Her taş için geçerli hareket edebileceği kareleri hesaplar
  /// 3. Bu kareleri "tehdit altında" olarak işaretler
  /// 
  /// [board]: Satranç tahtası
  /// [threateningColor]: Tehdit eden taşların rengi (örn: siyah taşlar)
  /// Returns: Tehdit altındaki pozisyonların Set'i
  static Set<Position> calculateThreatenedSquares(
    ChessBoard board,
    PieceColor threateningColor,
  ) {
    final threatenedSquares = <Position>{};

    // Tehdit eden renkteki tüm taşları bul
    final threateningPieces = board.getPiecesByColor(threateningColor);

    // Her bir rakip taş için kontrol ettiği kareleri hesapla
    for (final entry in threateningPieces.entries) {
      final piecePosition = entry.key;
      final piece = entry.value;

      // Bu taşın hareket edebileceği tüm kareleri al
      final attackedSquares = _getAttackedSquares(
        piecePosition,
        piece,
        board,
      );

      // Bu kareleri tehdit altında olarak ekle
      threatenedSquares.addAll(attackedSquares);
    }

    return threatenedSquares;
  }

  /// Belirli bir taşın saldırabileceği kareleri hesaplar
  /// 
  /// Pawn (Piyon) için özel durum: Piyon sadece çapraz saldırır!
  /// Diğer taşlar için normal hareket kareleri = saldırı kareleri
  static Set<Position> _getAttackedSquares(
    Position from,
    ChessPiece piece,
    ChessBoard board,
  ) {
    final attackedSquares = <Position>{};

    switch (piece.type) {
      case PieceType.pawn:
        // Piyon için özel durum: Sadece çapraz saldırır
        attackedSquares.addAll(_getPawnAttackSquares(from, piece, board.size));
        break;

      case PieceType.knight:
        // Knight için L-şeklindeki tüm kareler
        attackedSquares.addAll(
          MoveCalculator.getKnightMoves(from, boardSize: board.size),
        );
        break;

      case PieceType.king:
        // King için etrafındaki 8 kare
        attackedSquares.addAll(_getKingAttackSquares(from, board.size));
        break;

      case PieceType.rook:
        // Rook için yatay ve dikey çizgiler
        attackedSquares.addAll(_getRookAttackSquares(from, board));
        break;

      case PieceType.bishop:
        // Bishop için çapraz çizgiler
        attackedSquares.addAll(_getBishopAttackSquares(from, board));
        break;

      case PieceType.queen:
        // Queen için rook + bishop
        attackedSquares.addAll(_getRookAttackSquares(from, board));
        attackedSquares.addAll(_getBishopAttackSquares(from, board));
        break;
    }

    return attackedSquares;
  }

  /// Pawn'un saldırabileceği kareleri döndürür (sadece çapraz)
  static Set<Position> _getPawnAttackSquares(
    Position from,
    ChessPiece pawn,
    int boardSize,
  ) {
    final attacks = <Position>{};
    final direction = pawn.color == PieceColor.white ? -1 : 1;

    // Çapraz saldırı kareleri
    final leftDiagonal = Position(from.row + direction, from.col - 1);
    final rightDiagonal = Position(from.row + direction, from.col + 1);

    if (leftDiagonal.isValid(boardSize: boardSize)) {
      attacks.add(leftDiagonal);
    }
    if (rightDiagonal.isValid(boardSize: boardSize)) {
      attacks.add(rightDiagonal);
    }

    return attacks;
  }

  /// King'in saldırabileceği kareleri döndürür (etrafındaki 8 kare)
  static Set<Position> _getKingAttackSquares(Position from, int boardSize) {
    final attacks = <Position>{};
    final directions = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1],
    ];

    for (final dir in directions) {
      final pos = Position(from.row + dir[0], from.col + dir[1]);
      if (pos.isValid(boardSize: boardSize)) {
        attacks.add(pos);
      }
    }

    return attacks;
  }

  /// Rook'un saldırabileceği kareleri döndürür (yatay ve dikey)
  static Set<Position> _getRookAttackSquares(Position from, ChessBoard board) {
    final attacks = <Position>{};
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

        attacks.add(pos);

        // Taş varsa durur (ama o kareyi de kontrol eder)
        if (board.getPieceAt(pos) != null) break;

        row += dir[0];
        col += dir[1];
      }
    }

    return attacks;
  }

  /// Bishop'un saldırabileceği kareleri döndürür (çapraz)
  static Set<Position> _getBishopAttackSquares(
    Position from,
    ChessBoard board,
  ) {
    final attacks = <Position>{};
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

        attacks.add(pos);

        // Taş varsa durur (ama o kareyi de kontrol eder)
        if (board.getPieceAt(pos) != null) break;

        row += dir[0];
        col += dir[1];
      }
    }

    return attacks;
  }

  /// Bir pozisyonun tehdit altında olup olmadığını kontrol eder
  /// 
  /// [position]: Kontrol edilecek pozisyon
  /// [board]: Satranç tahtası
  /// [threateningColor]: Tehdit eden taşların rengi
  static bool isSquareThreatened(
    Position position,
    ChessBoard board,
    PieceColor threateningColor,
  ) {
    final threatenedSquares = calculateThreatenedSquares(board, threateningColor);
    return threatenedSquares.contains(position);
  }

  /// Knight için güvenli hareketleri hesaplar (tehdit altında olmayan)
  /// 
  /// Bu, Knight's Path oyununda kritik fonksiyon:
  /// - Knight'ın hareket edebileceği tüm L-şeklindeki kareleri bulur
  /// - Bunlardan tehdit altında olmayanları filtreler
  /// 
  /// [knightPosition]: Knight'ın mevcut pozisyonu
  /// [board]: Satranç tahtası
  /// [enemyColor]: Düşman taşların rengi
  static List<Position> getSafeKnightMoves(
    Position knightPosition,
    ChessBoard board,
    PieceColor enemyColor,
  ) {
    // Tüm geçerli Knight hareketlerini al
    final allKnightMoves = MoveCalculator.getKnightMoves(
      knightPosition,
      boardSize: board.size,
    );

    // Düşman taşların kontrol ettiği kareleri hesapla
    final threatenedSquares = calculateThreatenedSquares(board, enemyColor);

    // Sadece güvenli kareleri döndür
    return allKnightMoves
        .where((move) => !threatenedSquares.contains(move))
        .toList();
  }

  /// Belirli bir hareketin güvenli olup olmadığını kontrol eder
  /// 
  /// [from]: Başlangıç pozisyonu
  /// [to]: Hedef pozisyon
  /// [board]: Satranç tahtası
  /// [enemyColor]: Düşman rengi
  static bool isMoveToSafeSquare(
    Position from,
    Position to,
    ChessBoard board,
    PieceColor enemyColor,
  ) {
    // Hedef karenin tehdit altında olup olmadığını kontrol et
    return !isSquareThreatened(to, board, enemyColor);
  }
}
