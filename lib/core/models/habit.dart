import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

export 'habit_adapter.dart';

/// Alışkanlık sıklığı tipi
enum FrequencyType {
  daily, // Her gün
  weekly, // Haftada X kez
  specificDays, // Belirli günler
}

/// Alışkanlık modeli - Hive uyumlu
@HiveType(typeId: 1)
class Habit {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int iconCodePoint;

  @HiveField(3)
  final int colorValue;

  @HiveField(4)
  final String frequencyType;

  @HiveField(5)
  final int targetCount;

  @HiveField(6)
  final int currentCount;

  @HiveField(7)
  final String? illustrationAsset;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final List<bool>? weeklySchedule;

  @HiveField(10)
  final NotificationSettings notifications;

  @HiveField(11)
  final String? unit;

  @HiveField(12)
  final int streakCount;

  @HiveField(13)
  final DateTime? lastCompletedDate;

  @HiveField(14)
  final bool isArchived;

  @HiveField(15)
  final String? iconFontFamily;

  @HiveField(16)
  final DateTime? deletedAt;

  Habit({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.frequencyType,
    required this.targetCount,
    this.currentCount = 0,
    this.illustrationAsset,
    required this.createdAt,
    this.weeklySchedule,
    required this.notifications,
    this.unit,
    this.streakCount = 0,
    this.lastCompletedDate,
    this.isArchived = false,
    this.iconFontFamily,
    this.deletedAt,
  });

  /// Helper: FrequencyType enum'ına erişim
  FrequencyType get frequency => FrequencyType.values.firstWhere(
    (e) => e.toString().split('.').last == frequencyType,
    orElse: () => FrequencyType.daily,
  );

  /// Helper: Color'a erişim
  Color get color => Color(colorValue);

  /// Helper: IconData'ya erişim
  IconData get iconData => IconData(
    iconCodePoint,
    fontFamily: iconFontFamily ?? 'MaterialIcons',
    fontPackage: null, // MaterialIcons için null olmalı
  );

  /// Tamamlanma yüzdesi
  double get completionPercentage =>
      targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  /// Bugün tamamlandı mı
  bool get isCompletedToday => currentCount >= targetCount;

  /// İlerleme mesajı
  String get progressMessage {
    if (isCompletedToday) {
      final messages = [
        'Mükemmelsin!',
        'Harika gidiyorsun!',
        'Bugünü tamamladın!',
        'Şampiyon!',
      ];
      return messages[id.hashCode % messages.length];
    }
    final remaining = targetCount - currentCount;
    if (remaining == 1) {
      return 'Son bir adım!';
    }
    return 'Hedef: $targetCount ${unit ?? 'kez'}';
  }

  /// CopyWith metodu
  Habit copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? colorValue,
    String? frequencyType,
    int? targetCount,
    int? currentCount,
    String? illustrationAsset,
    DateTime? createdAt,
    List<bool>? weeklySchedule,
    NotificationSettings? notifications,
    String? unit,
    int? streakCount,
    DateTime? lastCompletedDate,
    bool? isArchived,
    String? iconFontFamily,
    DateTime? deletedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      frequencyType: frequencyType ?? this.frequencyType,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      illustrationAsset: illustrationAsset ?? this.illustrationAsset,
      createdAt: createdAt ?? this.createdAt,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      notifications: notifications ?? this.notifications,
      unit: unit ?? this.unit,
      streakCount: streakCount ?? this.streakCount,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      isArchived: isArchived ?? this.isArchived,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

/// Bildirim ayarları modeli
@HiveType(typeId: 2)
class NotificationSettings {
  @HiveField(0)
  final bool enabled;

  @HiveField(1)
  final String? morningTime;

  @HiveField(2)
  final String? eveningTime;

  @HiveField(3)
  final bool randomReminders;

  @HiveField(4)
  final bool snoozeEnabled;

  @HiveField(5)
  final String? customMessage;

  NotificationSettings({
    this.enabled = true,
    this.morningTime,
    this.eveningTime,
    this.randomReminders = true,
    this.snoozeEnabled = true,
    this.customMessage,
  });

  /// CopyWith metodu
  NotificationSettings copyWith({
    bool? enabled,
    String? morningTime,
    String? eveningTime,
    bool? randomReminders,
    bool? snoozeEnabled,
    String? customMessage,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      morningTime: morningTime ?? this.morningTime,
      eveningTime: eveningTime ?? this.eveningTime,
      randomReminders: randomReminders ?? this.randomReminders,
      snoozeEnabled: snoozeEnabled ?? this.snoozeEnabled,
      customMessage: customMessage ?? this.customMessage,
    );
  }
}

/// Ön ayarlı alışkanlık şablonu (UI'da kullanılır, Hive'a kaydedilmez)
class HabitTemplate {
  final String name;
  final IconData icon;
  final int defaultTarget;
  final String unit;
  final FrequencyType frequency;
  final String? illustrationAsset;
  final int colorValue;
  final String description;
  final String? reminderMessage;

  const HabitTemplate({
    required this.name,
    required this.icon,
    required this.defaultTarget,
    required this.unit,
    required this.frequency,
    this.illustrationAsset,
    required this.colorValue,
    required this.description,
    this.reminderMessage,
  });
}
