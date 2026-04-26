import 'package:flutter/material.dart';

/// Oyunlaştırmaya uygun canlı ve neşeli renk paleti
class AppColors {
  AppColors._();

  // Primary - Canlı ve enerjik mercan
  static const Color primary = Color(0xFFFF6B6B);
  static const Color primaryLight = Color(0xFFFF8E8E);
  static const Color primaryDark = Color(0xFFE85555);

  // Secondary - Neşeli turkuaz
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color secondaryLight = Color(0xFF7ED7D0);
  static const Color secondaryDark = Color(0xFF3DBBB3);

  // Accent - Altın sarısı
  static const Color accent = Color(0xFFFFE66D);
  static const Color accentDark = Color(0xFFFFD93D);

  // Background - Soft krem/peach
  static const Color background = Color(0xFFFDF6F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F0EB);

  // Status colors
  static const Color success = Color(0xFF95E1D3);
  static const Color successDark = Color(0xFF6BCFB8);
  static const Color warning = Color(0xFFF38181);
  static const Color error = Color(0xFFFF6B6B);

  // Text
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textTertiary = Color(0xFFB2BEC3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Gradient colors for habit cards
  static const List<Color> habitGradients = [
    Color(0xFFFF6B6B), // Mercan
    Color(0xFF4ECDC4), // Turkuaz
    Color(0xFF9B59B6), // Mor
    Color(0xFF27AE60), // Yeşil
    Color(0xFFFFE66D), // Sarı
    Color(0xFF3498DB), // Mavi
    Color(0xFFE67E22), // Turuncu
    Color(0xFF1ABC9C), // Zümrüt
  ];

  /// Alışkanlık index'ine göre renk döndür
  static Color getHabitColor(int index) {
    return habitGradients[index % habitGradients.length];
  }
}
