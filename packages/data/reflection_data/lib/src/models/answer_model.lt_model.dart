// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_model.dart';

// **************************************************************************
// LtDeserializationGenerator
// **************************************************************************

AnswerModel _$AnswerModelFromJson(Map<String, dynamic> json) {
  return AnswerModel(
    id: json['id'] as String,
    content: json['content'] as String,
    createdYmd: json['created_ymd'] as String,
    question: json['question'] == null
        ? null
        : QuestionModel.fromJson(json['question']),
    icon: json['icon'] == null ? null : IconModel.fromJson(json['icon']),
  );
}
