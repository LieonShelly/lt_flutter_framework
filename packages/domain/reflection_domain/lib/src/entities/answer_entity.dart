import 'question_entity.dart';
import 'icon_entity.dart';

class AnswerEntity {
  final String id;
  final String content;
  final DateTime createdAt;
  final QuestionEntity? question;
  final IconEntity? icon;

  const AnswerEntity({
    required this.id,
    required this.content,
    required this.createdAt,
    this.question,
    this.icon,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'question': question?.toJson(includeAnswers: false),
    'icon': icon?.toJson(),
  };

  factory AnswerEntity.fromJson(Map<String, dynamic> json) => AnswerEntity(
    id: json['id'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
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
          createdAt == other.createdAt;

  @override
  int get hashCode => id.hashCode ^ content.hashCode ^ createdAt.hashCode;
}
