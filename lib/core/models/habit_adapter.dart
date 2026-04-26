import 'package:hive/hive.dart';

import 'habit.dart';
import 'habit_log.dart';

/// Habit Hive Adapter
class HabitAdapter extends TypeAdapter<Habit> {
  @override
  int get typeId => 1;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      iconCodePoint: fields[2] as int,
      colorValue: fields[3] as int,
      frequencyType: fields[4] as String,
      targetCount: fields[5] as int,
      currentCount: fields[6] as int,
      illustrationAsset: fields[7] as String?,
      createdAt: fields[8] as DateTime,
      weeklySchedule: (fields[9] as List?)?.cast<bool>(),
      notifications: fields[10] as NotificationSettings,
      unit: fields[11] as String?,
      streakCount: fields[12] as int,
      lastCompletedDate: fields[13] as DateTime?,
      isArchived: fields[14] as bool,
      iconFontFamily: fields[15] as String?,
      deletedAt: fields[16] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCodePoint)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.frequencyType)
      ..writeByte(5)
      ..write(obj.targetCount)
      ..writeByte(6)
      ..write(obj.currentCount)
      ..writeByte(7)
      ..write(obj.illustrationAsset)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.weeklySchedule)
      ..writeByte(10)
      ..write(obj.notifications)
      ..writeByte(11)
      ..write(obj.unit)
      ..writeByte(12)
      ..write(obj.streakCount)
      ..writeByte(13)
      ..write(obj.lastCompletedDate)
      ..writeByte(14)
      ..write(obj.isArchived)
      ..writeByte(15)
      ..write(obj.iconFontFamily)
      ..writeByte(16)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// NotificationSettings Hive Adapter
class NotificationSettingsAdapter extends TypeAdapter<NotificationSettings> {
  @override
  int get typeId => 2;

  @override
  NotificationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettings(
      enabled: fields[0] as bool,
      morningTime: fields[1] as String?,
      eveningTime: fields[2] as String?,
      randomReminders: fields[3] as bool,
      snoozeEnabled: fields[4] as bool,
      customMessage: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.enabled)
      ..writeByte(1)
      ..write(obj.morningTime)
      ..writeByte(2)
      ..write(obj.eveningTime)
      ..writeByte(3)
      ..write(obj.randomReminders)
      ..writeByte(4)
      ..write(obj.snoozeEnabled)
      ..writeByte(5)
      ..write(obj.customMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// HabitLog Hive Adapter
class HabitLogAdapter extends TypeAdapter<HabitLog> {
  @override
  int get typeId => 3;

  @override
  HabitLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitLog(
      id: fields[0] as String,
      habitId: fields[1] as String,
      completedAt: fields[2] as DateTime,
      count: fields[3] as int,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.completedAt)
      ..writeByte(3)
      ..write(obj.count)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
