import 'package:flutter/foundation.dart';
import 'position.dart';
import 'piece.dart';

/// ========================================
/// BOARD - TAHTA YÖNETİMİ
/// ========================================
/// Satranç tahtasını ve üzerindeki taşları yönetir
/// 
/// ÖZELLİKLER:
/// - 8x8 tahta (veya özel boyut)
/// - Taş ekleme/çıkarma/taşıma
/// - Renk/tip bazlı taş filtreleme
/// - Tahta kopyalama (undo için)
/// 
/// KULLANIM:
/// board = ChessBoard(size: 8)
/// board.setPieceAt(Position(0, 0), piece)
/// piece = board.getPieceAt(position)
/// board.clone()  // Kopyasını al
/// ========================================

/// Satranç tahtasını temsil eder
/// Her kare bir Position, varsa bir ChessPiece içerir
class ChessBoard {
  final int size;  // Tahta boyutu (genelde 8x8)
  final Map<Position, ChessPiece> _pieces;  // Taşların pozisyon-taş eşleşmesi

  /// Yeni bir tahta oluştur
  /// size: Tahta boyutu (varsayılan 8x8)
  ChessBoard({this.size = 8}) : _pieces = {};

  /// Belirli bir pozisyondaki taşı döndürür
  /// 
  /// KULLANIM:
  /// piece = board.getPieceAt(Position(3, 4))  // e5'teki taşı al
  /// 
  /// DÖNÜŞ:
  /// - ChessPiece: O pozisyonda taş varsa
  /// - null: Kare boşsa
  ChessPiece? getPieceAt(Position pos) => _pieces[pos];

  /// Belirli bir pozisyona taş yerleştirir veya kaldırır
  /// 
  /// KULLANIM:
  /// board.setPieceAt(pos, piece)  // Taşı koy
  /// board.setPieceAt(pos, null)   // Taşı kaldır
  /// 
  /// pos: Hedef pozisyon (tahta sınırları içinde olmalı)
  /// piece: Yerleştirilecek taş (null ise taş kaldırılır)
  /// 
  /// HATA:
  /// Geçersiz pozisyon ise ArgumentError fırlatır
  void setPieceAt(Position pos, ChessPiece? piece) {
    // Pozisyon tahtanın içinde mi kontrol et
    if (!pos.isValid(boardSize: size)) {
      throw ArgumentError('Invalid position: $pos');
    }

    if (piece == null) {
      _pieces.remove(pos);  // null ise taşı kaldır
    } else {
      _pieces[pos] = piece;  // Taşı yerleştir
    }
  }

  /// Tahtadaki tüm taşları döndür (değiştirilemez kopya)
  Map<Position, ChessPiece> get pieces => Map.unmodifiable(_pieces);

  /// Belirli bir renkteki tüm taşları döndürür
  /// 
  /// KULLANIM:
  /// enemyPieces = board.getPiecesByColor(PieceColor.black)  // Tüm siyah taşlar
  /// 
  /// color: Taş rengi (white veya black)
  /// 
  /// DÖNÜŞ:
  /// Map<Position, ChessPiece> - O renkteki taşların pozisyon-taş eşleşmesi
  Map<Position, ChessPiece> getPiecesByColor(PieceColor color) {
    return Map.fromEntries(
      _pieces.entries.where((entry) => entry.value.color == color),
    );
  }

  /// Belirli bir tipteki tüm taşları döndürür
  /// 
  /// KULLANIM:
  /// rooks = board.getPiecesByType(PieceType.rook)  // Tüm kaleler
  Map<Position, ChessPiece> getPiecesByType(PieceType type) {
    return Map.fromEntries(
      _pieces.entries.where((entry) => entry.value.type == type),
    );
  }

  /// Pozisyon boş mu kontrol eder
  /// 
  /// KULLANIM:
  /// if (board.isSquareEmpty(pos)) { ... }  // Kare boşsa
  /// 
  /// DÖNÜŞ:
  /// true: Kare boş
  /// false: Karede taş var
  bool isSquareEmpty(Position pos) => !_pieces.containsKey(pos);

  /// Pozisyonda rakip taş var mı kontrol eder
  /// 
  /// KULLANIM:
  /// if (board.hasEnemyPiece(pos, PieceColor.white)) { ... }  // Düşman taşı varsa
  /// 
  /// pos: Kontrol edilecek pozisyon
  /// friendlyColor: Bizim rengimiz
  /// 
  /// DÖNÜŞ:
  /// true: O karede rakip renkte taş var
  /// false: Kare boş veya aynı renk taş var
  bool hasEnemyPiece(Position pos, PieceColor friendlyColor) {
    final piece = getPieceAt(pos);
    return piece != null && piece.color != friendlyColor;  // Farklı renk = rakip
  }

  /// Tahtayı temizler (tüm taşları kaldırır)
  /// 
  /// KULLANIM:
  /// board.clear()  // Tüm taşları sil
  void clear() {
    _pieces.clear();
  }

  /// Tahtanın bir kopyasını oluşturur (undo/redo için)
  /// 
  /// KULLANIM:
  /// backup = board.clone()  // Şu anki durumu kaydet
  /// // ... hamleler yap ...
  /// board = backup.clone()  // Geri al
  /// 
  /// NEDEN GEREKLİ:
  /// - Undo/Redo işlemleri için
  /// - "Ya bu hamleyi yaparsam?" simülasyonları için
  /// - Oyun durumunu kaydetmek için
  /// 
  /// DÖNÜŞ:
  /// Yeni bir ChessBoard - aynı taşlarla ama bağımsız
  ChessBoard clone() {
    final newBoard = ChessBoard(size: size);  // Yeni boş tahta
    _pieces.forEach((pos, piece) {
      newBoard.setPieceAt(pos, piece);  // Her taşı kopyala
    });
    return newBoard;  // Bağımsız kopya döndür
  }

  /// Tahtayı konsola yazdırır (debug/test için)
  /// 
  /// ÖRNEK ÇIKTI:
  /// · · · · · · · ·
  /// · ♘ · · · · · ·
  /// · · · ♜ · · · ·
  /// 
  /// ♘ = Taş sembolü
  /// · = Boş kare
  void printBoard() {
    for (int row = 0; row < size; row++) {
      String line = '';
      for (int col = 0; col < size; col++) {
        final piece = getPieceAt(Position(row, col));
        line += piece != null ? piece.symbol : '·';  // Taş varsa sembolü, yoksa nokta
        line += ' ';
      }
      // ignore: avoid_print
      debugPrint(line);  // Satırı yazdır
    }
  }

  @override
  String toString() => 'ChessBoard(size: $size, pieces: ${_pieces.length})';
}
