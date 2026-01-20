/// ========================================
/// POSITION - KONUM SİSTEMİ
/// ========================================
/// Satranç tahtasında bir kareyi temsil eder
/// 
/// KOORDINAT SİSTEMİ:
/// - row: Satır (0=üst, 7=alt)
/// - col: Sütun (0=sol, 7=sağ)
/// 
/// ÖRNEK:
/// Position(0, 0) = a8 (sol üst köşe)
/// Position(7, 7) = h1 (sağ alt köşe)
/// Position(7, 4) = e1
/// 
/// SATRANÇ NOTASYONU:
/// - a-h: sütunlar (soldan sağa)
/// - 1-8: satırlar (alttan yukarı)
/// ========================================
class Position {
  final int row;    // Satır numarası (0-7)
  final int col;    // Sütun numarası (0-7)

  /// Yeni bir pozisyon oluştur
  /// row: Satır (0-7), col: Sütun (0-7)
  const Position(this.row, this.col);

  /// Pozisyonun tahta sınırları içinde olup olmadığını kontrol eder
  /// 
  /// KULLANIM:
  /// Position(3, 4).isValid()  // true (e5 geçerli)
  /// Position(9, 9).isValid()  // false (tahtanın dışında)
  /// Position(-1, 3).isValid() // false (negatif değer)
  /// 
  /// boardSize: Tahta boyutu (varsayılan 8x8)
  bool isValid({int boardSize = 8}) {
    return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
  }

  /// Koordinatları satranç notasyonuna çevirir
  /// 
  /// DÖNÜŞÜM:
  /// Position(0, 0) -> "a8"  (sol üst)
  /// Position(7, 7) -> "h1"  (sağ alt)
  /// Position(3, 4) -> "e5"  (orta)
  /// 
  /// files: a-h sütunları
  /// rank: 8-1 satırları (yukarıdan aşağıya)
  String toChessNotation() {
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];  // Sütun isimleri
    final rank = 8 - row;  // Satır numarasını ters çevir (0->8, 7->1)
    return '${files[col]}$rank';  // "e5" gibi
  }

  /// Satranç notasyonundan Position oluşturur
  /// 
  /// DÖNÜŞÜM:
  /// "a8" -> Position(0, 0)  (sol üst)
  /// "h1" -> Position(7, 7)  (sağ alt)
  /// "e5" -> Position(3, 4)  (orta)
  /// 
  /// notation: "e4" gibi satranç notasyonu (harf+rakam)
  factory Position.fromChessNotation(String notation) {
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];  // Sütun isimleri
    final col = files.indexOf(notation[0]);  // İlk karakter sütunu verir ("e" -> 4)
    final row = 8 - int.parse(notation[1]);  // Rakamı ters çevir ("5" -> 3)
    return Position(row, col);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Position($row, $col) [${toChessNotation()}]';

  /// Mevcut pozisyondan yeni bir pozisyon oluşturur (kayma ile)
  /// 
  /// KULLANIM:
  /// Position(3, 4).offset(2, 1)  // Position(5, 5) - 2 aşağı, 1 sağa
  /// Position(3, 4).offset(-1, 0) // Position(2, 4) - 1 yukarı
  /// 
  /// At hareketi için kullanılır: offset(2, 1), offset(1, 2) vs.
  /// 
  /// rowDelta: Satır kayması (+aşağı, -yukarı)
  /// colDelta: Sütun kayması (+sağa, -sola)
  Position offset(int rowDelta, int colDelta) {
    return Position(row + rowDelta, col + colDelta);
  }
}
