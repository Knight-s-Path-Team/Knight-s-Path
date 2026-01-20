import 'package:flutter_test/flutter_test.dart';
import 'package:knights_path/logic/game_engine.dart';
import 'package:knights_path/logic/models/position.dart';
import 'package:knights_path/logic/models/piece.dart';

/// Bu dosyayı çalıştırmak için: flutter test test/logic/demo_test.dart --verbose
void main() {
  test('🐴 Demo Level 1: Basit Rook Tuzağı', () {
    print('\n📋 LEVEL 1: Basit Rook Tuzağı\n');
    
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
    print('⚠️  Tehdit altındaki kareler (${threatened.length} adet):');
    final threatenedList = threatened.toList()..sort((a, b) => 
      a.toChessNotation().compareTo(b.toChessNotation()));
    for (var pos in threatenedList.take(10)) {
      print('   - ${pos.toChessNotation()}');
    }
    if (threatenedList.length > 10) {
      print('   ... ve ${threatenedList.length - 10} kare daha');
    }
    
    // Geçerli hareketleri göster
    final validMoves = engine.getValidMoves();
    print('\n✅ Geçerli hareketler (${validMoves.length} adet):');
    for (var move in validMoves) {
      print('   - ${move.toChessNotation()}');
    }
    
    // c3 tehdit altında olmalı (kale c sütununu kontrol ediyor)
    expect(
      threatened.contains(Position.fromChessNotation('c3')),
      true,
      reason: 'c3 kalesi tarafından tehdit altında olmalı',
    );
    
    // Bir hamle dene - c3'e gidemez (kale kontrol ediyor)
    print('\n🚫 c3\'e gitmeyi dene...');
    final invalidMove = engine.makeMove(Position.fromChessNotation('c3'));
    print('   Sonuç: ${invalidMove ? "✅ Başarılı" : "❌ Başarısız (Tehdit altında!)"}');
    expect(invalidMove, false, reason: 'c3 tehdit altında, hamle başarısız olmalı');
    
    // Geçerli bir hamle yap - a3'e git
    print('\n✅ a3\'e gitmeyi dene...');
    final validMove = engine.makeMove(Position.fromChessNotation('a3'));
    print('   Sonuç: ${validMove ? "✅ Başarılı" : "❌ Başarısız"}');
    print('   Hamle sayısı: ${engine.moveCount}');
    expect(validMove, true);
    expect(engine.moveCount, 1);
    
    // b5'e git
    print('\n✅ b5\'e git...');
    engine.makeMove(Position.fromChessNotation('b5'));
    print('   Hamle sayısı: ${engine.moveCount}');
    
    // Şimdi d3'e gidebiliriz mi kontrol et
    print('\n🎯 Hedefe gitmeyi dene (d3)...');
    final canReach = engine.canReachTarget();
    print('   Hedefe ulaşılabilir mi? ${canReach ? "✅ Evet" : "❌ Hayır"}');
    
    if (canReach) {
      final targetMove = engine.makeMove(Position.fromChessNotation('d3'));
      print('   Sonuç: ${targetMove ? "✅ Başarılı" : "❌ Başarısız"}');
      print('   Oyun durumu: ${engine.gameState}');
      
      if (engine.gameState == GameState.won) {
        print('\n🎉 KAZANDINIZ! ${engine.moveCount} hamlede tamamladınız!');
        expect(engine.gameState, GameState.won);
      }
    }
    
    print('\n' + '='*50);
  });

  test('🐴 Demo Level 2: Çoklu Tehdit Paterni', () {
    print('\n📋 LEVEL 2: Çoklu Tehdit Paterni\n');
    
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
      print('   - ${move.toChessNotation()}');
    }
    
    // Hedefe ulaşılabilir mi?
    final canReach = engine.canReachTarget();
    print('\n🤔 Hedefe doğrudan ulaşılabilir mi? ${canReach ? "✅ Evet" : "❌ Hayır"}');
    
    // Minimum hamle hesaplama
    final minMoves = engine.calculateMinimumMoves();
    if (minMoves != null) {
      print('📊 En az $minMoves hamle gerekli');
      expect(minMoves, greaterThan(0));
    } else {
      print('⚠️  Hedefe ulaşılamıyor!');
    }
    
    print('\n💡 İpucu: Vezirin ve filin kontrol etmediği kareleri kullan!');
    print('\n' + '='*50);
  });

  test('🐴 Demo Level 3: Fotoğraftaki Senaryo', () {
    print('\n📋 LEVEL 3: Fotoğraftaki gibi karmaşık senaryo\n');
    
    final engine = GameEngine();
    
    // Fotoğraftaki gibi bir setup
    final level = LevelData(
      boardSize: 8,
      knightStartPosition: Position.fromChessNotation('c7'), 
      targetPosition: Position.fromChessNotation('a8'),
      enemyPieces: {
        // Üstte vezir
        Position.fromChessNotation('b8'): 
          ChessPiece(PieceType.queen, PieceColor.black),
        // Sağda fil
        Position.fromChessNotation('e5'): 
          ChessPiece(PieceType.bishop, PieceColor.black),
      },
      levelNumber: 3,
      description: 'Kritik level - Vezir a8\'i blokluyor!',
    );
    
    engine.initializeLevel(level);
    
    print('🎯 Hedef: ${level.targetPosition.toChessNotation()}');
    print('🏁 At: ${level.knightStartPosition.toChessNotation()}');
    print('👿 Düşmanlar:');
    print('   - Vezir @ b8 (a8\'i blokluyor!)');
    print('   - Fil @ e5\n');
    
    // a8 tehdit altında mı?
    final target = Position.fromChessNotation('a8');
    final isThreatened = engine.isSquareThreatened(target);
    print('⚠️  Hedef (a8) tehdit altında mı? ${isThreatened ? "🚫 EVET" : "✅ Hayır"}');
    
    // Direkt ulaşılabilir mi?
    final canReach = engine.canReachTarget();
    print('🤔 Direkt hamle ile ulaşılabilir mi? ${canReach ? "✅ Evet" : "❌ Hayır (Bloklanmış!)"}');
    
    expect(canReach, false, reason: 'a8 vezir tarafından bloklanmış olmalı');
    
    // Alternatif hareketler
    final validMoves = engine.getValidMoves();
    print('\n✅ Alternatif hareketler (${validMoves.length} adet):');
    for (var move in validMoves) {
      print('   - ${move.toChessNotation()}');
    }
    
    // Minimum hamle (dolaylı yol)
    final minMoves = engine.calculateMinimumMoves();
    if (minMoves != null) {
      print('\n📊 Dolaylı yoldan en az $minMoves hamle gerekli');
      print('💡 Bu bir bulmaca! Veziri atlayarak hedefe ulaşmalısınız.');
    }
    
    print('\n' + '='*50);
  });
}
