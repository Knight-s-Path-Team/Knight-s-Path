import 'package:knights_path/logic/game_engine.dart';
import 'package:knights_path/logic/models/position.dart';
import 'package:knights_path/logic/models/piece.dart';

void main() {
  print('🐴 Knight\'s Path - Logic Engine Demo 🐴\n');
  
  // Basit bir demo level oluştur
  demoLevel1();
  
  print('\n' + '='*50 + '\n');
  
  // Daha karmaşık bir level
  demoLevel2();
}

/// Demo Level 1: Basit rook tuzağı
void demoLevel1() {
  print('📋 LEVEL 1: Basit Rook Tuzağı\n');
  
  final engine = GameEngine();
  
  final level = LevelData(
    boardSize: 8,
    knightStartPosition: Position.fromChessNotation('b1'), // b1'den başla
    targetPosition: Position.fromChessNotation('d3'),      // d3'e git
    enemyPieces: {
      // c2'de bir kale var - c sütununu kontrol ediyor
      Position.fromChessNotation('c2'): 
        ChessPiece(PieceType.rook, PieceColor.black),
    },
    levelNumber: 1,
    description: 'Kalenin kontrolündeki c sütunundan kaçın!',
  );
  
  engine.initializeLevel(level);
  
  print('🎯 Hedef: ${level.targetPosition.toChessNotation()}');
  print('🏁 Başlangıç: ${level.knightStartPosition.toChessNotation()}');
  print('👿 Düşman: Kale @ c2\n');
  
  // Tehdit altındaki kareleri göster
  final threatened = engine.getThreatenedSquares();
  print('⚠️  Tehdit altındaki kareler:');
  for (var pos in threatened) {
    print('   - ${pos.toChessNotation()}');
  }
  
  // Geçerli hareketleri göster
  final validMoves = engine.getValidMoves();
  print('\n✅ Geçerli hareketler (${validMoves.length} adet):');
  for (var move in validMoves) {
    print('   - ${move.toChessNotation()}');
  }
  
  // Bir hamle dene - c3'e gidemez (kale kontrol ediyor)
  print('\n🚫 c3\'e gitmeyi dene...');
  final invalidMove = engine.makeMove(Position.fromChessNotation('c3'));
  print('   Sonuç: ${invalidMove ? "✅ Başarılı" : "❌ Başarısız (Tehdit altında!)"}');
  
  // Geçerli bir hamle yap - a3'e git
  print('\n✅ a3\'e gitmeyi dene...');
  final validMove = engine.makeMove(Position.fromChessNotation('a3'));
  print('   Sonuç: ${validMove ? "✅ Başarılı" : "❌ Başarısız"}');
  print('   Hamle sayısı: ${engine.moveCount}');
  
  // Şimdi d3'e git (hedef)
  print('\n🎯 Hedefe gitmeyi dene (d3)...');
  final targetMove = engine.makeMove(Position.fromChessNotation('d3'));
  print('   Sonuç: ${targetMove ? "✅ Başarılı" : "❌ Başarısız"}');
  print('   Oyun durumu: ${engine.gameState}');
  
  if (engine.gameState == GameState.won) {
    print('\n🎉 KAZANDINIZ! ${engine.moveCount} hamlede tamamladınız!');
  }
  
  // Minimum hamle sayısını hesapla
  print('\n📊 İstatistikler:');
  print('   Toplam hamle: ${engine.moveCount}');
  print('   Level: ${level.levelNumber}');
}

/// Demo Level 2: Karmaşık tehdit paterni
void demoLevel2() {
  print('📋 LEVEL 2: Çoklu Tehdit Paterni\n');
  
  final engine = GameEngine();
  
  final level = LevelData(
    boardSize: 8,
    knightStartPosition: Position.fromChessNotation('e4'), // Merkez
    targetPosition: Position.fromChessNotation('a8'),      // Köşe
    enemyPieces: {
      // Vezir merkezde - çok güçlü!
      Position.fromChessNotation('d4'): 
        ChessPiece(PieceType.queen, PieceColor.black),
      // Fil çaprazda
      Position.fromChessNotation('b7'): 
        ChessPiece(PieceType.bishop, PieceColor.black),
      // Kale üstte
      Position.fromChessNotation('a5'): 
        ChessPiece(PieceType.rook, PieceColor.black),
    },
    levelNumber: 2,
    description: 'Vezir, Fil ve Kale tuzağından kaçın!',
  );
  
  engine.initializeLevel(level);
  
  print('🎯 Hedef: ${level.targetPosition.toChessNotation()}');
  print('🏁 Başlangıç: ${level.knightStartPosition.toChessNotation()}');
  print('👿 Düşmanlar:');
  print('   - Vezir @ d4');
  print('   - Fil @ b7');
  print('   - Kale @ a5\n');
  
  // Tehdit analizi
  final threatened = engine.getThreatenedSquares();
  print('⚠️  Toplam ${threatened.length} kare tehdit altında!');
  
  // Geçerli hareketleri göster
  final validMoves = engine.getValidMoves();
  print('✅ Geçerli hareketler (${validMoves.length} adet):');
  for (var move in validMoves) {
    final isThreatened = threatened.contains(move);
    print('   - ${move.toChessNotation()} ${isThreatened ? "⚠️" : "✅"}');
  }
  
  // Hedefe ulaşılabilir mi?
  final canReach = engine.canReachTarget();
  print('\n🤔 Hedefe doğrudan ulaşılabilir mi? ${canReach ? "✅ Evet" : "❌ Hayır"}');
  
  // Minimum hamle hesaplama
  final minMoves = engine.calculateMinimumMoves();
  if (minMoves != null) {
    print('📊 En az $minMoves hamle gerekli');
  } else {
    print('⚠️  Hedefe ulaşılamıyor!');
  }
  
  print('\n💡 İpucu: Vezirin ve filin kontrol etmediği kareleri kullan!');
}
