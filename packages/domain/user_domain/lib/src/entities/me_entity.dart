import 'qod_strategy_option_entity.dart';
import 'reminder_slot_entity.dart';

/// 当前登录用户的详细信息实体（来自 GET /api/me）
class MeEntity {
  final String? email;
  final String? nickname;
  final QodStrategy qodStrategy;
  final DateTime? lastLoginAt;
  final bool hasPinnedQuestion;
  final String? reportPersonaId;
  final MePersonaEntity? reportPersona;
  final ReminderSlot? reminderSlot;

  const MeEntity({
    this.email,
    this.nickname,
    required this.qodStrategy,
    this.lastLoginAt,
    required this.hasPinnedQuestion,
    this.reportPersonaId,
    this.reportPersona,
    this.reminderSlot,
  });
}

/// 当前用户选中的 AI Persona 摘要
class MePersonaEntity {
  final String id;
  final String label;

  const MePersonaEntity({required this.id, required this.label});
}
