import '../models/habit.dart';

/// Bildirim servisi - şu anlık stub/mock
/// flutter_local_notifications Android 14 ile sorun yaşadığı için
/// basit loglama ile çalışıyor
class NotificationService {
  /// Bildirim servisini başlat
  static Future<void> initialize() async {
    // TODO: Flutter_local_notifications düzeltildiğinde buraya eklenecek
    print('NotificationService initialized (stub)');
  }

  /// Bildirim izinlerini kontrol et ve iste
  static Future<bool> requestPermissions() async {
    // Stub implementation
    return true;
  }

  /// Tüm bildirimleri iptal et
  static Future<void> cancelAll() async {
    print('All notifications cancelled (stub)');
  }

  /// Belirli bir bildirimi iptal et
  static Future<void> cancelNotification(int id) async {
    print('Notification $id cancelled (stub)');
  }

  /// Alışkanlık için sabah hatırlatıcı planla
  static Future<void> scheduleMorningReminder(
    Habit habit,
    String time, // "08:00" format
  ) async {
    print('Morning reminder scheduled for ${habit.name} at $time (stub)');
  }

  /// Alışkanlık için akşam hatırlatıcı planla
  static Future<void> scheduleEveningReminder(
    Habit habit,
    String time, // "20:00" format
  ) async {
    print('Evening reminder scheduled for ${habit.name} at $time (stub)');
  }

  /// "Beni Unutma Sakın" rastgele bildirim planla
  static Future<void> scheduleRandomReminder(Habit habit) async {
    if (!habit.notifications.randomReminders) return;

    print('Random reminder scheduled for ${habit.name} (stub)');
  }

  /// Ertelenen görev için bildirim planla (1, 2, 3 saat aralıklı)
  static Future<void> scheduleSnoozeReminders(
    Habit habit,
    DateTime baseTime,
  ) async {
    if (!habit.notifications.snoozeEnabled) return;

    // Bildirim 1: +1 saat
    print(
      'Snooze reminder 1 scheduled for ${habit.name} at ${baseTime.add(const Duration(hours: 1))} (stub)',
    );

    // Bildirim 2: +3 saat
    print(
      'Snooze reminder 2 scheduled for ${habit.name} at ${baseTime.add(const Duration(hours: 3))} (stub)',
    );

    // Bildirim 3: +6 saat
    print(
      'Snooze reminder 3 scheduled for ${habit.name} at ${baseTime.add(const Duration(hours: 6))} (stub)',
    );
  }

  /// Anlık test bildirimi gönder
  static Future<void> showTestNotification() async {
    print('Test notification shown (stub)');
  }
}
