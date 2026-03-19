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
