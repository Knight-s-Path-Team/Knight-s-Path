import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  // Veri tabanındaki anahtar kelime (Değişken ismi sabit)
  static const String _keyCurrentLevel = 'current_level';
  static const String _keyStars = 'total_stars';

  // 1. KAYDETME FONKSİYONU
  // Kullanıcı bir levelı geçtiğinde bunu çağır.
  // Örnek: StorageManager.saveLevel(2);
  static Future<void> saveLevel(int levelToSave) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Önce kayıtlı en yüksek level'ı kontrol et
    int savedLevel = prefs.getInt(_keyCurrentLevel) ?? 1;

    // Eğer yeni geçilen level, kayıtlı olandan büyükse kaydet.
    // Level 5'teyken Level 1 oynanırsa ilerleme bozulmaz.
    if (levelToSave > savedLevel) {
      await prefs.setInt(_keyCurrentLevel, levelToSave);
      print("İlerleme Kaydedildi: Level $levelToSave kilitleri açıldı.");
    }
  }

  // 2. OKUMA FONKSİYONU
  /* Oyun açılırken veya Harita ekranında bu çağırılır. Kayıt yoksa (ilk defa açılıyorsa) 1 döndürür.*/
  static Future<int> getReachedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentLevel) ?? 1;
  }

  // 3. LEVEL SIFIRLAMA (Testleriniz için)
  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentLevel);
    print("Tüm ilerleme sıfırlandı.");
  }
}