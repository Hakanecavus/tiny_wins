import 'package:hive/hive.dart';

export 'habit_adapter.dart';

/// Alışkanlık tamamlama kaydı - istatistikler için
@HiveType(typeId: 3)
class HabitLog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final DateTime completedAt;

  @HiveField(3)
  final int count;

  @HiveField(4)
  final String? note;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.completedAt,
    this.count = 1,
    this.note,
  });

  /// Tarih sadece gün olarak (karşılaştırma için)
  DateTime get dateOnly =>
      DateTime(completedAt.year, completedAt.month, completedAt.day);

  /// Haftanın günü (1=Monday, 7=Sunday)
  int get weekday => completedAt.weekday;
}

/// Günlük özet modeli (UI'da kullanılır)
class DailySummary {
  final DateTime date;
  final int totalHabits;
  final int completedHabits;
  final double completionRate;

  const DailySummary({
    required this.date,
    required this.totalHabits,
    required this.completedHabits,
    required this.completionRate,
  });

  factory DailySummary.fromLogs(
    DateTime date,
    List<HabitLog> logs,
    int totalHabitCount,
  ) {
    final dayLogs = logs.where((log) => log.dateOnly == date).length;
    final rate = totalHabitCount > 0 ? dayLogs / totalHabitCount : 0.0;

    return DailySummary(
      date: date,
      totalHabits: totalHabitCount,
      completedHabits: dayLogs,
      completionRate: rate,
    );
  }
}

/// Seri (streak) istatistikleri
class StreakStats {
  final int currentStreak;
  final int longestStreak;
  final DateTime? streakStartDate;
  final DateTime? streakEndDate;
  final int totalCompletions;

  const StreakStats({
    required this.currentStreak,
    required this.longestStreak,
    this.streakStartDate,
    this.streakEndDate,
    required this.totalCompletions,
  });
}
