import 'package:lt_annotation/annotation.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'question_model.dart';
import 'icon_model.dart';

part 'answer_model.lt_model.dart';

@ltDeserialization
class AnswerModel {
  final String id;
  final String content;
  @LtJsonKey('created_ymd')
  final String createdYmd;
  final QuestionModel? question;
  final IconModel? icon;

  AnswerModel({
    required this.id,
    required this.content,
    required this.createdYmd,
    this.question,
    this.icon,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerModelFromJson(json);

  AnswerEntity toEntity() {
    return AnswerEntity(
      id: id,
      content: content,
      createdAt: DateTime.parse(createdYmd),
      question: question?.toEntity(),
      icon: icon?.toEntity(),
    );
  }

  factory AnswerModel.fromEntity(AnswerEntity entity) {
    return AnswerModel(
      id: entity.id,
      content: entity.content,
      createdYmd: entity.createdAt.toIso8601String().split('T')[0],
      question: entity.question != null
          ? QuestionModel.fromEntity(entity.question!)
          : null,
      icon: entity.icon != null ? IconModel.fromEntity(entity.icon!) : null,
    );
  }
}
