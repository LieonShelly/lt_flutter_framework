/// 提醒时段枚举
enum ReminderSlot {
  morning,
  afternoon,
  evening;

  static ReminderSlot? fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'MORNING':
        return ReminderSlot.morning;
      case 'AFTERNOON':
        return ReminderSlot.afternoon;
      case 'EVENING':
        return ReminderSlot.evening;
      default:
        return null;
    }
  }

  String toApiString() => name.toUpperCase();
}

/// 每日提醒时段实体（来自 GET /api/me/reminder）
class ReminderSlotEntity {
  /// 提醒时段，为 null 表示已关闭提醒
  final ReminderSlot? slot;

  const ReminderSlotEntity({this.slot});
}
