import 'question_entity.dart';
import 'icon_entity.dart';

class AnswerEntity {
  final String id;
  final String content;
  final DateTime? createTms;
  final DateTime? createYmd;
  final QuestionEntity? question;
  final IconEntity? icon;

  const AnswerEntity({
    required this.id,
    required this.content,
    this.createTms,
    this.createYmd,
    this.question,
    this.icon,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'createTms': createTms?.toIso8601String(),
    "createYmd": createYmd?.toIso8601String(),
    'question': question?.toJson(includeAnswers: false),
    'icon': icon?.toJson(),
  };

  factory AnswerEntity.fromJson(Map<String, dynamic> json) => AnswerEntity(
    id: json['id'] as String,
    content: json['content'] as String,
    createTms: DateTime.parse(json['createTms'] as String),
    createYmd: DateTime.parse(json['createYmd'] as String),
    question: json['question'] != null
        ? QuestionEntity.fromJson(json['question'] as Map<String, dynamic>)
        : null,
    icon: json['icon'] != null
        ? IconEntity.fromJson(json['icon'] as Map<String, dynamic>)
        : null,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnswerEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          createTms == other.createTms &&
          createYmd == other.createYmd;

  @override
  int get hashCode =>
      id.hashCode ^ content.hashCode ^ createTms.hashCode ^ createYmd.hashCode;
}
