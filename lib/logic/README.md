# Knight's Path - Logic Engine 🐴♟️

## Proje Genel Bakış

Knight's Path, satranç tahtasında At (Knight) taşının L-şeklinde hareketlerini kullanarak hedefe ulaşma oyunudur. **En kritik özellik**: Oyuncu, rakip taşların tehdit ettiği karelere giremez!

## Görev Dağılımı

### ✅ Kişi A (Logic & Core) - TAMAMLANDI
- ✅ Satranç motoru
- ✅ Hareket kısıtlamaları  
- ✅ **Tehdit Altındaki Kareler algoritması** (En kritik!)

### 🎨 Kişi B (UI/UX & State)
- Flutter arayüzü
- Animasyonlar
- Level geçişleri
- State Management (Riverpod/Bloc)

### 📊 Kişi C (Data & Business)
- Level tasarımı (JSON)
- AdMob entegrasyonu
- Firebase Analytics
- Local storage

---

## 📂 Klasör Yapısı

```
lib/logic/
├── models/
│   ├── position.dart           # Satranç tahtası pozisyonları
│   ├── piece.dart              # Taş tipleri ve renkleri
│   ├── board.dart              # Satranç tahtası yönetimi
│   └── move_calculator.dart    # Taş hareket hesaplamaları
│
├── algorithms/
│   └── threatened_squares.dart # 🔥 TEHDİT ALGORİTMASI (KRİTİK!)
│
├── validators/
│   └── move_validator.dart     # Hamle doğrulama
│
└── game_engine.dart            # Ana oyun motoru
```

---

## 🎯 Ana Özellikler

### 1️⃣ Position (Pozisyon Yönetimi)
- Satranç notasyonu desteği (örn: "e4", "a8")
- Tahta sınır kontrolü
- Pozisyon eşitlik kontrolü

```dart
final pos = Position(4, 4);  // e4
print(pos.toChessNotation()); // "e4"

final pos2 = Position.fromChessNotation('a8');
```

### 2️⃣ ChessBoard (Tahta Yönetimi)
- Dinamik tahta boyutu (8x8, 12x12, vb.)
- Taş yerleştirme/kaldırma
- Renk ve tipe göre taş filtreleme

```dart
final board = ChessBoard(size: 8);
board.setPieceAt(
  Position(4, 4),
  ChessPiece(PieceType.knight, PieceColor.white),
);
```

### 3️⃣ Threatened Squares (🔥 EN KRİTİK!)
**Bu algoritma oyunun kalbini oluşturur!**

- Her taş tipinin saldırı paternini hesaplar
- Knight için L-şeklindeki 8 kare
- Rook için yatay/dikey çizgiler
- Bishop için çapraz çizgiler
- Queen için tüm yönler
- Pawn için sadece çapraz saldırı
- King için 8 komşu kare

```dart
// Siyah taşların tehdit ettiği tüm kareleri bul
final threatened = ThreatenedSquaresCalculator.calculateThreatenedSquares(
  board,
  PieceColor.black,
);

// Belirli bir kare tehdit altında mı?
if (threatened.contains(targetPosition)) {
  print('Bu kareye gidemezsiniz!');
}

// Knight için sadece GÜVENLİ hareketleri al
final safeMoves = ThreatenedSquaresCalculator.getSafeKnightMoves(
  knightPosition,
  board,
  PieceColor.black,
);
```

### 4️⃣ Move Validator (Hamle Doğrulama)
Knight's Path kurallarına göre hamle doğrular:

1. ✅ Taş Knight olmalı
2. ✅ L-şeklinde hareket olmalı
3. ✅ **Hedef kare tehdit altında olmamalı** (oyunun ana kuralı!)
4. ✅ Kendi taşını yiyemez

```dart
final result = MoveValidator.validateMove(
  from: Position(4, 4),
  to: Position(2, 3),
  board: board,
  enemyColor: PieceColor.black,
);

if (result.isValid) {
  print('Geçerli hamle!');
} else {
  print('Hata: ${result.errorMessage}');
}
```

### 5️⃣ Game Engine (Oyun Motoru)
Tüm logic parçalarını birleştirir:

```dart
final engine = GameEngine();

// Level'i başlat
engine.initializeLevel(LevelData(
  boardSize: 8,
  knightStartPosition: Position.fromChessNotation('b1'),
  targetPosition: Position.fromChessNotation('a8'),
  enemyPieces: {
    Position.fromChessNotation('d4'): 
      ChessPiece(PieceType.rook, PieceColor.black),
  },
  levelNumber: 1,
));

// Hamle yap
if (engine.makeMove(Position.fromChessNotation('c3'))) {
  print('Hamle başarılı!');
}

// Oyun durumunu kontrol et
switch (engine.gameState) {
  case GameState.won:
    print('🎉 Kazandınız!');
  case GameState.lost:
    print('😢 Kaybettiniz - Hamle kalmadı!');
  case GameState.playing:
    print('Oyun devam ediyor...');
}

// Geri al
engine.undoMove();

// Minimum hamle sayısını hesapla (BFS algoritması)
final minMoves = engine.calculateMinimumMoves();
print('En az $minMoves hamle gerekli');
```

---

## 🧪 Test Coverage

**50/50 test geçti! ✅**

```bash
flutter test test/logic/
```

### Test Grupları:
- ✅ Position Tests (5 test)
- ✅ ChessPiece Tests (2 test)
- ✅ ChessBoard Tests (6 test)
- ✅ MoveCalculator Tests (7 test)
- ✅ ThreatenedSquares Tests (17 test)
- ✅ GameEngine Tests (13 test)

---

## 🚀 Kullanım Örneği

```dart
import 'package:knights_path/logic/game_engine.dart';
import 'package:knights_path/logic/models/position.dart';
import 'package:knights_path/logic/models/piece.dart';

void main() {
  final engine = GameEngine();
  
  // Basit bir level
  final level = LevelData(
    boardSize: 8,
    knightStartPosition: Position.fromChessNotation('b1'),
    targetPosition: Position.fromChessNotation('a8'),
    enemyPieces: {
      Position.fromChessNotation('d4'): 
        ChessPiece(PieceType.rook, PieceColor.black),
      Position.fromChessNotation('f6'): 
        ChessPiece(PieceType.bishop, PieceColor.black),
    },
    levelNumber: 1,
    description: 'İlk seviye - Kale ve Fil tuzakları',
  );
  
  engine.initializeLevel(level);
  
  // Geçerli hareketleri göster
  final validMoves = engine.getValidMoves();
  print('Geçerli hamle sayısı: ${validMoves.length}');
  
  // Tehdit altındaki kareleri göster
  final threatened = engine.getThreatenedSquares();
  print('Tehdit altındaki kare sayısı: ${threatened.length}');
  
  // Hamle yap
  if (validMoves.isNotEmpty) {
    engine.makeMove(validMoves.first);
    print('Hamle yapıldı: ${engine.moveCount}. hamle');
  }
  
  // Debug çıktısı
  engine.printGameState();
}
```

---

## 🔧 API Referansı

### ThreatenedSquaresCalculator

#### `calculateThreatenedSquares(board, threateningColor)`
Belirli bir rengin kontrol ettiği tüm kareleri hesaplar.

**Parametreler:**
- `board`: ChessBoard - Satranç tahtası
- `threateningColor`: PieceColor - Tehdit eden renk

**Döndürür:** `Set<Position>` - Tehdit altındaki pozisyonlar

#### `isSquareThreatened(position, board, threateningColor)`
Belirli bir karenin tehdit altında olup olmadığını kontrol eder.

**Döndürür:** `bool`

#### `getSafeKnightMoves(knightPosition, board, enemyColor)`
Knight için sadece güvenli (tehdit altında olmayan) hareketleri döndürür.

**Döndürür:** `List<Position>`

---

## 🎮 Oyun Kuralları

1. **Hareket**: Knight sadece L-şeklinde hareket edebilir (2+1 kare)
2. **Hedef**: Belirtilen hedefe ulaşmaya çalış
3. **Tuzak**: Rakip taşların kontrol ettiği karelere GİREMEZSİN
4. **Kazanma**: Hedefe ulaş
5. **Kaybetme**: Hareket edebileceğin geçerli kare kalmazsa

---

## 📊 Performans Optimizasyonları

- ✅ Set kullanarak O(1) tehdit kontrolü
- ✅ BFS ile minimum hamle hesaplama
- ✅ Immutable board cloning
- ✅ Efficient move calculation

---

## 🤝 Ekip Entegrasyonu

### UI Team için (Kişi B):
```dart
// GameEngine instance'ını state management ile paylaş
final engine = ref.watch(gameEngineProvider);

// Geçerli hareketleri al ve UI'da göster
final validMoves = engine.getValidMoves();

// Tehdit altındaki kareleri kırmızı vurgula
final threatened = engine.getThreatenedSquares();

// Kullanıcı tıklaması
onSquareTap(Position position) {
  if (engine.makeMove(position)) {
    // Animasyon başlat
    // Ses çal
    // State güncelle
  }
}
```

### Data Team için (Kişi C):
```dart
// JSON'dan level yükle
final levelJson = await loadLevel(levelNumber);
final level = LevelData(
  boardSize: levelJson['boardSize'],
  knightStartPosition: Position.fromChessNotation(
    levelJson['knightStart']
  ),
  targetPosition: Position.fromChessNotation(
    levelJson['target']
  ),
  enemyPieces: parsePieces(levelJson['enemies']),
  levelNumber: levelNumber,
);

engine.initializeLevel(level);

// Analytics
analytics.logEvent('level_start', {
  'level': levelNumber,
  'min_moves': engine.calculateMinimumMoves(),
});
```

---

## 📝 Notlar

- Tüm logic kodları **test edilmiş** ve **production-ready**
- Kod **iyi dokümante edilmiş** ve **okunabilir**
- **Genişletilebilir** yapı: Yeni taş tipleri kolayca eklenebilir
- **Performanslı**: Büyük tahtalarda bile hızlı çalışır

---

## 🎉 Sonuç

Logic engine tamamlandı! Şimdi UI/UX ve Data ekipleri kendi görevlerine başlayabilir.

**Test komutları:**
```bash
# Tüm testleri çalıştır
flutter test

# Sadece logic testleri
flutter test test/logic/

# Coverage raporu
flutter test --coverage
```

**Branch durumu:**
- Branch: `feature/logic-engine`
- Durum: ✅ Ready for merge
- Tests: ✅ 50/50 passing

---

Made with ❤️ by Team A (Logic & Core)
