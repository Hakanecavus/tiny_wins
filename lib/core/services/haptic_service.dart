import 'package:flutter/services.dart';

/// Haptic feedback servisi
class HapticService {
  HapticService._();

  /// Hafif titreşim - UI etkileşimleri için
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Orta titreşim - Buton tıklamaları için
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Güçlü titreşim - Önemli etkileşimler için
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click - Seçim değişiklikleri için
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Başarı titreşimi - Alışkanlık tamamlama için 🎉
  static Future<void> success() async {
    // Kombine titreşim efekti
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Hata titreşimi
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// Arttırma titreşimi - Sayı artırma için (+1, +2...)
  static Future<void> increment() async {
    await HapticFeedback.selectionClick();
  }

  /// Tamamlama titreşimi - Hedefe ulaşıldığında
  static Future<void> completion() async {
    // Kutlama titreşim dizisi
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await HapticFeedback.heavyImpact();
  }

  /// Streak kutlaması - Yüksek seri sayılarında
  static Future<void> streakCelebration() async {
    // Daha uzun kutlama dizisi
    for (int i = 0; i < 5; i++) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
    }
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();
  }
}
