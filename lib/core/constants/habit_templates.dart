import 'package:flutter/material.dart';
import '../models/habit.dart';

/// Ön ayarlı alışkanlık şablonları - iOS uyumlu Material Icons
class HabitTemplates {
  HabitTemplates._();

  static const List<HabitTemplate> all = [
    // Su İçme
    HabitTemplate(
      name: 'Su İç',
      icon: Icons.water_drop,
      defaultTarget: 3,
      unit: 'bardak',
      frequency: FrequencyType.daily,
      illustrationAsset: 'assets/illustrations/water_bear.json',
      colorValue: 0xFFFF6B6B, // Mercan
      description: 'Günde 3 bardak su içmek başlangıç için mükemmel!',
      reminderMessage: 'Susuz kaldin, bir bardak su içsen?',
    ),

    // Kitap Okuma
    HabitTemplate(
      name: 'Kitap Oku',
      icon: Icons.menu_book,
      defaultTarget: 20,
      unit: 'sayfa',
      frequency: FrequencyType.weekly,
      illustrationAsset: 'assets/illustrations/reading_cat.json',
      colorValue: 0xFF4ECDC4, // Turkuaz
      description: 'Haftada 20 sayfa kitap büyük bir değişim!',
      reminderMessage: 'Bugün kitap okudun mu?',
    ),

    // Meditasyon
    HabitTemplate(
      name: 'Meditasyon',
      icon: Icons.self_improvement,
      defaultTarget: 10,
      unit: 'dakika',
      frequency: FrequencyType.daily,
      illustrationAsset: 'assets/illustrations/meditating_fox.json',
      colorValue: 0xFF9B59B6, // Mor
      description: 'Her gün 10 dakika zihin dinginliği',
      reminderMessage: 'Zihnini dinlendirme zamanı!',
    ),

    // Doğa Yürüyüşü
    HabitTemplate(
      name: 'Doğa Yürüyüşü',
      icon: Icons.forest,
      defaultTarget: 1,
      unit: 'kez',
      frequency: FrequencyType.weekly,
      illustrationAsset: 'assets/illustrations/hiking_bunny.json',
      colorValue: 0xFF27AE60, // Yeşil
      description: 'Haftada bir doğa ile buluşma zamanı!',
      reminderMessage: 'Doğada seni bekliyorum!',
    ),

    // Egzersiz
    HabitTemplate(
      name: 'Egzersiz',
      icon: Icons.directions_run,
      defaultTarget: 15,
      unit: 'dakika',
      frequency: FrequencyType.daily,
      illustrationAsset: 'assets/illustrations/exercising_dog.json',
      colorValue: 0xFFE67E22, // Turuncu
      description: 'Her gün 15 dakika hareket!',
      reminderMessage: 'Hareket zamanı, hazır mısın?',
    ),

    // Sağlıklı Yemek
    HabitTemplate(
      name: 'Sağlıklı Yemek',
      icon: Icons.restaurant,
      defaultTarget: 1,
      unit: 'öğün',
      frequency: FrequencyType.daily,
      illustrationAsset: 'assets/illustrations/cooking_panda.json',
      colorValue: 0xFF2ECC71, // Parlak yeşil
      description: 'Günde bir sağlıklı öğün!',
      reminderMessage: 'Bugün sağlıklı bir şeyler ye!',
    ),

    // Günlük Yazma
    HabitTemplate(
      name: 'Günlük Yaz',
      icon: Icons.edit_note,
      defaultTarget: 1,
      unit: 'sayfa',
      frequency: FrequencyType.daily,
      illustrationAsset: 'assets/illustrations/writing_owl.json',
      colorValue: 0xFF3498DB, // Mavi
      description: 'Düşüncelerini kağıda dök!',
      reminderMessage: 'Bugün neler hissediyorsun?',
    ),

    // Erken Uyuma
    HabitTemplate(
      name: 'Erken Uyu',
      icon: Icons.bedtime,
      defaultTarget: 1,
      unit: 'kez',
      frequency: FrequencyType.daily,
      illustrationAsset: 'assets/illustrations/sleeping_koala.json',
      colorValue: 0xFF1ABC9C, // Zümrüt
      description: 'Düzenli uyku sağlıklı hayat!',
      reminderMessage: 'Uyku zamanı geldi!',
    ),
  ];

  /// İsme göre template bul
  static HabitTemplate? findByName(String name) {
    try {
      return all.firstWhere((t) => t.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Template'den Habit oluştur
  static Habit createHabitFromTemplate(
    HabitTemplate template, {
    int? customTarget,
    NotificationSettings? notifications,
  }) {
    final now = DateTime.now();
    return Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: template.name,
      iconCodePoint: template.icon.codePoint,
      iconFontFamily: template.icon.fontFamily ?? 'MaterialIcons',
      colorValue: template.colorValue,
      frequencyType: template.frequency.toString().split('.').last,
      targetCount: customTarget ?? template.defaultTarget,
      unit: template.unit,
      illustrationAsset: template.illustrationAsset,
      createdAt: now,
      notifications: notifications ??
          NotificationSettings(
            morningTime: '08:00',
            eveningTime: '20:00',
            customMessage: template.reminderMessage,
          ),
    );
  }
}

/// Motivasyon mesajları
class MotivationMessages {
  MotivationMessages._();

  static const List<String> daily = [
    'Küçük adımlar, büyük değişimler!',
    'Bugün harika bir gün olacak!',
    'Kendine inan, yapabilirsin!',
    'Her gün biraz daha yaklaşıyorsun!',
    'Başarı seninle başlar!',
    'Bugün kendin için bir şeyler yap!',
    'Güne güzel bir başlangıç!',
    'Sen bir şampiyonsun!',
  ];

  static const List<String> completion = [
    'Harika! Devam et!',
    'Mükemmelsin!',
    'Bir adım daha attın!',
    'İşte bu!',
    'Gurur duyulası!',
    'Seninle gurur duyuyorum!',
    'Hedefe yaklaşıyorsun!',
    'Bugünkü görev tamamlandı!',
  ];

  static String getRandomDaily() {
    final index = DateTime.now().day % daily.length;
    return daily[index];
  }

  static String getRandomCompletion() {
    final index = DateTime.now().millisecond % completion.length;
    return completion[index];
  }
}

/// Frekans tipi gösterimleri
class FrequencyLabels {
  FrequencyLabels._();

  static String getLabel(FrequencyType type) {
    switch (type) {
      case FrequencyType.daily:
        return 'Her Gün';
      case FrequencyType.weekly:
        return 'Haftada';
      case FrequencyType.specificDays:
        return 'Belirli Günler';
    }
  }

  static String getDescription(FrequencyType type, int target) {
    switch (type) {
      case FrequencyType.daily:
        return 'Günde $target';
      case FrequencyType.weekly:
        return 'Haftada $target';
      case FrequencyType.specificDays:
        return 'Seçili günlerde $target';
    }
  }
}
