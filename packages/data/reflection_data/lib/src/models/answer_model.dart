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
  final String? createdYmd;
  @LtJsonKey('created_tms')
  final String? createdTms;
  final QuestionModel? question;
  final IconModel? icon;

  AnswerModel({
    required this.id,
    required this.content,
    this.createdYmd,
    this.createdTms,
    this.question,
    this.icon,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerModelFromJson(json);

  AnswerEntity toEntity() {
    return AnswerEntity(
      id: id,
      content: content,
      createTms: createdTms != null ? DateTime.parse(createdTms!) : null,
      createYmd: createdYmd != null ? DateTime.parse(createdYmd!) : null,
      question: question?.toEntity(),
      icon: icon?.toEntity(),
    );
  }

  factory AnswerModel.fromEntity(AnswerEntity entity) {
    return AnswerModel(
      id: entity.id,
      content: entity.content,
      createdYmd: entity.createYmd != null
          ? entity.createYmd!.toIso8601String().split('T')[0]
          : null,
      createdTms: entity.createTms != null
          ? entity.createTms!.toIso8601String().split('T')[0]
          : null,
      question: entity.question != null
          ? QuestionModel.fromEntity(entity.question!)
          : null,
      icon: entity.icon != null ? IconModel.fromEntity(entity.icon!) : null,
    );
  }
}
