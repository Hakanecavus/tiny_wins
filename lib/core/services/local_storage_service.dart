import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

/// Local storage service using Hive
class LocalStorageService {
  static const String _habitsBoxName = 'habits';
  static const String _habitLogsBoxName = 'habit_logs';
  static const String _settingsBoxName = 'settings';

  static Box<Habit>? _habitsBox;
  static Box<HabitLog>? _habitLogsBox;
  static Box<dynamic>? _settingsBox;

  /// Initialize Hive and register adapters
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(HabitAdapter());
    Hive.registerAdapter(HabitLogAdapter());
    Hive.registerAdapter(NotificationSettingsAdapter());

    // Open boxes
    _habitsBox = await Hive.openBox<Habit>(_habitsBoxName);
    _habitLogsBox = await Hive.openBox<HabitLog>(_habitLogsBoxName);
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
  }

  // ==================== HABITS ====================

  /// Tüm alışkanlıkları getir
  static List<Habit> getAllHabits() {
    return _habitsBox?.values.toList() ?? [];
  }

  /// Aktif (arşivlenmemiş ve silinmemiş) alışkanlıkları getir
  static List<Habit> getActiveHabits() {
    return _habitsBox?.values
            .where((h) => !h.isArchived && h.deletedAt == null)
            .toList() ??
        [];
  }

  /// Arşivlenmiş (ve silinmemiş) alışkanlıkları getir
  static List<Habit> getArchivedHabits() {
    return _habitsBox?.values
            .where((h) => h.isArchived && h.deletedAt == null)
            .toList() ??
        [];
  }

  /// ID'ye göre alışkanlık getir
  static Habit? getHabitById(String id) {
    return _habitsBox?.get(id);
  }

  /// Alışkanlık ekle/güncelle
  static Future<void> saveHabit(Habit habit) async {
    await _habitsBox?.put(habit.id, habit);
  }

  /// Alışkanlık sil (Soft delete)
  static Future<void> deleteHabit(String id) async {
    final habit = getHabitById(id);
    if (habit != null) {
      final updated = habit.copyWith(deletedAt: DateTime.now());
      await saveHabit(updated);
    }
  }

  /// Alışkanlığı arşivle/aktive et
  static Future<void> toggleArchiveHabit(String id) async {
    final habit = getHabitById(id);
    if (habit != null) {
      final updated = habit.copyWith(isArchived: !habit.isArchived);
      await saveHabit(updated);
    }
  }

  /// Alışkanlık ilerlemesini güncelle
  static Future<void> updateHabitProgress(
    String habitId,
    int newCount, {
    bool isCompleted = false,
  }) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    var updatedStreak = habit.streakCount;
    var lastCompleted = habit.lastCompletedDate;

    if (isCompleted && newCount >= habit.targetCount) {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      if (habit.lastCompletedDate != null) {
        final lastDate = DateTime(
          habit.lastCompletedDate!.year,
          habit.lastCompletedDate!.month,
          habit.lastCompletedDate!.day,
        );

        // Dün tamamladıysa streak devam eder
        final difference = todayDate.difference(lastDate).inDays;
        if (difference == 1) {
          updatedStreak = habit.streakCount + 1;
        } else if (difference > 1) {
          // Streak kırıldı
          updatedStreak = 1;
        }
      } else {
        updatedStreak = 1;
      }

      lastCompleted = today;
    }

    final updated = habit.copyWith(
      currentCount: newCount,
      streakCount: updatedStreak,
      lastCompletedDate: lastCompleted,
    );

    await saveHabit(updated);
  }

  /// Tüm ilerlemeleri sıfırla (gece yarısı)
  static Future<void> resetAllDailyProgress() async {
    final habits = getAllHabits();
    for (final habit in habits) {
      if (habit.currentCount > 0) {
        final updated = habit.copyWith(currentCount: 0);
        await saveHabit(updated);
      }
    }
  }

  /// Yeni gün kontrolü yap ve gerekirse sıfırla
  static Future<void> checkAndResetDailyProgress() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final lastReset = lastResetDate;
    if (lastReset == null || lastReset.isBefore(today)) {
      await resetAllDailyProgress();
      await setLastResetDate(today);
    }
  }

  // ==================== HABIT LOGS ====================

  /// Tamamlama kaydı ekle
  static Future<void> addHabitLog(HabitLog log) async {
    await _habitLogsBox?.put(log.id, log);
  }

  /// Alışkanlığa ait tüm kayıtları getir
  static List<HabitLog> getLogsForHabit(String habitId) {
    return _habitLogsBox?.values
            .where((log) => log.habitId == habitId)
            .toList() ??
        [];
  }

  /// Belirli tarih aralığındaki kayıtları getir
  static List<HabitLog> getLogsInDateRange(
    String habitId,
    DateTime start,
    DateTime end,
  ) {
    return _habitLogsBox?.values
            .where((log) =>
                log.habitId == habitId &&
                log.completedAt.isAfter(start) &&
                log.completedAt.isBefore(end))
            .toList() ??
        [];
  }

  /// Tüm kayıtları getir
  static List<HabitLog> getAllLogs() {
    return _habitLogsBox?.values.toList() ?? [];
  }

  /// Kayıt sil
  static Future<void> deleteLog(String logId) async {
    await _habitLogsBox?.delete(logId);
  }

  // ==================== SETTINGS ====================

  /// Onboarding tamamlandı mı?
  static bool get onboardingCompleted {
    return _settingsBox?.get('onboarding_completed') ?? false;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    await _settingsBox?.put('onboarding_completed', value);
  }

  /// Kullanıcı adı
  static String? get username {
    return _settingsBox?.get('username');
  }

  static Future<void> setUsername(String? value) async {
    await _settingsBox?.put('username', value);
  }

  /// Son sıfırlama tarihi
  static DateTime? get lastResetDate {
    final timestamp = _settingsBox?.get('last_reset_date');
    if (timestamp != null) {
      try {
        return DateTime.parse(timestamp);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<void> setLastResetDate(DateTime date) async {
    await _settingsBox?.put('last_reset_date', date.toIso8601String());
  }

  /// Box'ları temizle (debug/testing için)
  static Future<void> clearAll() async {
    await _habitsBox?.clear();
    await _habitLogsBox?.clear();
    await _settingsBox?.clear();
  }
}
