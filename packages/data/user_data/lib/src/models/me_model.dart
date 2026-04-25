import 'package:user_domain/user_domain.dart';

/// GET /api/me 响应 DTO
class MeModel {
  final String? email;
  final String? nickname;
  final String qodStrategy;
  final String? lastLoginAt;
  final bool hasPinnedQuestion;
  final String? reportPersonaId;
  final MePersonaModel? reportPersona;
  final String? reminderSlot;

  MeModel({
    this.email,
    this.nickname,
    required this.qodStrategy,
    this.lastLoginAt,
    required this.hasPinnedQuestion,
    this.reportPersonaId,
    this.reportPersona,
    this.reminderSlot,
  });

  factory MeModel.fromJson(Map<String, dynamic> json) {
    return MeModel(
      email: json['email'] as String?,
      nickname: json['nickname'] as String?,
      qodStrategy: json['qod_strategy'] as String? ?? 'RANDOM',
      lastLoginAt: json['last_login_at'] as String?,
      hasPinnedQuestion: json['has_pinned_question'] as bool? ?? false,
      reportPersonaId: json['report_persona_id'] as String?,
      reportPersona: json['report_persona'] == null
          ? null
          : MePersonaModel.fromJson(
              json['report_persona'] as Map<String, dynamic>),
      reminderSlot: json['reminder_slot'] as String?,
    );
  }

  MeEntity toEntity() {
    return MeEntity(
      email: email,
      nickname: nickname,
      qodStrategy: QodStrategy.fromString(qodStrategy),
      lastLoginAt:
          lastLoginAt != null ? DateTime.tryParse(lastLoginAt!) : null,
      hasPinnedQuestion: hasPinnedQuestion,
      reportPersonaId: reportPersonaId,
      reportPersona: reportPersona?.toEntity(),
      reminderSlot: ReminderSlot.fromString(reminderSlot),
    );
  }
}

class MePersonaModel {
  final String id;
  final String label;

  MePersonaModel({required this.id, required this.label});

  factory MePersonaModel.fromJson(Map<String, dynamic> json) {
    return MePersonaModel(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }

  MePersonaEntity toEntity() => MePersonaEntity(id: id, label: label);
}
