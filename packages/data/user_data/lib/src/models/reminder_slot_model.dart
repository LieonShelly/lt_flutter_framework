import 'package:user_domain/user_domain.dart';

/// 提醒时段 DTO
/// 对应 GET /api/me/reminder 和 POST /api/me/reminder 响应
class ReminderSlotModel {
  final String? slot;

  ReminderSlotModel({this.slot});

  factory ReminderSlotModel.fromJson(Map<String, dynamic> json) {
    return ReminderSlotModel(slot: json['slot'] as String?);
  }

  ReminderSlotEntity toEntity() {
    return ReminderSlotEntity(slot: ReminderSlot.fromString(slot));
  }
}
