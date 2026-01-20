import 'package:flutter_test/flutter_test.dart';
import 'package:knights_path/logic/models/position.dart';
import 'package:knights_path/logic/models/piece.dart';
import 'package:knights_path/logic/game_engine.dart';

void main() {
  test('🎮 MANUAL PLAY - Sen hamleleri değiştir!', () {
    final engine = GameEngine();

    print('\n' + '=' * 70);
    print('🐴 KNIGHT\'S PATH - MANUEL OYUN 🐴');
    print('=' * 70);

    // LEVEL SEÇ (bu kısmı değiştir!)
    print('\n📋 LEVEL: Kale Engeli');
    print('🎯 Görev: b1\'den h8\'e git!');
    print('👿 Dikkat: a5\'teki kale seni bekliyor!\n');

    engine.initializeLevel(
      LevelData(
        boardSize: 8,
        levelNumber: 1,
        knightStartPosition: Position.fromChessNotation('b1'),
        targetPosition: Position.fromChessNotation('h8'),
        enemyPieces: {
          Position.fromChessNotation('a5'): ChessPiece(
            PieceType.rook,
            PieceColor.black,
          ),
        },
      ),
    );

    // ==========================================
    // HAMLELERİ BURAYA YAZ! 👇
    // ==========================================
    final hamlelerin = [
      'c2', // 1. Hamle - At L şeklinde mi?
      'a4', // 2. Hamle
      'c5', // 3. Hamle
      'e6', // 4. Hamle
      'f8', // 5. Hamle
      'g6', // 6. Hamle
      'h8', // 7. Hamle - HEDEF!
    ];
    // ==========================================

    print('🎮 Oyun başlıyor! Hamlelerin:\n   ${hamlelerin.join(' → ')}\n');

    int moveNum = 0;
    for (final hamle in hamlelerin) {
      moveNum++;

      print('─' * 70);
      print('🎯 HAMLE $moveNum: "$hamle" hamlesini yapıyorsun...');
      print('─' * 70);

      printBoard(engine);

      try {
        final targetPos = Position.fromChessNotation(hamle);
        print(
          '\n📍 Şu anki pozisyon: ${engine.knightPosition.toChessNotation()}',
        );
        print('🎯 Gitmek istediğin yer: $hamle');

        // Hamleyi yap
        if (engine.makeMove(targetPos)) {
          // Başarılı hamle
          final capturedPiece = engine.board.getPieceAt(targetPos);

          print('✅ Hamle başarılı!');

          // Taş yedik mi?
          if (capturedPiece == null && engine.knightPosition == targetPos) {
            // Önceki pozisyonda taş vardı, şimdi yok - demek ki yedik
            print('🔥 SÜPER! Rakip taşı yedin! 💀');
          }

          print('📊 Toplam hamle: $moveNum');

          if (engine.knightPosition == engine.targetPosition) {
            printBoard(engine);
            printVictory(moveNum);
            return;
          }
        } else {
          // Geçersiz hamle
          printWhyInvalid(engine, targetPos);
          print('\n❌ TEST FAİL! Geçersiz hamle: $hamle');
          print(
            '💡 Geçerli hamleler: ${engine.getValidMoves().map((p) => p.toChessNotation()).join(', ')}',
          );
          fail('Hamle $moveNum geçersiz!');
        }

        print('');
      } catch (e) {
        print('❌ Hata: $e');
        fail('Hamle işlenirken hata!');
      }
    }

    // Hedefe ulaşamadık
    if (engine.knightPosition != engine.targetPosition) {
      printBoard(engine);
      print('❌ Daha hamle eklemelisin! Hedefe ulaşamadın!');
      print('💡 Son pozisyon: ${engine.knightPosition.toChessNotation()}');
      print('🎯 Hedef: ${engine.targetPosition.toChessNotation()}');
      fail('Hedefe ulaşılamadı!');
    }
  });
}

void printBoard(GameEngine engine) {
  print(
    '\n┌────────────────────────────────────────────────────────────────────┐',
  );
  print(
    '│  TAHTA DURUMU                                                      │',
  );
  print(
    '└────────────────────────────────────────────────────────────────────┘\n',
  );

  print('  8 │ · │ · │ · │ · │ · │ · │ · │ · │');

  for (int row = 7; row >= 0; row--) {
    StringBuffer rowStr = StringBuffer('  ${row + 1} │');

    for (int col = 0; col < 8; col++) {
      final pos = Position(row, col);
      final piece = engine.board.getPieceAt(pos);

      String cell;

      if (pos == engine.knightPosition) {
        cell = ' ♘ '; // Senin atın
      } else if (pos == engine.targetPosition) {
        cell = ' 🎯'; // Hedef
      } else if (piece != null) {
        cell = ' ${piece.symbol} '; // Rakip taş
      } else if (engine.isSquareThreatened(pos)) {
        cell = ' ❌'; // Tehdit
      } else if (engine.getValidMoves().contains(pos)) {
        cell = ' ✅'; // Gidebilirsin
      } else {
        cell = ' · '; // Boş
      }

      rowStr.write(cell);
      rowStr.write('│');
    }
    print('$rowStr');
  }

  print('    └────┴────┴────┴────┴────┴────┴────┴────┘');
  print('      a    b    c    d    e    f    g    h\n');

  print('  📖 Semboller:');
  print('     ♘  = Senin atın (şu anki pozisyon)');
  print('     🎯 = Hedef kare (buraya ulaşmalısın!)');
  print('     ♜♝♛ = Rakip taşlar (bazılarını yiyebilirsin!)');
  print('     ❌ = Tehdit altında (GİDEMEZSİN!)');
  print('     ✅ = Güvenli hareket (gidebilirsin!)');
  print('     ·  = Boş kare');
}

void printWhyInvalid(GameEngine engine, Position target) {
  print('\n❌ NEDEN GEÇERSİZ:');

  final currentPos = engine.knightPosition;
  final rowDiff = (target.row - currentPos.row).abs();
  final colDiff = (target.col - currentPos.col).abs();

  // At hamlesi mi kontrol et
  final isKnightMove =
      (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);

  if (!isKnightMove) {
    print('   🐴 At L şeklinde hareket eder!');
    print('   📏 Senin hamle: ${rowDiff}x${colDiff} (geçersiz)');
    print('   ✓ Doğru hamle: 2x1 veya 1x2');
    return;
  }

  if (engine.isSquareThreatened(target)) {
    print('   ⚠️  Hedef kare tehdit altında!');
    print('   💀 Rakip taşlardan biri o kareyi kontrol ediyor!');
    return;
  }

  print('   🤔 Bilinmeyen sebep - hamle motoru tarafından reddedildi.');
}

void printVictory(int moves) {
  print('\n' + '🎊' * 35);
  print('✨✨✨ KAZANDIN! ✨✨✨');
  print('🎊' * 35);

  print('\n🏆 Toplam hamle: $moves');
  print('⭐ Tebrikler! Oyunu tamamladın!\n');

  print('=' * 70);
}
