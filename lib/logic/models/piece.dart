/// ========================================
/// PIECE - TAŞ SİSTEMİ
/// ========================================
/// Satranç taşlarını temsil eder
/// 
/// TAŞ TİPLERİ:
/// - King (Şah): Her yöne 1 kare
/// - Queen (Vezir): Her yöne sınırsız
/// - Rook (Kale): Yatay/dikey sınırsız
/// - Bishop (Fil): Çapraz sınırsız
/// - Knight (At): L-şekli (2+1 veya 1+2)
/// - Pawn (Piyon): İleri 1, çapraz vurur
/// 
/// RENKLER:
/// - White (Beyaz): Oyuncunun taşı
/// - Black (Siyah): Düşman taşlar
/// ========================================

/// Satranç taşı rengi
/// white = beyaz (oyuncu), black = siyah (düşman)
enum PieceColor { 
  white,   // Beyaz - oyuncunun taşları
  black    // Siyah - düşman taşlar
}

/// Satranç taşı tipleri
/// Her taşın kendine özgü hareket kuralları var
enum PieceType { 
  king,     // Şah - her yöne 1 kare
  queen,    // Vezir - her yöne sınırsız
  rook,     // Kale - düz çizgilerde sınırsız
  bishop,   // Fil - çapraz sınırsız
  knight,   // At - L-şekli (2+1)
  pawn      // Piyon - ileri 1, çapraz vurur
}

/// Bir satranç taşını temsil eder
/// 
/// KULLANIM:
/// ChessPiece(PieceType.knight, PieceColor.white)  // Beyaz at
/// ChessPiece(PieceType.rook, PieceColor.black)    // Siyah kale
/// 
/// type: Taş tipi (at, kale, vezir vs.)
/// color: Taş rengi (beyaz/siyah)
class ChessPiece {
  final PieceType type;    // Taş tipi (king, queen, rook vs.)
  final PieceColor color;  // Taş rengi (white, black)

  /// Yeni bir satranç taşı oluştur
  const ChessPiece(this.type, this.color);

  /// Taşın Unicode sembolünü döndürür
  /// 
  /// BEYAZ SEMBOLLER:
  /// ♔ = Şah,  ♕ = Vezir,  ♖ = Kale
  /// ♗ = Fil,  ♘ = At,     ♙ = Piyon
  /// 
  /// SİYAH SEMBOLLER:
  /// ♚ = Şah,  ♛ = Vezir,  ♜ = Kale
  /// ♝ = Fil,  ♞ = At,     ♟ = Piyon
  /// 
  /// UI bu sembolleri ekranda gösterir
  String get symbol {
    // Beyaz taşların Unicode sembolleri
    const whiteSymbols = {
      PieceType.king: '♔',     // Beyaz şah
      PieceType.queen: '♕',    // Beyaz vezir
      PieceType.rook: '♖',     // Beyaz kale
      PieceType.bishop: '♗',   // Beyaz fil
      PieceType.knight: '♘',   // Beyaz at
      PieceType.pawn: '♙',     // Beyaz piyon
    };

    // Siyah taşların Unicode sembolleri
    const blackSymbols = {
      PieceType.king: '♚',     // Siyah şah
      PieceType.queen: '♛',    // Siyah vezir
      PieceType.rook: '♜',     // Siyah kale
      PieceType.bishop: '♝',   // Siyah fil
      PieceType.knight: '♞',   // Siyah at
      PieceType.pawn: '♟',     // Siyah piyon
    };

    // Renge göre doğru sembolü seç
    return color == PieceColor.white
        ? whiteSymbols[type]!   // Beyaz ise beyaz sembol
        : blackSymbols[type]!;  // Siyah ise siyah sembol
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
