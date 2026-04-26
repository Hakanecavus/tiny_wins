import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/habit.dart';
import '../../../core/models/habit_log.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/notification_service.dart';

/// Tüm alışkanlıklar state'i
final habitsProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<Habit>>>((ref) {
      return HabitsNotifier();
    });

/// Aktif alışkanlıklar (arşivlenmemiş ve bugünkü frekansa uygun olanlar)
final activeHabitsProvider = Provider<AsyncValue<List<Habit>>>((ref) {
  final habitsAsync = ref.watch(habitsProvider);
  return habitsAsync.when(
    data: (habits) {
      final now = DateTime.now();
      final weekdayIndex = now.weekday - 1;

      final activeToday = habits.where((h) {
        if (h.isArchived || h.deletedAt != null) return false;

        // Frekans kontrolü
        if (h.frequencyType == 'specificDays' && h.weeklySchedule != null) {
          if (!h.weeklySchedule![weekdayIndex]) return false;
        } else if (h.frequencyType == 'weekly') {
          if (now.weekday != h.createdAt.weekday) return false;
        }
        return true;
      }).toList();

      return AsyncValue.data(activeToday);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

/// Bugünkü tamamlanma oranı
final todayCompletionRateProvider = Provider<double>((ref) {
  final habitsAsync = ref.watch(activeHabitsProvider);
  return habitsAsync.when(
    data: (habits) {
      if (habits.isEmpty) return 1.0; // Hiç alışkanlık yoksa %100 kabul edelim
      final completed = habits.where((h) => h.isCompletedToday).length;
      return completed / habits.length;
    },
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
});

/// Toplam bireysel seri toplamı (eski)
final totalIndividualStreakProvider = Provider<int>((ref) {
  final habitsAsync = ref.watch(activeHabitsProvider);
  return habitsAsync.when(
    data: (habits) => habits.fold(0, (sum, h) => sum + h.streakCount),
    loading: () => 0,
    error: (_, _) => 0,
  );
});

/// Takvim için günlük başarı durumları
final calendarStatsProvider = Provider<Map<DateTime, bool>>((ref) {
  ref.watch(habitsProvider); // State değişimlerini izle
  final allHabits = LocalStorageService.getAllHabits();
  final allLogs = LocalStorageService.getAllLogs();

  if (allHabits.isEmpty) return {};

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final Map<DateTime, bool> stats = {};

  // 1. Geçmiş Günleri Hesapla (Loglardan)
  final Map<DateTime, Set<String>> dailyCompletions = {};
  for (final log in allLogs) {
    final date = DateTime(
      log.completedAt.year,
      log.completedAt.month,
      log.completedAt.day,
    );
    if (date.isAfter(today)) continue; // Gelecek loglarını yoksay

    final habit = allHabits.firstWhere(
      (h) => h.id == log.habitId,
      orElse: () => Habit(
        id: '',
        name: '',
        iconCodePoint: 0,
        colorValue: 0,
        frequencyType: 'daily',
        targetCount: 1,
        createdAt: DateTime.now(),
        notifications: NotificationSettings(enabled: false),
      ),
    );

    if (habit.id.isNotEmpty && log.count >= habit.targetCount) {
      dailyCompletions.putIfAbsent(date, () => {}).add(log.habitId);
    }
  }

  // Log bulunan tüm günler için kontrol et
  for (final date in dailyCompletions.keys) {
    if (date.isAtSameMomentAs(today)) continue; // Bugünü ayrı hesaplayacağız

    final requiredHabits = allHabits.where((h) {
      final createdDate = DateTime(
        h.createdAt.year,
        h.createdAt.month,
        h.createdAt.day,
      );
      if (createdDate.isAfter(date)) return false;
      if (h.deletedAt != null) {
        final deletedDate = DateTime(
          h.deletedAt!.year,
          h.deletedAt!.month,
          h.deletedAt!.day,
        );
        if (deletedDate.isBefore(date)) return false;
      }

      // Frekans kontrolü
      if (h.frequencyType == 'specificDays' && h.weeklySchedule != null) {
        final weekdayIndex = date.weekday - 1;
        if (!h.weeklySchedule![weekdayIndex]) return false;
      } else if (h.frequencyType == 'weekly') {
        if (date.weekday != h.createdAt.weekday) return false;
      }
      return true;
    }).toList();

    if (requiredHabits.isNotEmpty) {
      final completedIds = dailyCompletions[date] ?? {};
      stats[date] = completedIds.length >= requiredHabits.length;
    }
  }

  // 2. Bugünü Hesapla (Live State'den - Daha güvenilir)
  final activeToday = allHabits.where((h) {
    if (h.isArchived || h.deletedAt != null) return false;

    // Frekans kontrolü
    if (h.frequencyType == 'specificDays' && h.weeklySchedule != null) {
      if (!h.weeklySchedule![now.weekday - 1]) return false;
    } else if (h.frequencyType == 'weekly') {
      if (now.weekday != h.createdAt.weekday) return false;
    }
    return true;
  }).toList();

  if (activeToday.isNotEmpty) {
    stats[today] = activeToday.every((h) => h.isCompletedToday);
  }

  return stats;
});

/// Global Zincir Serisi (Duolingo Tarzı)
final globalStreakProvider = Provider<int>((ref) {
  final stats = ref.watch(calendarStatsProvider);

  if (stats.isEmpty) return 0;

  int streak = 0;
  DateTime checkDate = DateTime.now();
  final today = DateTime(checkDate.year, checkDate.month, checkDate.day);

  // Bugünden geriye doğru say
  while (true) {
    final dateKey = DateTime(checkDate.year, checkDate.month, checkDate.day);
    final isPerfect = stats[dateKey] ?? false;

    if (isPerfect) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      // Eğer bugün henüz tamamlanmadıysa ama dün tamamlandıysa, streak bozulmaz
      if (dateKey.isAtSameMomentAs(today)) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      }
      break;
    }
  }
  return streak;
});

/// Seçili tarih state'i (Takvim için)
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Belirli bir günde tamamlanan alışkanlıklar
final dailyCompletionsProvider = Provider.family<List<Habit>, DateTime>((
  ref,
  date,
) {
  ref.watch(habitsProvider); // State değişimlerini izle
  final allHabits = LocalStorageService.getAllHabits();
  final allLogs = LocalStorageService.getAllLogs();

  final targetDate = DateTime(date.year, date.month, date.day);

  // O tarihte var olan alışkanlıklar
  final habitsAtDate = allHabits.where((habit) {
    final createdDate = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );
    if (createdDate.isAfter(targetDate)) return false;
    if (habit.deletedAt != null) {
      final deletedDate = DateTime(
        habit.deletedAt!.year,
        habit.deletedAt!.month,
        habit.deletedAt!.day,
      );
      if (deletedDate.isBefore(targetDate)) return false;

      // Bugün silindiyse bugünkü kazanımlarda da görünmesin
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (targetDate.isAtSameMomentAs(today) &&
          deletedDate.isAtSameMomentAs(today))
        return false;
    }

    // Frekans kontrolü
    if (habit.frequencyType == 'specificDays' && habit.weeklySchedule != null) {
      final weekdayIndex = targetDate.weekday - 1;
      if (!habit.weeklySchedule![weekdayIndex]) return false;
    } else if (habit.frequencyType == 'weekly') {
      if (targetDate.weekday != habit.createdAt.weekday) return false;
    }

    return true;
  }).toList();

  final completedHabitIds = allLogs
      .where((log) {
        final logDate = DateTime(
          log.completedAt.year,
          log.completedAt.month,
          log.completedAt.day,
        );
        return logDate.isAtSameMomentAs(targetDate);
      })
      .map((log) => log.habitId)
      .toSet();

  return habitsAtDate.where((h) => completedHabitIds.contains(h.id)).toList();
});

/// Belirli bir gündeki alışkanlık durumları
final habitsForDateProvider = Provider.family<List<Habit>, DateTime>((
  ref,
  date,
) {
  ref.watch(habitsProvider); // State değişimlerini izle
  // Tüm alışkanlıkları getir (silinmişler dahil)
  final allHabits = LocalStorageService.getAllHabits();
  final allLogs = LocalStorageService.getAllLogs();

  final targetDate = DateTime(date.year, date.month, date.day);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // O tarihte aktif olan (oluşturulmuş ve henüz silinmemiş) alışkanlıkları filtrele
  final habitsAtDate = allHabits.where((habit) {
    final createdDate = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );

    // O tarihte henüz oluşturulmamışsa gösterme
    if (createdDate.isAfter(targetDate)) return false;

    // O tarihte zaten silinmişse gösterme
    if (habit.deletedAt != null) {
      final deletedDate = DateTime(
        habit.deletedAt!.year,
        habit.deletedAt!.month,
        habit.deletedAt!.day,
      );

      // Eğer hedef tarih silinme gününden sonraysa gösterme
      if (deletedDate.isBefore(targetDate)) return false;

      // Eğer hedef tarih BUGÜNSE ve bugün silindiyse gösterme (aktif listeden kalksın)
      if (targetDate.isAtSameMomentAs(today) &&
          deletedDate.isAtSameMomentAs(today))
        return false;
    }

    // Frekans kontrolü
    if (habit.frequencyType == 'specificDays' && habit.weeklySchedule != null) {
      // Pazartesi = 1, Pazar = 7 -> Index 0..6
      final weekdayIndex = targetDate.weekday - 1;
      if (!habit.weeklySchedule![weekdayIndex]) return false;
    } else if (habit.frequencyType == 'weekly') {
      // Eğer kullanıcı "Haftalık" seçtiyse, varsayılan olarak alışkanlığın oluşturulduğu
      // günün haftalık tekrarı olarak kabul edelim (Kullanıcı beklentisi bu yönde)
      if (targetDate.weekday != habit.createdAt.weekday) return false;
    }

    return true;
  }).toList();

  return habitsAtDate.map((habit) {
    // Bu habit için o güne ait logları bul
    final dayLogs = allLogs.where((log) {
      final logDate = DateTime(
        log.completedAt.year,
        log.completedAt.month,
        log.completedAt.day,
      );
      return log.habitId == habit.id && logDate.isAtSameMomentAs(targetDate);
    }).toList();

    // O günkü en yüksek ilerlemeyi al
    int dayProgress = 0;
    if (dayLogs.isNotEmpty) {
      dayProgress = dayLogs.map((l) => l.count).reduce((a, b) => a > b ? a : b);
    }

    return habit.copyWith(currentCount: dayProgress);
  }).toList();
});

/// Habits StateNotifier
class HabitsNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  HabitsNotifier() : super(const AsyncValue.loading()) {
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    try {
      final habits = LocalStorageService.getActiveHabits();
      state = AsyncValue.data(habits);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Alışkanlık ekle
  Future<void> addHabit(Habit habit) async {
    try {
      await LocalStorageService.saveHabit(habit);
      await _loadHabits();

      // Bildirimleri planla
      if (habit.notifications.enabled) {
        if (habit.notifications.morningTime != null) {
          await NotificationService.scheduleMorningReminder(
            habit,
            habit.notifications.morningTime!,
          );
        }
        if (habit.notifications.eveningTime != null) {
          await NotificationService.scheduleEveningReminder(
            habit,
            habit.notifications.eveningTime!,
          );
        }
        if (habit.notifications.randomReminders) {
          await NotificationService.scheduleRandomReminder(habit);
        }
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Alışkanlık ilerlemesini güncelle
  Future<void> incrementProgress(Habit habit) async {
    try {
      final newCount = habit.currentCount + 1;
      final isCompleted = newCount >= habit.targetCount;

      // Haptic feedback
      if (isCompleted && !habit.isCompletedToday) {
        await HapticService.completion();
      } else {
        await HapticService.increment();
      }

      // Update habit
      await LocalStorageService.updateHabitProgress(
        habit.id,
        newCount,
        isCompleted: isCompleted,
      );

      // Her ilerlemede log ekle/güncelle (geçmiş takibi için)
      final now = DateTime.now();
      final logId = "${habit.id}_${now.year}_${now.month}_${now.day}";
      final log = HabitLog(
        id: logId,
        habitId: habit.id,
        completedAt: now,
        count: newCount,
      );
      await LocalStorageService.addHabitLog(log);

      await _loadHabits();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Alışkanlık tamamlandı olarak işaretle
  Future<void> completeHabit(Habit habit) async {
    try {
      await HapticService.success();

      await LocalStorageService.updateHabitProgress(
        habit.id,
        habit.targetCount,
        isCompleted: true,
      );

      final now = DateTime.now();
      final logId = "${habit.id}_${now.year}_${now.month}_${now.day}";
      final log = HabitLog(
        id: logId,
        habitId: habit.id,
        completedAt: now,
        count: habit.targetCount,
      );
      await LocalStorageService.addHabitLog(log);

      await _loadHabits();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Alışkanlığı arşivle
  Future<void> archiveHabit(String habitId) async {
    try {
      await LocalStorageService.toggleArchiveHabit(habitId);
      // Cancel notifications
      await NotificationService.cancelNotification(habitId.hashCode.abs());
      await _loadHabits();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Alışkanlığı sil
  Future<void> deleteHabit(String habitId) async {
    try {
      await LocalStorageService.deleteHabit(habitId);
      await NotificationService.cancelNotification(habitId.hashCode.abs());
      await _loadHabits();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Tüm alışkanlıkları yenile
  Future<void> refresh() async {
    await _loadHabits();
  }

  /// Gece yarısı tüm ilerlemeleri sıfırla
  Future<void> resetDailyProgress() async {
    try {
      await LocalStorageService.resetAllDailyProgress();
      await _loadHabits();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// Seçili alışkanlık state'i (detay ekranı için)
final selectedHabitProvider = StateProvider<Habit?>((ref) => null);

/// Alışkanlık logları provider'ı
final habitLogsProvider = StreamProvider.family<List<HabitLog>, String>((
  ref,
  habitId,
) async* {
  while (true) {
    await Future.delayed(const Duration(seconds: 1));
    yield LocalStorageService.getLogsForHabit(habitId);
  }
});

/// Onboarding tamamlandı mı?
final onboardingCompletedProvider = Provider<bool>((ref) {
  return LocalStorageService.onboardingCompleted;
});

/// Onboarding'i tamamla
final completeOnboardingProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await LocalStorageService.setOnboardingCompleted(true);
  };
});
